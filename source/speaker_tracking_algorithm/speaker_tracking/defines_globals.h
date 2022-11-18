//
//  defines.h
//  3D_Speaker_Tracking
//
//  Created by Mathias Buder on 29.05.13.
//  Copyright (c) 2013 Mathias Buder. All rights reserved.
//

#ifndef _D_Speaker_Tracking_defines_globales_h
#define _D_Speaker_Tracking_defines_globales_h

// -------------------------------------------------------------------------------------------------------------
// GPIO ACCESS
// -------------------------------------------------------------------------------------------------------------
#define SET_GPIO( PIN_T )		( GPIO->gpval |= ( 1<<(PIN_T-15) ) )		// PIN_T = 23, 24, ..., 30
#define RESET_GPIO( PIN_T )		( GPIO->gpval &= ~( 1<<(PIN_T-15) ) )


// -------------------------------------------------------------------------------------------------------------
// GLOBAL PARAMETERS
// -------------------------------------------------------------------------------------------------------------
#define SAMPFREQ                        (48000)                             // Hz
#define PI                              (3.141593)
#define ACOUSTIC_VILOCITY               (343)                               // m/s
#define INV_ACOUSTIC_VILOCITY           ( 1.0 / ACOUSTIC_VILOCITY )			// s/m
#define CONVERT_INT16_TO_FLOAR			( 1.0 / 32768 )						// Convert 16Bit-Integer to Floating-Point-Value ( 1.0/(2^15) )
#define N_CHANNELS                     	(8)
#define N_COORDINATES                   (3)
#define N_ANGLES                   		(2)
#define N_CHANNEL_PAIRS                	( (N_CHANNELS-1) * N_CHANNELS/2 )
#define ARRAY_RADIUS                    (0.05)                           	// m
// -------------------------------------------------------------------------------------------------------------
// ANGLE
// -------------------------------------------------------------------------------------------------------------
// Search parameters
#define N_LOOPS                    		(6)
#define N_SEARCH_ANGLES            		(3)

// Phi
#define PHI                             (0)
#define PHI_MIN                         (-90)                               // deg
#define PHI_MAX                         (90)                                // deg
#define PHI_LENGTH                      (25)
#define PHI_START_EST_ID                (12)
#define PHI_SEARCH_RES_LIM              (3)
#define PHI_START_NUM_SEARCH_ANGLE      (3)

// Theta
#define THETA                           (1)
#define THETA_MIN                       (0)                                 // deg
#define THETA_MAX                       (359)                               // deg
#define THETA_LENGTH                    (51)
#define THETA_START_EST_ID              (17)
#define THETA_START_NUM_SEARCH_ANGLE    (3)

// -------------------------------------------------------------------------------------------------------------
// Check values
// -------------------------------------------------------------------------------------------------------------
#define INDEX_INVALID                   (-1)
#define ENERGIE_LIMIT					(40)

// -------------------------------------------------------------------------------------------------------------
// Histogram
// -------------------------------------------------------------------------------------------------------------
#define N_HISTOGRAM                   	(30)                                // EDMA-Frames
#define HISTOGRAM_THRESHOLD				(20)								// 20%

// -------------------------------------------------------------------------------------------------------------
// Buffer
// -------------------------------------------------------------------------------------------------------------
#define N_SAMPLES                       (512)
#define N_CORRELATION                   ( 2*N_SAMPLES )
#define BLOCKSIZE  						( N_SAMPLES )						// EDMA blocksize (max. 2731)

#define INV_N_CORRELATION               ( 1.0 / N_CORRELATION )
#define INV_N_SAMPLES                   ( 1.0 / N_SAMPLES )
#define CORR_OFFSET                     ( N_CORRELATION / 2 )
#define MAX_DELAY						(28+1) 								// Sample

// -------------------------------------------------------------------------------------------------------------
// FFT
// -------------------------------------------------------------------------------------------------------------
#define RADIX                           (2)                         		// radix or base
#define DELTA                           ( (2*PI) / N_CORRELATION )			// argument for sine/cosine

// -------------------------------------------------------------------------------------------------------------
// STRUCTURE DEFINITION
// -------------------------------------------------------------------------------------------------------------
typedef struct {
    float re, im;
}st_complex;

// Structure to hold values according to microphon array
typedef struct {
    float   f_MicAngle;
    float   f_MicPos[N_ANGLES][N_CHANNELS];
    float   f_MicTmpVec[N_COORDINATES];
    float   f_MicVector[N_COORDINATES][N_CHANNELS];
    float   f_MicDistance[N_COORDINATES][N_CHANNEL_PAIRS];
    float   f_DOAVector[N_COORDINATES];
    short   int16_DeltaTauRound[N_CHANNEL_PAIRS];
    float   f_MinDistance;
    float   int16_AngleRes;
    short   int16_NumOfMicPairs;
}Array;

// Structure to hold signal values
typedef struct {
    st_complex f_CmplxSigBuf[N_CHANNELS][N_CORRELATION];
    st_complex f_CmplxSigBufXY[N_CORRELATION];
    float	   f_SigBufXY[N_CHANNEL_PAIRS][MAX_DELAY];
    float      f_SigBufVar[N_CHANNELS];
    float      f_Ra_p[N_CHANNELS][N_CHANNELS];
    short      int16_HistRingBuf[N_ANGLES][N_HISTOGRAM];
} st_Buffer;




// Structure to hold values according to angles
typedef struct {
    short int16_StartIdx;
    short int16_EstIdx;
    short int16_Idx[N_SEARCH_ANGLES];
    short int16_SearchRes[N_LOOPS];
    short int16_Length;
    short int16_NumOfSearchAngles;
    float *f_LUT;
    short *int16_Hist;
    short int16_HistEstIdx;
    short int16_HistEstOldIdx;
    short int16_HistEstVal;
} Angle;


// -------------------------------------------------------------------------------------------------------------
// TI-FFT
// -------------------------------------------------------------------------------------------------------------
extern short iTwid[N_CORRELATION/2];       // index for twiddle constants W
extern st_complex W[N_CORRELATION/RADIX];  // array for twiddle constants

// -------------------------------------------------------------------------------------------------------------
// DECLARATION OF GLOBAL VARIABLES
// -----------------------------------------------------------------------------
extern Array st_CubeArray;                 	// Structure to hold constants according to microphone array
extern st_Buffer st_Buf;                   	// Structure to hold all signal values
extern Angle st_Phi;						// Structure to hold values according to angle phi
extern Angle st_Theta;						// Structure to hold values according to angle Theta
extern short int16_HistogramThreshold;		// Threshlod to handle histogram decision

// ------------------------------------------------------------------------------------------------------------
// FUNCTION PROTOTYPS
// ------------------------------------------------------------------------------------------------------------
void Init();								// Function to init required constants

#endif
