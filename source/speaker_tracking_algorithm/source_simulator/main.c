/***********************************************************************
author:			Jens Reermann
projectname:	SourceSimulator
revision:		1.0
date:			2013-04-12

based on:

  PCM3003 Demo Program (8 channels, EDMA ping-pong buffer processing)

  author    A.Klemenz
  company   D.SignT
  revision  1.1
  date      2008-11-06

  hardware  D.Module.6713
  compiler  TI CCS 3.3

  history   1.0 intial release 2005-02-17 by AK
            1.1 changed buffer signalling to allow buffer display in CCS
                2008-11-06 by AK
            1.2 adapted for D.Module.6713+PCM3003 with EDMA
                2009-11-03 by US
***********************************************************************/


/***********************************************************************
  		includes
***********************************************************************/
#include "bios.h"
#include "set_edma.h"
#include <stdlib.h>
#include <math.h>
#include "global_defines.h"
#include <DSPF_sp_cfftr2_dit.h>

/***********************************************************************
  		defines
***********************************************************************/
// max. 2731


#define RADIX 2				    	//radix or base
#define PI        	3.141592654f
#define DELTA (2*PI)/N_FFT			    //argument for sine/cosine


/***********************************************************************
  		globals
***********************************************************************/

//for EDMA
volatile short adcbuffer[N_CHANNEL][2][N_BLOCK];
volatile short dacbuffer[N_CHANNEL][2][N_BLOCK];
volatile int newdat;
volatile int block;

//for delays
float d[N_S][N_CHANNEL];

#ifdef INTEGER_DELAYS
	#define D_MAX 50
	int dInt[N_S][N_CHANNEL];
	float dInt_buffer[N_S][D_MAX];
	int dInt_max;
#endif

short dChange=0;
float theta[N_S];
float phi[N_S];

//for input-handling
#ifndef INTEGER_DELAYS
	float input[N_S][N_FFT];
#endif
float overlap[N_S][N_OVERLAP];

//for FFT and frequency response
typedef struct Complex_tag {
	float re,im;
} Complex;

Complex w_fft[N_FFT/RADIX];
Complex w_ifft[N_FFT/RADIX];
#ifdef INTEGER_DELAYS
	Complex x[N_CHANNEL][N_FFT+D_MAX]; 				    		//N_FFT complex data values
#else
	Complex x[N_CHANNEL][N_FFT]; 				    		//N_FFT complex data values
#endif
#pragma DATA_ALIGN(w_fft,sizeof(Complex))   //align W on boundary
#pragma DATA_ALIGN(w_ifft,sizeof(Complex))   //align W on boundary
#pragma DATA_ALIGN(x,sizeof(Complex))	//align input x on boundary

Complex H[N_S][N_CHANNEL][N_FFT];

//for internal sinus generation
float sin_array[8] = {
 0, 0.7071, 1.0000, 0.7071, 0.0000, -0.7071,
-1.0000, -0.7071};

float noise;


/***********************************************************************
  		functions
***********************************************************************/

bit_rev(Complex* x, int n)
{
	int i, j, k;
	float rtemp, itemp;
	j = 0;
	for(i=1; i < (n-1); i++)
	{
		k = n >> 1;
		while(k <= j)
		{
			j -= k;
			k >>= 1;
		}
		j += k;
		if(i < j)
		{
			rtemp = x[j].re;
			x[j].re = x[i].re;
			x[i].re = rtemp;
			itemp = x[j].im;
			x[j].im = x[i].im;
			x[i].im = itemp;
		}
	}
}





/**********************************************************************
  		main
**********************************************************************/
void main (void)
{

    /******************************************************************
      locals
    ******************************************************************/
    int i, ch, idx, u;
	#ifdef INTEGER_DELAYS
    	float d_min;
	#endif
    int ch_corr[N_CHANNEL] = {0, 2, 1, 3, 4, 6, 5, 7};
	float e;
	float saveReal=0;


    //  basic intialization
    init_module (0);

    //GPIO four output
    	GPIO->gpen  |= ( (1<<15) | (1<<14) | (1<<13) | (1<<12) | (1<<11) | (1<<10) | (1<<9) );
    	GPIO->gpdir |= ( (1<<15) | (1<<14) | (1<<13) | (1<<12) | (1<<11) | (1<<10) | (1<<9));

	// reset PCM30003
	// D.module6713
    clr_module_cfg (CFG_nRESOUT);

    for (ch=0; ch<N_CHANNEL; ch++)
    {
        for (idx=0; idx<N_BLOCK; idx++)
        {
            dacbuffer[ch][0][idx] = 0;
            dacbuffer[ch][1][idx] = 0;
        }
    }

    set_edma();

    set_module_cfg (CFG_nRESOUT);


	//Added
	e = PI*2.0/N_FFT;

	for (u=0;u<N_S;u++)
	{
		phi[u]=u*180+45;
		theta[u]=75;
	}

	for (ch=0; ch<N_S; ch++)
	{
		for(i=0; i<N_OVERLAP;i++)
		{
				overlap[N_S][i]=0;
		}
	}

	for(i=0; i < ( N_FFT>>1 ); i++)
	{
		w_fft[i].re = cos(i*e);
		w_fft[i].im = sin(i*e);
		w_ifft[i].re =  cos(i*e);
		w_ifft[i].im = -sin(i*e);
	}

	bit_rev(w_fft, N_FFT/RADIX);	//produces index for bitrev() W
	bit_rev(w_ifft, N_FFT/RADIX);	//produces index for bitrev() W

	dChange=1;

	noise=0.1;

    /******************************************************************
      main program loop
    ******************************************************************/
    block = -2;
    for (;;)
    {

        // if a new block is ready for processing
        if (block != -1)
        {
			GPIO->gpval &= ~(1<<14);
			if (dChange == 1)
			{
				#ifdef INTEGER_DELAYS
					dInt_max=0;
				#endif
				for(u=0; u<N_S; u++)
				{
					#ifdef UCA
						for(ch=0;ch<N_CHANNEL;ch++)
						{
							d[u][ch]=-R/V*sin(theta[u]/360*2*PI)*cos(phi[u]/360*2*PI-2*PI*ch/N_CHANNEL)*F_S;
						}
						
							d_min=0;
							//find biggest and smallest delay
							for(ch=0;ch<N_CHANNEL;ch++)
							{
								if(d_min>d[u][ch])
									d_min=d[u][ch];
							}
							#ifdef INTEGER_DELAYS
							//split into integer and float delay
							for(ch=0;ch<N_CHANNEL;ch++)
							{
								d[u][ch]=d[u][ch]-d_min;
								dInt[u][ch]=(int)d[u][ch];
								d[u][ch]=d[u][ch]-dInt[u][ch];
								if(dInt_max<dInt[u][ch])
									dInt_max=dInt[u][ch];
							}
							#else
							//delay signal
							for(ch=0;ch<N_CHANNEL;ch++)
							{
								d[u][ch]=d[u][ch]-d_min;
							}
							#endif
					#endif
					//calculate frequency response
					#ifdef MRRR
						for(ch=0; ch<N_CHANNEL; ch++)
						{
							for(i=0; i<N_FFT;i++)
							{
								if(i<N_FFT/2)
								{
									H[u][ch][i].re=cos(d[u][ch]*e*i);
									H[u][ch][i].im=-sin(d[u][ch]*e*i);
								}
								else if(i==N_FFT/2)
								{
									//can be set to zero
									H[u][ch][i].re=0;
									H[u][ch][i].im=0;
								}
								else
								{
									H[u][ch][i].re=cos(d[u][ch]*e*(N_FFT-i));
									H[u][ch][i].im=sin(d[u][ch]*e*(N_FFT-i));
								}
							}
						}
					#else
						for(ch=0; ch<N_CHANNEL; ch++)
						{
							for(i=0; i<N_FFT;i++)
							{
								if(i<N_FFT/2)
								{
									H[u][ch][i].re=cos(d[u][ch]*e*i);
									H[u][ch][i].im=-sin(d[u][ch]*e*i);
								}
								else if(i==N_FFT/2)
								{
									H[u][ch][i].re=cos(d[u][ch]*PI);
									H[u][ch][i].im=0;
								}
								else
								{
									H[u][ch][i].re=cos(d[u][ch]*e*(N_FFT-i));
									H[u][ch][i].im=sin(d[u][ch]*e*(N_FFT-i));
								}
							}
						}
					#endif
				}
				dChange=0;
			}
			else
			{
				#ifdef INTEGER_DELAYS
					for (u=0; u<N_S; u++)
					{
						//build signal
						for(ch=0;ch<N_CHANNEL;ch++)
						{
							//read adcbuffer
							for (idx=0; idx<(N_BLOCK); idx++)
							{
								x[ch][idx+ 		dInt[u][ch]	+N_OVERLAP	].re = (float) adcbuffer[ch_corr[u]][block][idx]/32768;
								x[ch][idx+ 		dInt[u][ch]	+N_OVERLAP	].im = 0.0 ;				    //zero imaginary part
							}

							//add overlap to signal
							for (idx=0; idx<N_OVERLAP; idx++)
							{
								x[ch][idx+		dInt[u][ch]				].re = overlap[u][idx];
								x[ch][idx+		dInt[u][ch]				].im = 0.0 ;
							}

							//add integer delays samples to signal
							for (idx=0; idx<dInt[u][ch]; idx++)
							{
								x[ch][idx								].re = dInt_buffer[u][D_MAX-dInt[u][ch]+idx];
								x[ch][idx								].im = 0.0 ;
							}

						}

						//save the integer delays samples for next round and save the last N_OVERLAP samples for next round
						for (idx=0; idx<dInt_max; idx++)
						{
							dInt_buffer[u][D_MAX-1-idx]	=x[0][-idx+ N_BLOCK+dInt[u][0]-1].re;//(float) adcbuffer[ch_corr[0]][block][N_BLOCK-N_OVERLAP-1-idx]/32768;
						}
						for (idx=0; idx<N_OVERLAP; idx++)
						{
							overlap[u][idx]				=x[0][idx+ N_BLOCK+dInt[u][0]].re;//(float) adcbuffer[ch_corr[0]][block][N_BLOCK-N_OVERLAP+idx]/32768;
						}


						//calculate for every channel ...
						for (ch=0; ch<N_CHANNEL; ch++)
						{

							#ifdef MRRR
							for (idx=N_FFT/2; idx<N_FFT; idx++)
							{
									x[ch][idx].re = x[ch][N_FFT-idx-1].re;
									x[ch][idx].im = 0.0 ;
							}
							#endif

							//calculate FFT
							DSPF_sp_cfftr2_dit((float*)x[ch], (float*)w_fft, N_FFT ) ;
							bit_rev(x[ch], N_FFT);

							//...the new frequency response
							for(idx=0; idx<N_FFT; idx++)
							{
								saveReal=x[ch][idx].re;
								x[ch][idx].re=x[ch][idx].re*H[u][ch][idx].re-x[ch][idx].im*H[u][ch][idx].im;
								x[ch][idx].im=saveReal*H[u][ch][idx].im+x[ch][idx].im*H[u][ch][idx].re;
							}

							//...the IFFT
							DSPF_sp_cfftr2_dit((float*)x[ch], (float*)w_ifft, N_FFT ) ;
							bit_rev(x[ch], N_FFT);

							//... and write results to dacbuffer
							if (u>0)
							{
								for (idx=0; idx<N_BLOCK; idx++)
								{
									dacbuffer[ch_corr[ch]][block][idx]=dacbuffer[ch_corr[ch]][block][idx]+(short)(x[ch][idx+(N_OVERLAP)/2].re*32768/N_FFT/N_S+0.5);
								}
							}
							else
							{
								for (idx=0; idx<N_BLOCK; idx++)
								{
									dacbuffer[ch_corr[ch]][block][idx]=(short)(x[ch][idx+(N_OVERLAP)/2].re*32768/N_FFT/N_S+0.5);
								}
							}
						}
					}
				#else
					//read adcbuffer
					for (u=0; u<N_S; u++)
					{
						for (idx=0; idx<N_BLOCK; idx++)
						{
							input[u][idx+ N_OVERLAP] = (float) adcbuffer[ch_corr[u]][block][idx]/32768;
						}


						//save the last N_OVERLAP samples for next round
						for (idx=0; idx<N_OVERLAP; idx++)
						{
							input[u][idx] = overlap[u][idx];
							overlap[u][idx]=input[u][idx+ N_BLOCK];
						}

						#ifdef MRRR
							for (idx=N_FFT/2; idx<N_FFT; idx++)
							{
								input[u][idx] = input[u][N_FFT-idx-1];
							}
						#endif

						for(idx=0; idx<N_FFT; idx++)
						{
							x[0][idx].re=input[u][idx];
							x[0][idx].im=0;
						}
						//calculate FFT
						DSPF_sp_cfftr2_dit((float*)x[0], (float*)w_fft, N_FFT ) ;
						bit_rev(x[0], N_FFT);

						//save FFT result on all channels
						for(ch=1;ch<N_CHANNEL;ch++)
						{
							for(idx=0; idx<N_FFT; idx++)
							{
								x[ch][idx].re=x[0][idx].re;
								x[ch][idx].im=x[0][idx].im;
							}
						}
						//calculate for every channel ...
						for (ch=0; ch<N_CHANNEL; ch++)
						{
							//...the new frequency response
							for(idx=0; idx<N_FFT; idx++)
							{
								saveReal=x[ch][idx].re;
								x[ch][idx].re=x[ch][idx].re*H[u][ch][idx].re-x[ch][idx].im*H[u][ch][idx].im;
								x[ch][idx].im=saveReal*H[u][ch][idx].im+x[ch][idx].im*H[u][ch][idx].re;
							}

							//...the IFFT
							DSPF_sp_cfftr2_dit((float*)x[ch], (float*)w_ifft, N_FFT ) ;
							bit_rev(x[ch], N_FFT);

							//... and write results to dacbuffer
							if (u>0)
							{
								for (idx=0; idx<N_BLOCK; idx++)
								{
									dacbuffer[ch_corr[ch]][block][idx]=dacbuffer[ch_corr[ch]][block][idx]+x[ch][idx+(N_OVERLAP)/2].re*32768/N_FFT/N_S;
								}
							}
							else
							{
								for (idx=0; idx<N_BLOCK; idx++)
								{
									dacbuffer[ch_corr[ch]][block][idx]=x[ch][idx+(N_OVERLAP)/2].re*32768/N_FFT/N_S;
								}
							}
						}
					}
				#endif
    		}

			#ifdef NOISE
			for(ch=0;ch<N_CHANNEL;ch++)
			{
				for (idx=0; idx<N_BLOCK; idx++)
				{
					dacbuffer[ch_corr[ch]][block][idx]=dacbuffer[ch_corr[ch]][block][idx]+(short)(noise*(rand()-RAND_MAX/2)+0.5);
				}
			}
			#endif

            asm (" nop;");

            // after processor is released from halt:
            // clear any pending EDMA complete interrupt events
            ICR = (1 << CPU_INT8);
            EDMA->cipr = (1<<13) | (1 << 3);



            // reset block
            block = -1;
            GPIO->gpval |= (1<<14);
        }

    }
}
