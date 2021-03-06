#include "ns.h"

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
	binaryname = "ns_input";

	// LAB 6: Your code here:
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
    uint8_t data[2048];
    int length, r;

    for (;;) {
        while ((length = sys_pkt_receive(data)) < 0)
            sys_yield();

        while (sys_page_alloc(0, &nsipcbuf, PTE_P | PTE_W | PTE_U) < 0)
            sys_yield();

        nsipcbuf.pkt.jp_len = length;
        memmove(nsipcbuf.pkt.jp_data, data, length);

        while (sys_ipc_try_send(ns_envid, NSREQ_INPUT, &nsipcbuf, PTE_P | PTE_W | PTE_U) < 0)
            sys_yield();
    }
}
