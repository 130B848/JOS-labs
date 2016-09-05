
obj/user/evilhello:     file format elf32-i386


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

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 5d 00 00 00       	call   8000a2 <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

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
  8000b9:	56                   	push   %esi
  8000ba:	57                   	push   %edi
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	8d 35 c6 00 80 00    	lea    0x8000c6,%esi
  8000c4:	0f 34                	sysenter 

008000c6 <label_21>:
  8000c6:	89 ec                	mov    %ebp,%esp
  8000c8:	5d                   	pop    %ebp
  8000c9:	5f                   	pop    %edi
  8000ca:	5e                   	pop    %esi
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
  8000ea:	56                   	push   %esi
  8000eb:	57                   	push   %edi
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	8d 35 f7 00 80 00    	lea    0x8000f7,%esi
  8000f5:	0f 34                	sysenter 

008000f7 <label_55>:
  8000f7:	89 ec                	mov    %ebp,%esp
  8000f9:	5d                   	pop    %ebp
  8000fa:	5f                   	pop    %edi
  8000fb:	5e                   	pop    %esi
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
  80011c:	56                   	push   %esi
  80011d:	57                   	push   %edi
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	8d 35 29 01 80 00    	lea    0x800129,%esi
  800127:	0f 34                	sysenter 

00800129 <label_90>:
  800129:	89 ec                	mov    %ebp,%esp
  80012b:	5d                   	pop    %ebp
  80012c:	5f                   	pop    %edi
  80012d:	5e                   	pop    %esi
  80012e:	5b                   	pop    %ebx
  80012f:	5a                   	pop    %edx
  800130:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800131:	85 c0                	test   %eax,%eax
  800133:	7e 17                	jle    80014c <label_90+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	50                   	push   %eax
  800139:	6a 03                	push   $0x3
  80013b:	68 0a 14 80 00       	push   $0x80140a
  800140:	6a 30                	push   $0x30
  800142:	68 27 14 80 00       	push   $0x801427
  800147:	e8 06 03 00 00       	call   800452 <_panic>

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
  80016b:	56                   	push   %esi
  80016c:	57                   	push   %edi
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	8d 35 78 01 80 00    	lea    0x800178,%esi
  800176:	0f 34                	sysenter 

00800178 <label_139>:
  800178:	89 ec                	mov    %ebp,%esp
  80017a:	5d                   	pop    %ebp
  80017b:	5f                   	pop    %edi
  80017c:	5e                   	pop    %esi
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
  80019e:	56                   	push   %esi
  80019f:	57                   	push   %edi
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	8d 35 ab 01 80 00    	lea    0x8001ab,%esi
  8001a9:	0f 34                	sysenter 

008001ab <label_174>:
  8001ab:	89 ec                	mov    %ebp,%esp
  8001ad:	5d                   	pop    %ebp
  8001ae:	5f                   	pop    %edi
  8001af:	5e                   	pop    %esi
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
  8001cf:	56                   	push   %esi
  8001d0:	57                   	push   %edi
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	8d 35 dc 01 80 00    	lea    0x8001dc,%esi
  8001da:	0f 34                	sysenter 

008001dc <label_209>:
  8001dc:	89 ec                	mov    %ebp,%esp
  8001de:	5d                   	pop    %ebp
  8001df:	5f                   	pop    %edi
  8001e0:	5e                   	pop    %esi
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
  800203:	56                   	push   %esi
  800204:	57                   	push   %edi
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	8d 35 10 02 80 00    	lea    0x800210,%esi
  80020e:	0f 34                	sysenter 

00800210 <label_244>:
  800210:	89 ec                	mov    %ebp,%esp
  800212:	5d                   	pop    %ebp
  800213:	5f                   	pop    %edi
  800214:	5e                   	pop    %esi
  800215:	5b                   	pop    %ebx
  800216:	5a                   	pop    %edx
  800217:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800218:	85 c0                	test   %eax,%eax
  80021a:	7e 17                	jle    800233 <label_244+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80021c:	83 ec 0c             	sub    $0xc,%esp
  80021f:	50                   	push   %eax
  800220:	6a 05                	push   $0x5
  800222:	68 0a 14 80 00       	push   $0x80140a
  800227:	6a 30                	push   $0x30
  800229:	68 27 14 80 00       	push   $0x801427
  80022e:	e8 1f 02 00 00       	call   800452 <_panic>

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
  80023f:	83 ec 20             	sub    $0x20,%esp
	// cprintf("sys_page_map gets here\n");
	// return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
	uint32_t args[5];
	args[0] = (uint32_t) srcenv;
  800242:	8b 45 08             	mov    0x8(%ebp),%eax
  800245:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	args[1] = (uint32_t) srcva;
  800248:	8b 45 0c             	mov    0xc(%ebp),%eax
  80024b:	89 45 e8             	mov    %eax,-0x18(%ebp)
	args[2] = (uint32_t) dstenv;
  80024e:	8b 45 10             	mov    0x10(%ebp),%eax
  800251:	89 45 ec             	mov    %eax,-0x14(%ebp)
	args[3] = (uint32_t) dstva;
  800254:	8b 45 14             	mov    0x14(%ebp),%eax
  800257:	89 45 f0             	mov    %eax,-0x10(%ebp)
	args[4] = (uint32_t) perm;
  80025a:	8b 45 18             	mov    0x18(%ebp),%eax
  80025d:	89 45 f4             	mov    %eax,-0xc(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800260:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800263:	b9 00 00 00 00       	mov    $0x0,%ecx
  800268:	b8 06 00 00 00       	mov    $0x6,%eax
  80026d:	89 cb                	mov    %ecx,%ebx
  80026f:	89 cf                	mov    %ecx,%edi
  800271:	51                   	push   %ecx
  800272:	52                   	push   %edx
  800273:	53                   	push   %ebx
  800274:	56                   	push   %esi
  800275:	57                   	push   %edi
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
  800279:	8d 35 81 02 80 00    	lea    0x800281,%esi
  80027f:	0f 34                	sysenter 

00800281 <label_304>:
  800281:	89 ec                	mov    %ebp,%esp
  800283:	5d                   	pop    %ebp
  800284:	5f                   	pop    %edi
  800285:	5e                   	pop    %esi
  800286:	5b                   	pop    %ebx
  800287:	5a                   	pop    %edx
  800288:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800289:	85 c0                	test   %eax,%eax
  80028b:	7e 17                	jle    8002a4 <label_304+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028d:	83 ec 0c             	sub    $0xc,%esp
  800290:	50                   	push   %eax
  800291:	6a 06                	push   $0x6
  800293:	68 0a 14 80 00       	push   $0x80140a
  800298:	6a 30                	push   $0x30
  80029a:	68 27 14 80 00       	push   $0x801427
  80029f:	e8 ae 01 00 00       	call   800452 <_panic>
	args[1] = (uint32_t) srcva;
	args[2] = (uint32_t) dstenv;
	args[3] = (uint32_t) dstva;
	args[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)args, 0, 0, 0, 0);
}
  8002a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002a7:	5b                   	pop    %ebx
  8002a8:	5f                   	pop    %edi
  8002a9:	5d                   	pop    %ebp
  8002aa:	c3                   	ret    

008002ab <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	57                   	push   %edi
  8002af:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002b0:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b5:	b8 07 00 00 00       	mov    $0x7,%eax
  8002ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c0:	89 fb                	mov    %edi,%ebx
  8002c2:	51                   	push   %ecx
  8002c3:	52                   	push   %edx
  8002c4:	53                   	push   %ebx
  8002c5:	56                   	push   %esi
  8002c6:	57                   	push   %edi
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
  8002ca:	8d 35 d2 02 80 00    	lea    0x8002d2,%esi
  8002d0:	0f 34                	sysenter 

008002d2 <label_353>:
  8002d2:	89 ec                	mov    %ebp,%esp
  8002d4:	5d                   	pop    %ebp
  8002d5:	5f                   	pop    %edi
  8002d6:	5e                   	pop    %esi
  8002d7:	5b                   	pop    %ebx
  8002d8:	5a                   	pop    %edx
  8002d9:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <label_353+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 07                	push   $0x7
  8002e4:	68 0a 14 80 00       	push   $0x80140a
  8002e9:	6a 30                	push   $0x30
  8002eb:	68 27 14 80 00       	push   $0x801427
  8002f0:	e8 5d 01 00 00       	call   800452 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5f                   	pop    %edi
  8002fa:	5d                   	pop    %ebp
  8002fb:	c3                   	ret    

008002fc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	57                   	push   %edi
  800300:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800301:	bf 00 00 00 00       	mov    $0x0,%edi
  800306:	b8 09 00 00 00       	mov    $0x9,%eax
  80030b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030e:	8b 55 08             	mov    0x8(%ebp),%edx
  800311:	89 fb                	mov    %edi,%ebx
  800313:	51                   	push   %ecx
  800314:	52                   	push   %edx
  800315:	53                   	push   %ebx
  800316:	56                   	push   %esi
  800317:	57                   	push   %edi
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	8d 35 23 03 80 00    	lea    0x800323,%esi
  800321:	0f 34                	sysenter 

00800323 <label_402>:
  800323:	89 ec                	mov    %ebp,%esp
  800325:	5d                   	pop    %ebp
  800326:	5f                   	pop    %edi
  800327:	5e                   	pop    %esi
  800328:	5b                   	pop    %ebx
  800329:	5a                   	pop    %edx
  80032a:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80032b:	85 c0                	test   %eax,%eax
  80032d:	7e 17                	jle    800346 <label_402+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032f:	83 ec 0c             	sub    $0xc,%esp
  800332:	50                   	push   %eax
  800333:	6a 09                	push   $0x9
  800335:	68 0a 14 80 00       	push   $0x80140a
  80033a:	6a 30                	push   $0x30
  80033c:	68 27 14 80 00       	push   $0x801427
  800341:	e8 0c 01 00 00       	call   800452 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800346:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800349:	5b                   	pop    %ebx
  80034a:	5f                   	pop    %edi
  80034b:	5d                   	pop    %ebp
  80034c:	c3                   	ret    

0080034d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	57                   	push   %edi
  800351:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800352:	bf 00 00 00 00       	mov    $0x0,%edi
  800357:	b8 0a 00 00 00       	mov    $0xa,%eax
  80035c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80035f:	8b 55 08             	mov    0x8(%ebp),%edx
  800362:	89 fb                	mov    %edi,%ebx
  800364:	51                   	push   %ecx
  800365:	52                   	push   %edx
  800366:	53                   	push   %ebx
  800367:	56                   	push   %esi
  800368:	57                   	push   %edi
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	8d 35 74 03 80 00    	lea    0x800374,%esi
  800372:	0f 34                	sysenter 

00800374 <label_451>:
  800374:	89 ec                	mov    %ebp,%esp
  800376:	5d                   	pop    %ebp
  800377:	5f                   	pop    %edi
  800378:	5e                   	pop    %esi
  800379:	5b                   	pop    %ebx
  80037a:	5a                   	pop    %edx
  80037b:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80037c:	85 c0                	test   %eax,%eax
  80037e:	7e 17                	jle    800397 <label_451+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800380:	83 ec 0c             	sub    $0xc,%esp
  800383:	50                   	push   %eax
  800384:	6a 0a                	push   $0xa
  800386:	68 0a 14 80 00       	push   $0x80140a
  80038b:	6a 30                	push   $0x30
  80038d:	68 27 14 80 00       	push   $0x801427
  800392:	e8 bb 00 00 00       	call   800452 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800397:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80039a:	5b                   	pop    %ebx
  80039b:	5f                   	pop    %edi
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	57                   	push   %edi
  8003a2:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003a3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003b1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003b4:	51                   	push   %ecx
  8003b5:	52                   	push   %edx
  8003b6:	53                   	push   %ebx
  8003b7:	56                   	push   %esi
  8003b8:	57                   	push   %edi
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	8d 35 c4 03 80 00    	lea    0x8003c4,%esi
  8003c2:	0f 34                	sysenter 

008003c4 <label_502>:
  8003c4:	89 ec                	mov    %ebp,%esp
  8003c6:	5d                   	pop    %ebp
  8003c7:	5f                   	pop    %edi
  8003c8:	5e                   	pop    %esi
  8003c9:	5b                   	pop    %ebx
  8003ca:	5a                   	pop    %edx
  8003cb:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003cc:	5b                   	pop    %ebx
  8003cd:	5f                   	pop    %edi
  8003ce:	5d                   	pop    %ebp
  8003cf:	c3                   	ret    

008003d0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	57                   	push   %edi
  8003d4:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003da:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003df:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e2:	89 d9                	mov    %ebx,%ecx
  8003e4:	89 df                	mov    %ebx,%edi
  8003e6:	51                   	push   %ecx
  8003e7:	52                   	push   %edx
  8003e8:	53                   	push   %ebx
  8003e9:	56                   	push   %esi
  8003ea:	57                   	push   %edi
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	8d 35 f6 03 80 00    	lea    0x8003f6,%esi
  8003f4:	0f 34                	sysenter 

008003f6 <label_537>:
  8003f6:	89 ec                	mov    %ebp,%esp
  8003f8:	5d                   	pop    %ebp
  8003f9:	5f                   	pop    %edi
  8003fa:	5e                   	pop    %esi
  8003fb:	5b                   	pop    %ebx
  8003fc:	5a                   	pop    %edx
  8003fd:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8003fe:	85 c0                	test   %eax,%eax
  800400:	7e 17                	jle    800419 <label_537+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800402:	83 ec 0c             	sub    $0xc,%esp
  800405:	50                   	push   %eax
  800406:	6a 0d                	push   $0xd
  800408:	68 0a 14 80 00       	push   $0x80140a
  80040d:	6a 30                	push   $0x30
  80040f:	68 27 14 80 00       	push   $0x801427
  800414:	e8 39 00 00 00       	call   800452 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800419:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80041c:	5b                   	pop    %ebx
  80041d:	5f                   	pop    %edi
  80041e:	5d                   	pop    %ebp
  80041f:	c3                   	ret    

00800420 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	57                   	push   %edi
  800424:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800425:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80042f:	8b 55 08             	mov    0x8(%ebp),%edx
  800432:	89 cb                	mov    %ecx,%ebx
  800434:	89 cf                	mov    %ecx,%edi
  800436:	51                   	push   %ecx
  800437:	52                   	push   %edx
  800438:	53                   	push   %ebx
  800439:	56                   	push   %esi
  80043a:	57                   	push   %edi
  80043b:	55                   	push   %ebp
  80043c:	89 e5                	mov    %esp,%ebp
  80043e:	8d 35 46 04 80 00    	lea    0x800446,%esi
  800444:	0f 34                	sysenter 

00800446 <label_586>:
  800446:	89 ec                	mov    %ebp,%esp
  800448:	5d                   	pop    %ebp
  800449:	5f                   	pop    %edi
  80044a:	5e                   	pop    %esi
  80044b:	5b                   	pop    %ebx
  80044c:	5a                   	pop    %edx
  80044d:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80044e:	5b                   	pop    %ebx
  80044f:	5f                   	pop    %edi
  800450:	5d                   	pop    %ebp
  800451:	c3                   	ret    

00800452 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800452:	55                   	push   %ebp
  800453:	89 e5                	mov    %esp,%ebp
  800455:	56                   	push   %esi
  800456:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800457:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80045a:	a1 10 20 80 00       	mov    0x802010,%eax
  80045f:	85 c0                	test   %eax,%eax
  800461:	74 11                	je     800474 <_panic+0x22>
		cprintf("%s: ", argv0);
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	50                   	push   %eax
  800467:	68 35 14 80 00       	push   $0x801435
  80046c:	e8 d4 00 00 00       	call   800545 <cprintf>
  800471:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800474:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80047a:	e8 d4 fc ff ff       	call   800153 <sys_getenvid>
  80047f:	83 ec 0c             	sub    $0xc,%esp
  800482:	ff 75 0c             	pushl  0xc(%ebp)
  800485:	ff 75 08             	pushl  0x8(%ebp)
  800488:	56                   	push   %esi
  800489:	50                   	push   %eax
  80048a:	68 3c 14 80 00       	push   $0x80143c
  80048f:	e8 b1 00 00 00       	call   800545 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800494:	83 c4 18             	add    $0x18,%esp
  800497:	53                   	push   %ebx
  800498:	ff 75 10             	pushl  0x10(%ebp)
  80049b:	e8 54 00 00 00       	call   8004f4 <vcprintf>
	cprintf("\n");
  8004a0:	c7 04 24 3a 14 80 00 	movl   $0x80143a,(%esp)
  8004a7:	e8 99 00 00 00       	call   800545 <cprintf>
  8004ac:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004af:	cc                   	int3   
  8004b0:	eb fd                	jmp    8004af <_panic+0x5d>

008004b2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004b2:	55                   	push   %ebp
  8004b3:	89 e5                	mov    %esp,%ebp
  8004b5:	53                   	push   %ebx
  8004b6:	83 ec 04             	sub    $0x4,%esp
  8004b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004bc:	8b 13                	mov    (%ebx),%edx
  8004be:	8d 42 01             	lea    0x1(%edx),%eax
  8004c1:	89 03                	mov    %eax,(%ebx)
  8004c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004c6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8004ca:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004cf:	75 1a                	jne    8004eb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	68 ff 00 00 00       	push   $0xff
  8004d9:	8d 43 08             	lea    0x8(%ebx),%eax
  8004dc:	50                   	push   %eax
  8004dd:	e8 c0 fb ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8004e2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004e8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004eb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004f2:	c9                   	leave  
  8004f3:	c3                   	ret    

008004f4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004fd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800504:	00 00 00 
	b.cnt = 0;
  800507:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80050e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800511:	ff 75 0c             	pushl  0xc(%ebp)
  800514:	ff 75 08             	pushl  0x8(%ebp)
  800517:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80051d:	50                   	push   %eax
  80051e:	68 b2 04 80 00       	push   $0x8004b2
  800523:	e8 c0 02 00 00       	call   8007e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800528:	83 c4 08             	add    $0x8,%esp
  80052b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800531:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800537:	50                   	push   %eax
  800538:	e8 65 fb ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  80053d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800543:	c9                   	leave  
  800544:	c3                   	ret    

00800545 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800545:	55                   	push   %ebp
  800546:	89 e5                	mov    %esp,%ebp
  800548:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80054b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80054e:	50                   	push   %eax
  80054f:	ff 75 08             	pushl  0x8(%ebp)
  800552:	e8 9d ff ff ff       	call   8004f4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800557:	c9                   	leave  
  800558:	c3                   	ret    

00800559 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800559:	55                   	push   %ebp
  80055a:	89 e5                	mov    %esp,%ebp
  80055c:	57                   	push   %edi
  80055d:	56                   	push   %esi
  80055e:	53                   	push   %ebx
  80055f:	83 ec 1c             	sub    $0x1c,%esp
  800562:	89 c7                	mov    %eax,%edi
  800564:	89 d6                	mov    %edx,%esi
  800566:	8b 45 08             	mov    0x8(%ebp),%eax
  800569:	8b 55 0c             	mov    0xc(%ebp),%edx
  80056c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80056f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800572:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800575:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800579:	0f 85 bf 00 00 00    	jne    80063e <printnum+0xe5>
  80057f:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  800585:	0f 8d de 00 00 00    	jge    800669 <printnum+0x110>
		judge_time_for_space = width;
  80058b:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  800591:	e9 d3 00 00 00       	jmp    800669 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800596:	83 eb 01             	sub    $0x1,%ebx
  800599:	85 db                	test   %ebx,%ebx
  80059b:	7f 37                	jg     8005d4 <printnum+0x7b>
  80059d:	e9 ea 00 00 00       	jmp    80068c <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  8005a2:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8005a5:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005aa:	83 ec 08             	sub    $0x8,%esp
  8005ad:	56                   	push   %esi
  8005ae:	83 ec 04             	sub    $0x4,%esp
  8005b1:	ff 75 dc             	pushl  -0x24(%ebp)
  8005b4:	ff 75 d8             	pushl  -0x28(%ebp)
  8005b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8005bd:	e8 ce 0c 00 00       	call   801290 <__umoddi3>
  8005c2:	83 c4 14             	add    $0x14,%esp
  8005c5:	0f be 80 5f 14 80 00 	movsbl 0x80145f(%eax),%eax
  8005cc:	50                   	push   %eax
  8005cd:	ff d7                	call   *%edi
  8005cf:	83 c4 10             	add    $0x10,%esp
  8005d2:	eb 16                	jmp    8005ea <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8005d4:	83 ec 08             	sub    $0x8,%esp
  8005d7:	56                   	push   %esi
  8005d8:	ff 75 18             	pushl  0x18(%ebp)
  8005db:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8005dd:	83 c4 10             	add    $0x10,%esp
  8005e0:	83 eb 01             	sub    $0x1,%ebx
  8005e3:	75 ef                	jne    8005d4 <printnum+0x7b>
  8005e5:	e9 a2 00 00 00       	jmp    80068c <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8005ea:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  8005f0:	0f 85 76 01 00 00    	jne    80076c <printnum+0x213>
		while(num_of_space-- > 0)
  8005f6:	a1 04 20 80 00       	mov    0x802004,%eax
  8005fb:	8d 50 ff             	lea    -0x1(%eax),%edx
  8005fe:	89 15 04 20 80 00    	mov    %edx,0x802004
  800604:	85 c0                	test   %eax,%eax
  800606:	7e 1d                	jle    800625 <printnum+0xcc>
			putch(' ', putdat);
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	56                   	push   %esi
  80060c:	6a 20                	push   $0x20
  80060e:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  800610:	a1 04 20 80 00       	mov    0x802004,%eax
  800615:	8d 50 ff             	lea    -0x1(%eax),%edx
  800618:	89 15 04 20 80 00    	mov    %edx,0x802004
  80061e:	83 c4 10             	add    $0x10,%esp
  800621:	85 c0                	test   %eax,%eax
  800623:	7f e3                	jg     800608 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800625:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80062c:	00 00 00 
		judge_time_for_space = 0;
  80062f:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800636:	00 00 00 
	}
}
  800639:	e9 2e 01 00 00       	jmp    80076c <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80063e:	8b 45 10             	mov    0x10(%ebp),%eax
  800641:	ba 00 00 00 00       	mov    $0x0,%edx
  800646:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800649:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80064c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80064f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800652:	83 fa 00             	cmp    $0x0,%edx
  800655:	0f 87 ba 00 00 00    	ja     800715 <printnum+0x1bc>
  80065b:	3b 45 10             	cmp    0x10(%ebp),%eax
  80065e:	0f 83 b1 00 00 00    	jae    800715 <printnum+0x1bc>
  800664:	e9 2d ff ff ff       	jmp    800596 <printnum+0x3d>
  800669:	8b 45 10             	mov    0x10(%ebp),%eax
  80066c:	ba 00 00 00 00       	mov    $0x0,%edx
  800671:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800674:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800677:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80067a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80067d:	83 fa 00             	cmp    $0x0,%edx
  800680:	77 37                	ja     8006b9 <printnum+0x160>
  800682:	3b 45 10             	cmp    0x10(%ebp),%eax
  800685:	73 32                	jae    8006b9 <printnum+0x160>
  800687:	e9 16 ff ff ff       	jmp    8005a2 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80068c:	83 ec 08             	sub    $0x8,%esp
  80068f:	56                   	push   %esi
  800690:	83 ec 04             	sub    $0x4,%esp
  800693:	ff 75 dc             	pushl  -0x24(%ebp)
  800696:	ff 75 d8             	pushl  -0x28(%ebp)
  800699:	ff 75 e4             	pushl  -0x1c(%ebp)
  80069c:	ff 75 e0             	pushl  -0x20(%ebp)
  80069f:	e8 ec 0b 00 00       	call   801290 <__umoddi3>
  8006a4:	83 c4 14             	add    $0x14,%esp
  8006a7:	0f be 80 5f 14 80 00 	movsbl 0x80145f(%eax),%eax
  8006ae:	50                   	push   %eax
  8006af:	ff d7                	call   *%edi
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	e9 b3 00 00 00       	jmp    80076c <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006b9:	83 ec 0c             	sub    $0xc,%esp
  8006bc:	ff 75 18             	pushl  0x18(%ebp)
  8006bf:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006c2:	50                   	push   %eax
  8006c3:	ff 75 10             	pushl  0x10(%ebp)
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8006cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8006cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d5:	e8 86 0a 00 00       	call   801160 <__udivdi3>
  8006da:	83 c4 18             	add    $0x18,%esp
  8006dd:	52                   	push   %edx
  8006de:	50                   	push   %eax
  8006df:	89 f2                	mov    %esi,%edx
  8006e1:	89 f8                	mov    %edi,%eax
  8006e3:	e8 71 fe ff ff       	call   800559 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006e8:	83 c4 18             	add    $0x18,%esp
  8006eb:	56                   	push   %esi
  8006ec:	83 ec 04             	sub    $0x4,%esp
  8006ef:	ff 75 dc             	pushl  -0x24(%ebp)
  8006f2:	ff 75 d8             	pushl  -0x28(%ebp)
  8006f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006fb:	e8 90 0b 00 00       	call   801290 <__umoddi3>
  800700:	83 c4 14             	add    $0x14,%esp
  800703:	0f be 80 5f 14 80 00 	movsbl 0x80145f(%eax),%eax
  80070a:	50                   	push   %eax
  80070b:	ff d7                	call   *%edi
  80070d:	83 c4 10             	add    $0x10,%esp
  800710:	e9 d5 fe ff ff       	jmp    8005ea <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800715:	83 ec 0c             	sub    $0xc,%esp
  800718:	ff 75 18             	pushl  0x18(%ebp)
  80071b:	83 eb 01             	sub    $0x1,%ebx
  80071e:	53                   	push   %ebx
  80071f:	ff 75 10             	pushl  0x10(%ebp)
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	ff 75 dc             	pushl  -0x24(%ebp)
  800728:	ff 75 d8             	pushl  -0x28(%ebp)
  80072b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80072e:	ff 75 e0             	pushl  -0x20(%ebp)
  800731:	e8 2a 0a 00 00       	call   801160 <__udivdi3>
  800736:	83 c4 18             	add    $0x18,%esp
  800739:	52                   	push   %edx
  80073a:	50                   	push   %eax
  80073b:	89 f2                	mov    %esi,%edx
  80073d:	89 f8                	mov    %edi,%eax
  80073f:	e8 15 fe ff ff       	call   800559 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800744:	83 c4 18             	add    $0x18,%esp
  800747:	56                   	push   %esi
  800748:	83 ec 04             	sub    $0x4,%esp
  80074b:	ff 75 dc             	pushl  -0x24(%ebp)
  80074e:	ff 75 d8             	pushl  -0x28(%ebp)
  800751:	ff 75 e4             	pushl  -0x1c(%ebp)
  800754:	ff 75 e0             	pushl  -0x20(%ebp)
  800757:	e8 34 0b 00 00       	call   801290 <__umoddi3>
  80075c:	83 c4 14             	add    $0x14,%esp
  80075f:	0f be 80 5f 14 80 00 	movsbl 0x80145f(%eax),%eax
  800766:	50                   	push   %eax
  800767:	ff d7                	call   *%edi
  800769:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  80076c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076f:	5b                   	pop    %ebx
  800770:	5e                   	pop    %esi
  800771:	5f                   	pop    %edi
  800772:	5d                   	pop    %ebp
  800773:	c3                   	ret    

00800774 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800777:	83 fa 01             	cmp    $0x1,%edx
  80077a:	7e 0e                	jle    80078a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80077c:	8b 10                	mov    (%eax),%edx
  80077e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800781:	89 08                	mov    %ecx,(%eax)
  800783:	8b 02                	mov    (%edx),%eax
  800785:	8b 52 04             	mov    0x4(%edx),%edx
  800788:	eb 22                	jmp    8007ac <getuint+0x38>
	else if (lflag)
  80078a:	85 d2                	test   %edx,%edx
  80078c:	74 10                	je     80079e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80078e:	8b 10                	mov    (%eax),%edx
  800790:	8d 4a 04             	lea    0x4(%edx),%ecx
  800793:	89 08                	mov    %ecx,(%eax)
  800795:	8b 02                	mov    (%edx),%eax
  800797:	ba 00 00 00 00       	mov    $0x0,%edx
  80079c:	eb 0e                	jmp    8007ac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80079e:	8b 10                	mov    (%eax),%edx
  8007a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007a3:	89 08                	mov    %ecx,(%eax)
  8007a5:	8b 02                	mov    (%edx),%eax
  8007a7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    

008007ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007b8:	8b 10                	mov    (%eax),%edx
  8007ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8007bd:	73 0a                	jae    8007c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007c2:	89 08                	mov    %ecx,(%eax)
  8007c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c7:	88 02                	mov    %al,(%edx)
}
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007d4:	50                   	push   %eax
  8007d5:	ff 75 10             	pushl  0x10(%ebp)
  8007d8:	ff 75 0c             	pushl  0xc(%ebp)
  8007db:	ff 75 08             	pushl  0x8(%ebp)
  8007de:	e8 05 00 00 00       	call   8007e8 <vprintfmt>
	va_end(ap);
}
  8007e3:	83 c4 10             	add    $0x10,%esp
  8007e6:	c9                   	leave  
  8007e7:	c3                   	ret    

008007e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	57                   	push   %edi
  8007ec:	56                   	push   %esi
  8007ed:	53                   	push   %ebx
  8007ee:	83 ec 2c             	sub    $0x2c,%esp
  8007f1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007f7:	eb 03                	jmp    8007fc <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f9:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ff:	8d 70 01             	lea    0x1(%eax),%esi
  800802:	0f b6 00             	movzbl (%eax),%eax
  800805:	83 f8 25             	cmp    $0x25,%eax
  800808:	74 27                	je     800831 <vprintfmt+0x49>
			if (ch == '\0')
  80080a:	85 c0                	test   %eax,%eax
  80080c:	75 0d                	jne    80081b <vprintfmt+0x33>
  80080e:	e9 9d 04 00 00       	jmp    800cb0 <vprintfmt+0x4c8>
  800813:	85 c0                	test   %eax,%eax
  800815:	0f 84 95 04 00 00    	je     800cb0 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	53                   	push   %ebx
  80081f:	50                   	push   %eax
  800820:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800822:	83 c6 01             	add    $0x1,%esi
  800825:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800829:	83 c4 10             	add    $0x10,%esp
  80082c:	83 f8 25             	cmp    $0x25,%eax
  80082f:	75 e2                	jne    800813 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800831:	b9 00 00 00 00       	mov    $0x0,%ecx
  800836:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80083a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800841:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800848:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80084f:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800856:	eb 08                	jmp    800860 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800858:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  80085b:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800860:	8d 46 01             	lea    0x1(%esi),%eax
  800863:	89 45 10             	mov    %eax,0x10(%ebp)
  800866:	0f b6 06             	movzbl (%esi),%eax
  800869:	0f b6 d0             	movzbl %al,%edx
  80086c:	83 e8 23             	sub    $0x23,%eax
  80086f:	3c 55                	cmp    $0x55,%al
  800871:	0f 87 fa 03 00 00    	ja     800c71 <vprintfmt+0x489>
  800877:	0f b6 c0             	movzbl %al,%eax
  80087a:	ff 24 85 a0 15 80 00 	jmp    *0x8015a0(,%eax,4)
  800881:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800884:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800888:	eb d6                	jmp    800860 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80088a:	8d 42 d0             	lea    -0x30(%edx),%eax
  80088d:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800890:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800894:	8d 50 d0             	lea    -0x30(%eax),%edx
  800897:	83 fa 09             	cmp    $0x9,%edx
  80089a:	77 6b                	ja     800907 <vprintfmt+0x11f>
  80089c:	8b 75 10             	mov    0x10(%ebp),%esi
  80089f:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8008a2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8008a5:	eb 09                	jmp    8008b0 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a7:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008aa:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8008ae:	eb b0                	jmp    800860 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008b0:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8008b3:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8008b6:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8008ba:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008bd:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8008c0:	83 f9 09             	cmp    $0x9,%ecx
  8008c3:	76 eb                	jbe    8008b0 <vprintfmt+0xc8>
  8008c5:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8008c8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8008cb:	eb 3d                	jmp    80090a <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d0:	8d 50 04             	lea    0x4(%eax),%edx
  8008d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d6:	8b 00                	mov    (%eax),%eax
  8008d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008db:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008de:	eb 2a                	jmp    80090a <vprintfmt+0x122>
  8008e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008e3:	85 c0                	test   %eax,%eax
  8008e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ea:	0f 49 d0             	cmovns %eax,%edx
  8008ed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f0:	8b 75 10             	mov    0x10(%ebp),%esi
  8008f3:	e9 68 ff ff ff       	jmp    800860 <vprintfmt+0x78>
  8008f8:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008fb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800902:	e9 59 ff ff ff       	jmp    800860 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800907:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80090a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80090e:	0f 89 4c ff ff ff    	jns    800860 <vprintfmt+0x78>
				width = precision, precision = -1;
  800914:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800917:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80091a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800921:	e9 3a ff ff ff       	jmp    800860 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800926:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80092a:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80092d:	e9 2e ff ff ff       	jmp    800860 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800932:	8b 45 14             	mov    0x14(%ebp),%eax
  800935:	8d 50 04             	lea    0x4(%eax),%edx
  800938:	89 55 14             	mov    %edx,0x14(%ebp)
  80093b:	83 ec 08             	sub    $0x8,%esp
  80093e:	53                   	push   %ebx
  80093f:	ff 30                	pushl  (%eax)
  800941:	ff d7                	call   *%edi
			break;
  800943:	83 c4 10             	add    $0x10,%esp
  800946:	e9 b1 fe ff ff       	jmp    8007fc <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80094b:	8b 45 14             	mov    0x14(%ebp),%eax
  80094e:	8d 50 04             	lea    0x4(%eax),%edx
  800951:	89 55 14             	mov    %edx,0x14(%ebp)
  800954:	8b 00                	mov    (%eax),%eax
  800956:	99                   	cltd   
  800957:	31 d0                	xor    %edx,%eax
  800959:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80095b:	83 f8 08             	cmp    $0x8,%eax
  80095e:	7f 0b                	jg     80096b <vprintfmt+0x183>
  800960:	8b 14 85 00 17 80 00 	mov    0x801700(,%eax,4),%edx
  800967:	85 d2                	test   %edx,%edx
  800969:	75 15                	jne    800980 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  80096b:	50                   	push   %eax
  80096c:	68 77 14 80 00       	push   $0x801477
  800971:	53                   	push   %ebx
  800972:	57                   	push   %edi
  800973:	e8 53 fe ff ff       	call   8007cb <printfmt>
  800978:	83 c4 10             	add    $0x10,%esp
  80097b:	e9 7c fe ff ff       	jmp    8007fc <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800980:	52                   	push   %edx
  800981:	68 80 14 80 00       	push   $0x801480
  800986:	53                   	push   %ebx
  800987:	57                   	push   %edi
  800988:	e8 3e fe ff ff       	call   8007cb <printfmt>
  80098d:	83 c4 10             	add    $0x10,%esp
  800990:	e9 67 fe ff ff       	jmp    8007fc <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800995:	8b 45 14             	mov    0x14(%ebp),%eax
  800998:	8d 50 04             	lea    0x4(%eax),%edx
  80099b:	89 55 14             	mov    %edx,0x14(%ebp)
  80099e:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8009a0:	85 c0                	test   %eax,%eax
  8009a2:	b9 70 14 80 00       	mov    $0x801470,%ecx
  8009a7:	0f 45 c8             	cmovne %eax,%ecx
  8009aa:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8009ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009b1:	7e 06                	jle    8009b9 <vprintfmt+0x1d1>
  8009b3:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8009b7:	75 19                	jne    8009d2 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009b9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009bc:	8d 70 01             	lea    0x1(%eax),%esi
  8009bf:	0f b6 00             	movzbl (%eax),%eax
  8009c2:	0f be d0             	movsbl %al,%edx
  8009c5:	85 d2                	test   %edx,%edx
  8009c7:	0f 85 9f 00 00 00    	jne    800a6c <vprintfmt+0x284>
  8009cd:	e9 8c 00 00 00       	jmp    800a5e <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009d2:	83 ec 08             	sub    $0x8,%esp
  8009d5:	ff 75 d0             	pushl  -0x30(%ebp)
  8009d8:	ff 75 cc             	pushl  -0x34(%ebp)
  8009db:	e8 62 03 00 00       	call   800d42 <strnlen>
  8009e0:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8009e3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8009e6:	83 c4 10             	add    $0x10,%esp
  8009e9:	85 c9                	test   %ecx,%ecx
  8009eb:	0f 8e a6 02 00 00    	jle    800c97 <vprintfmt+0x4af>
					putch(padc, putdat);
  8009f1:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8009f5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009f8:	89 cb                	mov    %ecx,%ebx
  8009fa:	83 ec 08             	sub    $0x8,%esp
  8009fd:	ff 75 0c             	pushl  0xc(%ebp)
  800a00:	56                   	push   %esi
  800a01:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a03:	83 c4 10             	add    $0x10,%esp
  800a06:	83 eb 01             	sub    $0x1,%ebx
  800a09:	75 ef                	jne    8009fa <vprintfmt+0x212>
  800a0b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800a0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a11:	e9 81 02 00 00       	jmp    800c97 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a16:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a1a:	74 1b                	je     800a37 <vprintfmt+0x24f>
  800a1c:	0f be c0             	movsbl %al,%eax
  800a1f:	83 e8 20             	sub    $0x20,%eax
  800a22:	83 f8 5e             	cmp    $0x5e,%eax
  800a25:	76 10                	jbe    800a37 <vprintfmt+0x24f>
					putch('?', putdat);
  800a27:	83 ec 08             	sub    $0x8,%esp
  800a2a:	ff 75 0c             	pushl  0xc(%ebp)
  800a2d:	6a 3f                	push   $0x3f
  800a2f:	ff 55 08             	call   *0x8(%ebp)
  800a32:	83 c4 10             	add    $0x10,%esp
  800a35:	eb 0d                	jmp    800a44 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800a37:	83 ec 08             	sub    $0x8,%esp
  800a3a:	ff 75 0c             	pushl  0xc(%ebp)
  800a3d:	52                   	push   %edx
  800a3e:	ff 55 08             	call   *0x8(%ebp)
  800a41:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a44:	83 ef 01             	sub    $0x1,%edi
  800a47:	83 c6 01             	add    $0x1,%esi
  800a4a:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800a4e:	0f be d0             	movsbl %al,%edx
  800a51:	85 d2                	test   %edx,%edx
  800a53:	75 31                	jne    800a86 <vprintfmt+0x29e>
  800a55:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a58:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a5e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a61:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a65:	7f 33                	jg     800a9a <vprintfmt+0x2b2>
  800a67:	e9 90 fd ff ff       	jmp    8007fc <vprintfmt+0x14>
  800a6c:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a6f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a72:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a75:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a78:	eb 0c                	jmp    800a86 <vprintfmt+0x29e>
  800a7a:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a7d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a80:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a83:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a86:	85 db                	test   %ebx,%ebx
  800a88:	78 8c                	js     800a16 <vprintfmt+0x22e>
  800a8a:	83 eb 01             	sub    $0x1,%ebx
  800a8d:	79 87                	jns    800a16 <vprintfmt+0x22e>
  800a8f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a92:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a95:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a98:	eb c4                	jmp    800a5e <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a9a:	83 ec 08             	sub    $0x8,%esp
  800a9d:	53                   	push   %ebx
  800a9e:	6a 20                	push   $0x20
  800aa0:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800aa2:	83 c4 10             	add    $0x10,%esp
  800aa5:	83 ee 01             	sub    $0x1,%esi
  800aa8:	75 f0                	jne    800a9a <vprintfmt+0x2b2>
  800aaa:	e9 4d fd ff ff       	jmp    8007fc <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800aaf:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800ab3:	7e 16                	jle    800acb <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800ab5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab8:	8d 50 08             	lea    0x8(%eax),%edx
  800abb:	89 55 14             	mov    %edx,0x14(%ebp)
  800abe:	8b 50 04             	mov    0x4(%eax),%edx
  800ac1:	8b 00                	mov    (%eax),%eax
  800ac3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800ac6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800ac9:	eb 34                	jmp    800aff <vprintfmt+0x317>
	else if (lflag)
  800acb:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800acf:	74 18                	je     800ae9 <vprintfmt+0x301>
		return va_arg(*ap, long);
  800ad1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad4:	8d 50 04             	lea    0x4(%eax),%edx
  800ad7:	89 55 14             	mov    %edx,0x14(%ebp)
  800ada:	8b 30                	mov    (%eax),%esi
  800adc:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800adf:	89 f0                	mov    %esi,%eax
  800ae1:	c1 f8 1f             	sar    $0x1f,%eax
  800ae4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800ae7:	eb 16                	jmp    800aff <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800ae9:	8b 45 14             	mov    0x14(%ebp),%eax
  800aec:	8d 50 04             	lea    0x4(%eax),%edx
  800aef:	89 55 14             	mov    %edx,0x14(%ebp)
  800af2:	8b 30                	mov    (%eax),%esi
  800af4:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800af7:	89 f0                	mov    %esi,%eax
  800af9:	c1 f8 1f             	sar    $0x1f,%eax
  800afc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800aff:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b02:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b05:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b08:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800b0b:	85 d2                	test   %edx,%edx
  800b0d:	79 28                	jns    800b37 <vprintfmt+0x34f>
				putch('-', putdat);
  800b0f:	83 ec 08             	sub    $0x8,%esp
  800b12:	53                   	push   %ebx
  800b13:	6a 2d                	push   $0x2d
  800b15:	ff d7                	call   *%edi
				num = -(long long) num;
  800b17:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b1a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b1d:	f7 d8                	neg    %eax
  800b1f:	83 d2 00             	adc    $0x0,%edx
  800b22:	f7 da                	neg    %edx
  800b24:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b27:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b2a:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800b2d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b32:	e9 b2 00 00 00       	jmp    800be9 <vprintfmt+0x401>
  800b37:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800b3c:	85 c9                	test   %ecx,%ecx
  800b3e:	0f 84 a5 00 00 00    	je     800be9 <vprintfmt+0x401>
				putch('+', putdat);
  800b44:	83 ec 08             	sub    $0x8,%esp
  800b47:	53                   	push   %ebx
  800b48:	6a 2b                	push   $0x2b
  800b4a:	ff d7                	call   *%edi
  800b4c:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800b4f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b54:	e9 90 00 00 00       	jmp    800be9 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800b59:	85 c9                	test   %ecx,%ecx
  800b5b:	74 0b                	je     800b68 <vprintfmt+0x380>
				putch('+', putdat);
  800b5d:	83 ec 08             	sub    $0x8,%esp
  800b60:	53                   	push   %ebx
  800b61:	6a 2b                	push   $0x2b
  800b63:	ff d7                	call   *%edi
  800b65:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800b68:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b6b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b6e:	e8 01 fc ff ff       	call   800774 <getuint>
  800b73:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b76:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800b79:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b7e:	eb 69                	jmp    800be9 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800b80:	83 ec 08             	sub    $0x8,%esp
  800b83:	53                   	push   %ebx
  800b84:	6a 30                	push   $0x30
  800b86:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800b88:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b8b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b8e:	e8 e1 fb ff ff       	call   800774 <getuint>
  800b93:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b96:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800b99:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800b9c:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800ba1:	eb 46                	jmp    800be9 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800ba3:	83 ec 08             	sub    $0x8,%esp
  800ba6:	53                   	push   %ebx
  800ba7:	6a 30                	push   $0x30
  800ba9:	ff d7                	call   *%edi
			putch('x', putdat);
  800bab:	83 c4 08             	add    $0x8,%esp
  800bae:	53                   	push   %ebx
  800baf:	6a 78                	push   $0x78
  800bb1:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bb3:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb6:	8d 50 04             	lea    0x4(%eax),%edx
  800bb9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bbc:	8b 00                	mov    (%eax),%eax
  800bbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bc6:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bc9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bcc:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800bd1:	eb 16                	jmp    800be9 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bd3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800bd6:	8d 45 14             	lea    0x14(%ebp),%eax
  800bd9:	e8 96 fb ff ff       	call   800774 <getuint>
  800bde:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800be1:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800be4:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800bf0:	56                   	push   %esi
  800bf1:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bf4:	50                   	push   %eax
  800bf5:	ff 75 dc             	pushl  -0x24(%ebp)
  800bf8:	ff 75 d8             	pushl  -0x28(%ebp)
  800bfb:	89 da                	mov    %ebx,%edx
  800bfd:	89 f8                	mov    %edi,%eax
  800bff:	e8 55 f9 ff ff       	call   800559 <printnum>
			break;
  800c04:	83 c4 20             	add    $0x20,%esp
  800c07:	e9 f0 fb ff ff       	jmp    8007fc <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800c0c:	8b 45 14             	mov    0x14(%ebp),%eax
  800c0f:	8d 50 04             	lea    0x4(%eax),%edx
  800c12:	89 55 14             	mov    %edx,0x14(%ebp)
  800c15:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800c17:	85 f6                	test   %esi,%esi
  800c19:	75 1a                	jne    800c35 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800c1b:	83 ec 08             	sub    $0x8,%esp
  800c1e:	68 18 15 80 00       	push   $0x801518
  800c23:	68 80 14 80 00       	push   $0x801480
  800c28:	e8 18 f9 ff ff       	call   800545 <cprintf>
  800c2d:	83 c4 10             	add    $0x10,%esp
  800c30:	e9 c7 fb ff ff       	jmp    8007fc <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800c35:	0f b6 03             	movzbl (%ebx),%eax
  800c38:	84 c0                	test   %al,%al
  800c3a:	79 1f                	jns    800c5b <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800c3c:	83 ec 08             	sub    $0x8,%esp
  800c3f:	68 50 15 80 00       	push   $0x801550
  800c44:	68 80 14 80 00       	push   $0x801480
  800c49:	e8 f7 f8 ff ff       	call   800545 <cprintf>
						*tmp = *(char *)putdat;
  800c4e:	0f b6 03             	movzbl (%ebx),%eax
  800c51:	88 06                	mov    %al,(%esi)
  800c53:	83 c4 10             	add    $0x10,%esp
  800c56:	e9 a1 fb ff ff       	jmp    8007fc <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800c5b:	88 06                	mov    %al,(%esi)
  800c5d:	e9 9a fb ff ff       	jmp    8007fc <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c62:	83 ec 08             	sub    $0x8,%esp
  800c65:	53                   	push   %ebx
  800c66:	52                   	push   %edx
  800c67:	ff d7                	call   *%edi
			break;
  800c69:	83 c4 10             	add    $0x10,%esp
  800c6c:	e9 8b fb ff ff       	jmp    8007fc <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c71:	83 ec 08             	sub    $0x8,%esp
  800c74:	53                   	push   %ebx
  800c75:	6a 25                	push   $0x25
  800c77:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c79:	83 c4 10             	add    $0x10,%esp
  800c7c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c80:	0f 84 73 fb ff ff    	je     8007f9 <vprintfmt+0x11>
  800c86:	83 ee 01             	sub    $0x1,%esi
  800c89:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c8d:	75 f7                	jne    800c86 <vprintfmt+0x49e>
  800c8f:	89 75 10             	mov    %esi,0x10(%ebp)
  800c92:	e9 65 fb ff ff       	jmp    8007fc <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c97:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800c9a:	8d 70 01             	lea    0x1(%eax),%esi
  800c9d:	0f b6 00             	movzbl (%eax),%eax
  800ca0:	0f be d0             	movsbl %al,%edx
  800ca3:	85 d2                	test   %edx,%edx
  800ca5:	0f 85 cf fd ff ff    	jne    800a7a <vprintfmt+0x292>
  800cab:	e9 4c fb ff ff       	jmp    8007fc <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800cb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	83 ec 18             	sub    $0x18,%esp
  800cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cc4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cc7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ccb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cd5:	85 c0                	test   %eax,%eax
  800cd7:	74 26                	je     800cff <vsnprintf+0x47>
  800cd9:	85 d2                	test   %edx,%edx
  800cdb:	7e 22                	jle    800cff <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cdd:	ff 75 14             	pushl  0x14(%ebp)
  800ce0:	ff 75 10             	pushl  0x10(%ebp)
  800ce3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ce6:	50                   	push   %eax
  800ce7:	68 ae 07 80 00       	push   $0x8007ae
  800cec:	e8 f7 fa ff ff       	call   8007e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cf1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cf4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cfa:	83 c4 10             	add    $0x10,%esp
  800cfd:	eb 05                	jmp    800d04 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d04:	c9                   	leave  
  800d05:	c3                   	ret    

00800d06 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d0c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d0f:	50                   	push   %eax
  800d10:	ff 75 10             	pushl  0x10(%ebp)
  800d13:	ff 75 0c             	pushl  0xc(%ebp)
  800d16:	ff 75 08             	pushl  0x8(%ebp)
  800d19:	e8 9a ff ff ff       	call   800cb8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d1e:	c9                   	leave  
  800d1f:	c3                   	ret    

00800d20 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d26:	80 3a 00             	cmpb   $0x0,(%edx)
  800d29:	74 10                	je     800d3b <strlen+0x1b>
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d30:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d33:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d37:	75 f7                	jne    800d30 <strlen+0x10>
  800d39:	eb 05                	jmp    800d40 <strlen+0x20>
  800d3b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	53                   	push   %ebx
  800d46:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d4c:	85 c9                	test   %ecx,%ecx
  800d4e:	74 1c                	je     800d6c <strnlen+0x2a>
  800d50:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d53:	74 1e                	je     800d73 <strnlen+0x31>
  800d55:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800d5a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d5c:	39 ca                	cmp    %ecx,%edx
  800d5e:	74 18                	je     800d78 <strnlen+0x36>
  800d60:	83 c2 01             	add    $0x1,%edx
  800d63:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800d68:	75 f0                	jne    800d5a <strnlen+0x18>
  800d6a:	eb 0c                	jmp    800d78 <strnlen+0x36>
  800d6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d71:	eb 05                	jmp    800d78 <strnlen+0x36>
  800d73:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d78:	5b                   	pop    %ebx
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	53                   	push   %ebx
  800d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d85:	89 c2                	mov    %eax,%edx
  800d87:	83 c2 01             	add    $0x1,%edx
  800d8a:	83 c1 01             	add    $0x1,%ecx
  800d8d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d91:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d94:	84 db                	test   %bl,%bl
  800d96:	75 ef                	jne    800d87 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d98:	5b                   	pop    %ebx
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	53                   	push   %ebx
  800d9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800da2:	53                   	push   %ebx
  800da3:	e8 78 ff ff ff       	call   800d20 <strlen>
  800da8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800dab:	ff 75 0c             	pushl  0xc(%ebp)
  800dae:	01 d8                	add    %ebx,%eax
  800db0:	50                   	push   %eax
  800db1:	e8 c5 ff ff ff       	call   800d7b <strcpy>
	return dst;
}
  800db6:	89 d8                	mov    %ebx,%eax
  800db8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dbb:	c9                   	leave  
  800dbc:	c3                   	ret    

00800dbd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	56                   	push   %esi
  800dc1:	53                   	push   %ebx
  800dc2:	8b 75 08             	mov    0x8(%ebp),%esi
  800dc5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dcb:	85 db                	test   %ebx,%ebx
  800dcd:	74 17                	je     800de6 <strncpy+0x29>
  800dcf:	01 f3                	add    %esi,%ebx
  800dd1:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800dd3:	83 c1 01             	add    $0x1,%ecx
  800dd6:	0f b6 02             	movzbl (%edx),%eax
  800dd9:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ddc:	80 3a 01             	cmpb   $0x1,(%edx)
  800ddf:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800de2:	39 cb                	cmp    %ecx,%ebx
  800de4:	75 ed                	jne    800dd3 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800de6:	89 f0                	mov    %esi,%eax
  800de8:	5b                   	pop    %ebx
  800de9:	5e                   	pop    %esi
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
  800df1:	8b 75 08             	mov    0x8(%ebp),%esi
  800df4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800df7:	8b 55 10             	mov    0x10(%ebp),%edx
  800dfa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800dfc:	85 d2                	test   %edx,%edx
  800dfe:	74 35                	je     800e35 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800e00:	89 d0                	mov    %edx,%eax
  800e02:	83 e8 01             	sub    $0x1,%eax
  800e05:	74 25                	je     800e2c <strlcpy+0x40>
  800e07:	0f b6 0b             	movzbl (%ebx),%ecx
  800e0a:	84 c9                	test   %cl,%cl
  800e0c:	74 22                	je     800e30 <strlcpy+0x44>
  800e0e:	8d 53 01             	lea    0x1(%ebx),%edx
  800e11:	01 c3                	add    %eax,%ebx
  800e13:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800e15:	83 c0 01             	add    $0x1,%eax
  800e18:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e1b:	39 da                	cmp    %ebx,%edx
  800e1d:	74 13                	je     800e32 <strlcpy+0x46>
  800e1f:	83 c2 01             	add    $0x1,%edx
  800e22:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800e26:	84 c9                	test   %cl,%cl
  800e28:	75 eb                	jne    800e15 <strlcpy+0x29>
  800e2a:	eb 06                	jmp    800e32 <strlcpy+0x46>
  800e2c:	89 f0                	mov    %esi,%eax
  800e2e:	eb 02                	jmp    800e32 <strlcpy+0x46>
  800e30:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e32:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e35:	29 f0                	sub    %esi,%eax
}
  800e37:	5b                   	pop    %ebx
  800e38:	5e                   	pop    %esi
  800e39:	5d                   	pop    %ebp
  800e3a:	c3                   	ret    

00800e3b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e41:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e44:	0f b6 01             	movzbl (%ecx),%eax
  800e47:	84 c0                	test   %al,%al
  800e49:	74 15                	je     800e60 <strcmp+0x25>
  800e4b:	3a 02                	cmp    (%edx),%al
  800e4d:	75 11                	jne    800e60 <strcmp+0x25>
		p++, q++;
  800e4f:	83 c1 01             	add    $0x1,%ecx
  800e52:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e55:	0f b6 01             	movzbl (%ecx),%eax
  800e58:	84 c0                	test   %al,%al
  800e5a:	74 04                	je     800e60 <strcmp+0x25>
  800e5c:	3a 02                	cmp    (%edx),%al
  800e5e:	74 ef                	je     800e4f <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e60:	0f b6 c0             	movzbl %al,%eax
  800e63:	0f b6 12             	movzbl (%edx),%edx
  800e66:	29 d0                	sub    %edx,%eax
}
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	56                   	push   %esi
  800e6e:	53                   	push   %ebx
  800e6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e75:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800e78:	85 f6                	test   %esi,%esi
  800e7a:	74 29                	je     800ea5 <strncmp+0x3b>
  800e7c:	0f b6 03             	movzbl (%ebx),%eax
  800e7f:	84 c0                	test   %al,%al
  800e81:	74 30                	je     800eb3 <strncmp+0x49>
  800e83:	3a 02                	cmp    (%edx),%al
  800e85:	75 2c                	jne    800eb3 <strncmp+0x49>
  800e87:	8d 43 01             	lea    0x1(%ebx),%eax
  800e8a:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800e8c:	89 c3                	mov    %eax,%ebx
  800e8e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e91:	39 c6                	cmp    %eax,%esi
  800e93:	74 17                	je     800eac <strncmp+0x42>
  800e95:	0f b6 08             	movzbl (%eax),%ecx
  800e98:	84 c9                	test   %cl,%cl
  800e9a:	74 17                	je     800eb3 <strncmp+0x49>
  800e9c:	83 c0 01             	add    $0x1,%eax
  800e9f:	3a 0a                	cmp    (%edx),%cl
  800ea1:	74 e9                	je     800e8c <strncmp+0x22>
  800ea3:	eb 0e                	jmp    800eb3 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ea5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eaa:	eb 0f                	jmp    800ebb <strncmp+0x51>
  800eac:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb1:	eb 08                	jmp    800ebb <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800eb3:	0f b6 03             	movzbl (%ebx),%eax
  800eb6:	0f b6 12             	movzbl (%edx),%edx
  800eb9:	29 d0                	sub    %edx,%eax
}
  800ebb:	5b                   	pop    %ebx
  800ebc:	5e                   	pop    %esi
  800ebd:	5d                   	pop    %ebp
  800ebe:	c3                   	ret    

00800ebf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	53                   	push   %ebx
  800ec3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800ec9:	0f b6 10             	movzbl (%eax),%edx
  800ecc:	84 d2                	test   %dl,%dl
  800ece:	74 1d                	je     800eed <strchr+0x2e>
  800ed0:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800ed2:	38 d3                	cmp    %dl,%bl
  800ed4:	75 06                	jne    800edc <strchr+0x1d>
  800ed6:	eb 1a                	jmp    800ef2 <strchr+0x33>
  800ed8:	38 ca                	cmp    %cl,%dl
  800eda:	74 16                	je     800ef2 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800edc:	83 c0 01             	add    $0x1,%eax
  800edf:	0f b6 10             	movzbl (%eax),%edx
  800ee2:	84 d2                	test   %dl,%dl
  800ee4:	75 f2                	jne    800ed8 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800ee6:	b8 00 00 00 00       	mov    $0x0,%eax
  800eeb:	eb 05                	jmp    800ef2 <strchr+0x33>
  800eed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ef2:	5b                   	pop    %ebx
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	53                   	push   %ebx
  800ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  800efc:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800eff:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800f02:	38 d3                	cmp    %dl,%bl
  800f04:	74 14                	je     800f1a <strfind+0x25>
  800f06:	89 d1                	mov    %edx,%ecx
  800f08:	84 db                	test   %bl,%bl
  800f0a:	74 0e                	je     800f1a <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f0c:	83 c0 01             	add    $0x1,%eax
  800f0f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800f12:	38 ca                	cmp    %cl,%dl
  800f14:	74 04                	je     800f1a <strfind+0x25>
  800f16:	84 d2                	test   %dl,%dl
  800f18:	75 f2                	jne    800f0c <strfind+0x17>
			break;
	return (char *) s;
}
  800f1a:	5b                   	pop    %ebx
  800f1b:	5d                   	pop    %ebp
  800f1c:	c3                   	ret    

00800f1d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
  800f20:	57                   	push   %edi
  800f21:	56                   	push   %esi
  800f22:	53                   	push   %ebx
  800f23:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f26:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f29:	85 c9                	test   %ecx,%ecx
  800f2b:	74 36                	je     800f63 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f2d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f33:	75 28                	jne    800f5d <memset+0x40>
  800f35:	f6 c1 03             	test   $0x3,%cl
  800f38:	75 23                	jne    800f5d <memset+0x40>
		c &= 0xFF;
  800f3a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f3e:	89 d3                	mov    %edx,%ebx
  800f40:	c1 e3 08             	shl    $0x8,%ebx
  800f43:	89 d6                	mov    %edx,%esi
  800f45:	c1 e6 18             	shl    $0x18,%esi
  800f48:	89 d0                	mov    %edx,%eax
  800f4a:	c1 e0 10             	shl    $0x10,%eax
  800f4d:	09 f0                	or     %esi,%eax
  800f4f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f51:	89 d8                	mov    %ebx,%eax
  800f53:	09 d0                	or     %edx,%eax
  800f55:	c1 e9 02             	shr    $0x2,%ecx
  800f58:	fc                   	cld    
  800f59:	f3 ab                	rep stos %eax,%es:(%edi)
  800f5b:	eb 06                	jmp    800f63 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f60:	fc                   	cld    
  800f61:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f63:	89 f8                	mov    %edi,%eax
  800f65:	5b                   	pop    %ebx
  800f66:	5e                   	pop    %esi
  800f67:	5f                   	pop    %edi
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    

00800f6a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	57                   	push   %edi
  800f6e:	56                   	push   %esi
  800f6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f72:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f75:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f78:	39 c6                	cmp    %eax,%esi
  800f7a:	73 35                	jae    800fb1 <memmove+0x47>
  800f7c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f7f:	39 d0                	cmp    %edx,%eax
  800f81:	73 2e                	jae    800fb1 <memmove+0x47>
		s += n;
		d += n;
  800f83:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f86:	89 d6                	mov    %edx,%esi
  800f88:	09 fe                	or     %edi,%esi
  800f8a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f90:	75 13                	jne    800fa5 <memmove+0x3b>
  800f92:	f6 c1 03             	test   $0x3,%cl
  800f95:	75 0e                	jne    800fa5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800f97:	83 ef 04             	sub    $0x4,%edi
  800f9a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f9d:	c1 e9 02             	shr    $0x2,%ecx
  800fa0:	fd                   	std    
  800fa1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fa3:	eb 09                	jmp    800fae <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fa5:	83 ef 01             	sub    $0x1,%edi
  800fa8:	8d 72 ff             	lea    -0x1(%edx),%esi
  800fab:	fd                   	std    
  800fac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fae:	fc                   	cld    
  800faf:	eb 1d                	jmp    800fce <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fb1:	89 f2                	mov    %esi,%edx
  800fb3:	09 c2                	or     %eax,%edx
  800fb5:	f6 c2 03             	test   $0x3,%dl
  800fb8:	75 0f                	jne    800fc9 <memmove+0x5f>
  800fba:	f6 c1 03             	test   $0x3,%cl
  800fbd:	75 0a                	jne    800fc9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800fbf:	c1 e9 02             	shr    $0x2,%ecx
  800fc2:	89 c7                	mov    %eax,%edi
  800fc4:	fc                   	cld    
  800fc5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fc7:	eb 05                	jmp    800fce <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fc9:	89 c7                	mov    %eax,%edi
  800fcb:	fc                   	cld    
  800fcc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fce:	5e                   	pop    %esi
  800fcf:	5f                   	pop    %edi
  800fd0:	5d                   	pop    %ebp
  800fd1:	c3                   	ret    

00800fd2 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800fd5:	ff 75 10             	pushl  0x10(%ebp)
  800fd8:	ff 75 0c             	pushl  0xc(%ebp)
  800fdb:	ff 75 08             	pushl  0x8(%ebp)
  800fde:	e8 87 ff ff ff       	call   800f6a <memmove>
}
  800fe3:	c9                   	leave  
  800fe4:	c3                   	ret    

00800fe5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	57                   	push   %edi
  800fe9:	56                   	push   %esi
  800fea:	53                   	push   %ebx
  800feb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fee:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ff1:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	74 39                	je     801031 <memcmp+0x4c>
  800ff8:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800ffb:	0f b6 13             	movzbl (%ebx),%edx
  800ffe:	0f b6 0e             	movzbl (%esi),%ecx
  801001:	38 ca                	cmp    %cl,%dl
  801003:	75 17                	jne    80101c <memcmp+0x37>
  801005:	b8 00 00 00 00       	mov    $0x0,%eax
  80100a:	eb 1a                	jmp    801026 <memcmp+0x41>
  80100c:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  801011:	83 c0 01             	add    $0x1,%eax
  801014:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  801018:	38 ca                	cmp    %cl,%dl
  80101a:	74 0a                	je     801026 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  80101c:	0f b6 c2             	movzbl %dl,%eax
  80101f:	0f b6 c9             	movzbl %cl,%ecx
  801022:	29 c8                	sub    %ecx,%eax
  801024:	eb 10                	jmp    801036 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801026:	39 f8                	cmp    %edi,%eax
  801028:	75 e2                	jne    80100c <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80102a:	b8 00 00 00 00       	mov    $0x0,%eax
  80102f:	eb 05                	jmp    801036 <memcmp+0x51>
  801031:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801036:	5b                   	pop    %ebx
  801037:	5e                   	pop    %esi
  801038:	5f                   	pop    %edi
  801039:	5d                   	pop    %ebp
  80103a:	c3                   	ret    

0080103b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	53                   	push   %ebx
  80103f:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  801042:	89 d0                	mov    %edx,%eax
  801044:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  801047:	39 c2                	cmp    %eax,%edx
  801049:	73 1d                	jae    801068 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  80104b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  80104f:	0f b6 0a             	movzbl (%edx),%ecx
  801052:	39 d9                	cmp    %ebx,%ecx
  801054:	75 09                	jne    80105f <memfind+0x24>
  801056:	eb 14                	jmp    80106c <memfind+0x31>
  801058:	0f b6 0a             	movzbl (%edx),%ecx
  80105b:	39 d9                	cmp    %ebx,%ecx
  80105d:	74 11                	je     801070 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80105f:	83 c2 01             	add    $0x1,%edx
  801062:	39 d0                	cmp    %edx,%eax
  801064:	75 f2                	jne    801058 <memfind+0x1d>
  801066:	eb 0a                	jmp    801072 <memfind+0x37>
  801068:	89 d0                	mov    %edx,%eax
  80106a:	eb 06                	jmp    801072 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  80106c:	89 d0                	mov    %edx,%eax
  80106e:	eb 02                	jmp    801072 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801070:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801072:	5b                   	pop    %ebx
  801073:	5d                   	pop    %ebp
  801074:	c3                   	ret    

00801075 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	57                   	push   %edi
  801079:	56                   	push   %esi
  80107a:	53                   	push   %ebx
  80107b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80107e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801081:	0f b6 01             	movzbl (%ecx),%eax
  801084:	3c 20                	cmp    $0x20,%al
  801086:	74 04                	je     80108c <strtol+0x17>
  801088:	3c 09                	cmp    $0x9,%al
  80108a:	75 0e                	jne    80109a <strtol+0x25>
		s++;
  80108c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80108f:	0f b6 01             	movzbl (%ecx),%eax
  801092:	3c 20                	cmp    $0x20,%al
  801094:	74 f6                	je     80108c <strtol+0x17>
  801096:	3c 09                	cmp    $0x9,%al
  801098:	74 f2                	je     80108c <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  80109a:	3c 2b                	cmp    $0x2b,%al
  80109c:	75 0a                	jne    8010a8 <strtol+0x33>
		s++;
  80109e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8010a1:	bf 00 00 00 00       	mov    $0x0,%edi
  8010a6:	eb 11                	jmp    8010b9 <strtol+0x44>
  8010a8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8010ad:	3c 2d                	cmp    $0x2d,%al
  8010af:	75 08                	jne    8010b9 <strtol+0x44>
		s++, neg = 1;
  8010b1:	83 c1 01             	add    $0x1,%ecx
  8010b4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010b9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8010bf:	75 15                	jne    8010d6 <strtol+0x61>
  8010c1:	80 39 30             	cmpb   $0x30,(%ecx)
  8010c4:	75 10                	jne    8010d6 <strtol+0x61>
  8010c6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8010ca:	75 7c                	jne    801148 <strtol+0xd3>
		s += 2, base = 16;
  8010cc:	83 c1 02             	add    $0x2,%ecx
  8010cf:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010d4:	eb 16                	jmp    8010ec <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  8010d6:	85 db                	test   %ebx,%ebx
  8010d8:	75 12                	jne    8010ec <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010da:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010df:	80 39 30             	cmpb   $0x30,(%ecx)
  8010e2:	75 08                	jne    8010ec <strtol+0x77>
		s++, base = 8;
  8010e4:	83 c1 01             	add    $0x1,%ecx
  8010e7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8010ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010f4:	0f b6 11             	movzbl (%ecx),%edx
  8010f7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010fa:	89 f3                	mov    %esi,%ebx
  8010fc:	80 fb 09             	cmp    $0x9,%bl
  8010ff:	77 08                	ja     801109 <strtol+0x94>
			dig = *s - '0';
  801101:	0f be d2             	movsbl %dl,%edx
  801104:	83 ea 30             	sub    $0x30,%edx
  801107:	eb 22                	jmp    80112b <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  801109:	8d 72 9f             	lea    -0x61(%edx),%esi
  80110c:	89 f3                	mov    %esi,%ebx
  80110e:	80 fb 19             	cmp    $0x19,%bl
  801111:	77 08                	ja     80111b <strtol+0xa6>
			dig = *s - 'a' + 10;
  801113:	0f be d2             	movsbl %dl,%edx
  801116:	83 ea 57             	sub    $0x57,%edx
  801119:	eb 10                	jmp    80112b <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  80111b:	8d 72 bf             	lea    -0x41(%edx),%esi
  80111e:	89 f3                	mov    %esi,%ebx
  801120:	80 fb 19             	cmp    $0x19,%bl
  801123:	77 16                	ja     80113b <strtol+0xc6>
			dig = *s - 'A' + 10;
  801125:	0f be d2             	movsbl %dl,%edx
  801128:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80112b:	3b 55 10             	cmp    0x10(%ebp),%edx
  80112e:	7d 0b                	jge    80113b <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  801130:	83 c1 01             	add    $0x1,%ecx
  801133:	0f af 45 10          	imul   0x10(%ebp),%eax
  801137:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801139:	eb b9                	jmp    8010f4 <strtol+0x7f>

	if (endptr)
  80113b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80113f:	74 0d                	je     80114e <strtol+0xd9>
		*endptr = (char *) s;
  801141:	8b 75 0c             	mov    0xc(%ebp),%esi
  801144:	89 0e                	mov    %ecx,(%esi)
  801146:	eb 06                	jmp    80114e <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801148:	85 db                	test   %ebx,%ebx
  80114a:	74 98                	je     8010e4 <strtol+0x6f>
  80114c:	eb 9e                	jmp    8010ec <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80114e:	89 c2                	mov    %eax,%edx
  801150:	f7 da                	neg    %edx
  801152:	85 ff                	test   %edi,%edi
  801154:	0f 45 c2             	cmovne %edx,%eax
}
  801157:	5b                   	pop    %ebx
  801158:	5e                   	pop    %esi
  801159:	5f                   	pop    %edi
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    
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
