/*
 * set_edma.c: all functions/interrupts for EDMA-handling
 * @author Jens Reermann
 * @version 1.0
 * @date 30.06.2013
 *
 * @based on:
 * PCM3003 Demo Program (8 channels, EDMA ping-pong buffer processing)
 * author    A.Klemenz
 * company   D.SignT
 * revision  1.1
 * date      2008-11-06
 * hardware  D.Module.6713
 * compiler  TI CCS 3.3
 * history   1.0 intial release 2005-02-17 by AK
 *           1.1 changed buffer signalling to allow buffer display in CCS
 *               2008-11-06 by AK
 *           1.2 adapted for D.Module.6713+PCM3003 with EDMA
 *               2009-11-03 by US
 */

#include "bios.h"
#include "set_edma.h"

extern volatile short adcbuffer[N_CHANNEL][2][N_BLOCK];
extern volatile short dacbuffer[N_CHANNEL][2][N_BLOCK];
extern volatile int newdat;
extern volatile int block;


/**
 *   edma_complete_int: edma complete interrupt
 *
 *   check which EDMA is completed (Ping or Pong Buffer EDMA), set global variable block
 *   transfer complete code - action
 *   13                     - Receive EDMA in block 0 complete
 *    3                     - Receive EDMA in block 1 complete
 *   further GPIO 15 is set and reset
 */
interrupt void edma_complete_int (void)
{
    if (EDMA->cipr & 1<<13)
    {
		GPIO->gpval &= ~(1<<15);//reset	
        EDMA->cipr = (1<<13);
        block = 0;
    }   
    if (EDMA->cipr & 1<<3)
    {
		GPIO->gpval |= (1<<15);	//set
        EDMA->cipr = (1<<3);
        block = 1;
    }
}

/**
 *   set_edma: set all EDMA-parameters
 *
 *   all EDMA-paremters are set
 *
 */
void set_edma(void)
{
/******************************************************************
      configure McBSP0 and McBSP1 transmitter and receiver:
        external clock and framesync
        two 16 bit data words per frame
        frame sync active high, one clock delay to data MSB
        write data on CLK falling edge, read on rising edge
    ******************************************************************/
    MCBSP(0)->spcr = MCBSP(1)->spcr = 0x02000000;	//Serial Port Control Register
    MCBSP(0)->rcr  = MCBSP(1)->rcr  = 0x00010140;	//Receive Control Register
    MCBSP(0)->xcr  = MCBSP(1)->xcr  = 0x00010140;	//Transmit Control Register
    MCBSP(0)->pcr  = MCBSP(1)->pcr  = 0x03;			//Pin Control Register
    MCBSP(0)->spcr = MCBSP(1)->spcr = 0x02010001;
    
    /******************************************************************
      configure EDMA 
        channel 12: XEVT0
        channel 13: REVT0
        channel 14: XEVT1
        channel 15: REVT1
        
      TCC codes: channel 12: 12 for block 0, 2 for block 1
                 channel 13: 13 for block 0, 3 for block 1
                 channel 14: 14 for block 0, 4 for block 1
                 channel 15: 15 for block 0, 5 for block 1
    ******************************************************************/
    //  clear and disable EDMA channel 12, 13, 14, and 15 events
    EDMA->eer &= ~((1<<12) | (1<<13) | (1<<14) | (1<<15));
    EDMA->ecr = ((1<<12) | (1<<13) | (1<<14) | (1<<15));

    // ping-pong buffer for XEVT0
    EDMA_PARAMRAM->event12.opt           = 0x2B100002 | (12 << 16);
    EDMA_PARAMRAM->reload[0].opt         = 0x2B100002 | ( 2 << 16);
    EDMA_PARAMRAM->reload[1].opt         = 0x2B100002 | (12 << 16);
    
    EDMA_PARAMRAM->event12.frm_elecnt    = 
    EDMA_PARAMRAM->reload[0].frm_elecnt  = 
    EDMA_PARAMRAM->reload[1].frm_elecnt  = ((N_BLOCK-1)<<16) | 4;				//FRMCNT=N_BLOCK-1, ELECNT=4
    
    EDMA_PARAMRAM->event12.dst           = 
    EDMA_PARAMRAM->reload[0].dst         = 
    EDMA_PARAMRAM->reload[1].dst         = (unsigned int)&MCBSP(0)->dxr;
    
    EDMA_PARAMRAM->event12.frm_eleidx    =
    EDMA_PARAMRAM->reload[0].frm_eleidx  = 
    EDMA_PARAMRAM->reload[1].frm_eleidx  = (-sizeof(short)*(3*2*N_BLOCK-1) << 16) | (2*sizeof(short)*N_BLOCK);

    EDMA_PARAMRAM->event12.elerld_link   = (4 << 16) | ((unsigned int)&EDMA_PARAMRAM->reload[0] & 0xFFFF);
    EDMA_PARAMRAM->reload[0].elerld_link = (4 << 16) | ((unsigned int)&EDMA_PARAMRAM->reload[1] & 0xFFFF);
    EDMA_PARAMRAM->reload[1].elerld_link = (4 << 16) | ((unsigned int)&EDMA_PARAMRAM->reload[0] & 0xFFFF);

    EDMA_PARAMRAM->event12.src           = (unsigned int) &dacbuffer[0][0][0];
    EDMA_PARAMRAM->reload[0].src         = (unsigned int) &dacbuffer[0][1][0];
    EDMA_PARAMRAM->reload[1].src         = (unsigned int) &dacbuffer[0][0][0];

    // ping-pong buffer for XEVT1
    EDMA_PARAMRAM->event14.opt           = 0x2B100002 | (14 << 16);
    EDMA_PARAMRAM->reload[4].opt         = 0x2B100002 | ( 4 << 16);
    EDMA_PARAMRAM->reload[5].opt         = 0x2B100002 | (14 << 16);

    EDMA_PARAMRAM->event14.frm_elecnt    = 
    EDMA_PARAMRAM->reload[4].frm_elecnt  = 
    EDMA_PARAMRAM->reload[5].frm_elecnt  = ((N_BLOCK-1)<<16) | 4;
    
    EDMA_PARAMRAM->event14.dst           = 
    EDMA_PARAMRAM->reload[4].dst         = 
    EDMA_PARAMRAM->reload[5].dst         = (unsigned int)&MCBSP(1)->dxr;
    
    EDMA_PARAMRAM->event14.frm_eleidx    =
    EDMA_PARAMRAM->reload[4].frm_eleidx  = 
    EDMA_PARAMRAM->reload[5].frm_eleidx  = (-sizeof(short)*(3*2*N_BLOCK-1) << 16) | (2*sizeof(short)*N_BLOCK);

    EDMA_PARAMRAM->event14.elerld_link   = (4 << 16) | ((unsigned int)&EDMA_PARAMRAM->reload[4] & 0xFFFF);
    EDMA_PARAMRAM->reload[4].elerld_link = (4 << 16) | ((unsigned int)&EDMA_PARAMRAM->reload[5] & 0xFFFF);
    EDMA_PARAMRAM->reload[5].elerld_link = (4 << 16) | ((unsigned int)&EDMA_PARAMRAM->reload[4] & 0xFFFF);

    EDMA_PARAMRAM->event14.src           = (unsigned int) &dacbuffer[4][0][0];
    EDMA_PARAMRAM->reload[4].src         = (unsigned int) &dacbuffer[4][1][0];
    EDMA_PARAMRAM->reload[5].src         = (unsigned int) &dacbuffer[4][0][0];

    // ping-pong buffer for REVT0
    EDMA_PARAMRAM->event13.opt           = 0x28700002 | (13 << 16);
    EDMA_PARAMRAM->reload[2].opt         = 0x28700002 | ( 3 << 16);
    EDMA_PARAMRAM->reload[3].opt         = 0x28700002 | (13 << 16);
    
    EDMA_PARAMRAM->event13.src           = 
    EDMA_PARAMRAM->reload[2].src         = 
    EDMA_PARAMRAM->reload[3].src         = (unsigned int)&MCBSP(0)->drr;
    
    EDMA_PARAMRAM->event13.frm_elecnt    = 
    EDMA_PARAMRAM->reload[2].frm_elecnt  = 
    EDMA_PARAMRAM->reload[3].frm_elecnt  = ((N_BLOCK-1)<<16) | 4;
    
    EDMA_PARAMRAM->event13.frm_eleidx    = 
    EDMA_PARAMRAM->reload[2].frm_eleidx  = 
    EDMA_PARAMRAM->reload[3].frm_eleidx  = (-sizeof(short)*(3*2*N_BLOCK-1) << 16) | (2*sizeof(short)*N_BLOCK);
    
    EDMA_PARAMRAM->event13.elerld_link   = (4 << 16) | ((unsigned int)&EDMA_PARAMRAM->reload[2] & 0xFFFF);
    EDMA_PARAMRAM->reload[2].elerld_link = (4 << 16) | ((unsigned int)&EDMA_PARAMRAM->reload[3] & 0xFFFF);
    EDMA_PARAMRAM->reload[3].elerld_link = (4 << 16) | ((unsigned int)&EDMA_PARAMRAM->reload[2] & 0xFFFF);
    
    EDMA_PARAMRAM->event13.dst           = (unsigned int) &adcbuffer[0][0][0];
    EDMA_PARAMRAM->reload[2].dst         = (unsigned int) &adcbuffer[0][1][0];
    EDMA_PARAMRAM->reload[3].dst         = (unsigned int) &adcbuffer[0][0][0];

    // ping-pong buffer for REVT1
    EDMA_PARAMRAM->event15.opt           = 0x28700002 | (15 << 16);
    EDMA_PARAMRAM->reload[6].opt         = 0x28700002 | ( 5 << 16);
    EDMA_PARAMRAM->reload[7].opt         = 0x28700002 | (15 << 16);
    
    EDMA_PARAMRAM->event15.src           = 
    EDMA_PARAMRAM->reload[6].src         = 
    EDMA_PARAMRAM->reload[7].src         = (unsigned int)&MCBSP(1)->drr;
    
    EDMA_PARAMRAM->event15.frm_elecnt    = 
    EDMA_PARAMRAM->reload[6].frm_elecnt  = 
    EDMA_PARAMRAM->reload[7].frm_elecnt  = ((N_BLOCK-1)<<16) | 4;
    
    EDMA_PARAMRAM->event15.frm_eleidx    = 
    EDMA_PARAMRAM->reload[6].frm_eleidx  = 
    EDMA_PARAMRAM->reload[7].frm_eleidx  = (-sizeof(short)*(3*2*N_BLOCK-1) << 16) | (2*sizeof(short)*N_BLOCK);
    
    EDMA_PARAMRAM->event15.elerld_link   = (4 << 16) | ((unsigned int)&EDMA_PARAMRAM->reload[6] & 0xFFFF);
    EDMA_PARAMRAM->reload[6].elerld_link = (4 << 16) | ((unsigned int)&EDMA_PARAMRAM->reload[7] & 0xFFFF);
    EDMA_PARAMRAM->reload[7].elerld_link = (4 << 16) | ((unsigned int)&EDMA_PARAMRAM->reload[6] & 0xFFFF);
    
    EDMA_PARAMRAM->event15.dst           = (unsigned int) &adcbuffer[4][0][0];
    EDMA_PARAMRAM->reload[6].dst         = (unsigned int) &adcbuffer[4][1][0];
    EDMA_PARAMRAM->reload[7].dst         = (unsigned int) &adcbuffer[4][0][0];


    /******************************************************************
      install EDMA complete interrupt and start interrupt system
    ******************************************************************/
    install_interrupt (CPU_INT8, edma_complete_int);
    IER |= 2;                                   /* enable NMI         */
    CSR |= 1;                                   /* set GIE            */
  
    /******************************************************************
      start EDMA processing for events 12, 13, 14, and 15
      manually trigger first XEVT0 and XEVT1
      enable EDMA complete interrupt for TCC 13 and 3
      take PCM30003 out of Reset
    ******************************************************************/
    EDMA->eer |= ((1<<12) | (1<<13) | (1<<14) | (1<<15));
    EDMA->esr = (1<<12) | (1<<14);
    EDMA->cier |= (1 << 13) | (1 << 3);

}
