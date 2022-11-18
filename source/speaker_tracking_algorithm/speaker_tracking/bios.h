/***********************************************************************

    bios.h - D.Module.C671x BIOS Header File

    Revision    1.2
    Company     D.SignT
    Author      Adolf Klemenz
    Created     18 Jun 2003

    Hardware    D.Module.C6711,6713 Rev.1
    Compiler    TI Code Composer Studio
    Options

    History     1.0 initial release 11 Feb 2003 by AK
                1.1 EMIF clock changed to 100 MHz ext. 12 May 2003 AK
                1.2 changed .svf programming algorithm to match
                    Xilinx tools 5.x
                    install_interrupt() changed to QDMA use
                    18 Jun 2003 by AK

***********************************************************************/
#ifndef _BIOS_
#define _BIOS_


/***********************************************************************
  C6000 Control Registers
***********************************************************************/
extern cregister volatile unsigned int CSR; /* Control Status Register    */
extern cregister volatile unsigned int IFR; /* Interrupt Flag Register    */
extern cregister volatile unsigned int ISR; /* Interrupt Set Register     */
extern cregister volatile unsigned int ICR; /* Interrupt Clear Register   */
extern cregister volatile unsigned int IER; /* Interrupt Enable Register  */
extern cregister volatile unsigned int ISTP;/* Interrupt Service Tbl Ptr  */
extern cregister volatile unsigned int IRP; /* Interrupt Return Pointer   */
extern cregister volatile unsigned int NRP; /* Non-maskable Int Return Ptr*/



/***********************************************************************
   type definitions for access to DSP on-chip peripherals
***********************************************************************/
typedef struct
{
    volatile unsigned int gblctl;
    volatile unsigned int cectl1;
    volatile unsigned int cectl0;
    int rsvd1;
    volatile unsigned int cectl2;
    volatile unsigned int cectl3;
    volatile unsigned int sdctl;
    volatile unsigned int sdtim;
    volatile unsigned int sdext;
} dsp_emif_struct;
#define EMIF ((dsp_emif_struct *) ((int*) 0x1800000))


typedef struct
{
    volatile unsigned int ccfg;
    int rsvd1[0xFFF];
    volatile unsigned int l2wbar;
    volatile unsigned int l2wwc;
    int rsvd2[2];
    volatile unsigned int l2wibar;
    volatile unsigned int l2wiwc;
    int rsvd3[2];
    volatile unsigned int l1pibar;
    volatile unsigned int l1piwc;
    int rsvd4[2];
    volatile unsigned int l1dwibar;
    volatile unsigned int l1dwiwc;
    int rsvd5[0x3F2];
    volatile unsigned int l2wb;
    volatile unsigned int l2wbinv;
    int rsvd6[0xC7E];
    volatile unsigned int mar0;
    volatile unsigned int mar1;
    volatile unsigned int mar2;
    volatile unsigned int mar3;
    int rsvd7[0x0C];
    volatile unsigned int mar4;
    volatile unsigned int mar5;
    volatile unsigned int mar6;
    volatile unsigned int mar7;
    int rsvd8[0x0C];
    volatile unsigned int mar8;
    volatile unsigned int mar9;
    volatile unsigned int mar10;
    volatile unsigned int mar11;
    int rsvd9[0x0C];
    volatile unsigned int mar12;
    volatile unsigned int mar13;
    volatile unsigned int mar14;
    volatile unsigned int mar15;
} dsp_cache_struct;
#define CACHE ((dsp_cache_struct *) ((int*) 0x1840000))


typedef struct
{
    volatile int muxh;
    volatile int muxl;
    volatile int extpol;
} dsp_intmux_struct;
#define INTMUX ((dsp_intmux_struct *) ((int*) 0x19C0000))


#define DEVCFG *(volatile unsigned int *) 0x19C0200;


typedef struct
{
    volatile unsigned int opt;
    volatile unsigned int src;
    volatile unsigned int frm_elecnt;
    volatile unsigned int dst;
    volatile unsigned int frm_eleidx;
    volatile unsigned int elerld_link;
} dsp_edma_param_struct;

typedef struct
{
    dsp_edma_param_struct event0;
    dsp_edma_param_struct event1;
    dsp_edma_param_struct event2;
    dsp_edma_param_struct event3;
    dsp_edma_param_struct event4;
    dsp_edma_param_struct event5;
    dsp_edma_param_struct event6;
    dsp_edma_param_struct event7;
    dsp_edma_param_struct event8;
    dsp_edma_param_struct event9;
    dsp_edma_param_struct event10;
    dsp_edma_param_struct event11;
    dsp_edma_param_struct event12;
    dsp_edma_param_struct event13;
    dsp_edma_param_struct event14;
    dsp_edma_param_struct event15;
    unsigned int rsvd[288];
    dsp_edma_param_struct reload[84];
    volatile unsigned int scratch1;
    volatile unsigned int scratch2;
} dsp_edma_paramram_struct;
#define EDMA_PARAMRAM ((dsp_edma_paramram_struct *) ((int*) 0x1A00000))


typedef struct
{
    volatile unsigned int pqsr;
    volatile unsigned int cipr;
    volatile unsigned int cier;
    volatile unsigned int ccer;
    volatile unsigned int er;
    volatile unsigned int eer;
    volatile unsigned int ecr;
    volatile unsigned int esr;
} dsp_edma_struct;
#define EDMA ((dsp_edma_struct *) ((int*) 0x1A0FFE0))


typedef struct
{
    volatile unsigned int qopt;
    volatile unsigned int qsrc;
    volatile unsigned int qcnt;
    volatile unsigned int qdst;
    volatile unsigned int qidx;
    int rsvd[3];
    volatile unsigned int qsopt;
    volatile unsigned int qssrc;
    volatile unsigned int qscnt;
    volatile unsigned int qsdst;
    volatile unsigned int qsidx;
} dsp_qdma_struct;
#define QDMA ((dsp_qdma_struct *) ((int*) 0x02000000))


typedef struct
{
    volatile unsigned int pllpid;
    int rsvd1[0x3F];
    volatile unsigned int pllcsr;
    int rsvd2[0x03];
    volatile unsigned int pllm;
    volatile unsigned int plldiv0;
    volatile unsigned int plldiv1;
    volatile unsigned int plldiv2;
    volatile unsigned int plldiv3;
    volatile unsigned int oscdiv1;
} dsp_pll_struct;
#define PLL ((dsp_pll_struct *) ((int*) 0x01B7C000))


typedef struct
{
    volatile unsigned int i2coar;
    volatile unsigned int i2cier;
    volatile unsigned int i2cstr;
    volatile unsigned int i2cclkl;
    volatile unsigned int i2cclkh;
    volatile unsigned int i2ccnt;
    volatile unsigned int i2cdrr;
    volatile unsigned int i2csar;
    volatile unsigned int i2cdxr;
    volatile unsigned int i2cmdr;
    volatile unsigned int i2cisrc;
    int rsvd;
    volatile unsigned int i2cpsc;
    volatile unsigned int i2cpid1;
    volatile unsigned int i2cpid2;
} dsp_i2c_struct;
#define I2C(n) ((dsp_i2c_struct *) ((int*) (0x01B40000+0x400*n)))


#define HPIC *(volatile unsigned int*) 0x1880000


typedef struct
{
    volatile int ctl;
    volatile int prd;
    volatile int cnt;
} dsp_timer_struct;
#define TIMER(n) ((dsp_timer_struct *) ((int*) (0x1940000+0x40000*n)))



typedef struct
{
    volatile int drr;
    volatile int dxr;
    volatile int spcr;
    volatile int rcr;
    volatile int xcr;
    volatile int srgr;
    volatile int mcr;
    volatile int rcer;
    volatile int xcer;
    volatile int pcr;
} dsp_mcbsp_struct;
#define MCBSP(n) ((dsp_mcbsp_struct *) ((int*) (0x18C0000+0x40000*n)))

#define MCBSPDATA(n) *(volatile unsigned int*) (0x30000000+0x4000000*n)


typedef struct
{
    volatile unsigned int gpen;
    volatile unsigned int gpdir;
    volatile unsigned int gpval;
    int rsvd;
    volatile unsigned int gpdh;
    volatile unsigned int gphm;
    volatile unsigned int gpdl;
    volatile unsigned int gplm;
    volatile unsigned int gpgc;
    volatile unsigned int gppol;
} dsp_gpio_struct;
#define GPIO ((dsp_gpio_struct *) ((int*) 0x1B00000))



/***********************************************************************
   C6713 memory mapping
***********************************************************************/
#define IRAM_BASE   0x00000000
#define CE0_BASE    0x80000000
#define CE1_BASE    0x90000000
#define CE2_BASE    0xA0000000
#define CE3_BASE    0xB0000000

#define SBSRAM_BASE CE0_BASE
#define SBSRAM_SIZE 0x00080000
#define SDRAM_BASE  CE3_BASE
#define SDRAM_SIZE  0x01000000

#define CPLD_BASE   0x90200000
#define IOSEL_BASE  0x90300000
#define MEMSEL_BASE CE2_BASE



/***********************************************************************
   UART 
***********************************************************************/
typedef struct
{
    unsigned int baud;      /* 200 .. 460800 */
    unsigned int databits;  /* 5,6,7,8       */
    unsigned int parity;    /* 'N','O','E'   */
    unsigned int stopbits;  /* 1,2           */
    unsigned int handshake; /* 'N','R','X'   */
    unsigned int Xon;       /* default: 0x11 */
    unsigned int Xoff;      /* default: 0x13 */
} uart_init_struct;


typedef struct
  {
    union
      {
	      volatile char dll_;
	      volatile char rhr_;
	      volatile char thr_;
      } adr0_0;
    char adr0_1;
    char adr0_2;
    char adr0_3;
    union
      {
	      volatile char dlm_;
	      volatile char ier_;
      } adr1_0;
    char adr1_1;
    char adr1_2;
    char adr1_3;
    union
      {
	      volatile char isr_;
	      volatile char fcr_;
	      volatile char efr_;
      } adr2_0;
    char adr2_1;
    char adr2_2;
    char adr2_3;
    volatile char lcr_;
    char adr3_1;
    char adr3_2;
    char adr3_3;
    union
      {
        volatile char mcr_;
        volatile char xon1_;
      } adr4_0;
    char adr4_1;
    char adr4_2;
    char adr4_3;
    union
      {
        volatile char lsr_;
        volatile char xon2_;
      } adr5_0;
    char adr5_1;
    char adr5_2;
    char adr5_3;
    union
      {
        volatile char msr_;
        volatile char xoff1_;
      } adr6_0;
    char adr6_1;
    char adr6_2;
    char adr6_3;
    union
      {
        volatile char spr_;
        volatile char xoff2_;
      } adr7_0;
    char adr7_1;
    char adr7_2;
    char adr7_3;
  } uart_struct;
     
     
#define UART_RHR     adr0_0.rhr_
#define UART_THR     adr0_0.thr_
#define UART_IER     adr1_0.ier_
#define UART_ISR     adr2_0.isr_
#define UART_FCR     adr2_0.fcr_
#define UART_LCR     lcr_
#define UART_MCR     adr4_0.mcr_
#define UART_LSR     adr5_0.lsr_
#define UART_MSR     adr6_0.msr_
#define UART_SPR     adr7_0.spr_
#define UART_DLL     adr0_0.dll_
#define UART_DLM     adr1_0.dlm_
#define UART_EFR     adr2_0.efr_
#define UART_XON1    adr4_0.xon1_
#define UART_XON2    adr5_0.xon2_
#define UART_XOFF1   adr6_0.xoff1_
#define UART_XOFF2   adr7_0.xoff2_

#define UART ((uart_struct *) ((char*) 0x902C0000 ))



/***********************************************************************
   FLASH 
   Macro only valid for first 512 Kbytes !
***********************************************************************/
#define FLASH_BASE 0x90000000
#define FLASH(addr) (*(volatile char *)(FLASH_BASE + 4*(addr)))


/***********************************************************************
   Module Configuration Register
***********************************************************************/
typedef struct
{
	volatile unsigned char cfg_reset;
	char rsvd1[3];
	volatile unsigned char cfg_intmux;
	char rsvd2[3];
	volatile unsigned char cfg_flashbank;
	char rsvd3[3];
	volatile unsigned char cfg_misc;
} module_cfg_struct;
#define CFG ((module_cfg_struct *) ((char*) 0x90280000 ))


#define CFG_RESETSOURCE  0x0001		/* read only */
#define CFG_nRESOUT      0x0002
#define CFG_CPLD_WAIT    0x0004
#define CFG_UART_RESET   0x0008
#define CFG_CPLD_nRESET  0x0010
#define CFG_WDOG_TRIGGER 0x0020		/* write only, 1 will toggle watchdog*/

#define CFG_INT5_nINT1      0x0000  /* external nINT1 mapped to DSP INT5 */
#define CFG_INT5_CPLD       0x0100  /* CPLD Interrupt mapped to DSP INT5 */
#define CFG_INT6_nINT2      0x0000  /* external nINT2 mapped to DSP INT6 */
#define CFG_INT6_CPLD       0x0200  /* CPLD Interrupt mapped to DSP INT6 */
#define CFG_INT6_UART       0x0400  /* UART interrupt mapped to DSP_INT6 */
#define CFG_INT6_UARTRXDMA  0x0600  /* UART RX DMA mapped to DSP INT6    */
#define CFG_INT7_nINT3      0x0000  /* external nINT3 mapped to DSP INT7 */
#define CFG_INT7_CPLD       0x0800  /* CPLD Interrupt mapped to DSP INT7 */
#define CFG_INT7_UART       0x1000  /* UART interrupt mapped to DSP_INT7 */
#define CFG_INT7_UARTTXDMA  0x1800  /* UART TX DMA mapped to DSP INT7    */

#define CFG_FLASH_BANK0		0x000000
#define CFG_FLASH_BANK1     0x010000
#define CFG_FLASH_BANK2		0x020000
#define CFG_FLASH_BANK3		0x030000


/***********************************************************************
   CPU Interrupts, use with install_interrupt()
***********************************************************************/
#ifndef CPU_INT_RST
#define CPU_INT_RST		0x00
#define CPU_INT_NMI 	0x01
#define CPU_INT_RSV1	0x02
#define CPU_INT_RSV2	0x03
#define CPU_INT4		0x04
#define CPU_INT5		0x05
#define CPU_INT6		0x06
#define CPU_INT7		0x07
#define CPU_INT8		0x08
#define CPU_INT9		0x09
#define CPU_INT10		0x0A
#define CPU_INT11		0x0B
#define CPU_INT12		0x0C
#define CPU_INT13		0x0D
#define CPU_INT14		0x0E
#define CPU_INT15		0x0F
#endif


/***********************************************************************
   offset type for low-level stdio driver
***********************************************************************/
#ifndef _OFF_T
#define _OFF_T
typedef int off_t;
#endif /* _OFF_T */
 


/***********************************************************************
   BIOS Function Prototypes
***********************************************************************/
far void init_module (int sdram_init);
far void bootload (unsigned int addr);

far void init_uart (uart_init_struct *uis);
far int  send_char (char c);
far char receive_char (void);
far int get_uart_rx_status (void);
far int get_uart_tx_status (void);
far void enable_uart_interrupt (char condition);

far int flash_get_device (void);
far int flash_sectorerase (unsigned int sector);
far int flash_write_char (unsigned addr_offs, char data);
far int flash_write_short (unsigned addr_offs, short data);
far int flash_write_int (unsigned addr_offs, int data);
far unsigned char flash_read_uchar (unsigned int addr_offs);
far char flash_read_char (unsigned int addr_offs);
far unsigned short flash_read_ushort (unsigned int addr_offs);
far short flash_read_short (unsigned int addr_offs);
far int flash_read_int (unsigned int addr_offs);

far void write_module_cfg (int cfg_settings);
far int get_module_cfg (void);
far void set_module_cfg (int cfg_settings);
far void clr_module_cfg (int cfg_settings);
far void watchdog_trigger (void);
far char *get_id (char *buffer);
far void delay (int msecs);
far void install_interrupt (int signal, void (*isr_func)(void));

far int uart_ioopen (const char *path, unsigned int flags, int fno);
far int uart_ioclose (int fno);
far int uart_ioread (int fno, char *buffer, unsigned int count);
far int uart_iowrite (int fno, const char *buffer, unsigned int count);
far off_t uart_iolseek (int fno, off_t offset, int origin);
far int uart_iorename (const char *oldname, const char *newname);
far int uart_iounlink (const char *path);

far int flash_ioopen (const char *path, unsigned int flags, int fno);
far int flash_ioclose (int fno);
far int flash_ioread (int fno, char *buffer, unsigned int count);
far int flash_iowrite (int fno, const char *buffer, unsigned int count);
far off_t flash_iolseek (int fno, off_t offset, int origin);
far int flash_iorename (const char *oldname, const char *newname);
far int flash_iounlink (const char *path);


/***********************************************************************
  BIOS Function Descriptions
***********************************************************************/

/***********************************************************************

    void init_module (int sdram_init)

    basic module initialization:
    - configure PLL
    - setup EMIF registers
    - clear filetable (stdio support for UART and Flash)

    Parameter   sdram_init: 1 = perform SDRAM initialization
                                (all data in SDRAM will be lost !)
                            0 = do not perform SDRAM initialization
                                (required if program contains initialized
                                 sections (code and/or data) in SDRAM
    Returns     -

***********************************************************************/
    
/***********************************************************************

    void bootload (unsigned int addr)

    bootload a program from Flash Memory

    Parameter   addr = address offset in Flash Memory
    Returns     never, the new program will be started

***********************************************************************/
    
/***********************************************************************

    void init_uart (uart_init_struct *uis)

    UART initialization

    Parameter   *uis = pointer to structure containing UART
                       initialization data
                       a NULL pointer will select the default
                       configuration (9600, 8N1, Xon/Xoff flow control)
    Returns     -

***********************************************************************/
    
/***********************************************************************

    int  send_char (char c)

    transmit a character via the UART

    Parameter   c = character to transmit
                a 0x800 will transmit a BREAK
    Returns     true (1)  if characer was stored in the UART
                          transmit buffer
                false (0) if transmit buffer was full

***********************************************************************/

/***********************************************************************

    char receive_char (void)

    receive a character via the UART

    Parameter   -
    Returns     character received, -1 if receive buffer empty

***********************************************************************/

/***********************************************************************

    int get_uart_rx_status (void)

    read status of UART receiver and modem status

    Parameter   -
    Returns     bit 0..7:   0 - receiver Fifo empty
                            1 - at least one charcter in recv. fifo
                bit 8..15:  modem status register
                            bit  8 CTS changed
                            bit  9 DSR changed
                            bit 10 RI changed
                            bit 11 CD changed
                            bit 12 CTS
                            bit 13 DSR (IN0 = nSETUP)
                            bit 14 RI (IN1)
                            bit 15 CD
                               
***********************************************************************/

/***********************************************************************

    int get_uart_tx_status (void)

    read status of UART transmitter
    
    Parameter   -
    Returns     UART transmitter status:
                    0 - transmit buffer full
                    1 - transmit buffer empty
                   -1 - transmit buffer AND shifter empty

***********************************************************************/
    
/***********************************************************************

    void enable_uart_interrupt (char condition)

    enable UART interrupt for the specified condition(s)
    switch UART interrupt to CPU_INT7

    Parameter   condition: 0     - none, interrupts disabled, INT7 = nINT3
                           bit 0 - receive interrupt
                           bit 1 - transmit interrupt
                           bit 3 - error interrupt
    Returns     -

***********************************************************************/
    
/***********************************************************************

    int flash_get_device (void)

    read Flash Memory manufacturer and device ID code

    Parameter   -
    Returns     manufacturer ID in bit 15..8
                device ID in bit 7..0

***********************************************************************/

/***********************************************************************

    flash_sectorerase (unsigned int sector)

    erase the specified Flash Memory Sector

    Parameter   sector to erase, valid sectors are 1..31
                sector 1 corresponds to Flash addresses 0x10000..0x1FFFF
                sector 2 corresponds to Flash addresses 0x20000..0x2FFFF
                etc
    Returns     true (1) if sector erase successful
                false (0) if timeout or invalid parameter

***********************************************************************/

/***********************************************************************

    int flash_write_char (unsigned addr_offs, char data)

    write an 8 bit byte to the Flash Memory

    Parameter   addr_offs - address offset in Flash Memory
                data      - byte to write
    Returns     true (1) if successful
                false (0) if timeout

***********************************************************************/

/***********************************************************************

    int flash_write_short (unsigned addr_offs, short data)

    write a 16 bit short to the Flash Memory

    Parameter   addr_offs - address offset in Flash Memory
                data      - short to write
    Returns     true (1) if successful
                false (0) if timeout

***********************************************************************/
    
/***********************************************************************

    int flash_write_int (unsigned addr_offs, int data)

    write a 32 bit integer to the Flash Memory

    Parameter   addr_offs - address offset in Flash Memory
                data      - integer to write
    Returns     true (1) if successful
                false (0) if timeout

***********************************************************************/

/***********************************************************************

    unsigned char flash_read_uchar (unsigned int addr_offs)

    read an unsigned char (8 bit) from Flash Memory

    Parameter   addr_offs - address offset in Flash Memory
    Returns     data read from Flash

***********************************************************************/

/***********************************************************************

    char flash_read_char (unsigned int addr_offs)

    read a signed char (8 bit) from Flash Memory

    Parameter   addr_offs - address offset in Flash Memory
    Returns     data read from Flash

***********************************************************************/

/***********************************************************************

    unsigned short flash_read_ushort (unsigned int addr_offs)

    read an unsigned short (16 bit) from Flash Memory

    Parameter   addr_offs - address offset in Flash Memory
    Returns     data read from Flash

***********************************************************************/

/***********************************************************************

    short flash_read_short (unsigned int addr_offs)

    read a signed short (16 bit) from Flash Memory

    Parameter   addr_offs - address offset in Flash Memory
    Returns     data read from Flash

***********************************************************************/

/***********************************************************************

    int flash_read_int (unsigned int addr_offs)

    read a signed or unsigned integer (32 bit) from Flash Memory

    Parameter   addr_offs - address offset in Flash Memory
    Returns     data read from Flash

***********************************************************************/

/***********************************************************************

    void write_module_cfg (int cfg_settings);

    write to the Module Configuration Register

    Parameter   cfg_settings = data to write to the Module Config Reg.
                               use onstants CFG_xxx
                               
                bit 0 - read only, no effect
                bit 1 - nRESOUT output (0=low, 1=high)
                bit 2 - sample nWAIT on User-CPLD access if bit is set
                bit 3 - UART reset if bit is set
                bit 4 - User-CPLD reset if bit is 0
                bit 5 - toggle watchdog trigger if bit is set
                bit 7,6   - not used, no effect
                bit 8     - CPU_INT5 multiplexer: 0=nINT1, 1=UserCPLD
                bit 10,9  - CPU_INT6 multiplexer:
                            00=nINT2, 01=UserCPLD, 10=UART, 11=UART_RxDMA
                bit 12,11 - CPU_INT7 multiplexer:
                            00=nINT3, 01=UserCPLD, 10=UART, 11=UART_TxDMA
                bit 15..13- not used, no effect
                bit 17,16 - Flash Memory Bank Select
                bit 23..18- not used, no effect
                bit 31..24- internal use only, always write as 0

    Returns     -

***********************************************************************/
    
/***********************************************************************

    int get_module_cfg (void)

    read state of Module Configuration Register

    Parameter   -
    Returns     bit 0     : reset source = 0 if power-on or manual reset,
                            1 if watchdog timeout
                bit 31..1 : see write_module_cfg()

***********************************************************************/

/***********************************************************************

    void set_module_cfg (int cfg_settings)

    set the specified bits in the Module Configuration Register

    Parameter   cfg_settings: bitmask, all '1' bits will be set in the
                              Module Configuration Register, all '0' bits
                              will remain unchanged

                              use CFG_xxx constants, refer to
                              write_module_cfg() for a description of the
                              individual bits
    Returns     -

***********************************************************************/
    
/***********************************************************************

    void clr_module_cfg (int cfg_settings)

    clear the specified bits in the Module Configuration Register

    Parameter   cfg_settings: bitmask, all '1' bits will be cleared in the
                              Module Configuration Register, all '0' bits
                              will remain unchanged

                              use CFG_xxx constants, refer to
                              write_module_cfg() for a description of the
                              individual bits
    Returns     -

***********************************************************************/

/***********************************************************************

    void watchdog_trigger (void)

    trigger watchdog

    Parameter   -
    Returns     -

***********************************************************************/

/***********************************************************************

    char *get_id (char *buffer)

    read module ID string

    Parameter   buffer to hold string
                 [0] - memory configuration
                       ' ' - no external memory on board
                       '1' - S1 memory configuration
                       '8' - D0 memory configuration
                       'B' - S1D0 memory configuration
                 [1] - HW revision mayor
                 [2] - HW revision minor
                 [3] - BIOS revision mayor
                 [4] - BIOS revision minor
                 [5] - terminating '\0'
    Returns     pointer to buffer

***********************************************************************/

/***********************************************************************

    void delay (unsigned int msecs)

    waste time... delay is based on the DSP Clock defined in the
    Module Configuration File

    Parameter   msecs - delay in milli-seconds
    Returns     -

***********************************************************************/

/***********************************************************************

   void install_interrupt (int signal, void (*isr_func)(void))

   install interrupt handler and enable interrupt
   remember that NMI must be enabled and GIE bit must be set before
   interrupts are processed by the DSP

   This function only works with the default interrupt vector table
   at addres 0.  Do not use if you linked your own IVT to the program
   or re-allocated the IVT !
   
   Parameter   signal   - interrupt source, use CPU_INTx
               isr_func - pointer to interrupt service function
                          (this function must be compiled with
                           interrupt qualifier to generate correct code)
                          If a NULL pointer is passed, the interrupt
                          will be disabled
   Returns     -

***********************************************************************/

/***********************************************************************

   STDIO DEVICE DRIVERS

   _uart_ioopen
   _uart_ioclose
   _uart_ioread
   _uart_iowrite
   _uart_iolseek       not implemented, UART is not a block device
   _uart_iorename      not implemented, UART file cannot be renamed
   _uart_iounlink      not implemented, UART file cannot be deleted

   _flash_ioopen
   _flash_ioclose
   _flash_ioread
   _flash_iolseek
   _flash_iowrite      not implemented, Flash file is read-only
   _flash_iorename     not implemented, Flash file cannot be renamed
   _flash_iounlink     not implemented, Flash file cannot be deleted

   use these functions with the add_device() function to install the
   device driver.

***********************************************************************/


    
/***********************************************************************
   BIOS Function Call Addresses
***********************************************************************/
asm ("_bootload                 .equ 00000200h");
asm ("_init_module              .equ 00000314h");
asm ("_init_uart                .equ 00000500h");
asm ("_send_char                .equ 00000650h");
asm ("_receive_char             .equ 000006f0h");
asm ("_get_uart_tx_status       .equ 00000728h");
asm ("_get_uart_rx_status       .equ 0000074ch");
asm ("_enable_uart_interrupt    .equ 00000770h");
asm ("_flash_get_device         .equ 000007a0h");
asm ("_flash_sectorerase        .equ 000007e4h");
asm ("_flash_write_char         .equ 000008d0h");
asm ("_flash_write_short        .equ 0000097ch");
asm ("_flash_write_int          .equ 000009bch");
asm ("_flash_read_uchar         .equ 00000a2ch");
asm ("_flash_read_char          .equ 00000a58h");
asm ("_flash_read_ushort        .equ 00000a84h");
asm ("_flash_read_short         .equ 00000ac0h");
asm ("_flash_read_int           .equ 00000b00h");
asm ("_write_module_cfg         .equ 00000b5ch");
asm ("_get_module_cfg           .equ 00000b84h");
asm ("_set_module_cfg           .equ 00000bc8h");
asm ("_clr_module_cfg           .equ 00000bf0h");
asm ("_watchdog_trigger         .equ 00000c18h");
asm ("_get_id                   .equ 00000c34h");
asm ("_delay                    .equ 00000c9ch");
asm ("_install_interrupt        .equ 00000cech");
asm ("_uart_ioopen              .equ 00000d98h");
asm ("_uart_ioclose             .equ 00000ddch");
asm ("_uart_ioread              .equ 00000e20h");
asm ("_uart_iowrite             .equ 00000e6ch");
asm ("_flash_ioclose            .equ 00000ed0h");
asm ("_flash_ioread             .equ 00000ef0h");
asm ("_uart_iolseek             .equ 00000f6ch");
asm ("_flash_iowrite            .equ 00000f6ch");
asm ("_flash_iounlink           .equ 00000f6ch");
asm ("_uart_iorename            .equ 00000f6ch");
asm ("_uart_iounlink            .equ 00000f6ch");
asm ("_flash_iorename           .equ 00000f6ch");
asm ("_flash_ioopen             .equ 00000f78h");
asm ("_flash_iolseek            .equ 0000105ch");

/***********************************************************************
    BIOS data
***********************************************************************/
asm ("_dsp_clock    .equ 01180h");
    

#endif /*_BIOS_*/


