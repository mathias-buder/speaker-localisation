/*
 * global_defines.h
 *
 *  Created on: 25.07.2013
 *      Author: test
 */

#ifndef GLOBAL_DEFINES_H_
#define GLOBAL_DEFINES_H_

#define UCA
#define N_S 2
#define R 0.045f
#define V 343
#define F_S 48000

#define MRRR
#define NOISE
//#define INTEGER_DELAYS

#ifdef MRRR
	#ifdef INTEGER_DELAYS

		#ifdef NOISE
			#define N_BLOCK  230
		#else
			#define N_BLOCK  200
		#endif

	#else
		#define N_BLOCK  150
	#endif

	#define N_FFT 512
	#define N_OVERLAP (N_FFT)/2-N_BLOCK
#else

	#define N_BLOCK  300


	#define N_FFT 512
	#define N_OVERLAP N_FFT-N_BLOCK
#endif


#define N_CHANNEL 8

#endif /* GLOBAL_DEFINES_H_ */
