
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
  8000b6:	56                   	push   %esi
  8000b7:	57                   	push   %edi
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	8d 35 c3 00 80 00    	lea    0x8000c3,%esi
  8000c1:	0f 34                	sysenter 

008000c3 <label_21>:
  8000c3:	89 ec                	mov    %ebp,%esp
  8000c5:	5d                   	pop    %ebp
  8000c6:	5f                   	pop    %edi
  8000c7:	5e                   	pop    %esi
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
  8000e7:	56                   	push   %esi
  8000e8:	57                   	push   %edi
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	8d 35 f4 00 80 00    	lea    0x8000f4,%esi
  8000f2:	0f 34                	sysenter 

008000f4 <label_55>:
  8000f4:	89 ec                	mov    %ebp,%esp
  8000f6:	5d                   	pop    %ebp
  8000f7:	5f                   	pop    %edi
  8000f8:	5e                   	pop    %esi
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
  800119:	56                   	push   %esi
  80011a:	57                   	push   %edi
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	8d 35 26 01 80 00    	lea    0x800126,%esi
  800124:	0f 34                	sysenter 

00800126 <label_90>:
  800126:	89 ec                	mov    %ebp,%esp
  800128:	5d                   	pop    %ebp
  800129:	5f                   	pop    %edi
  80012a:	5e                   	pop    %esi
  80012b:	5b                   	pop    %ebx
  80012c:	5a                   	pop    %edx
  80012d:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80012e:	85 c0                	test   %eax,%eax
  800130:	7e 17                	jle    800149 <label_90+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800132:	83 ec 0c             	sub    $0xc,%esp
  800135:	50                   	push   %eax
  800136:	6a 03                	push   $0x3
  800138:	68 0a 14 80 00       	push   $0x80140a
  80013d:	6a 29                	push   $0x29
  80013f:	68 27 14 80 00       	push   $0x801427
  800144:	e8 06 03 00 00       	call   80044f <_panic>

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
  800168:	56                   	push   %esi
  800169:	57                   	push   %edi
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	8d 35 75 01 80 00    	lea    0x800175,%esi
  800173:	0f 34                	sysenter 

00800175 <label_139>:
  800175:	89 ec                	mov    %ebp,%esp
  800177:	5d                   	pop    %ebp
  800178:	5f                   	pop    %edi
  800179:	5e                   	pop    %esi
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
  80019b:	56                   	push   %esi
  80019c:	57                   	push   %edi
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	8d 35 a8 01 80 00    	lea    0x8001a8,%esi
  8001a6:	0f 34                	sysenter 

008001a8 <label_174>:
  8001a8:	89 ec                	mov    %ebp,%esp
  8001aa:	5d                   	pop    %ebp
  8001ab:	5f                   	pop    %edi
  8001ac:	5e                   	pop    %esi
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
  8001cc:	56                   	push   %esi
  8001cd:	57                   	push   %edi
  8001ce:	55                   	push   %ebp
  8001cf:	89 e5                	mov    %esp,%ebp
  8001d1:	8d 35 d9 01 80 00    	lea    0x8001d9,%esi
  8001d7:	0f 34                	sysenter 

008001d9 <label_209>:
  8001d9:	89 ec                	mov    %ebp,%esp
  8001db:	5d                   	pop    %ebp
  8001dc:	5f                   	pop    %edi
  8001dd:	5e                   	pop    %esi
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
  800200:	56                   	push   %esi
  800201:	57                   	push   %edi
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	8d 35 0d 02 80 00    	lea    0x80020d,%esi
  80020b:	0f 34                	sysenter 

0080020d <label_244>:
  80020d:	89 ec                	mov    %ebp,%esp
  80020f:	5d                   	pop    %ebp
  800210:	5f                   	pop    %edi
  800211:	5e                   	pop    %esi
  800212:	5b                   	pop    %ebx
  800213:	5a                   	pop    %edx
  800214:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800215:	85 c0                	test   %eax,%eax
  800217:	7e 17                	jle    800230 <label_244+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  800219:	83 ec 0c             	sub    $0xc,%esp
  80021c:	50                   	push   %eax
  80021d:	6a 05                	push   $0x5
  80021f:	68 0a 14 80 00       	push   $0x80140a
  800224:	6a 29                	push   $0x29
  800226:	68 27 14 80 00       	push   $0x801427
  80022b:	e8 1f 02 00 00       	call   80044f <_panic>

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
  80023c:	83 ec 20             	sub    $0x20,%esp
	// cprintf("sys_page_map gets here\n");
	// return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
	uint32_t args[5];
	args[0] = (uint32_t) srcenv;
  80023f:	8b 45 08             	mov    0x8(%ebp),%eax
  800242:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	args[1] = (uint32_t) srcva;
  800245:	8b 45 0c             	mov    0xc(%ebp),%eax
  800248:	89 45 e8             	mov    %eax,-0x18(%ebp)
	args[2] = (uint32_t) dstenv;
  80024b:	8b 45 10             	mov    0x10(%ebp),%eax
  80024e:	89 45 ec             	mov    %eax,-0x14(%ebp)
	args[3] = (uint32_t) dstva;
  800251:	8b 45 14             	mov    0x14(%ebp),%eax
  800254:	89 45 f0             	mov    %eax,-0x10(%ebp)
	args[4] = (uint32_t) perm;
  800257:	8b 45 18             	mov    0x18(%ebp),%eax
  80025a:	89 45 f4             	mov    %eax,-0xc(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80025d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800260:	b9 00 00 00 00       	mov    $0x0,%ecx
  800265:	b8 06 00 00 00       	mov    $0x6,%eax
  80026a:	89 cb                	mov    %ecx,%ebx
  80026c:	89 cf                	mov    %ecx,%edi
  80026e:	51                   	push   %ecx
  80026f:	52                   	push   %edx
  800270:	53                   	push   %ebx
  800271:	56                   	push   %esi
  800272:	57                   	push   %edi
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	8d 35 7e 02 80 00    	lea    0x80027e,%esi
  80027c:	0f 34                	sysenter 

0080027e <label_304>:
  80027e:	89 ec                	mov    %ebp,%esp
  800280:	5d                   	pop    %ebp
  800281:	5f                   	pop    %edi
  800282:	5e                   	pop    %esi
  800283:	5b                   	pop    %ebx
  800284:	5a                   	pop    %edx
  800285:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 17                	jle    8002a1 <label_304+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 06                	push   $0x6
  800290:	68 0a 14 80 00       	push   $0x80140a
  800295:	6a 29                	push   $0x29
  800297:	68 27 14 80 00       	push   $0x801427
  80029c:	e8 ae 01 00 00       	call   80044f <_panic>
	args[1] = (uint32_t) srcva;
	args[2] = (uint32_t) dstenv;
	args[3] = (uint32_t) dstva;
	args[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)args, 0, 0, 0, 0);
}
  8002a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5f                   	pop    %edi
  8002a6:	5d                   	pop    %ebp
  8002a7:	c3                   	ret    

008002a8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	57                   	push   %edi
  8002ac:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002ad:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b2:	b8 07 00 00 00       	mov    $0x7,%eax
  8002b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bd:	89 fb                	mov    %edi,%ebx
  8002bf:	51                   	push   %ecx
  8002c0:	52                   	push   %edx
  8002c1:	53                   	push   %ebx
  8002c2:	56                   	push   %esi
  8002c3:	57                   	push   %edi
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	8d 35 cf 02 80 00    	lea    0x8002cf,%esi
  8002cd:	0f 34                	sysenter 

008002cf <label_353>:
  8002cf:	89 ec                	mov    %ebp,%esp
  8002d1:	5d                   	pop    %ebp
  8002d2:	5f                   	pop    %edi
  8002d3:	5e                   	pop    %esi
  8002d4:	5b                   	pop    %ebx
  8002d5:	5a                   	pop    %edx
  8002d6:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8002d7:	85 c0                	test   %eax,%eax
  8002d9:	7e 17                	jle    8002f2 <label_353+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	50                   	push   %eax
  8002df:	6a 07                	push   $0x7
  8002e1:	68 0a 14 80 00       	push   $0x80140a
  8002e6:	6a 29                	push   $0x29
  8002e8:	68 27 14 80 00       	push   $0x801427
  8002ed:	e8 5d 01 00 00       	call   80044f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002f5:	5b                   	pop    %ebx
  8002f6:	5f                   	pop    %edi
  8002f7:	5d                   	pop    %ebp
  8002f8:	c3                   	ret    

008002f9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
  8002fc:	57                   	push   %edi
  8002fd:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002fe:	bf 00 00 00 00       	mov    $0x0,%edi
  800303:	b8 09 00 00 00       	mov    $0x9,%eax
  800308:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030b:	8b 55 08             	mov    0x8(%ebp),%edx
  80030e:	89 fb                	mov    %edi,%ebx
  800310:	51                   	push   %ecx
  800311:	52                   	push   %edx
  800312:	53                   	push   %ebx
  800313:	56                   	push   %esi
  800314:	57                   	push   %edi
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	8d 35 20 03 80 00    	lea    0x800320,%esi
  80031e:	0f 34                	sysenter 

00800320 <label_402>:
  800320:	89 ec                	mov    %ebp,%esp
  800322:	5d                   	pop    %ebp
  800323:	5f                   	pop    %edi
  800324:	5e                   	pop    %esi
  800325:	5b                   	pop    %ebx
  800326:	5a                   	pop    %edx
  800327:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7e 17                	jle    800343 <label_402+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032c:	83 ec 0c             	sub    $0xc,%esp
  80032f:	50                   	push   %eax
  800330:	6a 09                	push   $0x9
  800332:	68 0a 14 80 00       	push   $0x80140a
  800337:	6a 29                	push   $0x29
  800339:	68 27 14 80 00       	push   $0x801427
  80033e:	e8 0c 01 00 00       	call   80044f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800343:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800346:	5b                   	pop    %ebx
  800347:	5f                   	pop    %edi
  800348:	5d                   	pop    %ebp
  800349:	c3                   	ret    

0080034a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	57                   	push   %edi
  80034e:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80034f:	bf 00 00 00 00       	mov    $0x0,%edi
  800354:	b8 0a 00 00 00       	mov    $0xa,%eax
  800359:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80035c:	8b 55 08             	mov    0x8(%ebp),%edx
  80035f:	89 fb                	mov    %edi,%ebx
  800361:	51                   	push   %ecx
  800362:	52                   	push   %edx
  800363:	53                   	push   %ebx
  800364:	56                   	push   %esi
  800365:	57                   	push   %edi
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	8d 35 71 03 80 00    	lea    0x800371,%esi
  80036f:	0f 34                	sysenter 

00800371 <label_451>:
  800371:	89 ec                	mov    %ebp,%esp
  800373:	5d                   	pop    %ebp
  800374:	5f                   	pop    %edi
  800375:	5e                   	pop    %esi
  800376:	5b                   	pop    %ebx
  800377:	5a                   	pop    %edx
  800378:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  800379:	85 c0                	test   %eax,%eax
  80037b:	7e 17                	jle    800394 <label_451+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80037d:	83 ec 0c             	sub    $0xc,%esp
  800380:	50                   	push   %eax
  800381:	6a 0a                	push   $0xa
  800383:	68 0a 14 80 00       	push   $0x80140a
  800388:	6a 29                	push   $0x29
  80038a:	68 27 14 80 00       	push   $0x801427
  80038f:	e8 bb 00 00 00       	call   80044f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800394:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800397:	5b                   	pop    %ebx
  800398:	5f                   	pop    %edi
  800399:	5d                   	pop    %ebp
  80039a:	c3                   	ret    

0080039b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	57                   	push   %edi
  80039f:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003a0:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003ae:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003b1:	51                   	push   %ecx
  8003b2:	52                   	push   %edx
  8003b3:	53                   	push   %ebx
  8003b4:	56                   	push   %esi
  8003b5:	57                   	push   %edi
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	8d 35 c1 03 80 00    	lea    0x8003c1,%esi
  8003bf:	0f 34                	sysenter 

008003c1 <label_502>:
  8003c1:	89 ec                	mov    %ebp,%esp
  8003c3:	5d                   	pop    %ebp
  8003c4:	5f                   	pop    %edi
  8003c5:	5e                   	pop    %esi
  8003c6:	5b                   	pop    %ebx
  8003c7:	5a                   	pop    %edx
  8003c8:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003c9:	5b                   	pop    %ebx
  8003ca:	5f                   	pop    %edi
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	57                   	push   %edi
  8003d1:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8003d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003d7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8003df:	89 d9                	mov    %ebx,%ecx
  8003e1:	89 df                	mov    %ebx,%edi
  8003e3:	51                   	push   %ecx
  8003e4:	52                   	push   %edx
  8003e5:	53                   	push   %ebx
  8003e6:	56                   	push   %esi
  8003e7:	57                   	push   %edi
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	8d 35 f3 03 80 00    	lea    0x8003f3,%esi
  8003f1:	0f 34                	sysenter 

008003f3 <label_537>:
  8003f3:	89 ec                	mov    %ebp,%esp
  8003f5:	5d                   	pop    %ebp
  8003f6:	5f                   	pop    %edi
  8003f7:	5e                   	pop    %esi
  8003f8:	5b                   	pop    %ebx
  8003f9:	5a                   	pop    %edx
  8003fa:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8003fb:	85 c0                	test   %eax,%eax
  8003fd:	7e 17                	jle    800416 <label_537+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003ff:	83 ec 0c             	sub    $0xc,%esp
  800402:	50                   	push   %eax
  800403:	6a 0d                	push   $0xd
  800405:	68 0a 14 80 00       	push   $0x80140a
  80040a:	6a 29                	push   $0x29
  80040c:	68 27 14 80 00       	push   $0x801427
  800411:	e8 39 00 00 00       	call   80044f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800416:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800419:	5b                   	pop    %ebx
  80041a:	5f                   	pop    %edi
  80041b:	5d                   	pop    %ebp
  80041c:	c3                   	ret    

0080041d <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  80041d:	55                   	push   %ebp
  80041e:	89 e5                	mov    %esp,%ebp
  800420:	57                   	push   %edi
  800421:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800422:	b9 00 00 00 00       	mov    $0x0,%ecx
  800427:	b8 0e 00 00 00       	mov    $0xe,%eax
  80042c:	8b 55 08             	mov    0x8(%ebp),%edx
  80042f:	89 cb                	mov    %ecx,%ebx
  800431:	89 cf                	mov    %ecx,%edi
  800433:	51                   	push   %ecx
  800434:	52                   	push   %edx
  800435:	53                   	push   %ebx
  800436:	56                   	push   %esi
  800437:	57                   	push   %edi
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	8d 35 43 04 80 00    	lea    0x800443,%esi
  800441:	0f 34                	sysenter 

00800443 <label_586>:
  800443:	89 ec                	mov    %ebp,%esp
  800445:	5d                   	pop    %ebp
  800446:	5f                   	pop    %edi
  800447:	5e                   	pop    %esi
  800448:	5b                   	pop    %ebx
  800449:	5a                   	pop    %edx
  80044a:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80044b:	5b                   	pop    %ebx
  80044c:	5f                   	pop    %edi
  80044d:	5d                   	pop    %ebp
  80044e:	c3                   	ret    

0080044f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	56                   	push   %esi
  800453:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800454:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800457:	a1 10 20 80 00       	mov    0x802010,%eax
  80045c:	85 c0                	test   %eax,%eax
  80045e:	74 11                	je     800471 <_panic+0x22>
		cprintf("%s: ", argv0);
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	50                   	push   %eax
  800464:	68 35 14 80 00       	push   $0x801435
  800469:	e8 d4 00 00 00       	call   800542 <cprintf>
  80046e:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800471:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800477:	e8 d4 fc ff ff       	call   800150 <sys_getenvid>
  80047c:	83 ec 0c             	sub    $0xc,%esp
  80047f:	ff 75 0c             	pushl  0xc(%ebp)
  800482:	ff 75 08             	pushl  0x8(%ebp)
  800485:	56                   	push   %esi
  800486:	50                   	push   %eax
  800487:	68 3c 14 80 00       	push   $0x80143c
  80048c:	e8 b1 00 00 00       	call   800542 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800491:	83 c4 18             	add    $0x18,%esp
  800494:	53                   	push   %ebx
  800495:	ff 75 10             	pushl  0x10(%ebp)
  800498:	e8 54 00 00 00       	call   8004f1 <vcprintf>
	cprintf("\n");
  80049d:	c7 04 24 3a 14 80 00 	movl   $0x80143a,(%esp)
  8004a4:	e8 99 00 00 00       	call   800542 <cprintf>
  8004a9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004ac:	cc                   	int3   
  8004ad:	eb fd                	jmp    8004ac <_panic+0x5d>

008004af <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004af:	55                   	push   %ebp
  8004b0:	89 e5                	mov    %esp,%ebp
  8004b2:	53                   	push   %ebx
  8004b3:	83 ec 04             	sub    $0x4,%esp
  8004b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004b9:	8b 13                	mov    (%ebx),%edx
  8004bb:	8d 42 01             	lea    0x1(%edx),%eax
  8004be:	89 03                	mov    %eax,(%ebx)
  8004c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004c3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8004c7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004cc:	75 1a                	jne    8004e8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	68 ff 00 00 00       	push   $0xff
  8004d6:	8d 43 08             	lea    0x8(%ebx),%eax
  8004d9:	50                   	push   %eax
  8004da:	e8 c0 fb ff ff       	call   80009f <sys_cputs>
		b->idx = 0;
  8004df:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004e5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004e8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004ef:	c9                   	leave  
  8004f0:	c3                   	ret    

008004f1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004f1:	55                   	push   %ebp
  8004f2:	89 e5                	mov    %esp,%ebp
  8004f4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004fa:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800501:	00 00 00 
	b.cnt = 0;
  800504:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80050b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80050e:	ff 75 0c             	pushl  0xc(%ebp)
  800511:	ff 75 08             	pushl  0x8(%ebp)
  800514:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80051a:	50                   	push   %eax
  80051b:	68 af 04 80 00       	push   $0x8004af
  800520:	e8 c0 02 00 00       	call   8007e5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800525:	83 c4 08             	add    $0x8,%esp
  800528:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80052e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800534:	50                   	push   %eax
  800535:	e8 65 fb ff ff       	call   80009f <sys_cputs>

	return b.cnt;
}
  80053a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800540:	c9                   	leave  
  800541:	c3                   	ret    

00800542 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800542:	55                   	push   %ebp
  800543:	89 e5                	mov    %esp,%ebp
  800545:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800548:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80054b:	50                   	push   %eax
  80054c:	ff 75 08             	pushl  0x8(%ebp)
  80054f:	e8 9d ff ff ff       	call   8004f1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800554:	c9                   	leave  
  800555:	c3                   	ret    

00800556 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800556:	55                   	push   %ebp
  800557:	89 e5                	mov    %esp,%ebp
  800559:	57                   	push   %edi
  80055a:	56                   	push   %esi
  80055b:	53                   	push   %ebx
  80055c:	83 ec 1c             	sub    $0x1c,%esp
  80055f:	89 c7                	mov    %eax,%edi
  800561:	89 d6                	mov    %edx,%esi
  800563:	8b 45 08             	mov    0x8(%ebp),%eax
  800566:	8b 55 0c             	mov    0xc(%ebp),%edx
  800569:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80056c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80056f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  800572:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800576:	0f 85 bf 00 00 00    	jne    80063b <printnum+0xe5>
  80057c:	39 1d 08 20 80 00    	cmp    %ebx,0x802008
  800582:	0f 8d de 00 00 00    	jge    800666 <printnum+0x110>
		judge_time_for_space = width;
  800588:	89 1d 08 20 80 00    	mov    %ebx,0x802008
  80058e:	e9 d3 00 00 00       	jmp    800666 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800593:	83 eb 01             	sub    $0x1,%ebx
  800596:	85 db                	test   %ebx,%ebx
  800598:	7f 37                	jg     8005d1 <printnum+0x7b>
  80059a:	e9 ea 00 00 00       	jmp    800689 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  80059f:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8005a2:	a3 04 20 80 00       	mov    %eax,0x802004
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	56                   	push   %esi
  8005ab:	83 ec 04             	sub    $0x4,%esp
  8005ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8005b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8005b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ba:	e8 d1 0c 00 00       	call   801290 <__umoddi3>
  8005bf:	83 c4 14             	add    $0x14,%esp
  8005c2:	0f be 80 5f 14 80 00 	movsbl 0x80145f(%eax),%eax
  8005c9:	50                   	push   %eax
  8005ca:	ff d7                	call   *%edi
  8005cc:	83 c4 10             	add    $0x10,%esp
  8005cf:	eb 16                	jmp    8005e7 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  8005d1:	83 ec 08             	sub    $0x8,%esp
  8005d4:	56                   	push   %esi
  8005d5:	ff 75 18             	pushl  0x18(%ebp)
  8005d8:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  8005da:	83 c4 10             	add    $0x10,%esp
  8005dd:	83 eb 01             	sub    $0x1,%ebx
  8005e0:	75 ef                	jne    8005d1 <printnum+0x7b>
  8005e2:	e9 a2 00 00 00       	jmp    800689 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  8005e7:	3b 1d 08 20 80 00    	cmp    0x802008,%ebx
  8005ed:	0f 85 76 01 00 00    	jne    800769 <printnum+0x213>
		while(num_of_space-- > 0)
  8005f3:	a1 04 20 80 00       	mov    0x802004,%eax
  8005f8:	8d 50 ff             	lea    -0x1(%eax),%edx
  8005fb:	89 15 04 20 80 00    	mov    %edx,0x802004
  800601:	85 c0                	test   %eax,%eax
  800603:	7e 1d                	jle    800622 <printnum+0xcc>
			putch(' ', putdat);
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	56                   	push   %esi
  800609:	6a 20                	push   $0x20
  80060b:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  80060d:	a1 04 20 80 00       	mov    0x802004,%eax
  800612:	8d 50 ff             	lea    -0x1(%eax),%edx
  800615:	89 15 04 20 80 00    	mov    %edx,0x802004
  80061b:	83 c4 10             	add    $0x10,%esp
  80061e:	85 c0                	test   %eax,%eax
  800620:	7f e3                	jg     800605 <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  800622:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800629:	00 00 00 
		judge_time_for_space = 0;
  80062c:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800633:	00 00 00 
	}
}
  800636:	e9 2e 01 00 00       	jmp    800769 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80063b:	8b 45 10             	mov    0x10(%ebp),%eax
  80063e:	ba 00 00 00 00       	mov    $0x0,%edx
  800643:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800646:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800649:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80064c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80064f:	83 fa 00             	cmp    $0x0,%edx
  800652:	0f 87 ba 00 00 00    	ja     800712 <printnum+0x1bc>
  800658:	3b 45 10             	cmp    0x10(%ebp),%eax
  80065b:	0f 83 b1 00 00 00    	jae    800712 <printnum+0x1bc>
  800661:	e9 2d ff ff ff       	jmp    800593 <printnum+0x3d>
  800666:	8b 45 10             	mov    0x10(%ebp),%eax
  800669:	ba 00 00 00 00       	mov    $0x0,%edx
  80066e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800671:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800674:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800677:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80067a:	83 fa 00             	cmp    $0x0,%edx
  80067d:	77 37                	ja     8006b6 <printnum+0x160>
  80067f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800682:	73 32                	jae    8006b6 <printnum+0x160>
  800684:	e9 16 ff ff ff       	jmp    80059f <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	56                   	push   %esi
  80068d:	83 ec 04             	sub    $0x4,%esp
  800690:	ff 75 dc             	pushl  -0x24(%ebp)
  800693:	ff 75 d8             	pushl  -0x28(%ebp)
  800696:	ff 75 e4             	pushl  -0x1c(%ebp)
  800699:	ff 75 e0             	pushl  -0x20(%ebp)
  80069c:	e8 ef 0b 00 00       	call   801290 <__umoddi3>
  8006a1:	83 c4 14             	add    $0x14,%esp
  8006a4:	0f be 80 5f 14 80 00 	movsbl 0x80145f(%eax),%eax
  8006ab:	50                   	push   %eax
  8006ac:	ff d7                	call   *%edi
  8006ae:	83 c4 10             	add    $0x10,%esp
  8006b1:	e9 b3 00 00 00       	jmp    800769 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006b6:	83 ec 0c             	sub    $0xc,%esp
  8006b9:	ff 75 18             	pushl  0x18(%ebp)
  8006bc:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006bf:	50                   	push   %eax
  8006c0:	ff 75 10             	pushl  0x10(%ebp)
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8006c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8006cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d2:	e8 89 0a 00 00       	call   801160 <__udivdi3>
  8006d7:	83 c4 18             	add    $0x18,%esp
  8006da:	52                   	push   %edx
  8006db:	50                   	push   %eax
  8006dc:	89 f2                	mov    %esi,%edx
  8006de:	89 f8                	mov    %edi,%eax
  8006e0:	e8 71 fe ff ff       	call   800556 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006e5:	83 c4 18             	add    $0x18,%esp
  8006e8:	56                   	push   %esi
  8006e9:	83 ec 04             	sub    $0x4,%esp
  8006ec:	ff 75 dc             	pushl  -0x24(%ebp)
  8006ef:	ff 75 d8             	pushl  -0x28(%ebp)
  8006f2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f8:	e8 93 0b 00 00       	call   801290 <__umoddi3>
  8006fd:	83 c4 14             	add    $0x14,%esp
  800700:	0f be 80 5f 14 80 00 	movsbl 0x80145f(%eax),%eax
  800707:	50                   	push   %eax
  800708:	ff d7                	call   *%edi
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	e9 d5 fe ff ff       	jmp    8005e7 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800712:	83 ec 0c             	sub    $0xc,%esp
  800715:	ff 75 18             	pushl  0x18(%ebp)
  800718:	83 eb 01             	sub    $0x1,%ebx
  80071b:	53                   	push   %ebx
  80071c:	ff 75 10             	pushl  0x10(%ebp)
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	ff 75 dc             	pushl  -0x24(%ebp)
  800725:	ff 75 d8             	pushl  -0x28(%ebp)
  800728:	ff 75 e4             	pushl  -0x1c(%ebp)
  80072b:	ff 75 e0             	pushl  -0x20(%ebp)
  80072e:	e8 2d 0a 00 00       	call   801160 <__udivdi3>
  800733:	83 c4 18             	add    $0x18,%esp
  800736:	52                   	push   %edx
  800737:	50                   	push   %eax
  800738:	89 f2                	mov    %esi,%edx
  80073a:	89 f8                	mov    %edi,%eax
  80073c:	e8 15 fe ff ff       	call   800556 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800741:	83 c4 18             	add    $0x18,%esp
  800744:	56                   	push   %esi
  800745:	83 ec 04             	sub    $0x4,%esp
  800748:	ff 75 dc             	pushl  -0x24(%ebp)
  80074b:	ff 75 d8             	pushl  -0x28(%ebp)
  80074e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800751:	ff 75 e0             	pushl  -0x20(%ebp)
  800754:	e8 37 0b 00 00       	call   801290 <__umoddi3>
  800759:	83 c4 14             	add    $0x14,%esp
  80075c:	0f be 80 5f 14 80 00 	movsbl 0x80145f(%eax),%eax
  800763:	50                   	push   %eax
  800764:	ff d7                	call   *%edi
  800766:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800769:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076c:	5b                   	pop    %ebx
  80076d:	5e                   	pop    %esi
  80076e:	5f                   	pop    %edi
  80076f:	5d                   	pop    %ebp
  800770:	c3                   	ret    

00800771 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800774:	83 fa 01             	cmp    $0x1,%edx
  800777:	7e 0e                	jle    800787 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800779:	8b 10                	mov    (%eax),%edx
  80077b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80077e:	89 08                	mov    %ecx,(%eax)
  800780:	8b 02                	mov    (%edx),%eax
  800782:	8b 52 04             	mov    0x4(%edx),%edx
  800785:	eb 22                	jmp    8007a9 <getuint+0x38>
	else if (lflag)
  800787:	85 d2                	test   %edx,%edx
  800789:	74 10                	je     80079b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80078b:	8b 10                	mov    (%eax),%edx
  80078d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800790:	89 08                	mov    %ecx,(%eax)
  800792:	8b 02                	mov    (%edx),%eax
  800794:	ba 00 00 00 00       	mov    $0x0,%edx
  800799:	eb 0e                	jmp    8007a9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80079b:	8b 10                	mov    (%eax),%edx
  80079d:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007a0:	89 08                	mov    %ecx,(%eax)
  8007a2:	8b 02                	mov    (%edx),%eax
  8007a4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007b1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007b5:	8b 10                	mov    (%eax),%edx
  8007b7:	3b 50 04             	cmp    0x4(%eax),%edx
  8007ba:	73 0a                	jae    8007c6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007bc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007bf:	89 08                	mov    %ecx,(%eax)
  8007c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c4:	88 02                	mov    %al,(%edx)
}
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007ce:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007d1:	50                   	push   %eax
  8007d2:	ff 75 10             	pushl  0x10(%ebp)
  8007d5:	ff 75 0c             	pushl  0xc(%ebp)
  8007d8:	ff 75 08             	pushl  0x8(%ebp)
  8007db:	e8 05 00 00 00       	call   8007e5 <vprintfmt>
	va_end(ap);
}
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    

008007e5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	57                   	push   %edi
  8007e9:	56                   	push   %esi
  8007ea:	53                   	push   %ebx
  8007eb:	83 ec 2c             	sub    $0x2c,%esp
  8007ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007f4:	eb 03                	jmp    8007f9 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f6:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8007fc:	8d 70 01             	lea    0x1(%eax),%esi
  8007ff:	0f b6 00             	movzbl (%eax),%eax
  800802:	83 f8 25             	cmp    $0x25,%eax
  800805:	74 27                	je     80082e <vprintfmt+0x49>
			if (ch == '\0')
  800807:	85 c0                	test   %eax,%eax
  800809:	75 0d                	jne    800818 <vprintfmt+0x33>
  80080b:	e9 9d 04 00 00       	jmp    800cad <vprintfmt+0x4c8>
  800810:	85 c0                	test   %eax,%eax
  800812:	0f 84 95 04 00 00    	je     800cad <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	53                   	push   %ebx
  80081c:	50                   	push   %eax
  80081d:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80081f:	83 c6 01             	add    $0x1,%esi
  800822:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800826:	83 c4 10             	add    $0x10,%esp
  800829:	83 f8 25             	cmp    $0x25,%eax
  80082c:	75 e2                	jne    800810 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80082e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800833:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800837:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80083e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800845:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80084c:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800853:	eb 08                	jmp    80085d <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800855:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  800858:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085d:	8d 46 01             	lea    0x1(%esi),%eax
  800860:	89 45 10             	mov    %eax,0x10(%ebp)
  800863:	0f b6 06             	movzbl (%esi),%eax
  800866:	0f b6 d0             	movzbl %al,%edx
  800869:	83 e8 23             	sub    $0x23,%eax
  80086c:	3c 55                	cmp    $0x55,%al
  80086e:	0f 87 fa 03 00 00    	ja     800c6e <vprintfmt+0x489>
  800874:	0f b6 c0             	movzbl %al,%eax
  800877:	ff 24 85 a0 15 80 00 	jmp    *0x8015a0(,%eax,4)
  80087e:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800881:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800885:	eb d6                	jmp    80085d <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800887:	8d 42 d0             	lea    -0x30(%edx),%eax
  80088a:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80088d:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800891:	8d 50 d0             	lea    -0x30(%eax),%edx
  800894:	83 fa 09             	cmp    $0x9,%edx
  800897:	77 6b                	ja     800904 <vprintfmt+0x11f>
  800899:	8b 75 10             	mov    0x10(%ebp),%esi
  80089c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80089f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8008a2:	eb 09                	jmp    8008ad <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a4:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008a7:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8008ab:	eb b0                	jmp    80085d <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008ad:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8008b0:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8008b3:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8008b7:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008ba:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8008bd:	83 f9 09             	cmp    $0x9,%ecx
  8008c0:	76 eb                	jbe    8008ad <vprintfmt+0xc8>
  8008c2:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8008c5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8008c8:	eb 3d                	jmp    800907 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cd:	8d 50 04             	lea    0x4(%eax),%edx
  8008d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d3:	8b 00                	mov    (%eax),%eax
  8008d5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d8:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008db:	eb 2a                	jmp    800907 <vprintfmt+0x122>
  8008dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008e0:	85 c0                	test   %eax,%eax
  8008e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e7:	0f 49 d0             	cmovns %eax,%edx
  8008ea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ed:	8b 75 10             	mov    0x10(%ebp),%esi
  8008f0:	e9 68 ff ff ff       	jmp    80085d <vprintfmt+0x78>
  8008f5:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008f8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008ff:	e9 59 ff ff ff       	jmp    80085d <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800904:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800907:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80090b:	0f 89 4c ff ff ff    	jns    80085d <vprintfmt+0x78>
				width = precision, precision = -1;
  800911:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800914:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800917:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80091e:	e9 3a ff ff ff       	jmp    80085d <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800923:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800927:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80092a:	e9 2e ff ff ff       	jmp    80085d <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80092f:	8b 45 14             	mov    0x14(%ebp),%eax
  800932:	8d 50 04             	lea    0x4(%eax),%edx
  800935:	89 55 14             	mov    %edx,0x14(%ebp)
  800938:	83 ec 08             	sub    $0x8,%esp
  80093b:	53                   	push   %ebx
  80093c:	ff 30                	pushl  (%eax)
  80093e:	ff d7                	call   *%edi
			break;
  800940:	83 c4 10             	add    $0x10,%esp
  800943:	e9 b1 fe ff ff       	jmp    8007f9 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800948:	8b 45 14             	mov    0x14(%ebp),%eax
  80094b:	8d 50 04             	lea    0x4(%eax),%edx
  80094e:	89 55 14             	mov    %edx,0x14(%ebp)
  800951:	8b 00                	mov    (%eax),%eax
  800953:	99                   	cltd   
  800954:	31 d0                	xor    %edx,%eax
  800956:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800958:	83 f8 08             	cmp    $0x8,%eax
  80095b:	7f 0b                	jg     800968 <vprintfmt+0x183>
  80095d:	8b 14 85 00 17 80 00 	mov    0x801700(,%eax,4),%edx
  800964:	85 d2                	test   %edx,%edx
  800966:	75 15                	jne    80097d <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  800968:	50                   	push   %eax
  800969:	68 77 14 80 00       	push   $0x801477
  80096e:	53                   	push   %ebx
  80096f:	57                   	push   %edi
  800970:	e8 53 fe ff ff       	call   8007c8 <printfmt>
  800975:	83 c4 10             	add    $0x10,%esp
  800978:	e9 7c fe ff ff       	jmp    8007f9 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80097d:	52                   	push   %edx
  80097e:	68 80 14 80 00       	push   $0x801480
  800983:	53                   	push   %ebx
  800984:	57                   	push   %edi
  800985:	e8 3e fe ff ff       	call   8007c8 <printfmt>
  80098a:	83 c4 10             	add    $0x10,%esp
  80098d:	e9 67 fe ff ff       	jmp    8007f9 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800992:	8b 45 14             	mov    0x14(%ebp),%eax
  800995:	8d 50 04             	lea    0x4(%eax),%edx
  800998:	89 55 14             	mov    %edx,0x14(%ebp)
  80099b:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80099d:	85 c0                	test   %eax,%eax
  80099f:	b9 70 14 80 00       	mov    $0x801470,%ecx
  8009a4:	0f 45 c8             	cmovne %eax,%ecx
  8009a7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8009aa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009ae:	7e 06                	jle    8009b6 <vprintfmt+0x1d1>
  8009b0:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8009b4:	75 19                	jne    8009cf <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009b6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009b9:	8d 70 01             	lea    0x1(%eax),%esi
  8009bc:	0f b6 00             	movzbl (%eax),%eax
  8009bf:	0f be d0             	movsbl %al,%edx
  8009c2:	85 d2                	test   %edx,%edx
  8009c4:	0f 85 9f 00 00 00    	jne    800a69 <vprintfmt+0x284>
  8009ca:	e9 8c 00 00 00       	jmp    800a5b <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009cf:	83 ec 08             	sub    $0x8,%esp
  8009d2:	ff 75 d0             	pushl  -0x30(%ebp)
  8009d5:	ff 75 cc             	pushl  -0x34(%ebp)
  8009d8:	e8 62 03 00 00       	call   800d3f <strnlen>
  8009dd:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8009e0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8009e3:	83 c4 10             	add    $0x10,%esp
  8009e6:	85 c9                	test   %ecx,%ecx
  8009e8:	0f 8e a6 02 00 00    	jle    800c94 <vprintfmt+0x4af>
					putch(padc, putdat);
  8009ee:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8009f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009f5:	89 cb                	mov    %ecx,%ebx
  8009f7:	83 ec 08             	sub    $0x8,%esp
  8009fa:	ff 75 0c             	pushl  0xc(%ebp)
  8009fd:	56                   	push   %esi
  8009fe:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a00:	83 c4 10             	add    $0x10,%esp
  800a03:	83 eb 01             	sub    $0x1,%ebx
  800a06:	75 ef                	jne    8009f7 <vprintfmt+0x212>
  800a08:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800a0b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a0e:	e9 81 02 00 00       	jmp    800c94 <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a13:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a17:	74 1b                	je     800a34 <vprintfmt+0x24f>
  800a19:	0f be c0             	movsbl %al,%eax
  800a1c:	83 e8 20             	sub    $0x20,%eax
  800a1f:	83 f8 5e             	cmp    $0x5e,%eax
  800a22:	76 10                	jbe    800a34 <vprintfmt+0x24f>
					putch('?', putdat);
  800a24:	83 ec 08             	sub    $0x8,%esp
  800a27:	ff 75 0c             	pushl  0xc(%ebp)
  800a2a:	6a 3f                	push   $0x3f
  800a2c:	ff 55 08             	call   *0x8(%ebp)
  800a2f:	83 c4 10             	add    $0x10,%esp
  800a32:	eb 0d                	jmp    800a41 <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800a34:	83 ec 08             	sub    $0x8,%esp
  800a37:	ff 75 0c             	pushl  0xc(%ebp)
  800a3a:	52                   	push   %edx
  800a3b:	ff 55 08             	call   *0x8(%ebp)
  800a3e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a41:	83 ef 01             	sub    $0x1,%edi
  800a44:	83 c6 01             	add    $0x1,%esi
  800a47:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800a4b:	0f be d0             	movsbl %al,%edx
  800a4e:	85 d2                	test   %edx,%edx
  800a50:	75 31                	jne    800a83 <vprintfmt+0x29e>
  800a52:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a55:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a5b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a5e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a62:	7f 33                	jg     800a97 <vprintfmt+0x2b2>
  800a64:	e9 90 fd ff ff       	jmp    8007f9 <vprintfmt+0x14>
  800a69:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a6c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a6f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a72:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a75:	eb 0c                	jmp    800a83 <vprintfmt+0x29e>
  800a77:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a7a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a7d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a80:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a83:	85 db                	test   %ebx,%ebx
  800a85:	78 8c                	js     800a13 <vprintfmt+0x22e>
  800a87:	83 eb 01             	sub    $0x1,%ebx
  800a8a:	79 87                	jns    800a13 <vprintfmt+0x22e>
  800a8c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800a8f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a95:	eb c4                	jmp    800a5b <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a97:	83 ec 08             	sub    $0x8,%esp
  800a9a:	53                   	push   %ebx
  800a9b:	6a 20                	push   $0x20
  800a9d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a9f:	83 c4 10             	add    $0x10,%esp
  800aa2:	83 ee 01             	sub    $0x1,%esi
  800aa5:	75 f0                	jne    800a97 <vprintfmt+0x2b2>
  800aa7:	e9 4d fd ff ff       	jmp    8007f9 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800aac:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800ab0:	7e 16                	jle    800ac8 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800ab2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab5:	8d 50 08             	lea    0x8(%eax),%edx
  800ab8:	89 55 14             	mov    %edx,0x14(%ebp)
  800abb:	8b 50 04             	mov    0x4(%eax),%edx
  800abe:	8b 00                	mov    (%eax),%eax
  800ac0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800ac3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800ac6:	eb 34                	jmp    800afc <vprintfmt+0x317>
	else if (lflag)
  800ac8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800acc:	74 18                	je     800ae6 <vprintfmt+0x301>
		return va_arg(*ap, long);
  800ace:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad1:	8d 50 04             	lea    0x4(%eax),%edx
  800ad4:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad7:	8b 30                	mov    (%eax),%esi
  800ad9:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800adc:	89 f0                	mov    %esi,%eax
  800ade:	c1 f8 1f             	sar    $0x1f,%eax
  800ae1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800ae4:	eb 16                	jmp    800afc <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800ae6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae9:	8d 50 04             	lea    0x4(%eax),%edx
  800aec:	89 55 14             	mov    %edx,0x14(%ebp)
  800aef:	8b 30                	mov    (%eax),%esi
  800af1:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800af4:	89 f0                	mov    %esi,%eax
  800af6:	c1 f8 1f             	sar    $0x1f,%eax
  800af9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800afc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800aff:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b02:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b05:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800b08:	85 d2                	test   %edx,%edx
  800b0a:	79 28                	jns    800b34 <vprintfmt+0x34f>
				putch('-', putdat);
  800b0c:	83 ec 08             	sub    $0x8,%esp
  800b0f:	53                   	push   %ebx
  800b10:	6a 2d                	push   $0x2d
  800b12:	ff d7                	call   *%edi
				num = -(long long) num;
  800b14:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b17:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b1a:	f7 d8                	neg    %eax
  800b1c:	83 d2 00             	adc    $0x0,%edx
  800b1f:	f7 da                	neg    %edx
  800b21:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b24:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b27:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800b2a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b2f:	e9 b2 00 00 00       	jmp    800be6 <vprintfmt+0x401>
  800b34:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800b39:	85 c9                	test   %ecx,%ecx
  800b3b:	0f 84 a5 00 00 00    	je     800be6 <vprintfmt+0x401>
				putch('+', putdat);
  800b41:	83 ec 08             	sub    $0x8,%esp
  800b44:	53                   	push   %ebx
  800b45:	6a 2b                	push   $0x2b
  800b47:	ff d7                	call   *%edi
  800b49:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800b4c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b51:	e9 90 00 00 00       	jmp    800be6 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800b56:	85 c9                	test   %ecx,%ecx
  800b58:	74 0b                	je     800b65 <vprintfmt+0x380>
				putch('+', putdat);
  800b5a:	83 ec 08             	sub    $0x8,%esp
  800b5d:	53                   	push   %ebx
  800b5e:	6a 2b                	push   $0x2b
  800b60:	ff d7                	call   *%edi
  800b62:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800b65:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b68:	8d 45 14             	lea    0x14(%ebp),%eax
  800b6b:	e8 01 fc ff ff       	call   800771 <getuint>
  800b70:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b73:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800b76:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b7b:	eb 69                	jmp    800be6 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800b7d:	83 ec 08             	sub    $0x8,%esp
  800b80:	53                   	push   %ebx
  800b81:	6a 30                	push   $0x30
  800b83:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800b85:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b88:	8d 45 14             	lea    0x14(%ebp),%eax
  800b8b:	e8 e1 fb ff ff       	call   800771 <getuint>
  800b90:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b93:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800b96:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800b99:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800b9e:	eb 46                	jmp    800be6 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800ba0:	83 ec 08             	sub    $0x8,%esp
  800ba3:	53                   	push   %ebx
  800ba4:	6a 30                	push   $0x30
  800ba6:	ff d7                	call   *%edi
			putch('x', putdat);
  800ba8:	83 c4 08             	add    $0x8,%esp
  800bab:	53                   	push   %ebx
  800bac:	6a 78                	push   $0x78
  800bae:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bb0:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb3:	8d 50 04             	lea    0x4(%eax),%edx
  800bb6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bb9:	8b 00                	mov    (%eax),%eax
  800bbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bc3:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bc6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bc9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800bce:	eb 16                	jmp    800be6 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bd0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800bd3:	8d 45 14             	lea    0x14(%ebp),%eax
  800bd6:	e8 96 fb ff ff       	call   800771 <getuint>
  800bdb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800bde:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800be1:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800be6:	83 ec 0c             	sub    $0xc,%esp
  800be9:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800bed:	56                   	push   %esi
  800bee:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bf1:	50                   	push   %eax
  800bf2:	ff 75 dc             	pushl  -0x24(%ebp)
  800bf5:	ff 75 d8             	pushl  -0x28(%ebp)
  800bf8:	89 da                	mov    %ebx,%edx
  800bfa:	89 f8                	mov    %edi,%eax
  800bfc:	e8 55 f9 ff ff       	call   800556 <printnum>
			break;
  800c01:	83 c4 20             	add    $0x20,%esp
  800c04:	e9 f0 fb ff ff       	jmp    8007f9 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800c09:	8b 45 14             	mov    0x14(%ebp),%eax
  800c0c:	8d 50 04             	lea    0x4(%eax),%edx
  800c0f:	89 55 14             	mov    %edx,0x14(%ebp)
  800c12:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800c14:	85 f6                	test   %esi,%esi
  800c16:	75 1a                	jne    800c32 <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800c18:	83 ec 08             	sub    $0x8,%esp
  800c1b:	68 18 15 80 00       	push   $0x801518
  800c20:	68 80 14 80 00       	push   $0x801480
  800c25:	e8 18 f9 ff ff       	call   800542 <cprintf>
  800c2a:	83 c4 10             	add    $0x10,%esp
  800c2d:	e9 c7 fb ff ff       	jmp    8007f9 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800c32:	0f b6 03             	movzbl (%ebx),%eax
  800c35:	84 c0                	test   %al,%al
  800c37:	79 1f                	jns    800c58 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800c39:	83 ec 08             	sub    $0x8,%esp
  800c3c:	68 50 15 80 00       	push   $0x801550
  800c41:	68 80 14 80 00       	push   $0x801480
  800c46:	e8 f7 f8 ff ff       	call   800542 <cprintf>
						*tmp = *(char *)putdat;
  800c4b:	0f b6 03             	movzbl (%ebx),%eax
  800c4e:	88 06                	mov    %al,(%esi)
  800c50:	83 c4 10             	add    $0x10,%esp
  800c53:	e9 a1 fb ff ff       	jmp    8007f9 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800c58:	88 06                	mov    %al,(%esi)
  800c5a:	e9 9a fb ff ff       	jmp    8007f9 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c5f:	83 ec 08             	sub    $0x8,%esp
  800c62:	53                   	push   %ebx
  800c63:	52                   	push   %edx
  800c64:	ff d7                	call   *%edi
			break;
  800c66:	83 c4 10             	add    $0x10,%esp
  800c69:	e9 8b fb ff ff       	jmp    8007f9 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c6e:	83 ec 08             	sub    $0x8,%esp
  800c71:	53                   	push   %ebx
  800c72:	6a 25                	push   $0x25
  800c74:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c76:	83 c4 10             	add    $0x10,%esp
  800c79:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c7d:	0f 84 73 fb ff ff    	je     8007f6 <vprintfmt+0x11>
  800c83:	83 ee 01             	sub    $0x1,%esi
  800c86:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c8a:	75 f7                	jne    800c83 <vprintfmt+0x49e>
  800c8c:	89 75 10             	mov    %esi,0x10(%ebp)
  800c8f:	e9 65 fb ff ff       	jmp    8007f9 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c94:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800c97:	8d 70 01             	lea    0x1(%eax),%esi
  800c9a:	0f b6 00             	movzbl (%eax),%eax
  800c9d:	0f be d0             	movsbl %al,%edx
  800ca0:	85 d2                	test   %edx,%edx
  800ca2:	0f 85 cf fd ff ff    	jne    800a77 <vprintfmt+0x292>
  800ca8:	e9 4c fb ff ff       	jmp    8007f9 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800cad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	83 ec 18             	sub    $0x18,%esp
  800cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbe:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cc1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cc4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800cc8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ccb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cd2:	85 c0                	test   %eax,%eax
  800cd4:	74 26                	je     800cfc <vsnprintf+0x47>
  800cd6:	85 d2                	test   %edx,%edx
  800cd8:	7e 22                	jle    800cfc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cda:	ff 75 14             	pushl  0x14(%ebp)
  800cdd:	ff 75 10             	pushl  0x10(%ebp)
  800ce0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ce3:	50                   	push   %eax
  800ce4:	68 ab 07 80 00       	push   $0x8007ab
  800ce9:	e8 f7 fa ff ff       	call   8007e5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cf1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cf7:	83 c4 10             	add    $0x10,%esp
  800cfa:	eb 05                	jmp    800d01 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cfc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d01:	c9                   	leave  
  800d02:	c3                   	ret    

00800d03 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d09:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d0c:	50                   	push   %eax
  800d0d:	ff 75 10             	pushl  0x10(%ebp)
  800d10:	ff 75 0c             	pushl  0xc(%ebp)
  800d13:	ff 75 08             	pushl  0x8(%ebp)
  800d16:	e8 9a ff ff ff       	call   800cb5 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d1b:	c9                   	leave  
  800d1c:	c3                   	ret    

00800d1d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d23:	80 3a 00             	cmpb   $0x0,(%edx)
  800d26:	74 10                	je     800d38 <strlen+0x1b>
  800d28:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800d2d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d30:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d34:	75 f7                	jne    800d2d <strlen+0x10>
  800d36:	eb 05                	jmp    800d3d <strlen+0x20>
  800d38:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	53                   	push   %ebx
  800d43:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d49:	85 c9                	test   %ecx,%ecx
  800d4b:	74 1c                	je     800d69 <strnlen+0x2a>
  800d4d:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d50:	74 1e                	je     800d70 <strnlen+0x31>
  800d52:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800d57:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d59:	39 ca                	cmp    %ecx,%edx
  800d5b:	74 18                	je     800d75 <strnlen+0x36>
  800d5d:	83 c2 01             	add    $0x1,%edx
  800d60:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800d65:	75 f0                	jne    800d57 <strnlen+0x18>
  800d67:	eb 0c                	jmp    800d75 <strnlen+0x36>
  800d69:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6e:	eb 05                	jmp    800d75 <strnlen+0x36>
  800d70:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d75:	5b                   	pop    %ebx
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	53                   	push   %ebx
  800d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d82:	89 c2                	mov    %eax,%edx
  800d84:	83 c2 01             	add    $0x1,%edx
  800d87:	83 c1 01             	add    $0x1,%ecx
  800d8a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d8e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d91:	84 db                	test   %bl,%bl
  800d93:	75 ef                	jne    800d84 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d95:	5b                   	pop    %ebx
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	53                   	push   %ebx
  800d9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d9f:	53                   	push   %ebx
  800da0:	e8 78 ff ff ff       	call   800d1d <strlen>
  800da5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800da8:	ff 75 0c             	pushl  0xc(%ebp)
  800dab:	01 d8                	add    %ebx,%eax
  800dad:	50                   	push   %eax
  800dae:	e8 c5 ff ff ff       	call   800d78 <strcpy>
	return dst;
}
  800db3:	89 d8                	mov    %ebx,%eax
  800db5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800db8:	c9                   	leave  
  800db9:	c3                   	ret    

00800dba <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	56                   	push   %esi
  800dbe:	53                   	push   %ebx
  800dbf:	8b 75 08             	mov    0x8(%ebp),%esi
  800dc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dc8:	85 db                	test   %ebx,%ebx
  800dca:	74 17                	je     800de3 <strncpy+0x29>
  800dcc:	01 f3                	add    %esi,%ebx
  800dce:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800dd0:	83 c1 01             	add    $0x1,%ecx
  800dd3:	0f b6 02             	movzbl (%edx),%eax
  800dd6:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800dd9:	80 3a 01             	cmpb   $0x1,(%edx)
  800ddc:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ddf:	39 cb                	cmp    %ecx,%ebx
  800de1:	75 ed                	jne    800dd0 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800de3:	89 f0                	mov    %esi,%eax
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	56                   	push   %esi
  800ded:	53                   	push   %ebx
  800dee:	8b 75 08             	mov    0x8(%ebp),%esi
  800df1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800df4:	8b 55 10             	mov    0x10(%ebp),%edx
  800df7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800df9:	85 d2                	test   %edx,%edx
  800dfb:	74 35                	je     800e32 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800dfd:	89 d0                	mov    %edx,%eax
  800dff:	83 e8 01             	sub    $0x1,%eax
  800e02:	74 25                	je     800e29 <strlcpy+0x40>
  800e04:	0f b6 0b             	movzbl (%ebx),%ecx
  800e07:	84 c9                	test   %cl,%cl
  800e09:	74 22                	je     800e2d <strlcpy+0x44>
  800e0b:	8d 53 01             	lea    0x1(%ebx),%edx
  800e0e:	01 c3                	add    %eax,%ebx
  800e10:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800e12:	83 c0 01             	add    $0x1,%eax
  800e15:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e18:	39 da                	cmp    %ebx,%edx
  800e1a:	74 13                	je     800e2f <strlcpy+0x46>
  800e1c:	83 c2 01             	add    $0x1,%edx
  800e1f:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800e23:	84 c9                	test   %cl,%cl
  800e25:	75 eb                	jne    800e12 <strlcpy+0x29>
  800e27:	eb 06                	jmp    800e2f <strlcpy+0x46>
  800e29:	89 f0                	mov    %esi,%eax
  800e2b:	eb 02                	jmp    800e2f <strlcpy+0x46>
  800e2d:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e2f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e32:	29 f0                	sub    %esi,%eax
}
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    

00800e38 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e41:	0f b6 01             	movzbl (%ecx),%eax
  800e44:	84 c0                	test   %al,%al
  800e46:	74 15                	je     800e5d <strcmp+0x25>
  800e48:	3a 02                	cmp    (%edx),%al
  800e4a:	75 11                	jne    800e5d <strcmp+0x25>
		p++, q++;
  800e4c:	83 c1 01             	add    $0x1,%ecx
  800e4f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e52:	0f b6 01             	movzbl (%ecx),%eax
  800e55:	84 c0                	test   %al,%al
  800e57:	74 04                	je     800e5d <strcmp+0x25>
  800e59:	3a 02                	cmp    (%edx),%al
  800e5b:	74 ef                	je     800e4c <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e5d:	0f b6 c0             	movzbl %al,%eax
  800e60:	0f b6 12             	movzbl (%edx),%edx
  800e63:	29 d0                	sub    %edx,%eax
}
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	56                   	push   %esi
  800e6b:	53                   	push   %ebx
  800e6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e72:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800e75:	85 f6                	test   %esi,%esi
  800e77:	74 29                	je     800ea2 <strncmp+0x3b>
  800e79:	0f b6 03             	movzbl (%ebx),%eax
  800e7c:	84 c0                	test   %al,%al
  800e7e:	74 30                	je     800eb0 <strncmp+0x49>
  800e80:	3a 02                	cmp    (%edx),%al
  800e82:	75 2c                	jne    800eb0 <strncmp+0x49>
  800e84:	8d 43 01             	lea    0x1(%ebx),%eax
  800e87:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800e89:	89 c3                	mov    %eax,%ebx
  800e8b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e8e:	39 c6                	cmp    %eax,%esi
  800e90:	74 17                	je     800ea9 <strncmp+0x42>
  800e92:	0f b6 08             	movzbl (%eax),%ecx
  800e95:	84 c9                	test   %cl,%cl
  800e97:	74 17                	je     800eb0 <strncmp+0x49>
  800e99:	83 c0 01             	add    $0x1,%eax
  800e9c:	3a 0a                	cmp    (%edx),%cl
  800e9e:	74 e9                	je     800e89 <strncmp+0x22>
  800ea0:	eb 0e                	jmp    800eb0 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ea2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea7:	eb 0f                	jmp    800eb8 <strncmp+0x51>
  800ea9:	b8 00 00 00 00       	mov    $0x0,%eax
  800eae:	eb 08                	jmp    800eb8 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800eb0:	0f b6 03             	movzbl (%ebx),%eax
  800eb3:	0f b6 12             	movzbl (%edx),%edx
  800eb6:	29 d0                	sub    %edx,%eax
}
  800eb8:	5b                   	pop    %ebx
  800eb9:	5e                   	pop    %esi
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	53                   	push   %ebx
  800ec0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800ec6:	0f b6 10             	movzbl (%eax),%edx
  800ec9:	84 d2                	test   %dl,%dl
  800ecb:	74 1d                	je     800eea <strchr+0x2e>
  800ecd:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800ecf:	38 d3                	cmp    %dl,%bl
  800ed1:	75 06                	jne    800ed9 <strchr+0x1d>
  800ed3:	eb 1a                	jmp    800eef <strchr+0x33>
  800ed5:	38 ca                	cmp    %cl,%dl
  800ed7:	74 16                	je     800eef <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ed9:	83 c0 01             	add    $0x1,%eax
  800edc:	0f b6 10             	movzbl (%eax),%edx
  800edf:	84 d2                	test   %dl,%dl
  800ee1:	75 f2                	jne    800ed5 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800ee3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee8:	eb 05                	jmp    800eef <strchr+0x33>
  800eea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eef:	5b                   	pop    %ebx
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    

00800ef2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	53                   	push   %ebx
  800ef6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef9:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800efc:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800eff:	38 d3                	cmp    %dl,%bl
  800f01:	74 14                	je     800f17 <strfind+0x25>
  800f03:	89 d1                	mov    %edx,%ecx
  800f05:	84 db                	test   %bl,%bl
  800f07:	74 0e                	je     800f17 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f09:	83 c0 01             	add    $0x1,%eax
  800f0c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800f0f:	38 ca                	cmp    %cl,%dl
  800f11:	74 04                	je     800f17 <strfind+0x25>
  800f13:	84 d2                	test   %dl,%dl
  800f15:	75 f2                	jne    800f09 <strfind+0x17>
			break;
	return (char *) s;
}
  800f17:	5b                   	pop    %ebx
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	57                   	push   %edi
  800f1e:	56                   	push   %esi
  800f1f:	53                   	push   %ebx
  800f20:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f23:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f26:	85 c9                	test   %ecx,%ecx
  800f28:	74 36                	je     800f60 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f2a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f30:	75 28                	jne    800f5a <memset+0x40>
  800f32:	f6 c1 03             	test   $0x3,%cl
  800f35:	75 23                	jne    800f5a <memset+0x40>
		c &= 0xFF;
  800f37:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f3b:	89 d3                	mov    %edx,%ebx
  800f3d:	c1 e3 08             	shl    $0x8,%ebx
  800f40:	89 d6                	mov    %edx,%esi
  800f42:	c1 e6 18             	shl    $0x18,%esi
  800f45:	89 d0                	mov    %edx,%eax
  800f47:	c1 e0 10             	shl    $0x10,%eax
  800f4a:	09 f0                	or     %esi,%eax
  800f4c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f4e:	89 d8                	mov    %ebx,%eax
  800f50:	09 d0                	or     %edx,%eax
  800f52:	c1 e9 02             	shr    $0x2,%ecx
  800f55:	fc                   	cld    
  800f56:	f3 ab                	rep stos %eax,%es:(%edi)
  800f58:	eb 06                	jmp    800f60 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f5d:	fc                   	cld    
  800f5e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f60:	89 f8                	mov    %edi,%eax
  800f62:	5b                   	pop    %ebx
  800f63:	5e                   	pop    %esi
  800f64:	5f                   	pop    %edi
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    

00800f67 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	57                   	push   %edi
  800f6b:	56                   	push   %esi
  800f6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f72:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f75:	39 c6                	cmp    %eax,%esi
  800f77:	73 35                	jae    800fae <memmove+0x47>
  800f79:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f7c:	39 d0                	cmp    %edx,%eax
  800f7e:	73 2e                	jae    800fae <memmove+0x47>
		s += n;
		d += n;
  800f80:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f83:	89 d6                	mov    %edx,%esi
  800f85:	09 fe                	or     %edi,%esi
  800f87:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f8d:	75 13                	jne    800fa2 <memmove+0x3b>
  800f8f:	f6 c1 03             	test   $0x3,%cl
  800f92:	75 0e                	jne    800fa2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800f94:	83 ef 04             	sub    $0x4,%edi
  800f97:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f9a:	c1 e9 02             	shr    $0x2,%ecx
  800f9d:	fd                   	std    
  800f9e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fa0:	eb 09                	jmp    800fab <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fa2:	83 ef 01             	sub    $0x1,%edi
  800fa5:	8d 72 ff             	lea    -0x1(%edx),%esi
  800fa8:	fd                   	std    
  800fa9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fab:	fc                   	cld    
  800fac:	eb 1d                	jmp    800fcb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fae:	89 f2                	mov    %esi,%edx
  800fb0:	09 c2                	or     %eax,%edx
  800fb2:	f6 c2 03             	test   $0x3,%dl
  800fb5:	75 0f                	jne    800fc6 <memmove+0x5f>
  800fb7:	f6 c1 03             	test   $0x3,%cl
  800fba:	75 0a                	jne    800fc6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800fbc:	c1 e9 02             	shr    $0x2,%ecx
  800fbf:	89 c7                	mov    %eax,%edi
  800fc1:	fc                   	cld    
  800fc2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fc4:	eb 05                	jmp    800fcb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fc6:	89 c7                	mov    %eax,%edi
  800fc8:	fc                   	cld    
  800fc9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fcb:	5e                   	pop    %esi
  800fcc:	5f                   	pop    %edi
  800fcd:	5d                   	pop    %ebp
  800fce:	c3                   	ret    

00800fcf <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800fd2:	ff 75 10             	pushl  0x10(%ebp)
  800fd5:	ff 75 0c             	pushl  0xc(%ebp)
  800fd8:	ff 75 08             	pushl  0x8(%ebp)
  800fdb:	e8 87 ff ff ff       	call   800f67 <memmove>
}
  800fe0:	c9                   	leave  
  800fe1:	c3                   	ret    

00800fe2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	57                   	push   %edi
  800fe6:	56                   	push   %esi
  800fe7:	53                   	push   %ebx
  800fe8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800feb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fee:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	74 39                	je     80102e <memcmp+0x4c>
  800ff5:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800ff8:	0f b6 13             	movzbl (%ebx),%edx
  800ffb:	0f b6 0e             	movzbl (%esi),%ecx
  800ffe:	38 ca                	cmp    %cl,%dl
  801000:	75 17                	jne    801019 <memcmp+0x37>
  801002:	b8 00 00 00 00       	mov    $0x0,%eax
  801007:	eb 1a                	jmp    801023 <memcmp+0x41>
  801009:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  80100e:	83 c0 01             	add    $0x1,%eax
  801011:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  801015:	38 ca                	cmp    %cl,%dl
  801017:	74 0a                	je     801023 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  801019:	0f b6 c2             	movzbl %dl,%eax
  80101c:	0f b6 c9             	movzbl %cl,%ecx
  80101f:	29 c8                	sub    %ecx,%eax
  801021:	eb 10                	jmp    801033 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801023:	39 f8                	cmp    %edi,%eax
  801025:	75 e2                	jne    801009 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801027:	b8 00 00 00 00       	mov    $0x0,%eax
  80102c:	eb 05                	jmp    801033 <memcmp+0x51>
  80102e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801033:	5b                   	pop    %ebx
  801034:	5e                   	pop    %esi
  801035:	5f                   	pop    %edi
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    

00801038 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	53                   	push   %ebx
  80103c:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  80103f:	89 d0                	mov    %edx,%eax
  801041:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  801044:	39 c2                	cmp    %eax,%edx
  801046:	73 1d                	jae    801065 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  801048:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  80104c:	0f b6 0a             	movzbl (%edx),%ecx
  80104f:	39 d9                	cmp    %ebx,%ecx
  801051:	75 09                	jne    80105c <memfind+0x24>
  801053:	eb 14                	jmp    801069 <memfind+0x31>
  801055:	0f b6 0a             	movzbl (%edx),%ecx
  801058:	39 d9                	cmp    %ebx,%ecx
  80105a:	74 11                	je     80106d <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80105c:	83 c2 01             	add    $0x1,%edx
  80105f:	39 d0                	cmp    %edx,%eax
  801061:	75 f2                	jne    801055 <memfind+0x1d>
  801063:	eb 0a                	jmp    80106f <memfind+0x37>
  801065:	89 d0                	mov    %edx,%eax
  801067:	eb 06                	jmp    80106f <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  801069:	89 d0                	mov    %edx,%eax
  80106b:	eb 02                	jmp    80106f <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80106d:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80106f:	5b                   	pop    %ebx
  801070:	5d                   	pop    %ebp
  801071:	c3                   	ret    

00801072 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	57                   	push   %edi
  801076:	56                   	push   %esi
  801077:	53                   	push   %ebx
  801078:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80107b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80107e:	0f b6 01             	movzbl (%ecx),%eax
  801081:	3c 20                	cmp    $0x20,%al
  801083:	74 04                	je     801089 <strtol+0x17>
  801085:	3c 09                	cmp    $0x9,%al
  801087:	75 0e                	jne    801097 <strtol+0x25>
		s++;
  801089:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80108c:	0f b6 01             	movzbl (%ecx),%eax
  80108f:	3c 20                	cmp    $0x20,%al
  801091:	74 f6                	je     801089 <strtol+0x17>
  801093:	3c 09                	cmp    $0x9,%al
  801095:	74 f2                	je     801089 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  801097:	3c 2b                	cmp    $0x2b,%al
  801099:	75 0a                	jne    8010a5 <strtol+0x33>
		s++;
  80109b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80109e:	bf 00 00 00 00       	mov    $0x0,%edi
  8010a3:	eb 11                	jmp    8010b6 <strtol+0x44>
  8010a5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8010aa:	3c 2d                	cmp    $0x2d,%al
  8010ac:	75 08                	jne    8010b6 <strtol+0x44>
		s++, neg = 1;
  8010ae:	83 c1 01             	add    $0x1,%ecx
  8010b1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010b6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8010bc:	75 15                	jne    8010d3 <strtol+0x61>
  8010be:	80 39 30             	cmpb   $0x30,(%ecx)
  8010c1:	75 10                	jne    8010d3 <strtol+0x61>
  8010c3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8010c7:	75 7c                	jne    801145 <strtol+0xd3>
		s += 2, base = 16;
  8010c9:	83 c1 02             	add    $0x2,%ecx
  8010cc:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010d1:	eb 16                	jmp    8010e9 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  8010d3:	85 db                	test   %ebx,%ebx
  8010d5:	75 12                	jne    8010e9 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010d7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010dc:	80 39 30             	cmpb   $0x30,(%ecx)
  8010df:	75 08                	jne    8010e9 <strtol+0x77>
		s++, base = 8;
  8010e1:	83 c1 01             	add    $0x1,%ecx
  8010e4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8010e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ee:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010f1:	0f b6 11             	movzbl (%ecx),%edx
  8010f4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010f7:	89 f3                	mov    %esi,%ebx
  8010f9:	80 fb 09             	cmp    $0x9,%bl
  8010fc:	77 08                	ja     801106 <strtol+0x94>
			dig = *s - '0';
  8010fe:	0f be d2             	movsbl %dl,%edx
  801101:	83 ea 30             	sub    $0x30,%edx
  801104:	eb 22                	jmp    801128 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  801106:	8d 72 9f             	lea    -0x61(%edx),%esi
  801109:	89 f3                	mov    %esi,%ebx
  80110b:	80 fb 19             	cmp    $0x19,%bl
  80110e:	77 08                	ja     801118 <strtol+0xa6>
			dig = *s - 'a' + 10;
  801110:	0f be d2             	movsbl %dl,%edx
  801113:	83 ea 57             	sub    $0x57,%edx
  801116:	eb 10                	jmp    801128 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  801118:	8d 72 bf             	lea    -0x41(%edx),%esi
  80111b:	89 f3                	mov    %esi,%ebx
  80111d:	80 fb 19             	cmp    $0x19,%bl
  801120:	77 16                	ja     801138 <strtol+0xc6>
			dig = *s - 'A' + 10;
  801122:	0f be d2             	movsbl %dl,%edx
  801125:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801128:	3b 55 10             	cmp    0x10(%ebp),%edx
  80112b:	7d 0b                	jge    801138 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  80112d:	83 c1 01             	add    $0x1,%ecx
  801130:	0f af 45 10          	imul   0x10(%ebp),%eax
  801134:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801136:	eb b9                	jmp    8010f1 <strtol+0x7f>

	if (endptr)
  801138:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80113c:	74 0d                	je     80114b <strtol+0xd9>
		*endptr = (char *) s;
  80113e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801141:	89 0e                	mov    %ecx,(%esi)
  801143:	eb 06                	jmp    80114b <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801145:	85 db                	test   %ebx,%ebx
  801147:	74 98                	je     8010e1 <strtol+0x6f>
  801149:	eb 9e                	jmp    8010e9 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80114b:	89 c2                	mov    %eax,%edx
  80114d:	f7 da                	neg    %edx
  80114f:	85 ff                	test   %edi,%edi
  801151:	0f 45 c2             	cmovne %edx,%eax
}
  801154:	5b                   	pop    %ebx
  801155:	5e                   	pop    %esi
  801156:	5f                   	pop    %edi
  801157:	5d                   	pop    %ebp
  801158:	c3                   	ret    
  801159:	66 90                	xchg   %ax,%ax
  80115b:	66 90                	xchg   %ax,%ax
  80115d:	66 90                	xchg   %ax,%ax
  80115f:	90                   	nop

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
