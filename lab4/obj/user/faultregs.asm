
obj/user/faultregs:     file format elf32-i386


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
  80002c:	e8 60 05 00 00       	call   800591 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 f1 19 80 00       	push   $0x8019f1
  800049:	68 c0 19 80 00       	push   $0x8019c0
  80004e:	e8 89 06 00 00       	call   8006dc <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 d0 19 80 00       	push   $0x8019d0
  80005c:	68 d4 19 80 00       	push   $0x8019d4
  800061:	e8 76 06 00 00       	call   8006dc <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 e4 19 80 00       	push   $0x8019e4
  800077:	e8 60 06 00 00       	call   8006dc <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 e8 19 80 00       	push   $0x8019e8
  80008e:	e8 49 06 00 00       	call   8006dc <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 f2 19 80 00       	push   $0x8019f2
  8000a6:	68 d4 19 80 00       	push   $0x8019d4
  8000ab:	e8 2c 06 00 00       	call   8006dc <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 e4 19 80 00       	push   $0x8019e4
  8000c3:	e8 14 06 00 00       	call   8006dc <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 e8 19 80 00       	push   $0x8019e8
  8000d5:	e8 02 06 00 00       	call   8006dc <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 f6 19 80 00       	push   $0x8019f6
  8000ed:	68 d4 19 80 00       	push   $0x8019d4
  8000f2:	e8 e5 05 00 00       	call   8006dc <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 e4 19 80 00       	push   $0x8019e4
  80010a:	e8 cd 05 00 00       	call   8006dc <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 e8 19 80 00       	push   $0x8019e8
  80011c:	e8 bb 05 00 00       	call   8006dc <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 fa 19 80 00       	push   $0x8019fa
  800134:	68 d4 19 80 00       	push   $0x8019d4
  800139:	e8 9e 05 00 00       	call   8006dc <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 e4 19 80 00       	push   $0x8019e4
  800151:	e8 86 05 00 00       	call   8006dc <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 e8 19 80 00       	push   $0x8019e8
  800163:	e8 74 05 00 00       	call   8006dc <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 fe 19 80 00       	push   $0x8019fe
  80017b:	68 d4 19 80 00       	push   $0x8019d4
  800180:	e8 57 05 00 00       	call   8006dc <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 e4 19 80 00       	push   $0x8019e4
  800198:	e8 3f 05 00 00       	call   8006dc <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 e8 19 80 00       	push   $0x8019e8
  8001aa:	e8 2d 05 00 00       	call   8006dc <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 02 1a 80 00       	push   $0x801a02
  8001c2:	68 d4 19 80 00       	push   $0x8019d4
  8001c7:	e8 10 05 00 00       	call   8006dc <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 e4 19 80 00       	push   $0x8019e4
  8001df:	e8 f8 04 00 00       	call   8006dc <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 e8 19 80 00       	push   $0x8019e8
  8001f1:	e8 e6 04 00 00       	call   8006dc <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 06 1a 80 00       	push   $0x801a06
  800209:	68 d4 19 80 00       	push   $0x8019d4
  80020e:	e8 c9 04 00 00       	call   8006dc <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 e4 19 80 00       	push   $0x8019e4
  800226:	e8 b1 04 00 00       	call   8006dc <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 e8 19 80 00       	push   $0x8019e8
  800238:	e8 9f 04 00 00       	call   8006dc <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 0a 1a 80 00       	push   $0x801a0a
  800250:	68 d4 19 80 00       	push   $0x8019d4
  800255:	e8 82 04 00 00       	call   8006dc <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 e4 19 80 00       	push   $0x8019e4
  80026d:	e8 6a 04 00 00       	call   8006dc <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 e8 19 80 00       	push   $0x8019e8
  80027f:	e8 58 04 00 00       	call   8006dc <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 0e 1a 80 00       	push   $0x801a0e
  800297:	68 d4 19 80 00       	push   $0x8019d4
  80029c:	e8 3b 04 00 00       	call   8006dc <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 e4 19 80 00       	push   $0x8019e4
  8002b4:	e8 23 04 00 00       	call   8006dc <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 15 1a 80 00       	push   $0x801a15
  8002c4:	68 d4 19 80 00       	push   $0x8019d4
  8002c9:	e8 0e 04 00 00       	call   8006dc <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	74 31                	je     80030a <check_regs+0x2d7>
  8002d9:	eb 55                	jmp    800330 <check_regs+0x2fd>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 e8 19 80 00       	push   $0x8019e8
  8002e3:	e8 f4 03 00 00       	call   8006dc <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 15 1a 80 00       	push   $0x801a15
  8002f3:	68 d4 19 80 00       	push   $0x8019d4
  8002f8:	e8 df 03 00 00       	call   8006dc <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 e4 19 80 00       	push   $0x8019e4
  800312:	e8 c5 03 00 00       	call   8006dc <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 19 1a 80 00       	push   $0x801a19
  800322:	e8 b5 03 00 00       	call   8006dc <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 e8 19 80 00       	push   $0x8019e8
  800338:	e8 9f 03 00 00       	call   8006dc <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 19 1a 80 00       	push   $0x801a19
  800348:	e8 8f 03 00 00       	call   8006dc <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 e4 19 80 00       	push   $0x8019e4
  80035a:	e8 7d 03 00 00       	call   8006dc <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 e8 19 80 00       	push   $0x8019e8
  80036c:	e8 6b 03 00 00       	call   8006dc <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 e4 19 80 00       	push   $0x8019e4
  80037e:	e8 59 03 00 00       	call   8006dc <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 19 1a 80 00       	push   $0x801a19
  80038e:	e8 49 03 00 00       	call   8006dc <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 80 1a 80 00       	push   $0x801a80
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 27 1a 80 00       	push   $0x801a27
  8003c6:	e8 1e 02 00 00       	call   8005e9 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 60 20 80 00    	mov    %edx,0x802060
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 64 20 80 00    	mov    %edx,0x802064
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 68 20 80 00    	mov    %edx,0x802068
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 70 20 80 00    	mov    %edx,0x802070
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 74 20 80 00    	mov    %edx,0x802074
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 78 20 80 00    	mov    %edx,0x802078
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  800425:	8b 40 30             	mov    0x30(%eax),%eax
  800428:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	68 3f 1a 80 00       	push   $0x801a3f
  800435:	68 4d 1a 80 00       	push   $0x801a4d
  80043a:	b9 60 20 80 00       	mov    $0x802060,%ecx
  80043f:	ba 38 1a 80 00       	mov    $0x801a38,%edx
  800444:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  800449:	e8 e5 fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  80044e:	83 c4 0c             	add    $0xc,%esp
  800451:	6a 07                	push   $0x7
  800453:	68 00 00 40 00       	push   $0x400000
  800458:	6a 00                	push   $0x0
  80045a:	e8 da 0f 00 00       	call   801439 <sys_page_alloc>
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	85 c0                	test   %eax,%eax
  800464:	79 12                	jns    800478 <pgfault+0xd8>
		panic("sys_page_alloc: %e", r);
  800466:	50                   	push   %eax
  800467:	68 54 1a 80 00       	push   $0x801a54
  80046c:	6a 5c                	push   $0x5c
  80046e:	68 27 1a 80 00       	push   $0x801a27
  800473:	e8 71 01 00 00       	call   8005e9 <_panic>
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <umain>:

void
umain(int argc, char **argv)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800480:	68 a0 03 80 00       	push   $0x8003a0
  800485:	e8 19 12 00 00       	call   8016a3 <set_pgfault_handler>

	__asm __volatile(
  80048a:	50                   	push   %eax
  80048b:	9c                   	pushf  
  80048c:	58                   	pop    %eax
  80048d:	0d d5 08 00 00       	or     $0x8d5,%eax
  800492:	50                   	push   %eax
  800493:	9d                   	popf   
  800494:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  800499:	8d 05 d4 04 80 00    	lea    0x8004d4,%eax
  80049f:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  8004a4:	58                   	pop    %eax
  8004a5:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8004ab:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  8004b1:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  8004b7:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  8004bd:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  8004c3:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  8004c9:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  8004ce:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  8004d4:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004db:	00 00 00 
  8004de:	89 3d 20 20 80 00    	mov    %edi,0x802020
  8004e4:	89 35 24 20 80 00    	mov    %esi,0x802024
  8004ea:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  8004f0:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  8004f6:	89 15 34 20 80 00    	mov    %edx,0x802034
  8004fc:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800502:	a3 3c 20 80 00       	mov    %eax,0x80203c
  800507:	89 25 48 20 80 00    	mov    %esp,0x802048
  80050d:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  800513:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  800519:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  80051f:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  800525:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  80052b:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  800531:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  800536:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  80053c:	50                   	push   %eax
  80053d:	9c                   	pushf  
  80053e:	58                   	pop    %eax
  80053f:	a3 44 20 80 00       	mov    %eax,0x802044
  800544:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80054f:	74 10                	je     800561 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	68 b4 1a 80 00       	push   $0x801ab4
  800559:	e8 7e 01 00 00       	call   8006dc <cprintf>
  80055e:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800561:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  800566:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	68 67 1a 80 00       	push   $0x801a67
  800573:	68 78 1a 80 00       	push   $0x801a78
  800578:	b9 20 20 80 00       	mov    $0x802020,%ecx
  80057d:	ba 38 1a 80 00       	mov    $0x801a38,%edx
  800582:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  800587:	e8 a7 fa ff ff       	call   800033 <check_regs>
}
  80058c:	83 c4 10             	add    $0x10,%esp
  80058f:	c9                   	leave  
  800590:	c3                   	ret    

00800591 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800591:	55                   	push   %ebp
  800592:	89 e5                	mov    %esp,%ebp
  800594:	56                   	push   %esi
  800595:	53                   	push   %ebx
  800596:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800599:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80059c:	e8 03 0e 00 00       	call   8013a4 <sys_getenvid>
  8005a1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005a6:	c1 e0 07             	shl    $0x7,%eax
  8005a9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005ae:	a3 d4 20 80 00       	mov    %eax,0x8020d4

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005b3:	85 db                	test   %ebx,%ebx
  8005b5:	7e 07                	jle    8005be <libmain+0x2d>
		binaryname = argv[0];
  8005b7:	8b 06                	mov    (%esi),%eax
  8005b9:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	56                   	push   %esi
  8005c2:	53                   	push   %ebx
  8005c3:	e8 b2 fe ff ff       	call   80047a <umain>

	// exit gracefully
	exit();
  8005c8:	e8 0a 00 00 00       	call   8005d7 <exit>
}
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005d3:	5b                   	pop    %ebx
  8005d4:	5e                   	pop    %esi
  8005d5:	5d                   	pop    %ebp
  8005d6:	c3                   	ret    

008005d7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005d7:	55                   	push   %ebp
  8005d8:	89 e5                	mov    %esp,%ebp
  8005da:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8005dd:	6a 00                	push   $0x0
  8005df:	e8 70 0d 00 00       	call   801354 <sys_env_destroy>
}
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	c9                   	leave  
  8005e8:	c3                   	ret    

008005e9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005e9:	55                   	push   %ebp
  8005ea:	89 e5                	mov    %esp,%ebp
  8005ec:	56                   	push   %esi
  8005ed:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005ee:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  8005f1:	a1 d8 20 80 00       	mov    0x8020d8,%eax
  8005f6:	85 c0                	test   %eax,%eax
  8005f8:	74 11                	je     80060b <_panic+0x22>
		cprintf("%s: ", argv0);
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	50                   	push   %eax
  8005fe:	68 dd 1a 80 00       	push   $0x801add
  800603:	e8 d4 00 00 00       	call   8006dc <cprintf>
  800608:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80060b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800611:	e8 8e 0d 00 00       	call   8013a4 <sys_getenvid>
  800616:	83 ec 0c             	sub    $0xc,%esp
  800619:	ff 75 0c             	pushl  0xc(%ebp)
  80061c:	ff 75 08             	pushl  0x8(%ebp)
  80061f:	56                   	push   %esi
  800620:	50                   	push   %eax
  800621:	68 e4 1a 80 00       	push   $0x801ae4
  800626:	e8 b1 00 00 00       	call   8006dc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80062b:	83 c4 18             	add    $0x18,%esp
  80062e:	53                   	push   %ebx
  80062f:	ff 75 10             	pushl  0x10(%ebp)
  800632:	e8 54 00 00 00       	call   80068b <vcprintf>
	cprintf("\n");
  800637:	c7 04 24 f0 19 80 00 	movl   $0x8019f0,(%esp)
  80063e:	e8 99 00 00 00       	call   8006dc <cprintf>
  800643:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800646:	cc                   	int3   
  800647:	eb fd                	jmp    800646 <_panic+0x5d>

00800649 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800649:	55                   	push   %ebp
  80064a:	89 e5                	mov    %esp,%ebp
  80064c:	53                   	push   %ebx
  80064d:	83 ec 04             	sub    $0x4,%esp
  800650:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800653:	8b 13                	mov    (%ebx),%edx
  800655:	8d 42 01             	lea    0x1(%edx),%eax
  800658:	89 03                	mov    %eax,(%ebx)
  80065a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80065d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800661:	3d ff 00 00 00       	cmp    $0xff,%eax
  800666:	75 1a                	jne    800682 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	68 ff 00 00 00       	push   $0xff
  800670:	8d 43 08             	lea    0x8(%ebx),%eax
  800673:	50                   	push   %eax
  800674:	e8 7a 0c 00 00       	call   8012f3 <sys_cputs>
		b->idx = 0;
  800679:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80067f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800682:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800686:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800689:	c9                   	leave  
  80068a:	c3                   	ret    

0080068b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80068b:	55                   	push   %ebp
  80068c:	89 e5                	mov    %esp,%ebp
  80068e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800694:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80069b:	00 00 00 
	b.cnt = 0;
  80069e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006a5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006a8:	ff 75 0c             	pushl  0xc(%ebp)
  8006ab:	ff 75 08             	pushl  0x8(%ebp)
  8006ae:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006b4:	50                   	push   %eax
  8006b5:	68 49 06 80 00       	push   $0x800649
  8006ba:	e8 c0 02 00 00       	call   80097f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006bf:	83 c4 08             	add    $0x8,%esp
  8006c2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006c8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006ce:	50                   	push   %eax
  8006cf:	e8 1f 0c 00 00       	call   8012f3 <sys_cputs>

	return b.cnt;
}
  8006d4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006da:	c9                   	leave  
  8006db:	c3                   	ret    

008006dc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006e2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006e5:	50                   	push   %eax
  8006e6:	ff 75 08             	pushl  0x8(%ebp)
  8006e9:	e8 9d ff ff ff       	call   80068b <vcprintf>
	va_end(ap);

	return cnt;
}
  8006ee:	c9                   	leave  
  8006ef:	c3                   	ret    

008006f0 <printnum>:
static int judge_time_for_space = 0;
static int num_of_space = 0;
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	57                   	push   %edi
  8006f4:	56                   	push   %esi
  8006f5:	53                   	push   %ebx
  8006f6:	83 ec 1c             	sub    $0x1c,%esp
  8006f9:	89 c7                	mov    %eax,%edi
  8006fb:	89 d6                	mov    %edx,%esi
  8006fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800700:	8b 55 0c             	mov    0xc(%ebp),%edx
  800703:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800706:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800709:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-' && width > judge_time_for_space) {
  80070c:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800710:	0f 85 bf 00 00 00    	jne    8007d5 <printnum+0xe5>
  800716:	39 1d d0 20 80 00    	cmp    %ebx,0x8020d0
  80071c:	0f 8d de 00 00 00    	jge    800800 <printnum+0x110>
		judge_time_for_space = width;
  800722:	89 1d d0 20 80 00    	mov    %ebx,0x8020d0
  800728:	e9 d3 00 00 00       	jmp    800800 <printnum+0x110>
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  80072d:	83 eb 01             	sub    $0x1,%ebx
  800730:	85 db                	test   %ebx,%ebx
  800732:	7f 37                	jg     80076b <printnum+0x7b>
  800734:	e9 ea 00 00 00       	jmp    800823 <printnum+0x133>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
  800739:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80073c:	a3 cc 20 80 00       	mov    %eax,0x8020cc
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	56                   	push   %esi
  800745:	83 ec 04             	sub    $0x4,%esp
  800748:	ff 75 dc             	pushl  -0x24(%ebp)
  80074b:	ff 75 d8             	pushl  -0x28(%ebp)
  80074e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800751:	ff 75 e0             	pushl  -0x20(%ebp)
  800754:	e8 f7 10 00 00       	call   801850 <__umoddi3>
  800759:	83 c4 14             	add    $0x14,%esp
  80075c:	0f be 80 07 1b 80 00 	movsbl 0x801b07(%eax),%eax
  800763:	50                   	push   %eax
  800764:	ff d7                	call   *%edi
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	eb 16                	jmp    800781 <printnum+0x91>
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
				putch(padc, putdat);
  80076b:	83 ec 08             	sub    $0x8,%esp
  80076e:	56                   	push   %esi
  80076f:	ff 75 18             	pushl  0x18(%ebp)
  800772:	ff d7                	call   *%edi
	} else {
		// print any needed pad characters before first digit
		if (padc == '-') {
			num_of_space = width - 1;
		} else {
			while (--width > 0)
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	83 eb 01             	sub    $0x1,%ebx
  80077a:	75 ef                	jne    80076b <printnum+0x7b>
  80077c:	e9 a2 00 00 00       	jmp    800823 <printnum+0x133>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
  800781:	3b 1d d0 20 80 00    	cmp    0x8020d0,%ebx
  800787:	0f 85 76 01 00 00    	jne    800903 <printnum+0x213>
		while(num_of_space-- > 0)
  80078d:	a1 cc 20 80 00       	mov    0x8020cc,%eax
  800792:	8d 50 ff             	lea    -0x1(%eax),%edx
  800795:	89 15 cc 20 80 00    	mov    %edx,0x8020cc
  80079b:	85 c0                	test   %eax,%eax
  80079d:	7e 1d                	jle    8007bc <printnum+0xcc>
			putch(' ', putdat);
  80079f:	83 ec 08             	sub    $0x8,%esp
  8007a2:	56                   	push   %esi
  8007a3:	6a 20                	push   $0x20
  8007a5:	ff d7                	call   *%edi

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
	// judge if it is time to put space
	if (padc == '-' && width == judge_time_for_space) {
		while(num_of_space-- > 0)
  8007a7:	a1 cc 20 80 00       	mov    0x8020cc,%eax
  8007ac:	8d 50 ff             	lea    -0x1(%eax),%edx
  8007af:	89 15 cc 20 80 00    	mov    %edx,0x8020cc
  8007b5:	83 c4 10             	add    $0x10,%esp
  8007b8:	85 c0                	test   %eax,%eax
  8007ba:	7f e3                	jg     80079f <printnum+0xaf>
			putch(' ', putdat);
		num_of_space = 0;
  8007bc:	c7 05 cc 20 80 00 00 	movl   $0x0,0x8020cc
  8007c3:	00 00 00 
		judge_time_for_space = 0;
  8007c6:	c7 05 d0 20 80 00 00 	movl   $0x0,0x8020d0
  8007cd:	00 00 00 
	}
}
  8007d0:	e9 2e 01 00 00       	jmp    800903 <printnum+0x213>
	if (padc == '-' && width > judge_time_for_space) {
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8007d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007e9:	83 fa 00             	cmp    $0x0,%edx
  8007ec:	0f 87 ba 00 00 00    	ja     8008ac <printnum+0x1bc>
  8007f2:	3b 45 10             	cmp    0x10(%ebp),%eax
  8007f5:	0f 83 b1 00 00 00    	jae    8008ac <printnum+0x1bc>
  8007fb:	e9 2d ff ff ff       	jmp    80072d <printnum+0x3d>
  800800:	8b 45 10             	mov    0x10(%ebp),%eax
  800803:	ba 00 00 00 00       	mov    $0x0,%edx
  800808:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80080b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80080e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800811:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800814:	83 fa 00             	cmp    $0x0,%edx
  800817:	77 37                	ja     800850 <printnum+0x160>
  800819:	3b 45 10             	cmp    0x10(%ebp),%eax
  80081c:	73 32                	jae    800850 <printnum+0x160>
  80081e:	e9 16 ff ff ff       	jmp    800739 <printnum+0x49>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800823:	83 ec 08             	sub    $0x8,%esp
  800826:	56                   	push   %esi
  800827:	83 ec 04             	sub    $0x4,%esp
  80082a:	ff 75 dc             	pushl  -0x24(%ebp)
  80082d:	ff 75 d8             	pushl  -0x28(%ebp)
  800830:	ff 75 e4             	pushl  -0x1c(%ebp)
  800833:	ff 75 e0             	pushl  -0x20(%ebp)
  800836:	e8 15 10 00 00       	call   801850 <__umoddi3>
  80083b:	83 c4 14             	add    $0x14,%esp
  80083e:	0f be 80 07 1b 80 00 	movsbl 0x801b07(%eax),%eax
  800845:	50                   	push   %eax
  800846:	ff d7                	call   *%edi
  800848:	83 c4 10             	add    $0x10,%esp
  80084b:	e9 b3 00 00 00       	jmp    800903 <printnum+0x213>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800850:	83 ec 0c             	sub    $0xc,%esp
  800853:	ff 75 18             	pushl  0x18(%ebp)
  800856:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800859:	50                   	push   %eax
  80085a:	ff 75 10             	pushl  0x10(%ebp)
  80085d:	83 ec 08             	sub    $0x8,%esp
  800860:	ff 75 dc             	pushl  -0x24(%ebp)
  800863:	ff 75 d8             	pushl  -0x28(%ebp)
  800866:	ff 75 e4             	pushl  -0x1c(%ebp)
  800869:	ff 75 e0             	pushl  -0x20(%ebp)
  80086c:	e8 af 0e 00 00       	call   801720 <__udivdi3>
  800871:	83 c4 18             	add    $0x18,%esp
  800874:	52                   	push   %edx
  800875:	50                   	push   %eax
  800876:	89 f2                	mov    %esi,%edx
  800878:	89 f8                	mov    %edi,%eax
  80087a:	e8 71 fe ff ff       	call   8006f0 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80087f:	83 c4 18             	add    $0x18,%esp
  800882:	56                   	push   %esi
  800883:	83 ec 04             	sub    $0x4,%esp
  800886:	ff 75 dc             	pushl  -0x24(%ebp)
  800889:	ff 75 d8             	pushl  -0x28(%ebp)
  80088c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80088f:	ff 75 e0             	pushl  -0x20(%ebp)
  800892:	e8 b9 0f 00 00       	call   801850 <__umoddi3>
  800897:	83 c4 14             	add    $0x14,%esp
  80089a:	0f be 80 07 1b 80 00 	movsbl 0x801b07(%eax),%eax
  8008a1:	50                   	push   %eax
  8008a2:	ff d7                	call   *%edi
  8008a4:	83 c4 10             	add    $0x10,%esp
  8008a7:	e9 d5 fe ff ff       	jmp    800781 <printnum+0x91>
		judge_time_for_space = width;
	}

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8008ac:	83 ec 0c             	sub    $0xc,%esp
  8008af:	ff 75 18             	pushl  0x18(%ebp)
  8008b2:	83 eb 01             	sub    $0x1,%ebx
  8008b5:	53                   	push   %ebx
  8008b6:	ff 75 10             	pushl  0x10(%ebp)
  8008b9:	83 ec 08             	sub    $0x8,%esp
  8008bc:	ff 75 dc             	pushl  -0x24(%ebp)
  8008bf:	ff 75 d8             	pushl  -0x28(%ebp)
  8008c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8008c8:	e8 53 0e 00 00       	call   801720 <__udivdi3>
  8008cd:	83 c4 18             	add    $0x18,%esp
  8008d0:	52                   	push   %edx
  8008d1:	50                   	push   %eax
  8008d2:	89 f2                	mov    %esi,%edx
  8008d4:	89 f8                	mov    %edi,%eax
  8008d6:	e8 15 fe ff ff       	call   8006f0 <printnum>
				putch(padc, putdat);
		}
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8008db:	83 c4 18             	add    $0x18,%esp
  8008de:	56                   	push   %esi
  8008df:	83 ec 04             	sub    $0x4,%esp
  8008e2:	ff 75 dc             	pushl  -0x24(%ebp)
  8008e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8008e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8008ee:	e8 5d 0f 00 00       	call   801850 <__umoddi3>
  8008f3:	83 c4 14             	add    $0x14,%esp
  8008f6:	0f be 80 07 1b 80 00 	movsbl 0x801b07(%eax),%eax
  8008fd:	50                   	push   %eax
  8008fe:	ff d7                	call   *%edi
  800900:	83 c4 10             	add    $0x10,%esp
		while(num_of_space-- > 0)
			putch(' ', putdat);
		num_of_space = 0;
		judge_time_for_space = 0;
	}
}
  800903:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5f                   	pop    %edi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80090e:	83 fa 01             	cmp    $0x1,%edx
  800911:	7e 0e                	jle    800921 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800913:	8b 10                	mov    (%eax),%edx
  800915:	8d 4a 08             	lea    0x8(%edx),%ecx
  800918:	89 08                	mov    %ecx,(%eax)
  80091a:	8b 02                	mov    (%edx),%eax
  80091c:	8b 52 04             	mov    0x4(%edx),%edx
  80091f:	eb 22                	jmp    800943 <getuint+0x38>
	else if (lflag)
  800921:	85 d2                	test   %edx,%edx
  800923:	74 10                	je     800935 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800925:	8b 10                	mov    (%eax),%edx
  800927:	8d 4a 04             	lea    0x4(%edx),%ecx
  80092a:	89 08                	mov    %ecx,(%eax)
  80092c:	8b 02                	mov    (%edx),%eax
  80092e:	ba 00 00 00 00       	mov    $0x0,%edx
  800933:	eb 0e                	jmp    800943 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800935:	8b 10                	mov    (%eax),%edx
  800937:	8d 4a 04             	lea    0x4(%edx),%ecx
  80093a:	89 08                	mov    %ecx,(%eax)
  80093c:	8b 02                	mov    (%edx),%eax
  80093e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80094b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80094f:	8b 10                	mov    (%eax),%edx
  800951:	3b 50 04             	cmp    0x4(%eax),%edx
  800954:	73 0a                	jae    800960 <sprintputch+0x1b>
		*b->buf++ = ch;
  800956:	8d 4a 01             	lea    0x1(%edx),%ecx
  800959:	89 08                	mov    %ecx,(%eax)
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	88 02                	mov    %al,(%edx)
}
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800968:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80096b:	50                   	push   %eax
  80096c:	ff 75 10             	pushl  0x10(%ebp)
  80096f:	ff 75 0c             	pushl  0xc(%ebp)
  800972:	ff 75 08             	pushl  0x8(%ebp)
  800975:	e8 05 00 00 00       	call   80097f <vprintfmt>
	va_end(ap);
}
  80097a:	83 c4 10             	add    $0x10,%esp
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	57                   	push   %edi
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	83 ec 2c             	sub    $0x2c,%esp
  800988:	8b 7d 08             	mov    0x8(%ebp),%edi
  80098b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80098e:	eb 03                	jmp    800993 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800990:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800993:	8b 45 10             	mov    0x10(%ebp),%eax
  800996:	8d 70 01             	lea    0x1(%eax),%esi
  800999:	0f b6 00             	movzbl (%eax),%eax
  80099c:	83 f8 25             	cmp    $0x25,%eax
  80099f:	74 27                	je     8009c8 <vprintfmt+0x49>
			if (ch == '\0')
  8009a1:	85 c0                	test   %eax,%eax
  8009a3:	75 0d                	jne    8009b2 <vprintfmt+0x33>
  8009a5:	e9 9d 04 00 00       	jmp    800e47 <vprintfmt+0x4c8>
  8009aa:	85 c0                	test   %eax,%eax
  8009ac:	0f 84 95 04 00 00    	je     800e47 <vprintfmt+0x4c8>
				return;
			putch(ch, putdat);
  8009b2:	83 ec 08             	sub    $0x8,%esp
  8009b5:	53                   	push   %ebx
  8009b6:	50                   	push   %eax
  8009b7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8009b9:	83 c6 01             	add    $0x1,%esi
  8009bc:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8009c0:	83 c4 10             	add    $0x10,%esp
  8009c3:	83 f8 25             	cmp    $0x25,%eax
  8009c6:	75 e2                	jne    8009aa <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8009c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009cd:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8009d1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8009d8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8009df:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8009e6:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8009ed:	eb 08                	jmp    8009f7 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ef:	8b 75 10             	mov    0x10(%ebp),%esi
		// Exercise 9: support for the "+" flag
		case '+':
			plusflag = 1;
  8009f2:	b9 01 00 00 00       	mov    $0x1,%ecx
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009f7:	8d 46 01             	lea    0x1(%esi),%eax
  8009fa:	89 45 10             	mov    %eax,0x10(%ebp)
  8009fd:	0f b6 06             	movzbl (%esi),%eax
  800a00:	0f b6 d0             	movzbl %al,%edx
  800a03:	83 e8 23             	sub    $0x23,%eax
  800a06:	3c 55                	cmp    $0x55,%al
  800a08:	0f 87 fa 03 00 00    	ja     800e08 <vprintfmt+0x489>
  800a0e:	0f b6 c0             	movzbl %al,%eax
  800a11:	ff 24 85 40 1c 80 00 	jmp    *0x801c40(,%eax,4)
  800a18:	8b 75 10             	mov    0x10(%ebp),%esi
			plusflag = 1;
			goto reswitch;

		// flag to pad on the right
		case '-':
			padc = '-';
  800a1b:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800a1f:	eb d6                	jmp    8009f7 <vprintfmt+0x78>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800a21:	8d 42 d0             	lea    -0x30(%edx),%eax
  800a24:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800a27:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800a2b:	8d 50 d0             	lea    -0x30(%eax),%edx
  800a2e:	83 fa 09             	cmp    $0x9,%edx
  800a31:	77 6b                	ja     800a9e <vprintfmt+0x11f>
  800a33:	8b 75 10             	mov    0x10(%ebp),%esi
  800a36:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a39:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800a3c:	eb 09                	jmp    800a47 <vprintfmt+0xc8>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a3e:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a41:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800a45:	eb b0                	jmp    8009f7 <vprintfmt+0x78>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800a47:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800a4a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800a4d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800a51:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800a54:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800a57:	83 f9 09             	cmp    $0x9,%ecx
  800a5a:	76 eb                	jbe    800a47 <vprintfmt+0xc8>
  800a5c:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800a5f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800a62:	eb 3d                	jmp    800aa1 <vprintfmt+0x122>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800a64:	8b 45 14             	mov    0x14(%ebp),%eax
  800a67:	8d 50 04             	lea    0x4(%eax),%edx
  800a6a:	89 55 14             	mov    %edx,0x14(%ebp)
  800a6d:	8b 00                	mov    (%eax),%eax
  800a6f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a72:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800a75:	eb 2a                	jmp    800aa1 <vprintfmt+0x122>
  800a77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a7a:	85 c0                	test   %eax,%eax
  800a7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a81:	0f 49 d0             	cmovns %eax,%edx
  800a84:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a87:	8b 75 10             	mov    0x10(%ebp),%esi
  800a8a:	e9 68 ff ff ff       	jmp    8009f7 <vprintfmt+0x78>
  800a8f:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800a92:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800a99:	e9 59 ff ff ff       	jmp    8009f7 <vprintfmt+0x78>
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a9e:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800aa1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800aa5:	0f 89 4c ff ff ff    	jns    8009f7 <vprintfmt+0x78>
				width = precision, precision = -1;
  800aab:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800aae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ab1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800ab8:	e9 3a ff ff ff       	jmp    8009f7 <vprintfmt+0x78>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800abd:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		lflag = 0;
		altflag = 0;
		// Exercise 9: support for the "+" flag
		int plusflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ac1:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800ac4:	e9 2e ff ff ff       	jmp    8009f7 <vprintfmt+0x78>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800ac9:	8b 45 14             	mov    0x14(%ebp),%eax
  800acc:	8d 50 04             	lea    0x4(%eax),%edx
  800acf:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad2:	83 ec 08             	sub    $0x8,%esp
  800ad5:	53                   	push   %ebx
  800ad6:	ff 30                	pushl  (%eax)
  800ad8:	ff d7                	call   *%edi
			break;
  800ada:	83 c4 10             	add    $0x10,%esp
  800add:	e9 b1 fe ff ff       	jmp    800993 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800ae2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae5:	8d 50 04             	lea    0x4(%eax),%edx
  800ae8:	89 55 14             	mov    %edx,0x14(%ebp)
  800aeb:	8b 00                	mov    (%eax),%eax
  800aed:	99                   	cltd   
  800aee:	31 d0                	xor    %edx,%eax
  800af0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800af2:	83 f8 08             	cmp    $0x8,%eax
  800af5:	7f 0b                	jg     800b02 <vprintfmt+0x183>
  800af7:	8b 14 85 a0 1d 80 00 	mov    0x801da0(,%eax,4),%edx
  800afe:	85 d2                	test   %edx,%edx
  800b00:	75 15                	jne    800b17 <vprintfmt+0x198>
				printfmt(putch, putdat, "error %d", err);
  800b02:	50                   	push   %eax
  800b03:	68 1f 1b 80 00       	push   $0x801b1f
  800b08:	53                   	push   %ebx
  800b09:	57                   	push   %edi
  800b0a:	e8 53 fe ff ff       	call   800962 <printfmt>
  800b0f:	83 c4 10             	add    $0x10,%esp
  800b12:	e9 7c fe ff ff       	jmp    800993 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800b17:	52                   	push   %edx
  800b18:	68 28 1b 80 00       	push   $0x801b28
  800b1d:	53                   	push   %ebx
  800b1e:	57                   	push   %edi
  800b1f:	e8 3e fe ff ff       	call   800962 <printfmt>
  800b24:	83 c4 10             	add    $0x10,%esp
  800b27:	e9 67 fe ff ff       	jmp    800993 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800b2c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2f:	8d 50 04             	lea    0x4(%eax),%edx
  800b32:	89 55 14             	mov    %edx,0x14(%ebp)
  800b35:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800b37:	85 c0                	test   %eax,%eax
  800b39:	b9 18 1b 80 00       	mov    $0x801b18,%ecx
  800b3e:	0f 45 c8             	cmovne %eax,%ecx
  800b41:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800b44:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b48:	7e 06                	jle    800b50 <vprintfmt+0x1d1>
  800b4a:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800b4e:	75 19                	jne    800b69 <vprintfmt+0x1ea>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b50:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800b53:	8d 70 01             	lea    0x1(%eax),%esi
  800b56:	0f b6 00             	movzbl (%eax),%eax
  800b59:	0f be d0             	movsbl %al,%edx
  800b5c:	85 d2                	test   %edx,%edx
  800b5e:	0f 85 9f 00 00 00    	jne    800c03 <vprintfmt+0x284>
  800b64:	e9 8c 00 00 00       	jmp    800bf5 <vprintfmt+0x276>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b69:	83 ec 08             	sub    $0x8,%esp
  800b6c:	ff 75 d0             	pushl  -0x30(%ebp)
  800b6f:	ff 75 cc             	pushl  -0x34(%ebp)
  800b72:	e8 62 03 00 00       	call   800ed9 <strnlen>
  800b77:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800b7a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800b7d:	83 c4 10             	add    $0x10,%esp
  800b80:	85 c9                	test   %ecx,%ecx
  800b82:	0f 8e a6 02 00 00    	jle    800e2e <vprintfmt+0x4af>
					putch(padc, putdat);
  800b88:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800b8c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800b8f:	89 cb                	mov    %ecx,%ebx
  800b91:	83 ec 08             	sub    $0x8,%esp
  800b94:	ff 75 0c             	pushl  0xc(%ebp)
  800b97:	56                   	push   %esi
  800b98:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b9a:	83 c4 10             	add    $0x10,%esp
  800b9d:	83 eb 01             	sub    $0x1,%ebx
  800ba0:	75 ef                	jne    800b91 <vprintfmt+0x212>
  800ba2:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800ba5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ba8:	e9 81 02 00 00       	jmp    800e2e <vprintfmt+0x4af>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800bad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800bb1:	74 1b                	je     800bce <vprintfmt+0x24f>
  800bb3:	0f be c0             	movsbl %al,%eax
  800bb6:	83 e8 20             	sub    $0x20,%eax
  800bb9:	83 f8 5e             	cmp    $0x5e,%eax
  800bbc:	76 10                	jbe    800bce <vprintfmt+0x24f>
					putch('?', putdat);
  800bbe:	83 ec 08             	sub    $0x8,%esp
  800bc1:	ff 75 0c             	pushl  0xc(%ebp)
  800bc4:	6a 3f                	push   $0x3f
  800bc6:	ff 55 08             	call   *0x8(%ebp)
  800bc9:	83 c4 10             	add    $0x10,%esp
  800bcc:	eb 0d                	jmp    800bdb <vprintfmt+0x25c>
				else
					putch(ch, putdat);
  800bce:	83 ec 08             	sub    $0x8,%esp
  800bd1:	ff 75 0c             	pushl  0xc(%ebp)
  800bd4:	52                   	push   %edx
  800bd5:	ff 55 08             	call   *0x8(%ebp)
  800bd8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bdb:	83 ef 01             	sub    $0x1,%edi
  800bde:	83 c6 01             	add    $0x1,%esi
  800be1:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800be5:	0f be d0             	movsbl %al,%edx
  800be8:	85 d2                	test   %edx,%edx
  800bea:	75 31                	jne    800c1d <vprintfmt+0x29e>
  800bec:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800bef:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bf2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bf5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800bf8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800bfc:	7f 33                	jg     800c31 <vprintfmt+0x2b2>
  800bfe:	e9 90 fd ff ff       	jmp    800993 <vprintfmt+0x14>
  800c03:	89 7d 08             	mov    %edi,0x8(%ebp)
  800c06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c09:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800c0c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800c0f:	eb 0c                	jmp    800c1d <vprintfmt+0x29e>
  800c11:	89 7d 08             	mov    %edi,0x8(%ebp)
  800c14:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c17:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800c1a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c1d:	85 db                	test   %ebx,%ebx
  800c1f:	78 8c                	js     800bad <vprintfmt+0x22e>
  800c21:	83 eb 01             	sub    $0x1,%ebx
  800c24:	79 87                	jns    800bad <vprintfmt+0x22e>
  800c26:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800c29:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c2f:	eb c4                	jmp    800bf5 <vprintfmt+0x276>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800c31:	83 ec 08             	sub    $0x8,%esp
  800c34:	53                   	push   %ebx
  800c35:	6a 20                	push   $0x20
  800c37:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800c39:	83 c4 10             	add    $0x10,%esp
  800c3c:	83 ee 01             	sub    $0x1,%esi
  800c3f:	75 f0                	jne    800c31 <vprintfmt+0x2b2>
  800c41:	e9 4d fd ff ff       	jmp    800993 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c46:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800c4a:	7e 16                	jle    800c62 <vprintfmt+0x2e3>
		return va_arg(*ap, long long);
  800c4c:	8b 45 14             	mov    0x14(%ebp),%eax
  800c4f:	8d 50 08             	lea    0x8(%eax),%edx
  800c52:	89 55 14             	mov    %edx,0x14(%ebp)
  800c55:	8b 50 04             	mov    0x4(%eax),%edx
  800c58:	8b 00                	mov    (%eax),%eax
  800c5a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800c5d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800c60:	eb 34                	jmp    800c96 <vprintfmt+0x317>
	else if (lflag)
  800c62:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800c66:	74 18                	je     800c80 <vprintfmt+0x301>
		return va_arg(*ap, long);
  800c68:	8b 45 14             	mov    0x14(%ebp),%eax
  800c6b:	8d 50 04             	lea    0x4(%eax),%edx
  800c6e:	89 55 14             	mov    %edx,0x14(%ebp)
  800c71:	8b 30                	mov    (%eax),%esi
  800c73:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800c76:	89 f0                	mov    %esi,%eax
  800c78:	c1 f8 1f             	sar    $0x1f,%eax
  800c7b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800c7e:	eb 16                	jmp    800c96 <vprintfmt+0x317>
	else
		return va_arg(*ap, int);
  800c80:	8b 45 14             	mov    0x14(%ebp),%eax
  800c83:	8d 50 04             	lea    0x4(%eax),%edx
  800c86:	89 55 14             	mov    %edx,0x14(%ebp)
  800c89:	8b 30                	mov    (%eax),%esi
  800c8b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800c8e:	89 f0                	mov    %esi,%eax
  800c90:	c1 f8 1f             	sar    $0x1f,%eax
  800c93:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c96:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800c99:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800c9c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c9f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800ca2:	85 d2                	test   %edx,%edx
  800ca4:	79 28                	jns    800cce <vprintfmt+0x34f>
				putch('-', putdat);
  800ca6:	83 ec 08             	sub    $0x8,%esp
  800ca9:	53                   	push   %ebx
  800caa:	6a 2d                	push   $0x2d
  800cac:	ff d7                	call   *%edi
				num = -(long long) num;
  800cae:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800cb1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800cb4:	f7 d8                	neg    %eax
  800cb6:	83 d2 00             	adc    $0x0,%edx
  800cb9:	f7 da                	neg    %edx
  800cbb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800cbe:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800cc1:	83 c4 10             	add    $0x10,%esp
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
				putch('+', putdat);
				plusflag = 0;
			}
			base = 10;
  800cc4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc9:	e9 b2 00 00 00       	jmp    800d80 <vprintfmt+0x401>
  800cce:	b8 0a 00 00 00       	mov    $0xa,%eax
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			} else if (plusflag) {	// Exercise 9: support for the "+" flag
  800cd3:	85 c9                	test   %ecx,%ecx
  800cd5:	0f 84 a5 00 00 00    	je     800d80 <vprintfmt+0x401>
				putch('+', putdat);
  800cdb:	83 ec 08             	sub    $0x8,%esp
  800cde:	53                   	push   %ebx
  800cdf:	6a 2b                	push   $0x2b
  800ce1:	ff d7                	call   *%edi
  800ce3:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
			}
			base = 10;
  800ce6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ceb:	e9 90 00 00 00       	jmp    800d80 <vprintfmt+0x401>
			goto number;

		// unsigned decimal
		case 'u':
			if (plusflag) {	// Exercise 9: support for the "+" flag
  800cf0:	85 c9                	test   %ecx,%ecx
  800cf2:	74 0b                	je     800cff <vprintfmt+0x380>
				putch('+', putdat);
  800cf4:	83 ec 08             	sub    $0x8,%esp
  800cf7:	53                   	push   %ebx
  800cf8:	6a 2b                	push   $0x2b
  800cfa:	ff d7                	call   *%edi
  800cfc:	83 c4 10             	add    $0x10,%esp
				plusflag = 0;
		  }
			num = getuint(&ap, lflag);
  800cff:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800d02:	8d 45 14             	lea    0x14(%ebp),%eax
  800d05:	e8 01 fc ff ff       	call   80090b <getuint>
  800d0a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d0d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800d10:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800d15:	eb 69                	jmp    800d80 <vprintfmt+0x401>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
  800d17:	83 ec 08             	sub    $0x8,%esp
  800d1a:	53                   	push   %ebx
  800d1b:	6a 30                	push   $0x30
  800d1d:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800d1f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800d22:	8d 45 14             	lea    0x14(%ebp),%eax
  800d25:	e8 e1 fb ff ff       	call   80090b <getuint>
  800d2a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d2d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800d30:	83 c4 10             	add    $0x10,%esp
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			// Exercise 8
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800d33:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800d38:	eb 46                	jmp    800d80 <vprintfmt+0x401>
			// putch('X', putdat);
			// break;

		// pointer
		case 'p':
			putch('0', putdat);
  800d3a:	83 ec 08             	sub    $0x8,%esp
  800d3d:	53                   	push   %ebx
  800d3e:	6a 30                	push   $0x30
  800d40:	ff d7                	call   *%edi
			putch('x', putdat);
  800d42:	83 c4 08             	add    $0x8,%esp
  800d45:	53                   	push   %ebx
  800d46:	6a 78                	push   $0x78
  800d48:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800d4a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d4d:	8d 50 04             	lea    0x4(%eax),%edx
  800d50:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800d53:	8b 00                	mov    (%eax),%eax
  800d55:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d5d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800d60:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800d63:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800d68:	eb 16                	jmp    800d80 <vprintfmt+0x401>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800d6a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800d6d:	8d 45 14             	lea    0x14(%ebp),%eax
  800d70:	e8 96 fb ff ff       	call   80090b <getuint>
  800d75:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d78:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800d7b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800d87:	56                   	push   %esi
  800d88:	ff 75 e4             	pushl  -0x1c(%ebp)
  800d8b:	50                   	push   %eax
  800d8c:	ff 75 dc             	pushl  -0x24(%ebp)
  800d8f:	ff 75 d8             	pushl  -0x28(%ebp)
  800d92:	89 da                	mov    %ebx,%edx
  800d94:	89 f8                	mov    %edi,%eax
  800d96:	e8 55 f9 ff ff       	call   8006f0 <printnum>
			break;
  800d9b:	83 c4 20             	add    $0x20,%esp
  800d9e:	e9 f0 fb ff ff       	jmp    800993 <vprintfmt+0x14>
          const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
          const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

          // Your code here
					// cprintf("n: %d\n", *(char *)putdat);
					char *tmp = va_arg(ap, char *);	// The parameter is va_list ap, not va_list *ap
  800da3:	8b 45 14             	mov    0x14(%ebp),%eax
  800da6:	8d 50 04             	lea    0x4(%eax),%edx
  800da9:	89 55 14             	mov    %edx,0x14(%ebp)
  800dac:	8b 30                	mov    (%eax),%esi
					if (!tmp) {
  800dae:	85 f6                	test   %esi,%esi
  800db0:	75 1a                	jne    800dcc <vprintfmt+0x44d>
						cprintf("%s", null_error);
  800db2:	83 ec 08             	sub    $0x8,%esp
  800db5:	68 c0 1b 80 00       	push   $0x801bc0
  800dba:	68 28 1b 80 00       	push   $0x801b28
  800dbf:	e8 18 f9 ff ff       	call   8006dc <cprintf>
  800dc4:	83 c4 10             	add    $0x10,%esp
  800dc7:	e9 c7 fb ff ff       	jmp    800993 <vprintfmt+0x14>
					} else if ((*(char *)putdat) & 0x80) {
  800dcc:	0f b6 03             	movzbl (%ebx),%eax
  800dcf:	84 c0                	test   %al,%al
  800dd1:	79 1f                	jns    800df2 <vprintfmt+0x473>
						cprintf("%s", overflow_error);
  800dd3:	83 ec 08             	sub    $0x8,%esp
  800dd6:	68 f8 1b 80 00       	push   $0x801bf8
  800ddb:	68 28 1b 80 00       	push   $0x801b28
  800de0:	e8 f7 f8 ff ff       	call   8006dc <cprintf>
						*tmp = *(char *)putdat;
  800de5:	0f b6 03             	movzbl (%ebx),%eax
  800de8:	88 06                	mov    %al,(%esi)
  800dea:	83 c4 10             	add    $0x10,%esp
  800ded:	e9 a1 fb ff ff       	jmp    800993 <vprintfmt+0x14>
					} else {
						*tmp = *(char *)putdat;
  800df2:	88 06                	mov    %al,(%esi)
  800df4:	e9 9a fb ff ff       	jmp    800993 <vprintfmt+0x14>
          break;
      }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800df9:	83 ec 08             	sub    $0x8,%esp
  800dfc:	53                   	push   %ebx
  800dfd:	52                   	push   %edx
  800dfe:	ff d7                	call   *%edi
			break;
  800e00:	83 c4 10             	add    $0x10,%esp
  800e03:	e9 8b fb ff ff       	jmp    800993 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800e08:	83 ec 08             	sub    $0x8,%esp
  800e0b:	53                   	push   %ebx
  800e0c:	6a 25                	push   $0x25
  800e0e:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800e10:	83 c4 10             	add    $0x10,%esp
  800e13:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800e17:	0f 84 73 fb ff ff    	je     800990 <vprintfmt+0x11>
  800e1d:	83 ee 01             	sub    $0x1,%esi
  800e20:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800e24:	75 f7                	jne    800e1d <vprintfmt+0x49e>
  800e26:	89 75 10             	mov    %esi,0x10(%ebp)
  800e29:	e9 65 fb ff ff       	jmp    800993 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e2e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800e31:	8d 70 01             	lea    0x1(%eax),%esi
  800e34:	0f b6 00             	movzbl (%eax),%eax
  800e37:	0f be d0             	movsbl %al,%edx
  800e3a:	85 d2                	test   %edx,%edx
  800e3c:	0f 85 cf fd ff ff    	jne    800c11 <vprintfmt+0x292>
  800e42:	e9 4c fb ff ff       	jmp    800993 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800e47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4a:	5b                   	pop    %ebx
  800e4b:	5e                   	pop    %esi
  800e4c:	5f                   	pop    %edi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	83 ec 18             	sub    $0x18,%esp
  800e55:	8b 45 08             	mov    0x8(%ebp),%eax
  800e58:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800e5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e5e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800e62:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800e65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	74 26                	je     800e96 <vsnprintf+0x47>
  800e70:	85 d2                	test   %edx,%edx
  800e72:	7e 22                	jle    800e96 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800e74:	ff 75 14             	pushl  0x14(%ebp)
  800e77:	ff 75 10             	pushl  0x10(%ebp)
  800e7a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800e7d:	50                   	push   %eax
  800e7e:	68 45 09 80 00       	push   $0x800945
  800e83:	e8 f7 fa ff ff       	call   80097f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800e88:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e8b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e91:	83 c4 10             	add    $0x10,%esp
  800e94:	eb 05                	jmp    800e9b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800e96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800e9b:	c9                   	leave  
  800e9c:	c3                   	ret    

00800e9d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ea3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ea6:	50                   	push   %eax
  800ea7:	ff 75 10             	pushl  0x10(%ebp)
  800eaa:	ff 75 0c             	pushl  0xc(%ebp)
  800ead:	ff 75 08             	pushl  0x8(%ebp)
  800eb0:	e8 9a ff ff ff       	call   800e4f <vsnprintf>
	va_end(ap);

	return rc;
}
  800eb5:	c9                   	leave  
  800eb6:	c3                   	ret    

00800eb7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ebd:	80 3a 00             	cmpb   $0x0,(%edx)
  800ec0:	74 10                	je     800ed2 <strlen+0x1b>
  800ec2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ec7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800eca:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ece:	75 f7                	jne    800ec7 <strlen+0x10>
  800ed0:	eb 05                	jmp    800ed7 <strlen+0x20>
  800ed2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    

00800ed9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	53                   	push   %ebx
  800edd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ee0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ee3:	85 c9                	test   %ecx,%ecx
  800ee5:	74 1c                	je     800f03 <strnlen+0x2a>
  800ee7:	80 3b 00             	cmpb   $0x0,(%ebx)
  800eea:	74 1e                	je     800f0a <strnlen+0x31>
  800eec:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800ef1:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ef3:	39 ca                	cmp    %ecx,%edx
  800ef5:	74 18                	je     800f0f <strnlen+0x36>
  800ef7:	83 c2 01             	add    $0x1,%edx
  800efa:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800eff:	75 f0                	jne    800ef1 <strnlen+0x18>
  800f01:	eb 0c                	jmp    800f0f <strnlen+0x36>
  800f03:	b8 00 00 00 00       	mov    $0x0,%eax
  800f08:	eb 05                	jmp    800f0f <strnlen+0x36>
  800f0a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800f0f:	5b                   	pop    %ebx
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    

00800f12 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	53                   	push   %ebx
  800f16:	8b 45 08             	mov    0x8(%ebp),%eax
  800f19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800f1c:	89 c2                	mov    %eax,%edx
  800f1e:	83 c2 01             	add    $0x1,%edx
  800f21:	83 c1 01             	add    $0x1,%ecx
  800f24:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800f28:	88 5a ff             	mov    %bl,-0x1(%edx)
  800f2b:	84 db                	test   %bl,%bl
  800f2d:	75 ef                	jne    800f1e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800f2f:	5b                   	pop    %ebx
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    

00800f32 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	53                   	push   %ebx
  800f36:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800f39:	53                   	push   %ebx
  800f3a:	e8 78 ff ff ff       	call   800eb7 <strlen>
  800f3f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800f42:	ff 75 0c             	pushl  0xc(%ebp)
  800f45:	01 d8                	add    %ebx,%eax
  800f47:	50                   	push   %eax
  800f48:	e8 c5 ff ff ff       	call   800f12 <strcpy>
	return dst;
}
  800f4d:	89 d8                	mov    %ebx,%eax
  800f4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f52:	c9                   	leave  
  800f53:	c3                   	ret    

00800f54 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	56                   	push   %esi
  800f58:	53                   	push   %ebx
  800f59:	8b 75 08             	mov    0x8(%ebp),%esi
  800f5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f62:	85 db                	test   %ebx,%ebx
  800f64:	74 17                	je     800f7d <strncpy+0x29>
  800f66:	01 f3                	add    %esi,%ebx
  800f68:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800f6a:	83 c1 01             	add    $0x1,%ecx
  800f6d:	0f b6 02             	movzbl (%edx),%eax
  800f70:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800f73:	80 3a 01             	cmpb   $0x1,(%edx)
  800f76:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f79:	39 cb                	cmp    %ecx,%ebx
  800f7b:	75 ed                	jne    800f6a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800f7d:	89 f0                	mov    %esi,%eax
  800f7f:	5b                   	pop    %ebx
  800f80:	5e                   	pop    %esi
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    

00800f83 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	56                   	push   %esi
  800f87:	53                   	push   %ebx
  800f88:	8b 75 08             	mov    0x8(%ebp),%esi
  800f8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f8e:	8b 55 10             	mov    0x10(%ebp),%edx
  800f91:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800f93:	85 d2                	test   %edx,%edx
  800f95:	74 35                	je     800fcc <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800f97:	89 d0                	mov    %edx,%eax
  800f99:	83 e8 01             	sub    $0x1,%eax
  800f9c:	74 25                	je     800fc3 <strlcpy+0x40>
  800f9e:	0f b6 0b             	movzbl (%ebx),%ecx
  800fa1:	84 c9                	test   %cl,%cl
  800fa3:	74 22                	je     800fc7 <strlcpy+0x44>
  800fa5:	8d 53 01             	lea    0x1(%ebx),%edx
  800fa8:	01 c3                	add    %eax,%ebx
  800faa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800fac:	83 c0 01             	add    $0x1,%eax
  800faf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800fb2:	39 da                	cmp    %ebx,%edx
  800fb4:	74 13                	je     800fc9 <strlcpy+0x46>
  800fb6:	83 c2 01             	add    $0x1,%edx
  800fb9:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800fbd:	84 c9                	test   %cl,%cl
  800fbf:	75 eb                	jne    800fac <strlcpy+0x29>
  800fc1:	eb 06                	jmp    800fc9 <strlcpy+0x46>
  800fc3:	89 f0                	mov    %esi,%eax
  800fc5:	eb 02                	jmp    800fc9 <strlcpy+0x46>
  800fc7:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800fc9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800fcc:	29 f0                	sub    %esi,%eax
}
  800fce:	5b                   	pop    %ebx
  800fcf:	5e                   	pop    %esi
  800fd0:	5d                   	pop    %ebp
  800fd1:	c3                   	ret    

00800fd2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fd8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800fdb:	0f b6 01             	movzbl (%ecx),%eax
  800fde:	84 c0                	test   %al,%al
  800fe0:	74 15                	je     800ff7 <strcmp+0x25>
  800fe2:	3a 02                	cmp    (%edx),%al
  800fe4:	75 11                	jne    800ff7 <strcmp+0x25>
		p++, q++;
  800fe6:	83 c1 01             	add    $0x1,%ecx
  800fe9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800fec:	0f b6 01             	movzbl (%ecx),%eax
  800fef:	84 c0                	test   %al,%al
  800ff1:	74 04                	je     800ff7 <strcmp+0x25>
  800ff3:	3a 02                	cmp    (%edx),%al
  800ff5:	74 ef                	je     800fe6 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ff7:	0f b6 c0             	movzbl %al,%eax
  800ffa:	0f b6 12             	movzbl (%edx),%edx
  800ffd:	29 d0                	sub    %edx,%eax
}
  800fff:	5d                   	pop    %ebp
  801000:	c3                   	ret    

00801001 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	56                   	push   %esi
  801005:	53                   	push   %ebx
  801006:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801009:	8b 55 0c             	mov    0xc(%ebp),%edx
  80100c:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  80100f:	85 f6                	test   %esi,%esi
  801011:	74 29                	je     80103c <strncmp+0x3b>
  801013:	0f b6 03             	movzbl (%ebx),%eax
  801016:	84 c0                	test   %al,%al
  801018:	74 30                	je     80104a <strncmp+0x49>
  80101a:	3a 02                	cmp    (%edx),%al
  80101c:	75 2c                	jne    80104a <strncmp+0x49>
  80101e:	8d 43 01             	lea    0x1(%ebx),%eax
  801021:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  801023:	89 c3                	mov    %eax,%ebx
  801025:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801028:	39 c6                	cmp    %eax,%esi
  80102a:	74 17                	je     801043 <strncmp+0x42>
  80102c:	0f b6 08             	movzbl (%eax),%ecx
  80102f:	84 c9                	test   %cl,%cl
  801031:	74 17                	je     80104a <strncmp+0x49>
  801033:	83 c0 01             	add    $0x1,%eax
  801036:	3a 0a                	cmp    (%edx),%cl
  801038:	74 e9                	je     801023 <strncmp+0x22>
  80103a:	eb 0e                	jmp    80104a <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80103c:	b8 00 00 00 00       	mov    $0x0,%eax
  801041:	eb 0f                	jmp    801052 <strncmp+0x51>
  801043:	b8 00 00 00 00       	mov    $0x0,%eax
  801048:	eb 08                	jmp    801052 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80104a:	0f b6 03             	movzbl (%ebx),%eax
  80104d:	0f b6 12             	movzbl (%edx),%edx
  801050:	29 d0                	sub    %edx,%eax
}
  801052:	5b                   	pop    %ebx
  801053:	5e                   	pop    %esi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	53                   	push   %ebx
  80105a:	8b 45 08             	mov    0x8(%ebp),%eax
  80105d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  801060:	0f b6 10             	movzbl (%eax),%edx
  801063:	84 d2                	test   %dl,%dl
  801065:	74 1d                	je     801084 <strchr+0x2e>
  801067:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  801069:	38 d3                	cmp    %dl,%bl
  80106b:	75 06                	jne    801073 <strchr+0x1d>
  80106d:	eb 1a                	jmp    801089 <strchr+0x33>
  80106f:	38 ca                	cmp    %cl,%dl
  801071:	74 16                	je     801089 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801073:	83 c0 01             	add    $0x1,%eax
  801076:	0f b6 10             	movzbl (%eax),%edx
  801079:	84 d2                	test   %dl,%dl
  80107b:	75 f2                	jne    80106f <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  80107d:	b8 00 00 00 00       	mov    $0x0,%eax
  801082:	eb 05                	jmp    801089 <strchr+0x33>
  801084:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801089:	5b                   	pop    %ebx
  80108a:	5d                   	pop    %ebp
  80108b:	c3                   	ret    

0080108c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	53                   	push   %ebx
  801090:	8b 45 08             	mov    0x8(%ebp),%eax
  801093:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  801096:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  801099:	38 d3                	cmp    %dl,%bl
  80109b:	74 14                	je     8010b1 <strfind+0x25>
  80109d:	89 d1                	mov    %edx,%ecx
  80109f:	84 db                	test   %bl,%bl
  8010a1:	74 0e                	je     8010b1 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8010a3:	83 c0 01             	add    $0x1,%eax
  8010a6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8010a9:	38 ca                	cmp    %cl,%dl
  8010ab:	74 04                	je     8010b1 <strfind+0x25>
  8010ad:	84 d2                	test   %dl,%dl
  8010af:	75 f2                	jne    8010a3 <strfind+0x17>
			break;
	return (char *) s;
}
  8010b1:	5b                   	pop    %ebx
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	57                   	push   %edi
  8010b8:	56                   	push   %esi
  8010b9:	53                   	push   %ebx
  8010ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8010c0:	85 c9                	test   %ecx,%ecx
  8010c2:	74 36                	je     8010fa <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8010c4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8010ca:	75 28                	jne    8010f4 <memset+0x40>
  8010cc:	f6 c1 03             	test   $0x3,%cl
  8010cf:	75 23                	jne    8010f4 <memset+0x40>
		c &= 0xFF;
  8010d1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8010d5:	89 d3                	mov    %edx,%ebx
  8010d7:	c1 e3 08             	shl    $0x8,%ebx
  8010da:	89 d6                	mov    %edx,%esi
  8010dc:	c1 e6 18             	shl    $0x18,%esi
  8010df:	89 d0                	mov    %edx,%eax
  8010e1:	c1 e0 10             	shl    $0x10,%eax
  8010e4:	09 f0                	or     %esi,%eax
  8010e6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8010e8:	89 d8                	mov    %ebx,%eax
  8010ea:	09 d0                	or     %edx,%eax
  8010ec:	c1 e9 02             	shr    $0x2,%ecx
  8010ef:	fc                   	cld    
  8010f0:	f3 ab                	rep stos %eax,%es:(%edi)
  8010f2:	eb 06                	jmp    8010fa <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8010f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f7:	fc                   	cld    
  8010f8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8010fa:	89 f8                	mov    %edi,%eax
  8010fc:	5b                   	pop    %ebx
  8010fd:	5e                   	pop    %esi
  8010fe:	5f                   	pop    %edi
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	57                   	push   %edi
  801105:	56                   	push   %esi
  801106:	8b 45 08             	mov    0x8(%ebp),%eax
  801109:	8b 75 0c             	mov    0xc(%ebp),%esi
  80110c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80110f:	39 c6                	cmp    %eax,%esi
  801111:	73 35                	jae    801148 <memmove+0x47>
  801113:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801116:	39 d0                	cmp    %edx,%eax
  801118:	73 2e                	jae    801148 <memmove+0x47>
		s += n;
		d += n;
  80111a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80111d:	89 d6                	mov    %edx,%esi
  80111f:	09 fe                	or     %edi,%esi
  801121:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801127:	75 13                	jne    80113c <memmove+0x3b>
  801129:	f6 c1 03             	test   $0x3,%cl
  80112c:	75 0e                	jne    80113c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80112e:	83 ef 04             	sub    $0x4,%edi
  801131:	8d 72 fc             	lea    -0x4(%edx),%esi
  801134:	c1 e9 02             	shr    $0x2,%ecx
  801137:	fd                   	std    
  801138:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80113a:	eb 09                	jmp    801145 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80113c:	83 ef 01             	sub    $0x1,%edi
  80113f:	8d 72 ff             	lea    -0x1(%edx),%esi
  801142:	fd                   	std    
  801143:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801145:	fc                   	cld    
  801146:	eb 1d                	jmp    801165 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801148:	89 f2                	mov    %esi,%edx
  80114a:	09 c2                	or     %eax,%edx
  80114c:	f6 c2 03             	test   $0x3,%dl
  80114f:	75 0f                	jne    801160 <memmove+0x5f>
  801151:	f6 c1 03             	test   $0x3,%cl
  801154:	75 0a                	jne    801160 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801156:	c1 e9 02             	shr    $0x2,%ecx
  801159:	89 c7                	mov    %eax,%edi
  80115b:	fc                   	cld    
  80115c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80115e:	eb 05                	jmp    801165 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801160:	89 c7                	mov    %eax,%edi
  801162:	fc                   	cld    
  801163:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801165:	5e                   	pop    %esi
  801166:	5f                   	pop    %edi
  801167:	5d                   	pop    %ebp
  801168:	c3                   	ret    

00801169 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80116c:	ff 75 10             	pushl  0x10(%ebp)
  80116f:	ff 75 0c             	pushl  0xc(%ebp)
  801172:	ff 75 08             	pushl  0x8(%ebp)
  801175:	e8 87 ff ff ff       	call   801101 <memmove>
}
  80117a:	c9                   	leave  
  80117b:	c3                   	ret    

0080117c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	57                   	push   %edi
  801180:	56                   	push   %esi
  801181:	53                   	push   %ebx
  801182:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801185:	8b 75 0c             	mov    0xc(%ebp),%esi
  801188:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80118b:	85 c0                	test   %eax,%eax
  80118d:	74 39                	je     8011c8 <memcmp+0x4c>
  80118f:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  801192:	0f b6 13             	movzbl (%ebx),%edx
  801195:	0f b6 0e             	movzbl (%esi),%ecx
  801198:	38 ca                	cmp    %cl,%dl
  80119a:	75 17                	jne    8011b3 <memcmp+0x37>
  80119c:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a1:	eb 1a                	jmp    8011bd <memcmp+0x41>
  8011a3:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  8011a8:	83 c0 01             	add    $0x1,%eax
  8011ab:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  8011af:	38 ca                	cmp    %cl,%dl
  8011b1:	74 0a                	je     8011bd <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  8011b3:	0f b6 c2             	movzbl %dl,%eax
  8011b6:	0f b6 c9             	movzbl %cl,%ecx
  8011b9:	29 c8                	sub    %ecx,%eax
  8011bb:	eb 10                	jmp    8011cd <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011bd:	39 f8                	cmp    %edi,%eax
  8011bf:	75 e2                	jne    8011a3 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8011c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c6:	eb 05                	jmp    8011cd <memcmp+0x51>
  8011c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011cd:	5b                   	pop    %ebx
  8011ce:	5e                   	pop    %esi
  8011cf:	5f                   	pop    %edi
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	53                   	push   %ebx
  8011d6:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  8011d9:	89 d0                	mov    %edx,%eax
  8011db:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  8011de:	39 c2                	cmp    %eax,%edx
  8011e0:	73 1d                	jae    8011ff <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  8011e2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  8011e6:	0f b6 0a             	movzbl (%edx),%ecx
  8011e9:	39 d9                	cmp    %ebx,%ecx
  8011eb:	75 09                	jne    8011f6 <memfind+0x24>
  8011ed:	eb 14                	jmp    801203 <memfind+0x31>
  8011ef:	0f b6 0a             	movzbl (%edx),%ecx
  8011f2:	39 d9                	cmp    %ebx,%ecx
  8011f4:	74 11                	je     801207 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8011f6:	83 c2 01             	add    $0x1,%edx
  8011f9:	39 d0                	cmp    %edx,%eax
  8011fb:	75 f2                	jne    8011ef <memfind+0x1d>
  8011fd:	eb 0a                	jmp    801209 <memfind+0x37>
  8011ff:	89 d0                	mov    %edx,%eax
  801201:	eb 06                	jmp    801209 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  801203:	89 d0                	mov    %edx,%eax
  801205:	eb 02                	jmp    801209 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801207:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801209:	5b                   	pop    %ebx
  80120a:	5d                   	pop    %ebp
  80120b:	c3                   	ret    

0080120c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	57                   	push   %edi
  801210:	56                   	push   %esi
  801211:	53                   	push   %ebx
  801212:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801215:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801218:	0f b6 01             	movzbl (%ecx),%eax
  80121b:	3c 20                	cmp    $0x20,%al
  80121d:	74 04                	je     801223 <strtol+0x17>
  80121f:	3c 09                	cmp    $0x9,%al
  801221:	75 0e                	jne    801231 <strtol+0x25>
		s++;
  801223:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801226:	0f b6 01             	movzbl (%ecx),%eax
  801229:	3c 20                	cmp    $0x20,%al
  80122b:	74 f6                	je     801223 <strtol+0x17>
  80122d:	3c 09                	cmp    $0x9,%al
  80122f:	74 f2                	je     801223 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  801231:	3c 2b                	cmp    $0x2b,%al
  801233:	75 0a                	jne    80123f <strtol+0x33>
		s++;
  801235:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801238:	bf 00 00 00 00       	mov    $0x0,%edi
  80123d:	eb 11                	jmp    801250 <strtol+0x44>
  80123f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801244:	3c 2d                	cmp    $0x2d,%al
  801246:	75 08                	jne    801250 <strtol+0x44>
		s++, neg = 1;
  801248:	83 c1 01             	add    $0x1,%ecx
  80124b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801250:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801256:	75 15                	jne    80126d <strtol+0x61>
  801258:	80 39 30             	cmpb   $0x30,(%ecx)
  80125b:	75 10                	jne    80126d <strtol+0x61>
  80125d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801261:	75 7c                	jne    8012df <strtol+0xd3>
		s += 2, base = 16;
  801263:	83 c1 02             	add    $0x2,%ecx
  801266:	bb 10 00 00 00       	mov    $0x10,%ebx
  80126b:	eb 16                	jmp    801283 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  80126d:	85 db                	test   %ebx,%ebx
  80126f:	75 12                	jne    801283 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801271:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801276:	80 39 30             	cmpb   $0x30,(%ecx)
  801279:	75 08                	jne    801283 <strtol+0x77>
		s++, base = 8;
  80127b:	83 c1 01             	add    $0x1,%ecx
  80127e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801283:	b8 00 00 00 00       	mov    $0x0,%eax
  801288:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80128b:	0f b6 11             	movzbl (%ecx),%edx
  80128e:	8d 72 d0             	lea    -0x30(%edx),%esi
  801291:	89 f3                	mov    %esi,%ebx
  801293:	80 fb 09             	cmp    $0x9,%bl
  801296:	77 08                	ja     8012a0 <strtol+0x94>
			dig = *s - '0';
  801298:	0f be d2             	movsbl %dl,%edx
  80129b:	83 ea 30             	sub    $0x30,%edx
  80129e:	eb 22                	jmp    8012c2 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  8012a0:	8d 72 9f             	lea    -0x61(%edx),%esi
  8012a3:	89 f3                	mov    %esi,%ebx
  8012a5:	80 fb 19             	cmp    $0x19,%bl
  8012a8:	77 08                	ja     8012b2 <strtol+0xa6>
			dig = *s - 'a' + 10;
  8012aa:	0f be d2             	movsbl %dl,%edx
  8012ad:	83 ea 57             	sub    $0x57,%edx
  8012b0:	eb 10                	jmp    8012c2 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  8012b2:	8d 72 bf             	lea    -0x41(%edx),%esi
  8012b5:	89 f3                	mov    %esi,%ebx
  8012b7:	80 fb 19             	cmp    $0x19,%bl
  8012ba:	77 16                	ja     8012d2 <strtol+0xc6>
			dig = *s - 'A' + 10;
  8012bc:	0f be d2             	movsbl %dl,%edx
  8012bf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8012c2:	3b 55 10             	cmp    0x10(%ebp),%edx
  8012c5:	7d 0b                	jge    8012d2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  8012c7:	83 c1 01             	add    $0x1,%ecx
  8012ca:	0f af 45 10          	imul   0x10(%ebp),%eax
  8012ce:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8012d0:	eb b9                	jmp    80128b <strtol+0x7f>

	if (endptr)
  8012d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8012d6:	74 0d                	je     8012e5 <strtol+0xd9>
		*endptr = (char *) s;
  8012d8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012db:	89 0e                	mov    %ecx,(%esi)
  8012dd:	eb 06                	jmp    8012e5 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8012df:	85 db                	test   %ebx,%ebx
  8012e1:	74 98                	je     80127b <strtol+0x6f>
  8012e3:	eb 9e                	jmp    801283 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8012e5:	89 c2                	mov    %eax,%edx
  8012e7:	f7 da                	neg    %edx
  8012e9:	85 ff                	test   %edi,%edi
  8012eb:	0f 45 c2             	cmovne %edx,%eax
}
  8012ee:	5b                   	pop    %ebx
  8012ef:	5e                   	pop    %esi
  8012f0:	5f                   	pop    %edi
  8012f1:	5d                   	pop    %ebp
  8012f2:	c3                   	ret    

008012f3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	57                   	push   %edi
  8012f7:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8012f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801300:	8b 55 08             	mov    0x8(%ebp),%edx
  801303:	89 c3                	mov    %eax,%ebx
  801305:	89 c7                	mov    %eax,%edi
  801307:	51                   	push   %ecx
  801308:	52                   	push   %edx
  801309:	53                   	push   %ebx
  80130a:	56                   	push   %esi
  80130b:	57                   	push   %edi
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	8d 35 17 13 80 00    	lea    0x801317,%esi
  801315:	0f 34                	sysenter 

00801317 <label_21>:
  801317:	89 ec                	mov    %ebp,%esp
  801319:	5d                   	pop    %ebp
  80131a:	5f                   	pop    %edi
  80131b:	5e                   	pop    %esi
  80131c:	5b                   	pop    %ebx
  80131d:	5a                   	pop    %edx
  80131e:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80131f:	5b                   	pop    %ebx
  801320:	5f                   	pop    %edi
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    

00801323 <sys_cgetc>:

int
sys_cgetc(void)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	57                   	push   %edi
  801327:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801328:	b9 00 00 00 00       	mov    $0x0,%ecx
  80132d:	b8 01 00 00 00       	mov    $0x1,%eax
  801332:	89 ca                	mov    %ecx,%edx
  801334:	89 cb                	mov    %ecx,%ebx
  801336:	89 cf                	mov    %ecx,%edi
  801338:	51                   	push   %ecx
  801339:	52                   	push   %edx
  80133a:	53                   	push   %ebx
  80133b:	56                   	push   %esi
  80133c:	57                   	push   %edi
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
  801340:	8d 35 48 13 80 00    	lea    0x801348,%esi
  801346:	0f 34                	sysenter 

00801348 <label_55>:
  801348:	89 ec                	mov    %ebp,%esp
  80134a:	5d                   	pop    %ebp
  80134b:	5f                   	pop    %edi
  80134c:	5e                   	pop    %esi
  80134d:	5b                   	pop    %ebx
  80134e:	5a                   	pop    %edx
  80134f:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801350:	5b                   	pop    %ebx
  801351:	5f                   	pop    %edi
  801352:	5d                   	pop    %ebp
  801353:	c3                   	ret    

00801354 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	57                   	push   %edi
  801358:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801359:	bb 00 00 00 00       	mov    $0x0,%ebx
  80135e:	b8 03 00 00 00       	mov    $0x3,%eax
  801363:	8b 55 08             	mov    0x8(%ebp),%edx
  801366:	89 d9                	mov    %ebx,%ecx
  801368:	89 df                	mov    %ebx,%edi
  80136a:	51                   	push   %ecx
  80136b:	52                   	push   %edx
  80136c:	53                   	push   %ebx
  80136d:	56                   	push   %esi
  80136e:	57                   	push   %edi
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	8d 35 7a 13 80 00    	lea    0x80137a,%esi
  801378:	0f 34                	sysenter 

0080137a <label_90>:
  80137a:	89 ec                	mov    %ebp,%esp
  80137c:	5d                   	pop    %ebp
  80137d:	5f                   	pop    %edi
  80137e:	5e                   	pop    %esi
  80137f:	5b                   	pop    %ebx
  801380:	5a                   	pop    %edx
  801381:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801382:	85 c0                	test   %eax,%eax
  801384:	7e 17                	jle    80139d <label_90+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801386:	83 ec 0c             	sub    $0xc,%esp
  801389:	50                   	push   %eax
  80138a:	6a 03                	push   $0x3
  80138c:	68 c4 1d 80 00       	push   $0x801dc4
  801391:	6a 30                	push   $0x30
  801393:	68 e1 1d 80 00       	push   $0x801de1
  801398:	e8 4c f2 ff ff       	call   8005e9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80139d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a0:	5b                   	pop    %ebx
  8013a1:	5f                   	pop    %edi
  8013a2:	5d                   	pop    %ebp
  8013a3:	c3                   	ret    

008013a4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	57                   	push   %edi
  8013a8:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013ae:	b8 02 00 00 00       	mov    $0x2,%eax
  8013b3:	89 ca                	mov    %ecx,%edx
  8013b5:	89 cb                	mov    %ecx,%ebx
  8013b7:	89 cf                	mov    %ecx,%edi
  8013b9:	51                   	push   %ecx
  8013ba:	52                   	push   %edx
  8013bb:	53                   	push   %ebx
  8013bc:	56                   	push   %esi
  8013bd:	57                   	push   %edi
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	8d 35 c9 13 80 00    	lea    0x8013c9,%esi
  8013c7:	0f 34                	sysenter 

008013c9 <label_139>:
  8013c9:	89 ec                	mov    %ebp,%esp
  8013cb:	5d                   	pop    %ebp
  8013cc:	5f                   	pop    %edi
  8013cd:	5e                   	pop    %esi
  8013ce:	5b                   	pop    %ebx
  8013cf:	5a                   	pop    %edx
  8013d0:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8013d1:	5b                   	pop    %ebx
  8013d2:	5f                   	pop    %edi
  8013d3:	5d                   	pop    %ebp
  8013d4:	c3                   	ret    

008013d5 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  8013d5:	55                   	push   %ebp
  8013d6:	89 e5                	mov    %esp,%ebp
  8013d8:	57                   	push   %edi
  8013d9:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013da:	bf 00 00 00 00       	mov    $0x0,%edi
  8013df:	b8 04 00 00 00       	mov    $0x4,%eax
  8013e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ea:	89 fb                	mov    %edi,%ebx
  8013ec:	51                   	push   %ecx
  8013ed:	52                   	push   %edx
  8013ee:	53                   	push   %ebx
  8013ef:	56                   	push   %esi
  8013f0:	57                   	push   %edi
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	8d 35 fc 13 80 00    	lea    0x8013fc,%esi
  8013fa:	0f 34                	sysenter 

008013fc <label_174>:
  8013fc:	89 ec                	mov    %ebp,%esp
  8013fe:	5d                   	pop    %ebp
  8013ff:	5f                   	pop    %edi
  801400:	5e                   	pop    %esi
  801401:	5b                   	pop    %ebx
  801402:	5a                   	pop    %edx
  801403:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  801404:	5b                   	pop    %ebx
  801405:	5f                   	pop    %edi
  801406:	5d                   	pop    %ebp
  801407:	c3                   	ret    

00801408 <sys_yield>:

void
sys_yield(void)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	57                   	push   %edi
  80140c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80140d:	ba 00 00 00 00       	mov    $0x0,%edx
  801412:	b8 0b 00 00 00       	mov    $0xb,%eax
  801417:	89 d1                	mov    %edx,%ecx
  801419:	89 d3                	mov    %edx,%ebx
  80141b:	89 d7                	mov    %edx,%edi
  80141d:	51                   	push   %ecx
  80141e:	52                   	push   %edx
  80141f:	53                   	push   %ebx
  801420:	56                   	push   %esi
  801421:	57                   	push   %edi
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	8d 35 2d 14 80 00    	lea    0x80142d,%esi
  80142b:	0f 34                	sysenter 

0080142d <label_209>:
  80142d:	89 ec                	mov    %ebp,%esp
  80142f:	5d                   	pop    %ebp
  801430:	5f                   	pop    %edi
  801431:	5e                   	pop    %esi
  801432:	5b                   	pop    %ebx
  801433:	5a                   	pop    %edx
  801434:	59                   	pop    %ecx

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801435:	5b                   	pop    %ebx
  801436:	5f                   	pop    %edi
  801437:	5d                   	pop    %ebp
  801438:	c3                   	ret    

00801439 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	57                   	push   %edi
  80143d:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80143e:	bf 00 00 00 00       	mov    $0x0,%edi
  801443:	b8 05 00 00 00       	mov    $0x5,%eax
  801448:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80144b:	8b 55 08             	mov    0x8(%ebp),%edx
  80144e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801451:	51                   	push   %ecx
  801452:	52                   	push   %edx
  801453:	53                   	push   %ebx
  801454:	56                   	push   %esi
  801455:	57                   	push   %edi
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	8d 35 61 14 80 00    	lea    0x801461,%esi
  80145f:	0f 34                	sysenter 

00801461 <label_244>:
  801461:	89 ec                	mov    %ebp,%esp
  801463:	5d                   	pop    %ebp
  801464:	5f                   	pop    %edi
  801465:	5e                   	pop    %esi
  801466:	5b                   	pop    %ebx
  801467:	5a                   	pop    %edx
  801468:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  801469:	85 c0                	test   %eax,%eax
  80146b:	7e 17                	jle    801484 <label_244+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80146d:	83 ec 0c             	sub    $0xc,%esp
  801470:	50                   	push   %eax
  801471:	6a 05                	push   $0x5
  801473:	68 c4 1d 80 00       	push   $0x801dc4
  801478:	6a 30                	push   $0x30
  80147a:	68 e1 1d 80 00       	push   $0x801de1
  80147f:	e8 65 f1 ff ff       	call   8005e9 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801484:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801487:	5b                   	pop    %ebx
  801488:	5f                   	pop    %edi
  801489:	5d                   	pop    %ebp
  80148a:	c3                   	ret    

0080148b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	57                   	push   %edi
  80148f:	53                   	push   %ebx
  801490:	83 ec 20             	sub    $0x20,%esp
	// cprintf("sys_page_map gets here\n");
	// return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
	uint32_t args[5];
	args[0] = (uint32_t) srcenv;
  801493:	8b 45 08             	mov    0x8(%ebp),%eax
  801496:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	args[1] = (uint32_t) srcva;
  801499:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	args[2] = (uint32_t) dstenv;
  80149f:	8b 45 10             	mov    0x10(%ebp),%eax
  8014a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
	args[3] = (uint32_t) dstva;
  8014a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
	args[4] = (uint32_t) perm;
  8014ab:	8b 45 18             	mov    0x18(%ebp),%eax
  8014ae:	89 45 f4             	mov    %eax,-0xc(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8014b1:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8014b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014b9:	b8 06 00 00 00       	mov    $0x6,%eax
  8014be:	89 cb                	mov    %ecx,%ebx
  8014c0:	89 cf                	mov    %ecx,%edi
  8014c2:	51                   	push   %ecx
  8014c3:	52                   	push   %edx
  8014c4:	53                   	push   %ebx
  8014c5:	56                   	push   %esi
  8014c6:	57                   	push   %edi
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	8d 35 d2 14 80 00    	lea    0x8014d2,%esi
  8014d0:	0f 34                	sysenter 

008014d2 <label_304>:
  8014d2:	89 ec                	mov    %ebp,%esp
  8014d4:	5d                   	pop    %ebp
  8014d5:	5f                   	pop    %edi
  8014d6:	5e                   	pop    %esi
  8014d7:	5b                   	pop    %ebx
  8014d8:	5a                   	pop    %edx
  8014d9:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	7e 17                	jle    8014f5 <label_304+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014de:	83 ec 0c             	sub    $0xc,%esp
  8014e1:	50                   	push   %eax
  8014e2:	6a 06                	push   $0x6
  8014e4:	68 c4 1d 80 00       	push   $0x801dc4
  8014e9:	6a 30                	push   $0x30
  8014eb:	68 e1 1d 80 00       	push   $0x801de1
  8014f0:	e8 f4 f0 ff ff       	call   8005e9 <_panic>
	args[1] = (uint32_t) srcva;
	args[2] = (uint32_t) dstenv;
	args[3] = (uint32_t) dstva;
	args[4] = (uint32_t) perm;
	return syscall(SYS_page_map, 1, (uint32_t)args, 0, 0, 0, 0);
}
  8014f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f8:	5b                   	pop    %ebx
  8014f9:	5f                   	pop    %edi
  8014fa:	5d                   	pop    %ebp
  8014fb:	c3                   	ret    

008014fc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	57                   	push   %edi
  801500:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801501:	bf 00 00 00 00       	mov    $0x0,%edi
  801506:	b8 07 00 00 00       	mov    $0x7,%eax
  80150b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80150e:	8b 55 08             	mov    0x8(%ebp),%edx
  801511:	89 fb                	mov    %edi,%ebx
  801513:	51                   	push   %ecx
  801514:	52                   	push   %edx
  801515:	53                   	push   %ebx
  801516:	56                   	push   %esi
  801517:	57                   	push   %edi
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	8d 35 23 15 80 00    	lea    0x801523,%esi
  801521:	0f 34                	sysenter 

00801523 <label_353>:
  801523:	89 ec                	mov    %ebp,%esp
  801525:	5d                   	pop    %ebp
  801526:	5f                   	pop    %edi
  801527:	5e                   	pop    %esi
  801528:	5b                   	pop    %ebx
  801529:	5a                   	pop    %edx
  80152a:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80152b:	85 c0                	test   %eax,%eax
  80152d:	7e 17                	jle    801546 <label_353+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  80152f:	83 ec 0c             	sub    $0xc,%esp
  801532:	50                   	push   %eax
  801533:	6a 07                	push   $0x7
  801535:	68 c4 1d 80 00       	push   $0x801dc4
  80153a:	6a 30                	push   $0x30
  80153c:	68 e1 1d 80 00       	push   $0x801de1
  801541:	e8 a3 f0 ff ff       	call   8005e9 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801546:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801549:	5b                   	pop    %ebx
  80154a:	5f                   	pop    %edi
  80154b:	5d                   	pop    %ebp
  80154c:	c3                   	ret    

0080154d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	57                   	push   %edi
  801551:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801552:	bf 00 00 00 00       	mov    $0x0,%edi
  801557:	b8 09 00 00 00       	mov    $0x9,%eax
  80155c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80155f:	8b 55 08             	mov    0x8(%ebp),%edx
  801562:	89 fb                	mov    %edi,%ebx
  801564:	51                   	push   %ecx
  801565:	52                   	push   %edx
  801566:	53                   	push   %ebx
  801567:	56                   	push   %esi
  801568:	57                   	push   %edi
  801569:	55                   	push   %ebp
  80156a:	89 e5                	mov    %esp,%ebp
  80156c:	8d 35 74 15 80 00    	lea    0x801574,%esi
  801572:	0f 34                	sysenter 

00801574 <label_402>:
  801574:	89 ec                	mov    %ebp,%esp
  801576:	5d                   	pop    %ebp
  801577:	5f                   	pop    %edi
  801578:	5e                   	pop    %esi
  801579:	5b                   	pop    %ebx
  80157a:	5a                   	pop    %edx
  80157b:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80157c:	85 c0                	test   %eax,%eax
  80157e:	7e 17                	jle    801597 <label_402+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801580:	83 ec 0c             	sub    $0xc,%esp
  801583:	50                   	push   %eax
  801584:	6a 09                	push   $0x9
  801586:	68 c4 1d 80 00       	push   $0x801dc4
  80158b:	6a 30                	push   $0x30
  80158d:	68 e1 1d 80 00       	push   $0x801de1
  801592:	e8 52 f0 ff ff       	call   8005e9 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801597:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80159a:	5b                   	pop    %ebx
  80159b:	5f                   	pop    %edi
  80159c:	5d                   	pop    %ebp
  80159d:	c3                   	ret    

0080159e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80159e:	55                   	push   %ebp
  80159f:	89 e5                	mov    %esp,%ebp
  8015a1:	57                   	push   %edi
  8015a2:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015a3:	bf 00 00 00 00       	mov    $0x0,%edi
  8015a8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8015ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8015b3:	89 fb                	mov    %edi,%ebx
  8015b5:	51                   	push   %ecx
  8015b6:	52                   	push   %edx
  8015b7:	53                   	push   %ebx
  8015b8:	56                   	push   %esi
  8015b9:	57                   	push   %edi
  8015ba:	55                   	push   %ebp
  8015bb:	89 e5                	mov    %esp,%ebp
  8015bd:	8d 35 c5 15 80 00    	lea    0x8015c5,%esi
  8015c3:	0f 34                	sysenter 

008015c5 <label_451>:
  8015c5:	89 ec                	mov    %ebp,%esp
  8015c7:	5d                   	pop    %ebp
  8015c8:	5f                   	pop    %edi
  8015c9:	5e                   	pop    %esi
  8015ca:	5b                   	pop    %ebx
  8015cb:	5a                   	pop    %edx
  8015cc:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  8015cd:	85 c0                	test   %eax,%eax
  8015cf:	7e 17                	jle    8015e8 <label_451+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015d1:	83 ec 0c             	sub    $0xc,%esp
  8015d4:	50                   	push   %eax
  8015d5:	6a 0a                	push   $0xa
  8015d7:	68 c4 1d 80 00       	push   $0x801dc4
  8015dc:	6a 30                	push   $0x30
  8015de:	68 e1 1d 80 00       	push   $0x801de1
  8015e3:	e8 01 f0 ff ff       	call   8005e9 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8015e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015eb:	5b                   	pop    %ebx
  8015ec:	5f                   	pop    %edi
  8015ed:	5d                   	pop    %ebp
  8015ee:	c3                   	ret    

008015ef <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	57                   	push   %edi
  8015f3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8015f4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8015f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8015ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801602:	8b 7d 14             	mov    0x14(%ebp),%edi
  801605:	51                   	push   %ecx
  801606:	52                   	push   %edx
  801607:	53                   	push   %ebx
  801608:	56                   	push   %esi
  801609:	57                   	push   %edi
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	8d 35 15 16 80 00    	lea    0x801615,%esi
  801613:	0f 34                	sysenter 

00801615 <label_502>:
  801615:	89 ec                	mov    %ebp,%esp
  801617:	5d                   	pop    %ebp
  801618:	5f                   	pop    %edi
  801619:	5e                   	pop    %esi
  80161a:	5b                   	pop    %ebx
  80161b:	5a                   	pop    %edx
  80161c:	59                   	pop    %ecx

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80161d:	5b                   	pop    %ebx
  80161e:	5f                   	pop    %edi
  80161f:	5d                   	pop    %ebp
  801620:	c3                   	ret    

00801621 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801621:	55                   	push   %ebp
  801622:	89 e5                	mov    %esp,%ebp
  801624:	57                   	push   %edi
  801625:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801626:	bb 00 00 00 00       	mov    $0x0,%ebx
  80162b:	b8 0d 00 00 00       	mov    $0xd,%eax
  801630:	8b 55 08             	mov    0x8(%ebp),%edx
  801633:	89 d9                	mov    %ebx,%ecx
  801635:	89 df                	mov    %ebx,%edi
  801637:	51                   	push   %ecx
  801638:	52                   	push   %edx
  801639:	53                   	push   %ebx
  80163a:	56                   	push   %esi
  80163b:	57                   	push   %edi
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	8d 35 47 16 80 00    	lea    0x801647,%esi
  801645:	0f 34                	sysenter 

00801647 <label_537>:
  801647:	89 ec                	mov    %ebp,%esp
  801649:	5d                   	pop    %ebp
  80164a:	5f                   	pop    %edi
  80164b:	5e                   	pop    %esi
  80164c:	5b                   	pop    %ebx
  80164d:	5a                   	pop    %edx
  80164e:	59                   	pop    %ecx
							"b" (a3),
							"D" (a4)
							: "cc", "memory");


	if(check && ret > 0)
  80164f:	85 c0                	test   %eax,%eax
  801651:	7e 17                	jle    80166a <label_537+0x23>
		panic("syscall %d returned %d (> 0)", num, ret);
  801653:	83 ec 0c             	sub    $0xc,%esp
  801656:	50                   	push   %eax
  801657:	6a 0d                	push   $0xd
  801659:	68 c4 1d 80 00       	push   $0x801dc4
  80165e:	6a 30                	push   $0x30
  801660:	68 e1 1d 80 00       	push   $0x801de1
  801665:	e8 7f ef ff ff       	call   8005e9 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80166a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166d:	5b                   	pop    %ebx
  80166e:	5f                   	pop    %edi
  80166f:	5d                   	pop    %ebp
  801670:	c3                   	ret    

00801671 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	57                   	push   %edi
  801675:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801676:	b9 00 00 00 00       	mov    $0x0,%ecx
  80167b:	b8 0e 00 00 00       	mov    $0xe,%eax
  801680:	8b 55 08             	mov    0x8(%ebp),%edx
  801683:	89 cb                	mov    %ecx,%ebx
  801685:	89 cf                	mov    %ecx,%edi
  801687:	51                   	push   %ecx
  801688:	52                   	push   %edx
  801689:	53                   	push   %ebx
  80168a:	56                   	push   %esi
  80168b:	57                   	push   %edi
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	8d 35 97 16 80 00    	lea    0x801697,%esi
  801695:	0f 34                	sysenter 

00801697 <label_586>:
  801697:	89 ec                	mov    %ebp,%esp
  801699:	5d                   	pop    %ebp
  80169a:	5f                   	pop    %edi
  80169b:	5e                   	pop    %esi
  80169c:	5b                   	pop    %ebx
  80169d:	5a                   	pop    %edx
  80169e:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80169f:	5b                   	pop    %ebx
  8016a0:	5f                   	pop    %edi
  8016a1:	5d                   	pop    %ebp
  8016a2:	c3                   	ret    

008016a3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8016a9:	83 3d dc 20 80 00 00 	cmpl   $0x0,0x8020dc
  8016b0:	75 3c                	jne    8016ee <set_pgfault_handler+0x4b>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8016b2:	83 ec 04             	sub    $0x4,%esp
  8016b5:	6a 07                	push   $0x7
  8016b7:	68 00 f0 bf ee       	push   $0xeebff000
  8016bc:	6a 00                	push   $0x0
  8016be:	e8 76 fd ff ff       	call   801439 <sys_page_alloc>
		if (r) {
  8016c3:	83 c4 10             	add    $0x10,%esp
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	74 12                	je     8016dc <set_pgfault_handler+0x39>
			panic("set_pgfault_handler: %e\n", r);
  8016ca:	50                   	push   %eax
  8016cb:	68 ef 1d 80 00       	push   $0x801def
  8016d0:	6a 22                	push   $0x22
  8016d2:	68 08 1e 80 00       	push   $0x801e08
  8016d7:	e8 0d ef ff ff       	call   8005e9 <_panic>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8016dc:	83 ec 08             	sub    $0x8,%esp
  8016df:	68 f8 16 80 00       	push   $0x8016f8
  8016e4:	6a 00                	push   $0x0
  8016e6:	e8 b3 fe ff ff       	call   80159e <sys_env_set_pgfault_upcall>
  8016eb:	83 c4 10             	add    $0x10,%esp
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8016ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f1:	a3 dc 20 80 00       	mov    %eax,0x8020dc
}
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    

008016f8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8016f8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8016f9:	a1 dc 20 80 00       	mov    0x8020dc,%eax
	call *%eax
  8016fe:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801700:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x30(%esp), %eax
  801703:	8b 44 24 30          	mov    0x30(%esp),%eax
	leal -0x4(%eax), %eax	// preserve space to store trap-time eip
  801707:	8d 40 fc             	lea    -0x4(%eax),%eax
	movl %eax, 0x30(%esp)
  80170a:	89 44 24 30          	mov    %eax,0x30(%esp)

	movl 0x28(%esp), %ecx
  80170e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	movl %ecx, (%eax)
  801712:	89 08                	mov    %ecx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  801714:	83 c4 08             	add    $0x8,%esp
	popal
  801717:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  801718:	83 c4 04             	add    $0x4,%esp
	popfl
  80171b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80171c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80171d:	c3                   	ret    
  80171e:	66 90                	xchg   %ax,%ax

00801720 <__udivdi3>:
  801720:	55                   	push   %ebp
  801721:	57                   	push   %edi
  801722:	56                   	push   %esi
  801723:	53                   	push   %ebx
  801724:	83 ec 1c             	sub    $0x1c,%esp
  801727:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80172b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80172f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801733:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801737:	85 f6                	test   %esi,%esi
  801739:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80173d:	89 ca                	mov    %ecx,%edx
  80173f:	89 f8                	mov    %edi,%eax
  801741:	75 3d                	jne    801780 <__udivdi3+0x60>
  801743:	39 cf                	cmp    %ecx,%edi
  801745:	0f 87 c5 00 00 00    	ja     801810 <__udivdi3+0xf0>
  80174b:	85 ff                	test   %edi,%edi
  80174d:	89 fd                	mov    %edi,%ebp
  80174f:	75 0b                	jne    80175c <__udivdi3+0x3c>
  801751:	b8 01 00 00 00       	mov    $0x1,%eax
  801756:	31 d2                	xor    %edx,%edx
  801758:	f7 f7                	div    %edi
  80175a:	89 c5                	mov    %eax,%ebp
  80175c:	89 c8                	mov    %ecx,%eax
  80175e:	31 d2                	xor    %edx,%edx
  801760:	f7 f5                	div    %ebp
  801762:	89 c1                	mov    %eax,%ecx
  801764:	89 d8                	mov    %ebx,%eax
  801766:	89 cf                	mov    %ecx,%edi
  801768:	f7 f5                	div    %ebp
  80176a:	89 c3                	mov    %eax,%ebx
  80176c:	89 d8                	mov    %ebx,%eax
  80176e:	89 fa                	mov    %edi,%edx
  801770:	83 c4 1c             	add    $0x1c,%esp
  801773:	5b                   	pop    %ebx
  801774:	5e                   	pop    %esi
  801775:	5f                   	pop    %edi
  801776:	5d                   	pop    %ebp
  801777:	c3                   	ret    
  801778:	90                   	nop
  801779:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801780:	39 ce                	cmp    %ecx,%esi
  801782:	77 74                	ja     8017f8 <__udivdi3+0xd8>
  801784:	0f bd fe             	bsr    %esi,%edi
  801787:	83 f7 1f             	xor    $0x1f,%edi
  80178a:	0f 84 98 00 00 00    	je     801828 <__udivdi3+0x108>
  801790:	bb 20 00 00 00       	mov    $0x20,%ebx
  801795:	89 f9                	mov    %edi,%ecx
  801797:	89 c5                	mov    %eax,%ebp
  801799:	29 fb                	sub    %edi,%ebx
  80179b:	d3 e6                	shl    %cl,%esi
  80179d:	89 d9                	mov    %ebx,%ecx
  80179f:	d3 ed                	shr    %cl,%ebp
  8017a1:	89 f9                	mov    %edi,%ecx
  8017a3:	d3 e0                	shl    %cl,%eax
  8017a5:	09 ee                	or     %ebp,%esi
  8017a7:	89 d9                	mov    %ebx,%ecx
  8017a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017ad:	89 d5                	mov    %edx,%ebp
  8017af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8017b3:	d3 ed                	shr    %cl,%ebp
  8017b5:	89 f9                	mov    %edi,%ecx
  8017b7:	d3 e2                	shl    %cl,%edx
  8017b9:	89 d9                	mov    %ebx,%ecx
  8017bb:	d3 e8                	shr    %cl,%eax
  8017bd:	09 c2                	or     %eax,%edx
  8017bf:	89 d0                	mov    %edx,%eax
  8017c1:	89 ea                	mov    %ebp,%edx
  8017c3:	f7 f6                	div    %esi
  8017c5:	89 d5                	mov    %edx,%ebp
  8017c7:	89 c3                	mov    %eax,%ebx
  8017c9:	f7 64 24 0c          	mull   0xc(%esp)
  8017cd:	39 d5                	cmp    %edx,%ebp
  8017cf:	72 10                	jb     8017e1 <__udivdi3+0xc1>
  8017d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8017d5:	89 f9                	mov    %edi,%ecx
  8017d7:	d3 e6                	shl    %cl,%esi
  8017d9:	39 c6                	cmp    %eax,%esi
  8017db:	73 07                	jae    8017e4 <__udivdi3+0xc4>
  8017dd:	39 d5                	cmp    %edx,%ebp
  8017df:	75 03                	jne    8017e4 <__udivdi3+0xc4>
  8017e1:	83 eb 01             	sub    $0x1,%ebx
  8017e4:	31 ff                	xor    %edi,%edi
  8017e6:	89 d8                	mov    %ebx,%eax
  8017e8:	89 fa                	mov    %edi,%edx
  8017ea:	83 c4 1c             	add    $0x1c,%esp
  8017ed:	5b                   	pop    %ebx
  8017ee:	5e                   	pop    %esi
  8017ef:	5f                   	pop    %edi
  8017f0:	5d                   	pop    %ebp
  8017f1:	c3                   	ret    
  8017f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8017f8:	31 ff                	xor    %edi,%edi
  8017fa:	31 db                	xor    %ebx,%ebx
  8017fc:	89 d8                	mov    %ebx,%eax
  8017fe:	89 fa                	mov    %edi,%edx
  801800:	83 c4 1c             	add    $0x1c,%esp
  801803:	5b                   	pop    %ebx
  801804:	5e                   	pop    %esi
  801805:	5f                   	pop    %edi
  801806:	5d                   	pop    %ebp
  801807:	c3                   	ret    
  801808:	90                   	nop
  801809:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801810:	89 d8                	mov    %ebx,%eax
  801812:	f7 f7                	div    %edi
  801814:	31 ff                	xor    %edi,%edi
  801816:	89 c3                	mov    %eax,%ebx
  801818:	89 d8                	mov    %ebx,%eax
  80181a:	89 fa                	mov    %edi,%edx
  80181c:	83 c4 1c             	add    $0x1c,%esp
  80181f:	5b                   	pop    %ebx
  801820:	5e                   	pop    %esi
  801821:	5f                   	pop    %edi
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    
  801824:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801828:	39 ce                	cmp    %ecx,%esi
  80182a:	72 0c                	jb     801838 <__udivdi3+0x118>
  80182c:	31 db                	xor    %ebx,%ebx
  80182e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801832:	0f 87 34 ff ff ff    	ja     80176c <__udivdi3+0x4c>
  801838:	bb 01 00 00 00       	mov    $0x1,%ebx
  80183d:	e9 2a ff ff ff       	jmp    80176c <__udivdi3+0x4c>
  801842:	66 90                	xchg   %ax,%ax
  801844:	66 90                	xchg   %ax,%ax
  801846:	66 90                	xchg   %ax,%ax
  801848:	66 90                	xchg   %ax,%ax
  80184a:	66 90                	xchg   %ax,%ax
  80184c:	66 90                	xchg   %ax,%ax
  80184e:	66 90                	xchg   %ax,%ax

00801850 <__umoddi3>:
  801850:	55                   	push   %ebp
  801851:	57                   	push   %edi
  801852:	56                   	push   %esi
  801853:	53                   	push   %ebx
  801854:	83 ec 1c             	sub    $0x1c,%esp
  801857:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80185b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80185f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801863:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801867:	85 d2                	test   %edx,%edx
  801869:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80186d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801871:	89 f3                	mov    %esi,%ebx
  801873:	89 3c 24             	mov    %edi,(%esp)
  801876:	89 74 24 04          	mov    %esi,0x4(%esp)
  80187a:	75 1c                	jne    801898 <__umoddi3+0x48>
  80187c:	39 f7                	cmp    %esi,%edi
  80187e:	76 50                	jbe    8018d0 <__umoddi3+0x80>
  801880:	89 c8                	mov    %ecx,%eax
  801882:	89 f2                	mov    %esi,%edx
  801884:	f7 f7                	div    %edi
  801886:	89 d0                	mov    %edx,%eax
  801888:	31 d2                	xor    %edx,%edx
  80188a:	83 c4 1c             	add    $0x1c,%esp
  80188d:	5b                   	pop    %ebx
  80188e:	5e                   	pop    %esi
  80188f:	5f                   	pop    %edi
  801890:	5d                   	pop    %ebp
  801891:	c3                   	ret    
  801892:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801898:	39 f2                	cmp    %esi,%edx
  80189a:	89 d0                	mov    %edx,%eax
  80189c:	77 52                	ja     8018f0 <__umoddi3+0xa0>
  80189e:	0f bd ea             	bsr    %edx,%ebp
  8018a1:	83 f5 1f             	xor    $0x1f,%ebp
  8018a4:	75 5a                	jne    801900 <__umoddi3+0xb0>
  8018a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8018aa:	0f 82 e0 00 00 00    	jb     801990 <__umoddi3+0x140>
  8018b0:	39 0c 24             	cmp    %ecx,(%esp)
  8018b3:	0f 86 d7 00 00 00    	jbe    801990 <__umoddi3+0x140>
  8018b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8018bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8018c1:	83 c4 1c             	add    $0x1c,%esp
  8018c4:	5b                   	pop    %ebx
  8018c5:	5e                   	pop    %esi
  8018c6:	5f                   	pop    %edi
  8018c7:	5d                   	pop    %ebp
  8018c8:	c3                   	ret    
  8018c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8018d0:	85 ff                	test   %edi,%edi
  8018d2:	89 fd                	mov    %edi,%ebp
  8018d4:	75 0b                	jne    8018e1 <__umoddi3+0x91>
  8018d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8018db:	31 d2                	xor    %edx,%edx
  8018dd:	f7 f7                	div    %edi
  8018df:	89 c5                	mov    %eax,%ebp
  8018e1:	89 f0                	mov    %esi,%eax
  8018e3:	31 d2                	xor    %edx,%edx
  8018e5:	f7 f5                	div    %ebp
  8018e7:	89 c8                	mov    %ecx,%eax
  8018e9:	f7 f5                	div    %ebp
  8018eb:	89 d0                	mov    %edx,%eax
  8018ed:	eb 99                	jmp    801888 <__umoddi3+0x38>
  8018ef:	90                   	nop
  8018f0:	89 c8                	mov    %ecx,%eax
  8018f2:	89 f2                	mov    %esi,%edx
  8018f4:	83 c4 1c             	add    $0x1c,%esp
  8018f7:	5b                   	pop    %ebx
  8018f8:	5e                   	pop    %esi
  8018f9:	5f                   	pop    %edi
  8018fa:	5d                   	pop    %ebp
  8018fb:	c3                   	ret    
  8018fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801900:	8b 34 24             	mov    (%esp),%esi
  801903:	bf 20 00 00 00       	mov    $0x20,%edi
  801908:	89 e9                	mov    %ebp,%ecx
  80190a:	29 ef                	sub    %ebp,%edi
  80190c:	d3 e0                	shl    %cl,%eax
  80190e:	89 f9                	mov    %edi,%ecx
  801910:	89 f2                	mov    %esi,%edx
  801912:	d3 ea                	shr    %cl,%edx
  801914:	89 e9                	mov    %ebp,%ecx
  801916:	09 c2                	or     %eax,%edx
  801918:	89 d8                	mov    %ebx,%eax
  80191a:	89 14 24             	mov    %edx,(%esp)
  80191d:	89 f2                	mov    %esi,%edx
  80191f:	d3 e2                	shl    %cl,%edx
  801921:	89 f9                	mov    %edi,%ecx
  801923:	89 54 24 04          	mov    %edx,0x4(%esp)
  801927:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80192b:	d3 e8                	shr    %cl,%eax
  80192d:	89 e9                	mov    %ebp,%ecx
  80192f:	89 c6                	mov    %eax,%esi
  801931:	d3 e3                	shl    %cl,%ebx
  801933:	89 f9                	mov    %edi,%ecx
  801935:	89 d0                	mov    %edx,%eax
  801937:	d3 e8                	shr    %cl,%eax
  801939:	89 e9                	mov    %ebp,%ecx
  80193b:	09 d8                	or     %ebx,%eax
  80193d:	89 d3                	mov    %edx,%ebx
  80193f:	89 f2                	mov    %esi,%edx
  801941:	f7 34 24             	divl   (%esp)
  801944:	89 d6                	mov    %edx,%esi
  801946:	d3 e3                	shl    %cl,%ebx
  801948:	f7 64 24 04          	mull   0x4(%esp)
  80194c:	39 d6                	cmp    %edx,%esi
  80194e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801952:	89 d1                	mov    %edx,%ecx
  801954:	89 c3                	mov    %eax,%ebx
  801956:	72 08                	jb     801960 <__umoddi3+0x110>
  801958:	75 11                	jne    80196b <__umoddi3+0x11b>
  80195a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80195e:	73 0b                	jae    80196b <__umoddi3+0x11b>
  801960:	2b 44 24 04          	sub    0x4(%esp),%eax
  801964:	1b 14 24             	sbb    (%esp),%edx
  801967:	89 d1                	mov    %edx,%ecx
  801969:	89 c3                	mov    %eax,%ebx
  80196b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80196f:	29 da                	sub    %ebx,%edx
  801971:	19 ce                	sbb    %ecx,%esi
  801973:	89 f9                	mov    %edi,%ecx
  801975:	89 f0                	mov    %esi,%eax
  801977:	d3 e0                	shl    %cl,%eax
  801979:	89 e9                	mov    %ebp,%ecx
  80197b:	d3 ea                	shr    %cl,%edx
  80197d:	89 e9                	mov    %ebp,%ecx
  80197f:	d3 ee                	shr    %cl,%esi
  801981:	09 d0                	or     %edx,%eax
  801983:	89 f2                	mov    %esi,%edx
  801985:	83 c4 1c             	add    $0x1c,%esp
  801988:	5b                   	pop    %ebx
  801989:	5e                   	pop    %esi
  80198a:	5f                   	pop    %edi
  80198b:	5d                   	pop    %ebp
  80198c:	c3                   	ret    
  80198d:	8d 76 00             	lea    0x0(%esi),%esi
  801990:	29 f9                	sub    %edi,%ecx
  801992:	19 d6                	sbb    %edx,%esi
  801994:	89 74 24 04          	mov    %esi,0x4(%esp)
  801998:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80199c:	e9 18 ff ff ff       	jmp    8018b9 <__umoddi3+0x69>
