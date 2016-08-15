/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
  TRAPHANDLER_NOEC(_divide_error, T_DIVIDE);
  TRAPHANDLER_NOEC(_debug, T_DEBUG);
  TRAPHANDLER_NOEC(_non_maskable_interrupt, T_NMI);
  TRAPHANDLER_NOEC(_breakpoint, T_BRKPT);
  TRAPHANDLER_NOEC(_overflow, T_OFLOW);
  TRAPHANDLER_NOEC(_bound_range_exceeded, T_BOUND);
  TRAPHANDLER_NOEC(_invalid_opcode, T_ILLOP);
  TRAPHANDLER_NOEC(_device_not_available, T_DEVICE);
  TRAPHANDLER(_double_fault, T_DBLFLT);

  TRAPHANDLER(_invalid_tss, T_TSS);
  TRAPHANDLER(_segment_not_present, T_SEGNP);
  TRAPHANDLER(_stack_fault, T_STACK);
  TRAPHANDLER(_general_protection, T_GPFLT);
  TRAPHANDLER(_page_fault, T_PGFLT);

  TRAPHANDLER_NOEC(_x87_fpu_error, T_FPERR);
  TRAPHANDLER(_alignment_check, T_ALIGN);
  TRAPHANDLER_NOEC(_machine_check, T_MCHK);
  TRAPHANDLER_NOEC(_simd_fp_exception, T_SIMDERR );


.globl sysenter_handler;
.type sysenter_handler, @function;
.align 2;
sysenter_handler:
/*
 * Lab 3: Your code here for system call handling
 */
   pushl $GD_UD
   pushl %ebp
   pushfl
   pushl $GD_UT
   pushl %esi
   pushl $0
 	 pushl $0

   pushw $0    # uint16_t tf_padding2
   pushw %ds
   pushw $0    # uint16_t tf_padding1
   pushw %es
   pushal

   movw $GD_KD, %ax
   movw %ax, %ds
   movw %ax, %es
   pushl %esp

   call syscall_helper

   popl %esp
   popal
   popw %cx  # eliminate padding
   popw %es
   popw %cx  # eliminate padding
   popw %ds

   movl %ebp, %ecx
   movl %esi, %edx
   sysexit

/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:
  pushw $0    # uint16_t tf_padding2
	pushw %ds
	pushw $0    # uint16_t tf_padding1
	pushw %es
	pushal

  movl $GD_KD, %eax
	movw %ax, %ds
	movw %ax, %es
	pushl %esp

	call trap
