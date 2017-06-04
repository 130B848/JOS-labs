#ifndef JOS_KERN_E1000_H
#define JOS_KERN_E1000_H

#include <kern/pci.h>

#include <inc/error.h>

#include <inc/memlayout.h>

volatile uint32_t *volatile e1000_ptr;

#define E1000_VENDOR_ID 0x8086
#define E1000_DEVICE_ID 0x100E

#define TX_MAX_PKT_LEN 1518
#define TX_ARRAY_LEN 64

#define RX_MAX_PKT_LEN 2048
#define RX_ARRAY_LEN 128

#define E1000_STATUS   (0x00008 / sizeof(e1000_ptr))  /* Device Status - RO */
#define E1000_TCTL     (0x00400 / sizeof(e1000_ptr))  /* TX Control - RW */
#define E1000_TIPG     (0x00410 / sizeof(e1000_ptr))  /* TX Inter-packet gap -RW */
#define E1000_RCTL     (0x00100 / sizeof(e1000_ptr))  /* RX Control - RW */
#define E1000_EERD     (0x00014 / sizeof(e1000_ptr))  /* EEPROM Read - RW */

#define E1000_EEPROM_RW_REG_DONE   0x10 /* Offset to READ/WRITE done bit */
#define E1000_EEPROM_RW_REG_START  1    /* First bit for telling part to start operation */

#define E1000_TDBAL    (0x03800 / sizeof(e1000_ptr))  /* TX Descriptor Base Address Low - RW */
#define E1000_TDBAH    (0x03804 / sizeof(e1000_ptr))  /* TX Descriptor Base Address High - RW */
#define E1000_TDLEN    (0x03808 / sizeof(e1000_ptr))  /* TX Descriptor Length - RW */
#define E1000_TDH      (0x03810 / sizeof(e1000_ptr))  /* TX Descriptor Head - RW */
#define E1000_TDT      (0x03818 / sizeof(e1000_ptr))  /* TX Descripotr Tail - RW */

#define E1000_RDBAL    (0x02800 / sizeof(e1000_ptr))  /* RX Descriptor Base Address Low - RW */
#define E1000_RDBAH    (0x02804 / sizeof(e1000_ptr))  /* RX Descriptor Base Address High - RW */
#define E1000_RDLEN    (0x02808 / sizeof(e1000_ptr))  /* RX Descriptor Length - RW */
#define E1000_RDH      (0x02810 / sizeof(e1000_ptr))  /* RX Descriptor Head - RW */
#define E1000_RDT      (0x02818 / sizeof(e1000_ptr))  /* RX Descriptor Tail - RW */

/* Transmit Control */
#define E1000_TCTL_EN     (0x1 << 1)      /* enable tx */
#define E1000_TCTL_PSP    (0x1 << 3)      /* pad short packets */
#define E1000_TCTL_CT     (0x10 << 4)     /* collision threshold */
#define E1000_TCTL_COLD   (0x40 << 12)    /* collision distance */

/* Receive Control */
#define E1000_RCTL_EN     (0x1 << 1)    /* enable */
#define E1000_RCTL_LPE    (0x1 << 5)    /* long packet enable */
#define E1000_RCTL_LBM    (0x3 << 6)    /* loopback mode */
#define E1000_RCTL_RDMTS  (0x3 << 8)    /* rx desc min threshold size */
#define E1000_RCTL_MO     (0x3 << 12)   /* multicast offset 11:0 */
#define E1000_RCTL_BAM    (0x1 << 15)   /* broadcast enable */
#define E1000_RCTL_BSIZE  (0x3 << 16)   /* receive buffer size */
#define E1000_RCTL_SECRC  (0x1 << 26)   /* strip ethernet */

/* TIPG bit definitions */
#define E1000_TIPG_IPGT   0xA
#define E1000_TIPG_IPGR1  (0x4 << 10) 
#define E1000_TIPG_IPGR2  (0x6 << 20) 

/* Transmit Descriptor bit definitions */
#define E1000_TXD_CMD_EOP    0x1        /* End of Packet */
#define E1000_TXD_CMD_RS     (0x1 << 3) /* Report Status */
#define E1000_TXD_STAT_DD    0x00000001 /* Descriptor Done */

/* Receive Descriptor bit definitions */
#define E1000_RXD_STAT_DD       0x01    /* Descriptor Done */
#define E1000_RXD_STAT_EOP      0x02    /* End of Packet */

/* Receive Address Low & High */
#define E1000_RAL       (0x5400 / sizeof(e1000_ptr))
#define E1000_RAH       (0x5404 / sizeof(e1000_ptr))
#define E1000_RAH_AV    (0x1 << 31)

struct tx_desc {
    uint64_t addr;
    uint16_t length;
    uint8_t cso;
    uint8_t cmd;
    uint8_t status;
    uint8_t css;
    uint16_t special;
};

struct tx_pkt {
    uint8_t pkt[TX_MAX_PKT_LEN];
};

struct rx_desc {
    uint64_t addr;
    uint16_t length;
    uint16_t checksum;
    uint8_t status;
    uint8_t errors;
    uint16_t special;
};

struct rx_pkt {
    uint8_t pkt[RX_MAX_PKT_LEN];
};

int e1000_attach(struct pci_func *pcif);
int e1000_transmit(uint8_t *data, uint32_t length);
int e1000_receive(uint8_t *data);

#endif	// JOS_KERN_E1000_H
