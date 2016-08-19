// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(vpd[PDX(addr)] & PTE_P) || !(vpt[PGNUM(addr)] & PTE_COW)) {
		panic("Faulting access is not a write to COW page.");
	}

	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_U | PTE_W | PTE_P);
	if (r) {
		panic("pgfault alloc new page failed %e", r);
	}
	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
	r = sys_page_map(0, (void *)PFTEMP,
				0, (void *)ROUNDDOWN(addr, PGSIZE), PTE_U | PTE_W | PTE_P);
	if (r) {
		panic("pgfault map pages failed %e", r);
	}
	// panic("pgfault not implemented");
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	int perm = PTE_U | PTE_P;
	void *pn_addr = (void *)(pn * PGSIZE);
	pte_t pte = vpt[PGNUM(pn_addr)];
	if ((pte & PTE_COW) || (pte & PTE_W)) {
		perm |= PTE_COW;
		r = sys_page_map(0, pn_addr, envid, pn_addr, perm);
		if (r) {
			panic("duppage sys_page_map 1/2 failed %e", r);
		}
		// TODO: Still don't know why
		r = sys_page_map(0, pn_addr, 0, pn_addr, perm);
		if (r) {
			panic("duppage sys_page_map 2/2 failed %e", r);
		}
	} else {
		r = sys_page_map(0, pn_addr, envid, pn_addr, perm);
		if (r) {
			panic("duppage sys_page_map 1/1 failed %e", r);
		}
	}
	// panic("duppage not implemented");
	return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use vpd, vpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);

	int r;
	envid_t child_id;
	child_id = sys_exofork();
	if (child_id < 0) {
		return -1;
	} else if (!child_id) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	} else {
		size_t pn;
		pde_t pde;
		pte_t pte;

		for (pn = UTEXT / PGSIZE; pn < (UTOP - PGSIZE) / PGSIZE; pn++) {
			if ((vpd[pn / NPTENTRIES] & PTE_P) &&
					(vpt[pn] & PTE_P) && (vpt[pn] & PTE_U)) {
				duppage(child_id, pn);
			}
		}

		r = sys_page_alloc(child_id, (void *)(UTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
		if (r) {
			panic("fork sys_page_alloc failed %e", r);
		}

		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(child_id, _pgfault_upcall);
		if (r) {
			panic("fork sys_env_set_pgfault_upcall failed %e", r);
		}

		r = sys_env_set_status(child_id, ENV_RUNNABLE);
		if (r) {
			panic("fork sys_env_set_status failed %e", r);
		}
		return child_id;
	}
	// panic("fork not implemented");
}

// Challenge!
int
sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}
