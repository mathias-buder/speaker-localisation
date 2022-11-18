//
//  defines_globals.c
//  3D_Speaker_Tracking
//
//  Created by Mathias Buder on 31.05.13.
//  Copyright (c) 2013 Mathias Buder. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "defines_globals.h"
#include "functions.h"
#include "setup.h"

#ifndef C_MODE_ON
	#include "DSPF_sp_bitrev_cplx.h"
#endif




// -----------------------------------------------------------------------------
// TI-FFT
// -----------------------------------------------------------------------------
short iTwid[N_CORRELATION/2];				// index for twiddle constants W
st_complex W[N_CORRELATION/RADIX];			// array for twiddle constants
// -----------------------------------------------------------------------------
// GLOBAL VARIABLE DECLARATION
// -----------------------------------------------------------------------------
Array st_CubeArray;                 // Structure to hold constants according to microphone array
st_Buffer st_Buf;                   // Structure to hold all signal values

Angle st_Phi;						// Structure to hold values according to angle Phi
Angle st_Theta;						// Structure to hold values according to angle Theta
short int16_HistogramThreshold;		// Threshlod to handle histogram decision


void Init(){

    
    /*###########################################################################################
     --------------------------------------- INIT VARIABLES -------------------------------------
     ############################################################################################*/
    
    
	// -------------------------------------------------------------------------------------------
	// Locals
	// -------------------------------------------------------------------------------------------
		short i;
    
    // -------------------------------------------------------------------------------------------
    // Microphone array
    // -------------------------------------------------------------------------------------------
		st_CubeArray.f_MicAngle = acos(sqrt(2.0/3));
		st_CubeArray.f_MinDistance = 2*ARRAY_RADIUS/sqrtf(3);

		// Calculate angle resolution
		st_CubeArray.int16_AngleRes = asin( ACOUSTIC_VILOCITY / (st_CubeArray.f_MinDistance * SAMPFREQ) );

		// Init Microphone angle matrix
		// Row 1
		st_CubeArray.f_MicPos[0][0] =  st_CubeArray.f_MicAngle;     // Mic 1
		st_CubeArray.f_MicPos[0][1] =  st_CubeArray.f_MicAngle;     // Mic 2
		st_CubeArray.f_MicPos[0][2] =  st_CubeArray.f_MicAngle;     // Mic 3
		st_CubeArray.f_MicPos[0][3] =  st_CubeArray.f_MicAngle;     // Mic 4
		st_CubeArray.f_MicPos[0][4] = -st_CubeArray.f_MicAngle;     // Mic 5
		st_CubeArray.f_MicPos[0][5] = -st_CubeArray.f_MicAngle;     // Mic 6
		st_CubeArray.f_MicPos[0][6] = -st_CubeArray.f_MicAngle;     // Mic 7
		st_CubeArray.f_MicPos[0][7] = -st_CubeArray.f_MicAngle;     // Mic 8

		// Row 2
		st_CubeArray.f_MicPos[1][0] = deg2rad( -45  );              // Mic 1
		st_CubeArray.f_MicPos[1][1] = deg2rad(  45  );              // Mic 2
		st_CubeArray.f_MicPos[1][2] = deg2rad(  135 );              // Mic 3
		st_CubeArray.f_MicPos[1][3] = deg2rad(  225 );              // Mic 4
		st_CubeArray.f_MicPos[1][4] = deg2rad( -45  );              // Mic 5
		st_CubeArray.f_MicPos[1][5] = deg2rad(  45  );              // Mic 6
		st_CubeArray.f_MicPos[1][6] = deg2rad(  135 );              // Mic 7
		st_CubeArray.f_MicPos[1][7] = deg2rad(  225 );              // Mic 8

    // -------------------------------------------------------------------------------------------
    // FFT from TI
    // -------------------------------------------------------------------------------------------
		for( i = 0; i < N_CORRELATION/RADIX; i++ ) {
			W[i].re = (float)  cos(DELTA*i); 						//real pos component of W
			W[i].im = (float) -sin(DELTA*i);						//neg imag component of W
		}                                                           //see cfftr2_dit

		digitrev_index( iTwid, N_CORRELATION/RADIX, RADIX );          //produces index for bitrev() W

		#ifdef C_MODE_ON
			C_DSPF_sp_bitrev_cplx( (double*) W , iTwid, N_CORRELATION/RADIX );
		#else
			DSPF_sp_bitrev_cplx( (double*) W , iTwid, N_CORRELATION/RADIX );
		#endif

    // -------------------------------------------------------------------------------------------
    // Angle Phi and Theta
    // -------------------------------------------------------------------------------------------
		st_Phi.int16_EstIdx = PHI_START_EST_ID;
		st_Theta.int16_EstIdx = THETA_START_EST_ID;

		st_Phi.int16_NumOfSearchAngles = PHI_START_NUM_SEARCH_ANGLE;
		st_Theta.int16_NumOfSearchAngles = THETA_START_NUM_SEARCH_ANGLE;

		st_Phi.int16_Length = PHI_LENGTH;
		st_Theta.int16_Length = THETA_LENGTH;

		st_Phi.f_LUT = (float*) malloc( sizeof(float) * PHI_LENGTH );
		st_Theta.f_LUT = (float*) malloc( sizeof(float) * THETA_LENGTH );

		st_Phi.int16_Hist = (short*) malloc( sizeof(short) * PHI_LENGTH );
		st_Theta.int16_Hist = (short*) malloc( sizeof(short) * THETA_LENGTH );

		st_Phi.int16_HistEstOldIdx = INDEX_INVALID;
		st_Theta.int16_HistEstOldIdx = INDEX_INVALID;

		for ( i=0; i < N_LOOPS; i++ ) {
			st_Theta.int16_SearchRes[i] = ceil( THETA_LENGTH / (3 * pow(2, i)) );
			st_Phi.int16_SearchRes[i] = ceil( PHI_LENGTH / (3 * pow(2, i)) );
		}
    
    // -------------------------------------------------------------------------------------------
    // Historgram
    // -------------------------------------------------------------------------------------------
		// Init Historgram-Ring-Buffer with value -1 (INDEX_INVAILD)
		memset( st_Buf.int16_HistRingBuf, INDEX_INVALID, sizeof(short) * N_ANGLES * N_HISTOGRAM );

		// Calculate histogram threshold
		short tmpThreshold = HISTOGRAM_THRESHOLD;
		int16_HistogramThreshold = (short) (N_HISTOGRAM * tmpThreshold * 0.01);

    // -------------------------------------------------------------------------------------------
    // Calculate all necessary constants
    // -------------------------------------------------------------------------------------------
		CalcMicMatrix( &st_CubeArray, N_CHANNELS, ARRAY_RADIUS );
		CalcMicDistance( &st_CubeArray, N_CHANNELS, N_CHANNEL_PAIRS, N_COORDINATES );
		CalcAngleLUTs( &st_CubeArray, st_Phi.f_LUT , st_Theta.f_LUT, THETA_LENGTH, PHI_LENGTH );
}
