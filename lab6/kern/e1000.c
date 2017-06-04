#include <kern/e1000.h>
#include <kern/pmap.h>

#include <inc/string.h>

struct tx_desc tx_desc_buf[TX_ARRAY_LEN] __attribute__((aligned(16)));
struct tx_pkt tx_pkt_buf[TX_ARRAY_LEN] __attribute__((aligned(16)));

struct rx_desc rx_desc_buf[RX_ARRAY_LEN] __attribute__((aligned(16)));
struct rx_pkt rx_pkt_buf[RX_ARRAY_LEN] __attribute__((aligned(16)));

void e1000_mem_init() {
    memset(tx_desc_buf, 0, sizeof(struct tx_desc) * TX_ARRAY_LEN);
    memset(tx_pkt_buf, 0, sizeof(struct tx_pkt) * TX_ARRAY_LEN);

    int i;
    for (i = 0; i < TX_ARRAY_LEN; i++) {
        tx_desc_buf[i].addr = PADDR(tx_pkt_buf[i].pkt);
        tx_desc_buf[i].status |= E1000_TXD_STAT_DD;
    }

    memset(rx_desc_buf, 0, sizeof(struct rx_desc) * RX_ARRAY_LEN);
    memset(rx_pkt_buf, 0, sizeof(struct rx_pkt) * RX_ARRAY_LEN);
    
    for (i = 0; i < RX_ARRAY_LEN; i++) {
        rx_desc_buf[i].addr = PADDR(rx_pkt_buf[i].pkt);
    }
}

void x_init() {
    e1000_ptr[E1000_TDBAL] = PADDR(tx_desc_buf);
    e1000_ptr[E1000_TDBAH] = 0;
    e1000_ptr[E1000_TDLEN] = sizeof(struct tx_desc) * TX_ARRAY_LEN;
    e1000_ptr[E1000_TDH]   = 0;
    e1000_ptr[E1000_TDT]   = 0;

    // TCTL part
    e1000_ptr[E1000_TCTL] |= (E1000_TCTL_EN | E1000_TCTL_PSP | E1000_TCTL_CT | E1000_TCTL_COLD);

    // TIPG part
    e1000_ptr[E1000_TIPG] = (0 | E1000_TIPG_IPGT | E1000_TIPG_IPGR1 | E1000_TIPG_IPGR2);

    // Bind MAC address
    e1000_ptr[E1000_RAL] = 0x12005452;
    e1000_ptr[E1000_RAH] = (0x00005634 | E1000_RAH_AV);

    e1000_ptr[E1000_RDBAL] = PADDR(rx_desc_buf);
    e1000_ptr[E1000_RDBAH] = 0;
    e1000_ptr[E1000_RDLEN] = sizeof(struct rx_desc) * RX_ARRAY_LEN;
    e1000_ptr[E1000_RDH]   = 0; // first valid rx_desc
    e1000_ptr[E1000_RDT]   = RX_ARRAY_LEN - 1;
    
    e1000_ptr[E1000_RCTL]  =  E1000_RCTL_EN;
    e1000_ptr[E1000_RCTL] &= ~E1000_RCTL_LPE;
    e1000_ptr[E1000_RCTL] &= ~E1000_RCTL_LBM;
    e1000_ptr[E1000_RCTL] &= ~E1000_RCTL_RDMTS;
    e1000_ptr[E1000_RCTL] &= ~E1000_RCTL_MO;
    e1000_ptr[E1000_RCTL] |=  E1000_RCTL_BAM;
    e1000_ptr[E1000_RCTL] &= ~E1000_RCTL_BSIZE;
    e1000_ptr[E1000_RCTL] |=  E1000_RCTL_SECRC;
}

int e1000_transmit(uint8_t *data, uint32_t length) {
    if (length > TX_MAX_PKT_LEN) {
        cprintf("e1000_transmit: too long\n");
        return -E_PKT_TOO_LONG;
    }

    uint32_t TDT = e1000_ptr[E1000_TDT];
    struct tx_desc desc = tx_desc_buf[TDT];
    if (!(desc.status & E1000_TXD_STAT_DD)) {
        cprintf("e1000_transmit: full\n");
        return -E_TX_FULL;
    }

    memmove(tx_pkt_buf[TDT].pkt, data, length);
    
    desc.length = length;
    desc.status &= ~E1000_TXD_STAT_DD;
    desc.cmd |= (E1000_TXD_CMD_RS | E1000_TXD_CMD_EOP);
    tx_desc_buf[TDT] = desc;

    e1000_ptr[E1000_TDT] = (TDT + 1) % TX_ARRAY_LEN;

    return 0;
}

int e1000_receive(uint8_t *data) {
    uint8_t RDT = (e1000_ptr[E1000_RDT] + 1) % RX_ARRAY_LEN;
    struct rx_desc desc = rx_desc_buf[RDT];
    //cprintf("receive length = %d\n", desc.length);
    if (!(desc.status & E1000_RXD_STAT_DD)) {
        return -E_RCV_EMPTY;
    }

    memmove(data, rx_pkt_buf[RDT].pkt, desc.length);
    desc.status &= (~E1000_RXD_STAT_DD | ~E1000_RXD_STAT_EOP);
    e1000_ptr[E1000_RDT] = RDT;
    return desc.length;
}

// LAB 6: Your driver code here
int e1000_attach(struct pci_func *pcif) {
    pci_func_enable(pcif);
    e1000_mem_init();

    boot_map_region(kern_pgdir, KSTACKTOP, pcif->reg_size[0], pcif->reg_base[0], PTE_PCD | PTE_PWT | PTE_W);
    e1000_ptr = (uint32_t *)KSTACKTOP;
    assert(e1000_ptr[E1000_STATUS] == 0x80080783);

    x_init();

    return 0;
}
