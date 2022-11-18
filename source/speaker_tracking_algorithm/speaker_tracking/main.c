/***********************************************************************
  File : main.c

  	  Creator:	US 				14.06.2010
  	  Editor:	Mathias Buder	01.07.2013

	DESCRIPTION:

		TODO ...

  allows to store 80000 samples in 8 channesl to a file 
  >> B48_UPV_Feature_D_Mod_C6713_plus_D_Mod_PCM_EDMA_SDRAM.bin <<

------------------------------------------------------------------------
  Changes:
  08-Apr-2010 US *** SDRAM support implemented ***
  10-Jun-2010 US *** INTs off implemented ***
                 A.Klemenz, CSR und EDMA INTs abschalten
  07-Jul-2010 US internal_sinus generates a DELAYED sine wave on all 8 outputs

------------------------------------------------------------------------

  PCM3003 Demo Program (8 channels, EDMA ping-pong buffer processing)

  author    A.Klemenz
  company   D.SignT
  revision  1.1
  date      2008-11-06

  *** reworked by US 3-Nov-09, EDMA version for D.Module.6713 with PCM3003 ***
  *** DSK6713 EDMA program adapted to D.Module.6713 ***

  hardware  D.Module.6713
  compiler  TI CCS 5.11

  history   1.0 intial release 2005-02-17 by AK
            1.1 changed buffer signalling to allow buffer display in CCS
                2008-11-06 by AK
            1.2 adapted for D.Module.6713+PCM3003 with EDMA 
                2009-11-03 by US

  ---------------------------------------------------------------------

  This is the serial data format of the PCM3003 module:
  
                    _______________________________________________
  PCM3003 nRESET __| 
                      _           _           _           _
  PCM3003 FS     ____| |_________| |_________| |_________| |_______
                        _____ _____ _____ _____ _____ _____ _____ _
  PCM3003 DAT McBSP0 --|_ch0_|_ch2_|_ch1_|_ch3_|_ch0_|_ch2_|_ch1_|_
                        _____ _____ _____ _____ _____ _____ _____ _
  PCM3003 DAT McBSP1 --|_ch4_|_ch6_|_ch5_|_ch7_|_ch4_|_ch6_|_ch5_|_
  

  This program sorts the ADC and DAC data in ping-pong buffers. Each channel
  uses two blocks (0 and 1). While EDMA transfers/receives from/to block0,
  the CPU can process block1 and vice-versa.
  The buffer structure is:
  
  
      ch7 block1
      ch7 block0 -----------
      ----------            |
      ch5 block1            |
      ch5 block0            |
      ----------            |
  /\  ch6 block1            |FRMIDX
   |  ch6 block0 <-         |
   |  ----------   |        |
      ch4 block1   |ELEIDX  |
   a  ch4 block0 --    <----
   d  ----------
   d  ch3 block1
   r  ch3 block0
   e  ----------
   s  ch1 block1
   s  ch1 block0       ___
      ----------      /  sample(BLOCKSIZE-1)
      ch2 block1     /   sample(BLOCKSIZE-2)
      ch2 block0    /    ...
      ----------   /     sample(2)
      ch0 block1 _/      sample(1)
      ch0 block0 ________sample(0)
      
  This buffer can be described in C language as
  buffer[channel][block][index]
  with channel = 0..7, block = 0,1, and index = 0..BLOCKSIZE-1
  
  Because the PCM3003 transmits and receives physical DAC and ADC 
  channels in a 0,2,1,3 sequence, the physical channel and the logical 
  channel numbers do not match. This may be compensated by correcting
  the channel number, if required:
  
  int channel_correction[8] = {0, 2, 1, 3, 4, 6, 5, 7};
  data = buffer[channel_correction[channel]][block][index];
  
  
  IMPORTANT NOTE: 
    The EDMA frame index (FRMIDX) is limited to -32768 .. +32767.
    To perform the desired sorting, frame index is calculated as 
    -sizeof(short)*(3*2*BLOCKSIZE-1)
    The max. BLOCKSIZE to stay within the frame index limits is 2731

***********************************************************************/

/***********************************************************************
  includes
***********************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "bios.h"
#include "setup.h"
#include "defines_globals.h"
#include "functions.h"


/***********************************************************************
  Select test file when running in C-Mode
***********************************************************************/
#ifdef C_MODE_ON
	//#include "H_Sim_Files/moving_diag_Noise_5-Pos_81-Pos_Intpl_SNR-100dB_N_128.h"
	#include "H_Sim_Files/moving_diag_Noise_5-Pos_81-Pos_Intpl_SNR-100dB_N_512.h"
	//#include "H_Sim_Files/moving_diag_Noise_5-Pos_81-Pos_Intpl_SNR-100dB_N_10000.h"
#endif


/***********************************************************************
  defines
***********************************************************************/


/***********************************************************************
  globals
    data buffer [CHANNELS][BLOCKS][BLOCKSIZE]
***********************************************************************/
volatile short adcbuffer[N_CHANNELS][2][BLOCKSIZE];

#ifdef ADC_LOOP_THROUGH_MODE_ON
	volatile short dacbuffer[2][2][BLOCKSIZE];
#endif

volatile short int16_block, int16_idx;

 //double Energie_Limit = ENERGIE_LIMIT;
float energielimit = ENERGIE_LIMIT;

float f_Phi_deg = 0;
float f_Theta_deg = 0;
float f_Phi_rad = 0;
float f_Theta_rad = 0;

float f_Phi_Hist_deg = 0;
float f_Theta_Hist_deg = 0;
float f_Phi_Hist_rad = 0;
float f_Theta_Hist_rad = 0;

// Structure to handle UART configurations
uart_init_struct st_InitUART;



/***********************************************************************
    function    edma complete interrupt

    Parameter   -
    Returns     -

    check which EDMA is completed (Ping or Pong Buffer EDMA),
    set global variable block 

    transfer complete code - action
    13                     - Receive EDMA in block 0 complete
     3                     - Receive EDMA in block 1 complete
***********************************************************************/
#ifndef C_MODE_ON
	interrupt void edma_complete_int (void) {
		if (EDMA->cipr & 1<<13) {
			EDMA->cipr = (1<<13);
			int16_block = 0;

			#ifdef PROFILE_MODE_ON
				SET_GPIO(23);
			#endif
		}

		if (EDMA->cipr & 1<<3) {
			EDMA->cipr = (1<<3);
			int16_block = 1;

			#ifdef PROFILE_MODE_ON
				RESET_GPIO(23);
			#endif
		}
	}
#endif



/**********************************************************************
 *************************** MAIN PROGRAM *****************************
***********************************************************************/

void main (void) {
    /******************************************************************
     Locals
    ******************************************************************/
    int ch_corr[8] = {0, 2, 1, 3, 4, 6, 5, 7};	// Channel correction according to EDMA read order
    short int16_Channel_Cnt, int16_Hist_Cnt;

    /******************************************************************
     Basic intialization
    ******************************************************************/
	#ifndef C_MODE_ON
	// D.module6713
    init_module (0);

    /******************************************************************
     Configure UART
    ******************************************************************/
    st_InitUART.baud = 460800;		// 200 .. 460800 //
	st_InitUART.databits = 8;		// 5,6,7,8
	st_InitUART.stopbits = 1;		// 1,2
	st_InitUART.parity = 'E';		// 'N','O','E' -> N:No, O:Odd, E:Even
	st_InitUART.handshake = 'N';	// 'N','R','X'
	st_InitUART.Xon = 0x11;			// default: 0x11
	st_InitUART.Xoff = 0x13;		// default: 0x13
	init_uart( &st_InitUART );		// Call init_uart() and set values assigned above


    /******************************************************************
      Reset PCM30003
    ******************************************************************/
    // D.module6713
    clr_module_cfg (CFG_nRESOUT);

    /******************************************************************
	Configure McBSP0 and McBSP1 transmitter and receiver:

		External clock and framesync two 16 bit data words
		per frame frame sync active high, one clock delay to
		data MSB write data on CLK falling edge, read on rising edge
    ******************************************************************/
    MCBSP(0)->spcr = MCBSP(1)->spcr = 0x02000000;
    MCBSP(0)->rcr  = MCBSP(1)->rcr  = 0x00010140;
    MCBSP(0)->xcr  = MCBSP(1)->xcr  = 0x00010140;
    MCBSP(0)->pcr  = MCBSP(1)->pcr  = 0x03;
    MCBSP(0)->spcr = MCBSP(1)->spcr = 0x02010001;
    

    /******************************************************************
	Configure EDMA
	channel 12: XEVT0
	channel 13: REVT0
	channel 14: XEVT1
	channel 15: REVT1
        
	TCC codes:	channel 12: 12 for block 0, 2 for block 1
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
    EDMA_PARAMRAM->reload[1].frm_elecnt  = ((BLOCKSIZE-1)<<16) | 4;
    
    EDMA_PARAMRAM->event12.dst           = 
    EDMA_PARAMRAM->reload[0].dst         = 
    EDMA_PARAMRAM->reload[1].dst         = (unsigned int)&MCBSP(0)->dxr;
    
    EDMA_PARAMRAM->event12.frm_eleidx    =
    EDMA_PARAMRAM->reload[0].frm_eleidx  = 
    EDMA_PARAMRAM->reload[1].frm_eleidx  = (-sizeof(short)*(3*2*BLOCKSIZE-1) << 16) | (2*sizeof(short)*BLOCKSIZE);

    EDMA_PARAMRAM->event12.elerld_link   = (4 << 16) | ((unsigned int)&EDMA_PARAMRAM->reload[0] & 0xFFFF);
    EDMA_PARAMRAM->reload[0].elerld_link = (4 << 16) | ((unsigned int)&EDMA_PARAMRAM->reload[1] & 0xFFFF);
    EDMA_PARAMRAM->reload[1].elerld_link = (4 << 16) | ((unsigned int)&EDMA_PARAMRAM->reload[0] & 0xFFFF);

    //****************************************************************************************************************
    // DAC-Part
    //****************************************************************************************************************
	#ifdef ADC_LOOP_THROUGH_MODE_ON
		EDMA_PARAMRAM->event12.src           = (unsigned int) &dacbuffer[0][0][0];
		EDMA_PARAMRAM->reload[0].src         = (unsigned int) &dacbuffer[0][1][0];
		EDMA_PARAMRAM->reload[1].src         = (unsigned int) &dacbuffer[0][0][0];
	#endif
    //****************************************************************************************************************

    // ping-pong buffer for XEVT1
    EDMA_PARAMRAM->event14.opt           = 0x2B100002 | (14 << 16);
    EDMA_PARAMRAM->reload[4].opt         = 0x2B100002 | ( 4 << 16);
    EDMA_PARAMRAM->reload[5].opt         = 0x2B100002 | (14 << 16);

    EDMA_PARAMRAM->event14.frm_elecnt    = 
    EDMA_PARAMRAM->reload[4].frm_elecnt  = 
    EDMA_PARAMRAM->reload[5].frm_elecnt  = ((BLOCKSIZE-1)<<16) | 4;
    
    EDMA_PARAMRAM->event14.dst           = 
    EDMA_PARAMRAM->reload[4].dst         = 
    EDMA_PARAMRAM->reload[5].dst         = (unsigned int)&MCBSP(1)->dxr;
    
    EDMA_PARAMRAM->event14.frm_eleidx    =
    EDMA_PARAMRAM->reload[4].frm_eleidx  = 
    EDMA_PARAMRAM->reload[5].frm_eleidx  = (-sizeof(short)*(3*2*BLOCKSIZE-1) << 16) | (2*sizeof(short)*BLOCKSIZE);

    EDMA_PARAMRAM->event14.elerld_link   = (4 << 16) | ((unsigned int)&EDMA_PARAMRAM->reload[4] & 0xFFFF);
    EDMA_PARAMRAM->reload[4].elerld_link = (4 << 16) | ((unsigned int)&EDMA_PARAMRAM->reload[5] & 0xFFFF);
    EDMA_PARAMRAM->reload[5].elerld_link = (4 << 16) | ((unsigned int)&EDMA_PARAMRAM->reload[4] & 0xFFFF);

    //****************************************************************************************************************
    // DAC-Part
    //****************************************************************************************************************
	#ifdef ADC_LOOP_THROUGH_MODE_ON
		EDMA_PARAMRAM->event14.src           = (unsigned int) &dacbuffer[1][0][0];
		EDMA_PARAMRAM->reload[4].src         = (unsigned int) &dacbuffer[1][1][0];
		EDMA_PARAMRAM->reload[5].src         = (unsigned int) &dacbuffer[1][0][0];
	#endif
    //****************************************************************************************************************

    // ping-pong buffer for REVT0
    EDMA_PARAMRAM->event13.opt           = 0x28700002 | (13 << 16);
    EDMA_PARAMRAM->reload[2].opt         = 0x28700002 | ( 3 << 16);
    EDMA_PARAMRAM->reload[3].opt         = 0x28700002 | (13 << 16);
    
    EDMA_PARAMRAM->event13.src           = 
    EDMA_PARAMRAM->reload[2].src         = 
    EDMA_PARAMRAM->reload[3].src         = (unsigned int)&MCBSP(0)->drr;
    
    EDMA_PARAMRAM->event13.frm_elecnt    = 
    EDMA_PARAMRAM->reload[2].frm_elecnt  = 
    EDMA_PARAMRAM->reload[3].frm_elecnt  = ((BLOCKSIZE-1)<<16) | 4;
    
    EDMA_PARAMRAM->event13.frm_eleidx    = 
    EDMA_PARAMRAM->reload[2].frm_eleidx  = 
    EDMA_PARAMRAM->reload[3].frm_eleidx  = (-sizeof(short)*(3*2*BLOCKSIZE-1) << 16) | (2*sizeof(short)*BLOCKSIZE);
    
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
    EDMA_PARAMRAM->reload[7].frm_elecnt  = ((BLOCKSIZE-1)<<16) | 4;
    
    EDMA_PARAMRAM->event15.frm_eleidx    = 
    EDMA_PARAMRAM->reload[6].frm_eleidx  = 
    EDMA_PARAMRAM->reload[7].frm_eleidx  = (-sizeof(short)*(3*2*BLOCKSIZE-1) << 16) | (2*sizeof(short)*BLOCKSIZE);
    
    EDMA_PARAMRAM->event15.elerld_link   = (4 << 16) | ((unsigned int)&EDMA_PARAMRAM->reload[6] & 0xFFFF);
    EDMA_PARAMRAM->reload[6].elerld_link = (4 << 16) | ((unsigned int)&EDMA_PARAMRAM->reload[7] & 0xFFFF);
    EDMA_PARAMRAM->reload[7].elerld_link = (4 << 16) | ((unsigned int)&EDMA_PARAMRAM->reload[6] & 0xFFFF);
    
    EDMA_PARAMRAM->event15.dst           = (unsigned int) &adcbuffer[4][0][0];
    EDMA_PARAMRAM->reload[6].dst         = (unsigned int) &adcbuffer[4][1][0];
    EDMA_PARAMRAM->reload[7].dst         = (unsigned int) &adcbuffer[4][0][0];


    /******************************************************************
      Install EDMA complete interrupt and start interrupt system
    ******************************************************************/
    install_interrupt (CPU_INT8, edma_complete_int);
    IER |= 2;										 /* enable NMI */
    CSR |= 1;                                   	 /* set GIE */

    /******************************************************************
      Start EDMA processing for events 12, 13, 14, and 15
      manually trigger first XEVT0 and XEVT1
      enable EDMA complete interrupt for TCC 13 and 3
      take PCM30003 out of Reset
    ******************************************************************/
    EDMA->eer |= ((1<<12) | (1<<13) | (1<<14) | (1<<15));
    EDMA->esr = (1<<12) | (1<<14);
    EDMA->cier |= (1 << 13) | (1 << 3);

    // D.module6713
    set_module_cfg ( CFG_nRESOUT );
    
    /******************************************************************
     Configure GPIO's
    ******************************************************************/
    GPIO->gpen  |= ( (1<<15) | (1<<14) | (1<<13) | (1<<12) | (1<<11) | (1<<10) | (1<<9) | (1<<8) );
    GPIO->gpdir |= ( (1<<15) | (1<<14) | (1<<13) | (1<<12) | (1<<11) | (1<<10) | (1<<9) | (1<<8) );
    GPIO->gpval &= ~( (1<<15) | (1<<14) | (1<<13) | (1<<12) | (1<<11) | (1<<10) | (1<<9) | (1<<8) );

	#endif // #ifndef C_MODE_ON

    // Reset EDMA-Block
    int16_block = -1;

    // -----------------------------------------------------------------------------
    // Initialize all required constants
    // -----------------------------------------------------------------------------
    Init();
    int16_Hist_Cnt = 0;

    /*****************************************************************************************************************************************************
     MAIN PROGRAMM LOOP
    *****************************************************************************************************************************************************/
    for (;;) {

        // if a new block is ready for processing
		#ifndef C_MODE_ON
        	if (int16_block != -1) {
		#endif

        SET_GPIO(30);
        // ------------------------------------------------------------------------------------------------------
        // ADC Loop back (Loop back only channel 0)
        // ------------------------------------------------------------------------------------------------------
		#ifdef ADC_LOOP_THROUGH_MODE_ON
        	 for (int16_idx=0; int16_idx < BLOCKSIZE; int16_idx++){
        		 dacbuffer[0][int16_block][int16_idx] = adcbuffer[0][int16_block][int16_idx];
        	 }
		#endif

        		// ------------------------------------------------------------------------------------------------------
        		// (1/8) Check signal energy
        	    // ------------------------------------------------------------------------------------------------------
				#ifdef C_MODE_ON
        			if( CalcEnergy( int16_Sim_File[0], N_SAMPLES ) > energielimit ) {
				#else
        				if( CalcEnergy( adcbuffer[ch_corr[0]][int16_block], N_SAMPLES ) > energielimit ) {
				#endif
        			// ------------------------------------------------------------------------------------------------------
					// (2) Read data from ADC-Buffer and copy to complex data structure
					// ------------------------------------------------------------------------------------------------------
						#ifdef PROFILE_MODE_ON
							SET_GPIO(24);
						#endif

						for( int16_Channel_Cnt=0; int16_Channel_Cnt < N_CHANNELS; int16_Channel_Cnt++ ) {

						#ifdef C_MODE_ON
							Copy2CmplxStruct( 	int16_Sim_File[int16_Channel_Cnt],
												st_Buf.f_CmplxSigBuf[int16_Channel_Cnt],
												N_SAMPLES );
						#else
							Copy2CmplxStruct( 	adcbuffer[ch_corr[int16_Channel_Cnt]][int16_block],
												st_Buf.f_CmplxSigBuf[int16_Channel_Cnt],
												N_SAMPLES );
						#endif

						} // for(int16_Channel_Cnt=0 ...

						#ifdef PROFILE_MODE_ON
							RESET_GPIO(24);
						#endif
					// ----------------------------------------------------------------------------------------------------------------
					// (3) Calculate variance of each Microphone channel before Cross-Correlation's, FFT's will be calculated In-Place
					// ----------------------------------------------------------------------------------------------------------------
						#ifdef PROFILE_MODE_ON
							SET_GPIO(25);
						#endif
						// TODO float DSPF_sp_vecsum_sq(const float *x,int n)
						CalcVariance( st_Buf.f_CmplxSigBuf,
									  st_Buf.f_SigBufVar,
									  N_SAMPLES, N_CHANNELS,
									  INV_N_SAMPLES );

						#ifdef PROFILE_MODE_ON
							RESET_GPIO(25);
						#endif
					// ------------------------------------------------------------------------------------------------------
					// (4) Calculate Cross-Correlation-Functions (Covariance) across all microphone pair (28 pairs)
					// ------------------------------------------------------------------------------------------------------
						#ifdef PROFILE_MODE_ON
							SET_GPIO(26);
						#endif
						FastCrossCorrelation( 	st_Buf.f_CmplxSigBuf,
												st_Buf.f_CmplxSigBufXY,
												st_Buf.f_SigBufXY,
												N_CHANNELS,
												N_CHANNEL_PAIRS,
												N_CORRELATION );
						#ifdef PROFILE_MODE_ON
							RESET_GPIO(26);
						#endif
					// --------------------------------------------------------------------------------------------------------------
					// (5) Create Spatial-Correlation-Matrix Ra(p), search for minimum and store estimated index
					// --------------------------------------------------------------------------------------------------------------
						#ifdef PROFILE_MODE_ON
							SET_GPIO(27);
						#endif

							SearchAndFind( 		&st_Phi,
												&st_Theta,
												&st_CubeArray,
												&st_Buf,
												N_LOOPS );

						#ifdef PROFILE_MODE_ON
							RESET_GPIO(27);
						#endif
					// --------------------------------------------------------------------------------------------------------------
					// (6) Store estimated angles in Histogram-Ring-Buffer
					// ------------------------------------------------------------------------------------------------------


						#ifdef HISTOGRAM_MODE_ON
							st_Buf.int16_HistRingBuf[PHI][int16_Hist_Cnt] = st_Phi.int16_EstIdx;
							st_Buf.int16_HistRingBuf[THETA][int16_Hist_Cnt] = st_Theta.int16_EstIdx;
						#endif


						//##################################################################
						// DEBUG AND DISPLAY
					 	//##################################################################
						f_Phi_deg = rad2deg( st_Phi.f_LUT[st_Phi.int16_EstIdx] );
						f_Phi_rad = st_Phi.f_LUT[st_Phi.int16_EstIdx];

						f_Theta_deg = rad2deg( st_Theta.f_LUT[st_Theta.int16_EstIdx] );
						f_Theta_rad = st_Theta.f_LUT[st_Theta.int16_EstIdx];
						//##################################################################/


        			} // if( CalcEnergy( ...


        			else {
						st_Buf.int16_HistRingBuf[PHI][int16_Hist_Cnt] = INDEX_INVALID;
						st_Buf.int16_HistRingBuf[THETA][int16_Hist_Cnt] = INDEX_INVALID;
					}

        			// Increment global counter
        			int16_Hist_Cnt++;


					// Check histogram counter / Reset
					if(int16_Hist_Cnt >= N_HISTOGRAM) {
						int16_Hist_Cnt = 0;
					}

					// ------------------------------------------------------------------------------------------------------
					// (7) Create histogram and search for maximum
					//-------------------------------------------------------------------------------------------------------
						#ifdef HISTOGRAM_MODE_ON

							#ifdef PROFILE_MODE_ON
								SET_GPIO(28);
							#endif

							CreateHistogram( st_Buf.int16_HistRingBuf,
											 &st_Phi,
											 &st_Theta );


							//##################################################################
							// DEBUG AND DISPLAY
							//##################################################################
							if( st_Phi.int16_HistEstIdx > INDEX_INVALID ) {
								f_Phi_Hist_deg = rad2deg( st_Phi.f_LUT[st_Phi.int16_HistEstIdx] );
								f_Phi_Hist_rad = st_Phi.f_LUT[st_Phi.int16_HistEstIdx];
							}

							if( st_Theta.int16_HistEstIdx > INDEX_INVALID ) {
								f_Theta_Hist_deg = rad2deg( st_Theta.f_LUT[st_Theta.int16_HistEstIdx] );
								f_Theta_Hist_rad = st_Theta.f_LUT[st_Theta.int16_HistEstIdx];
							}
							//##################################################################
							#ifdef PROFILE_MODE_ON
								RESET_GPIO(28);
							#endif

						#endif

					RESET_GPIO(30);
					// ------------------------------------------------------------------------------------------------------
					// (8) Send angle values via UART if valid
					// ------------------------------------------------------------------------------------------------------
						#ifdef UART_MODE_ON
							#ifdef PROFILE_MODE_ON
								SET_GPIO(29);
							#endif

							#ifdef HISTOGRAM_MODE_ON
								if( st_Phi.int16_HistEstIdx > INDEX_INVALID ) {
									send_string( Short2ASCII( (short) ( 1000 * st_Phi.f_LUT[st_Phi.int16_HistEstIdx] ), PHI ) );
								}
								if( st_Theta.int16_HistEstIdx > INDEX_INVALID) {
									send_string( Short2ASCII( (short) ( 1000 * st_Theta.f_LUT[st_Theta.int16_HistEstIdx] ), THETA ) );
								}
							#else
								if( st_Phi.int16_EstIdx > INDEX_INVALID ) {
									send_string( Short2ASCII( (short) ( 1000 * st_Phi.f_LUT[st_Phi.int16_EstIdx] ), PHI ) );
								}
								if( st_Phi.int16_EstIdx > INDEX_INVALID ) {
									send_string( Short2ASCII( (short) ( 1000 * st_Theta.f_LUT[st_Theta.int16_EstIdx] ), THETA ) );
								}
							#endif

							#ifdef PROFILE_MODE_ON
								RESET_GPIO(29);
							#endif
						#endif

						// ------------------------------------------------------------------------
						asm(" nop"); // place break point here!
						// ------------------------------------------------------------------------
			// ------------------------------------------------------------------------------------------------------
			// (9) Clear any pending EDMA complete interrupt events (after processor is released from halt)
			// ------------------------------------------------------------------------------------------------------
			#ifndef C_MODE_ON
				ICR = (1 << CPU_INT8);
				EDMA->cipr = (1<<13) | (1 << 3);
			#endif

				// reset block
	#ifndef C_MODE_ON
				int16_block = -1;

        } // if(int16_block ...
	#endif
    } // for (;;)

} // void main (void)




