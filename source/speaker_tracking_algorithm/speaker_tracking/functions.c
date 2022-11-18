//
//  functions.c
//  3D_Speaker_Tracking
//
//  Created by Mathias Buder on 29.05.13.
//  Copyright (c) 2013 Mathias Buder. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include <math.h>
#include "bios.h"
#include "setup.h"
#include "defines_globals.h"
#include "functions.h"

#ifndef C_MODE_ON
	#include "DSPF_sp_cfftr2_dit.h"
	#include "DSPF_sp_icfftr2_dif.h"
#endif


/*###########################################################################################
 ------------------------------------- BASIC OPERATIONS -------------------------------------
############################################################################################*/

/*********************************************************************************************
 float rad2deg( float rad )
 
 DESCRIPTION:
 	Convert angle in radiant to angle in degree.

    Parameter   rad - float value to convert
    Returns     deg - converted float value

 *********************************************************************************************/
float rad2deg( float rad ){
    return ( rad*180/PI );
}

/*********************************************************************************************
 float deg2rad( float deg )
 
 DESCRIPTION:
    Convert angle in degree to angle in radian.

    Parameter   deg - float value to convert
    Returns     rad - converted float value
 *********************************************************************************************/
float deg2rad( float deg ){
    return ( deg*PI/180 );
}

/*********************************************************************************************
 void CalcMicMatrix ( Array *st_CubeArray,
                      short int16_NumOfMics,
                      float f_ArrayRadius)
 
 DESCRIPTION:
    TODO ...
*********************************************************************************************/
void CalcMicMatrix ( Array *st_CubeArray,
                     short int16_NumOfMics,
                     float f_ArrayRadius){
    
    short i;
    
    for ( i=0; i < int16_NumOfMics; i++ ) {
        st_CubeArray->f_MicVector[0][i] = f_ArrayRadius * cos( st_CubeArray->f_MicPos[0][i] ) * cos( st_CubeArray->f_MicPos[1][i] );
        st_CubeArray->f_MicVector[1][i] = f_ArrayRadius * cos( st_CubeArray->f_MicPos[0][i] ) * sin( st_CubeArray->f_MicPos[1][i] );
        st_CubeArray->f_MicVector[2][i] = f_ArrayRadius * sin( st_CubeArray->f_MicPos[0][i] );
    }
}

/*********************************************************************************************
 void CalcMicDistance( Array *st_CubeArray,
                       short int16_NumOfMics,
                       short int16_NumOfMicPairs,
                       short int16_NumOfCoords)
 
 DESCRIPTION:
    Calculates matrix by joining each microphone pair.
    The joining-vectors represent the distance
    between every microphone.
*********************************************************************************************/
void CalcMicDistance( Array *st_CubeArray,
                      short int16_NumOfMics,
                      short int16_NumOfMicPairs,
                      short int16_NumOfCoords ){
    
    short i,j,k,J,n;
    
    // Reset loop values
    i = 0;
    j = 1;
    k = 0;
    J = 1;
    
    while ( k < int16_NumOfMicPairs ) {
        
        for ( n=0; n < int16_NumOfCoords; n++ ) {
            st_CubeArray->f_MicDistance[n][k] = st_CubeArray->f_MicVector[n][i] - st_CubeArray->f_MicVector[n][j];
        }
        
        k++;
        
        if ( j == (int16_NumOfMics-1 ) ) {
            J++;
            j=J;
            i++;
        }
        else{
            j++;
        }
    }
}

/*********************************************************************************************
 void CalcAngleLUTs( Array *st_CubeArray,
                     short int16_ThetaLen,
                     short int16_PhiLen)
 
 DESCRIPTION:
    TODO ...
*********************************************************************************************/
void CalcAngleLUTs( Array *st_CubeArray,
                    float *PhiLUT,
                    float *ThetaLUT,
                    short int16_ThetaLen,
                    short int16_PhiLen ){
    
    short i;
    
    // Create look-up-values for theta
    for ( i=0; i < int16_ThetaLen; i++ ) {
        ThetaLUT[i] = i * st_CubeArray->int16_AngleRes;
    }
    
    // Create look-up-values for phi
    for ( i=0; i < (int16_PhiLen-1)/2; i++ ) {

    	// Negative values
        PhiLUT[i] = (-1) * (((int16_PhiLen-1)/2)-i) * st_CubeArray->int16_AngleRes;

        // Positive values
        PhiLUT[i + ((int16_PhiLen-1)/2)+1] = (i+1) * st_CubeArray->int16_AngleRes;
    }

    PhiLUT[(int16_PhiLen-1)/2] = 0.0;
}

/*********************************************************************************************
 float CalcDetNxN( float f_Scr[N_CHANNELS][N_CHANNELS],
                   short int16_Len )
 
 DESCRIPTION:
    Calculates determinant of 2D-Array of size ( int16_Len x int16_Len )
 *********************************************************************************************/
float CalcDetNxN( float f_Scr[N_CHANNELS][N_CHANNELS],
                  short int16_Len ){

	// Locals
    short i, j, k;
    short l = 0;
    double d_factor;
    double d_det = 1.0;
    

    // Transform matrix into upper triangular
    for( i = 0; i < int16_Len - 1; i++ ) {

    	// Elementary Row Operation I
        if( f_Scr[i][i] == 0 )
        {
            for( k = i; k < int16_Len; k++ ) {
                if(f_Scr[k][i] != 0) {
                    for(j = 0; j < int16_Len; j++) {
                        d_det = f_Scr[i][j];
                        f_Scr[i][j] = f_Scr[k][j];
                        f_Scr[k][j] = d_det;
                    }
                    k = int16_Len;
                }
            }
            l++;
        }

        // Elementary Row Operation II
        if( f_Scr[i][i] != 0 ) {
            for( k = i + 1; k < int16_Len; k++ ) {
                d_factor = -1.0 * f_Scr[k][i] / f_Scr[i][i];
                
                for( j = i; j < int16_Len; j++ ) {
                    f_Scr[k][j] = f_Scr[k][j] + (d_factor * f_Scr[i][j]);
                }
            }
        }
    }
    
    // Calculate determinant
    for( i = 0; i < int16_Len; i++ ) {
        d_det *= f_Scr[i][i];
    }
    
    // Modify determinant
    if( l % 2 != 0 ) {
        d_det = -1.0 * d_det;
    }
    
    return d_det;
}

/*********************************************************************************************
 void UCAFunctionTauRound(  Array *st_CubeArray ,
                            float f_phi, float f_theta,
                            short int16_NumOfMicPairs,
                            float f_InvAcousticVilocity,
                            short int16_SamplingFrequancy){
 
 DESCRIPTION:
    TODO ...
 *********************************************************************************************/
void UCAFunctionTauRound( Array *st_CubeArray ,
                          float f_phi,
                          float f_theta,
                          short int16_NumOfMicPairs,
                          float f_InvAcousticVilocity,
                          unsigned short int16_SamplingFrequancy ){
    
    short i;
    float f_tmp;
    
    // Calculate Direction-Of-Arrival (DOA) vector according to azimuth and elevation
    st_CubeArray->f_DOAVector[0] = cos(f_phi) * cos(f_theta);
    st_CubeArray->f_DOAVector[1] = cos(f_phi) * sin(f_theta);
    st_CubeArray->f_DOAVector[2] = sin(f_phi);

    // Calculate all  DOA's
    for ( i=0; i < int16_NumOfMicPairs; i++ ) {

        f_tmp =  -( ( ( st_CubeArray->f_MicDistance[0][i] * st_CubeArray->f_DOAVector[0] +
                        st_CubeArray->f_MicDistance[1][i] * st_CubeArray->f_DOAVector[1] +
                        st_CubeArray->f_MicDistance[2][i] * st_CubeArray->f_DOAVector[2] ) *
                          f_InvAcousticVilocity ) * int16_SamplingFrequancy );

        // Round results
        if ( f_tmp > 0 ) {
        	st_CubeArray->int16_DeltaTauRound[i] = (short) (f_tmp + 0.5);
        }
        else {
			st_CubeArray->int16_DeltaTauRound[i] = ( (short) (f_tmp - 0.5) );
		}
    }
}


/*********************************************************************************************
 void CmplxConjMul( st_complex *st_Sig_1,
                    st_complex *st_Sig_2,
                    st_complex *DestBuf,
                    short int16_BufLen ){
 
 DESCRIPTION:
 	 This function implements the complex conjugate multiplication for two array of
 	 type st_complex with same length.

 	 Parameters:
		st_complex *st_Sig_1 - Poiter to complex signal buffer 1
		st_complex *st_Sig_1 - Poiter to complex signal buffer 2
		st_complex *DestBuf  - Poiter to complex destination buffer
		int16_BufLen         - Length of buffers

 *********************************************************************************************/
void CmplxConjMul( st_complex *st_Sig_1,
                   st_complex *st_Sig_2,
                   st_complex *DestBuf,
                   short int16_BufLen ){
    short i;
    
    for ( i=0; i < int16_BufLen; i++ ) {
        DestBuf[i].re= ( st_Sig_1[i].re * st_Sig_2[i].re ) + ( st_Sig_1[i].im * st_Sig_2[i].im );
        DestBuf[i].im= ( st_Sig_1[i].im * st_Sig_2[i].re ) - ( st_Sig_1[i].re * st_Sig_2[i].im );
    }
}



/*********************************************************************************************
void FastCrossCorrelation( st_complex st_Scr[N_CHANNELS][N_CORRELATION],
                           st_complex st_Helper[N_CORRELATION],
						   float st_Dest[N_CHANNEL_PAIRS][MAX_DELAY],
                           short int16_NumOfMics,
                           short int16_NumOfMicPairs,
                           short int16_BufLen ){
 
 DESCRIPTION:
    TODO ...
 *********************************************************************************************/
void FastCrossCorrelation( st_complex st_Scr[N_CHANNELS][N_CORRELATION],
                           st_complex st_Helper[N_CORRELATION],
						   float st_Dest[N_CHANNEL_PAIRS][MAX_DELAY],
                           short int16_NumOfMics,
                           short int16_NumOfMicPairs,
                           short int16_BufLen ){
        
    short i, j, k, n;

    // Calculate all FFT's in place
    for ( i=0; i < int16_NumOfMics; i++ ) {
		#ifdef C_MODE_ON
    		C_DSPF_sp_cfftr2_dit( (float*) st_Scr[i], (float*) W, int16_BufLen );
		#else
    		DSPF_sp_cfftr2_dit( (float*) st_Scr[i], (float*) W, int16_BufLen );
		#endif
    }
    
    // Calculate Cross-Correlation-Functions in place (result is not FFT-shifted by int16_BufLen/2)
    n = 0;
    for ( i=0; i < (int16_NumOfMics-1); i++ ) {			// Row
        for ( j=(i+1); j < int16_NumOfMics; j++ ) {		// Column
            
        	CmplxConjMul( st_Scr[i], st_Scr[j], st_Helper, int16_BufLen );

			#ifdef C_MODE_ON
        		C_DSPF_sp_icfftr2_dif( (float*) st_Helper, (float*) W, int16_BufLen );
			#else
        		DSPF_sp_icfftr2_dif( (float*) st_Helper, (float*) W, int16_BufLen );
			#endif

        	// Set Zero-Element
        	st_Dest[n][((MAX_DELAY-1)/2)] = st_Helper[0].re * INV_N_CORRELATION;

        	// Cut minimum data needed out of Cross-Correlation-Function
        	for( k=0; k < (MAX_DELAY-1)/2; k++) {
        		st_Dest[n][k] = st_Helper[k + int16_BufLen - (MAX_DELAY-1)/2].re * INV_N_CORRELATION;
        		st_Dest[n][k+ ((MAX_DELAY+1)/2)] = st_Helper[k+1].re * INV_N_CORRELATION;
        	}

        	n++;
        }
    }
}




/*********************************************************************************************
void digitrev_index( short *index,
					 int n,
					 int radix )

 DESCRIPTION:
	From TI's docs on bitrev_cplx (both docs and code):
	This routine calculates the index for digitrev of length n (length of index is
	2^(radix*ceil(k/radix)) where n = 2^k.
	in other words Either:
					sqrt(n) when n=2^even# Or: sqrt(2)*sqrt(n) when n=2^odd# [radix 2]
					sqrt(n) when n=4^even# Or: sqrt(4)*sqrt(n) when n=4^odd# [radix 4]
					Note: the variable "radix" is 2 for radix-2 and 4 for radix-4
 *********************************************************************************************/
void digitrev_index( short *index, int n, int radix ){


	int		i,j,k;
	short	nbits, nbot, ntop, ndiff, n2, raddiv2;

	nbits = 0;
	i = n;
	while ( i > 1 ){
		i = i >> 1;
		nbits++;
	}

	raddiv2	= radix >> 1;
	nbot	= nbits >> raddiv2;
	nbot	= nbot << raddiv2 - 1;
	ndiff	= nbits & raddiv2;
	ntop	= nbot + ndiff;
	n2	= 1 << ntop;
	index[0] = 0;
	for ( i = 1, j = n2/radix + 1; i < n2 - 1; i++ ){
		index[i] = j - 1;
		for ( k = n2/radix; k*(radix-1) < j; k /= radix )
				j -= k*(radix-1);
		j += k;
	}
	index[n2 - 1] = n2 - 1;

}

/*********************************************************************************************
 void Copy2CmplxStruct( const short int16_Scr[N_CHANNELS][N_SAMPLES],
                        st_complex st_Dest[N_CHANNELS][N_CORRELATION],
                        short int16_ScrLen,
                        short int16_DestLen,
                        short int16_NumOfMics ){
 
 DESCRIPTION:
    TODO ...
 *********************************************************************************************/
void Copy2CmplxStruct( volatile short int16_Scr[N_SAMPLES],
                      st_complex st_Dest[N_CORRELATION],
                      short int16_ScrLen ){
    short i;
    
    for ( i=0; i < int16_ScrLen; i++ ) {
        
        // Copy source buffer to complex struct
        st_Dest[i].re = ( (float) int16_Scr[i] ) * CONVERT_INT16_TO_FLOAR;
        st_Dest[i].im = 0.0;
 
        // do zero-padding for the rest of destination buffer
        st_Dest[i+int16_ScrLen].re = 0.0;
        st_Dest[i+int16_ScrLen].im = 0.0;
    }
}



/*###########################################################################################
 ----------------------------- Direction-Of-Arrival OPERATIONS ------------------------------
 ############################################################################################*/



/*********************************************************************************************
 void CalcVariance( st_complex st_Scr[N_CHANNELS][N_CORRELATION],
                    float *f_Dest,
                    short int16_BufLen,
 
 DESCRIPTION:
    TODO ...
 *********************************************************************************************/
void CalcVariance( st_complex st_Scr[N_CHANNELS][N_CORRELATION],
                   float *f_Dest,
                   short int16_BufLen,
                   short int16_NumOfMics,
                   float f_Norm ){
    
    short i, j;
    
    // Calculate variance elements of Ra(p)
    for ( i=0; i < int16_NumOfMics; i++ ) {
        f_Dest[i] = 0;
        for ( j=0; j < int16_BufLen; j++ ) {
            f_Dest[i] += st_Scr[i][j].re * st_Scr[i][j].re;
        }
        f_Dest[i] = f_Norm * f_Dest[i];
        
    }
}



/*********************************************************************************************
void Create_Ra_p(   float f_Scr[N_CHANNEL_PAIRS][MAX_DELAY],
					float f_Scr_Var[N_CHANNELS],
					float f_Dest[N_CHANNELS][N_CHANNELS],
					short int16_DeltaTau[N_CHANNEL_PAIRS] )
 
 DESCRIPTION:
    TODO ...
 *********************************************************************************************/
void Create_R(		float f_Scr[N_CHANNEL_PAIRS][MAX_DELAY],
					float f_Scr_Var[N_CHANNELS],
					float f_Dest[N_CHANNELS][N_CHANNELS],
					short int16_DeltaTau[N_CHANNEL_PAIRS] ){


	// Row: 1
	f_Dest[0][0] = f_Scr_Var[0];										// Column: 1 (X_00)
	f_Dest[0][1] = f_Scr[0][int16_DeltaTau[0] + (MAX_DELAY-1)/2];		// Column: 2 (X_01)
	f_Dest[0][2] = f_Scr[1][int16_DeltaTau[1] + (MAX_DELAY-1)/2];		// Column: 3 (X_02)
	f_Dest[0][3] = f_Scr[2][int16_DeltaTau[2] + (MAX_DELAY-1)/2];		// Column: 4 (X_03)
	f_Dest[0][4] = f_Scr[3][int16_DeltaTau[3] + (MAX_DELAY-1)/2];		// Column: 5 (X_04)
	f_Dest[0][5] = f_Scr[4][int16_DeltaTau[4] + (MAX_DELAY-1)/2];		// Column: 6 (X_05)
	f_Dest[0][6] = f_Scr[5][int16_DeltaTau[5] + (MAX_DELAY-1)/2];		// Column: 7 (X_06)
	f_Dest[0][7] = f_Scr[6][int16_DeltaTau[6] + (MAX_DELAY-1)/2];		// Column: 8 (X_07)

	// Row: 2
	f_Dest[1][0] = f_Scr[0][int16_DeltaTau[0] + (MAX_DELAY-1)/2];		// Column: 1 (X_10)
	f_Dest[1][1] = f_Scr_Var[1];                                    	// Column: 2 (X_11)
	f_Dest[1][2] = f_Scr[7][int16_DeltaTau[7] + (MAX_DELAY-1)/2];		// Column: 3 (X_12)
	f_Dest[1][3] = f_Scr[8][int16_DeltaTau[8] + (MAX_DELAY-1)/2];		// Column: 4 (X_13)
	f_Dest[1][4] = f_Scr[9][int16_DeltaTau[9] + (MAX_DELAY-1)/2];		// Column: 5 (X_14)
	f_Dest[1][5] = f_Scr[10][int16_DeltaTau[10] + (MAX_DELAY-1)/2];		// Column: 6 (X_15)
	f_Dest[1][6] = f_Scr[11][int16_DeltaTau[11] + (MAX_DELAY-1)/2];		// Column: 7 (X_16)
	f_Dest[1][7] = f_Scr[12][int16_DeltaTau[12] + (MAX_DELAY-1)/2];		// Column: 8 (X_17)

	// Row: 3
	f_Dest[2][0] = f_Scr[1][int16_DeltaTau[1] + (MAX_DELAY-1)/2];		// Column: 1 (X_20)
	f_Dest[2][1] = f_Scr[7][int16_DeltaTau[7] + (MAX_DELAY-1)/2];		// Column: 2 (X_21)
	f_Dest[2][2] = f_Scr_Var[2];                                    	// Column: 3 (X_22)
	f_Dest[2][3] = f_Scr[13][int16_DeltaTau[13] + (MAX_DELAY-1)/2];		// Column: 4 (X_23)
	f_Dest[2][4] = f_Scr[14][int16_DeltaTau[14] + (MAX_DELAY-1)/2];		// Column: 5 (X_24)
	f_Dest[2][5] = f_Scr[15][int16_DeltaTau[15] + (MAX_DELAY-1)/2];		// Column: 6 (X_25)
	f_Dest[2][6] = f_Scr[16][int16_DeltaTau[16] + (MAX_DELAY-1)/2];		// Column: 7 (X_26)
	f_Dest[2][7] = f_Scr[17][int16_DeltaTau[17] + (MAX_DELAY-1)/2];		// Column: 8 (X_27)

	// Row: 4
	f_Dest[3][0] = f_Scr[2][int16_DeltaTau[2] + (MAX_DELAY-1)/2];		// Column: 1 (X_30)
	f_Dest[3][1] = f_Scr[8][int16_DeltaTau[8] + (MAX_DELAY-1)/2];		// Column: 2 (X_31)
	f_Dest[3][2] = f_Scr[13][int16_DeltaTau[13] + (MAX_DELAY-1)/2];		// Column: 3 (X_32)
	f_Dest[3][3] = f_Scr_Var[3];										// Column: 4 (X_33)
	f_Dest[3][4] = f_Scr[18][int16_DeltaTau[18] + (MAX_DELAY-1)/2];		// Column: 5 (X_34)
	f_Dest[3][5] = f_Scr[19][int16_DeltaTau[19] + (MAX_DELAY-1)/2];		// Column: 6 (X_35)
	f_Dest[3][6] = f_Scr[20][int16_DeltaTau[20] + (MAX_DELAY-1)/2];		// Column: 7 (X_36)
	f_Dest[3][7] = f_Scr[21][int16_DeltaTau[21] + (MAX_DELAY-1)/2];		// Column: 8 (X_37)

	// Row: 5
	f_Dest[4][0] = f_Scr[3][int16_DeltaTau[3] + (MAX_DELAY-1)/2];		// Column: 1 (X_40)
	f_Dest[4][1] = f_Scr[9][int16_DeltaTau[9] + (MAX_DELAY-1)/2];		// Column: 2 (X_41)
	f_Dest[4][2] = f_Scr[14][int16_DeltaTau[14] + (MAX_DELAY-1)/2];		// Column: 3 (X_42)
	f_Dest[4][3] = f_Scr[18][int16_DeltaTau[18] + (MAX_DELAY-1)/2];		// Column: 4 (X_43)
	f_Dest[4][4] = f_Scr_Var[4];                                    	// Column: 5 (X_44)
	f_Dest[4][5] = f_Scr[22][int16_DeltaTau[22] + (MAX_DELAY-1)/2];		// Column: 6 (X_45)
	f_Dest[4][6] = f_Scr[23][int16_DeltaTau[23] + (MAX_DELAY-1)/2];		// Column: 7 (X_46)
	f_Dest[4][7] = f_Scr[24][int16_DeltaTau[24] + (MAX_DELAY-1)/2];		// Column: 8 (X_47)

	// Row: 6
	f_Dest[5][0] = f_Scr[4][int16_DeltaTau[4] + (MAX_DELAY-1)/2];		// Column: 1 (X_50)
	f_Dest[5][1] = f_Scr[10][int16_DeltaTau[10] + (MAX_DELAY-1)/2];		// Column: 2 (X_51)
	f_Dest[5][2] = f_Scr[15][int16_DeltaTau[15] + (MAX_DELAY-1)/2];		// Column: 3 (X_52)
	f_Dest[5][3] = f_Scr[19][int16_DeltaTau[19] + (MAX_DELAY-1)/2];		// Column: 4 (X_53)
	f_Dest[5][4] = f_Scr[22][int16_DeltaTau[22] + (MAX_DELAY-1)/2];		// Column: 5 (X_54)
	f_Dest[5][5] = f_Scr_Var[5];                                   		// Column: 6 (X_55)
	f_Dest[5][6] = f_Scr[25][int16_DeltaTau[25] + (MAX_DELAY-1)/2];		// Column: 7 (X_56)
	f_Dest[5][7] = f_Scr[26][int16_DeltaTau[26] + (MAX_DELAY-1)/2];		// Column: 8 (X_57)

	// Row: 7
	f_Dest[6][0] = f_Scr[5][int16_DeltaTau[5] + (MAX_DELAY-1)/2];		// Column: 1 (X_60)
	f_Dest[6][1] = f_Scr[11][int16_DeltaTau[11] + (MAX_DELAY-1)/2];		// Column: 2 (X_61)
	f_Dest[6][2] = f_Scr[16][int16_DeltaTau[16] + (MAX_DELAY-1)/2];		// Column: 3 (X_62)
	f_Dest[6][3] = f_Scr[20][int16_DeltaTau[20] + (MAX_DELAY-1)/2];		// Column: 4 (X_63)
	f_Dest[6][4] = f_Scr[23][int16_DeltaTau[23] + (MAX_DELAY-1)/2];		// Column: 5 (X_64)
	f_Dest[6][5] = f_Scr[25][int16_DeltaTau[25] + (MAX_DELAY-1)/2];		// Column: 6 (X_65)
	f_Dest[6][6] = f_Scr_Var[6];                                    	// Column: 7 (X_66)
	f_Dest[6][7] = f_Scr[27][int16_DeltaTau[27]-1];						// Column: 8 (X_67)

	// Row: 8
	f_Dest[7][0] = f_Scr[6][int16_DeltaTau[6] + (MAX_DELAY-1)/2];       // Column: 1 (X_70)
	f_Dest[7][1] = f_Scr[12][int16_DeltaTau[12] + (MAX_DELAY-1)/2];     // Column: 2 (X_71)
	f_Dest[7][2] = f_Scr[17][int16_DeltaTau[17] + (MAX_DELAY-1)/2];     // Column: 3 (X_72)
	f_Dest[7][3] = f_Scr[21][int16_DeltaTau[21] + (MAX_DELAY-1)/2];     // Column: 4 (X_73)
	f_Dest[7][4] = f_Scr[24][int16_DeltaTau[24] + (MAX_DELAY-1)/2];     // Column: 5 (X_74)
	f_Dest[7][5] = f_Scr[26][int16_DeltaTau[26] + (MAX_DELAY-1)/2];     // Column: 6 (X_75)
	f_Dest[7][6] = f_Scr[27][int16_DeltaTau[27] + (MAX_DELAY-1)/2];		// Column: 7 (X_76)
	f_Dest[7][7] = f_Scr_Var[7];                                    	// Column: 8 (X_77)

}


#ifdef SEARCH_OPT_MODE_ON
/*********************************************************************************************
 void SearchAndFind()
 
 DESCRIPTION:
    TODO ...
 *********************************************************************************************/
void SearchAndFind( Angle *st_Phi,
                    Angle *st_Theta,
                    Array *st_CubeArray,
                    st_Buffer *st_SigBuf,
                    short int16_NumOfLoops ){

    short i, j, k;
    float f_Det, f_DetMin;

    // Reset start values for search
    st_Phi->int16_EstIdx = PHI_START_EST_ID;
    st_Theta->int16_EstIdx = THETA_START_EST_ID;
    st_Phi->int16_NumOfSearchAngles = N_SEARCH_ANGLES;
    st_Theta->int16_NumOfSearchAngles = N_SEARCH_ANGLES;


    // Search across entire area
    for ( k=0; k < int16_NumOfLoops; k++ ) {


    	// Direction properties for angle theta
        st_Theta->int16_StartIdx = st_Theta->int16_EstIdx - st_Theta->int16_SearchRes[k];

        if ( st_Theta->int16_StartIdx < 0 ) {
            st_Theta->int16_StartIdx = st_Theta->int16_Length + st_Theta->int16_StartIdx;
        }


        // Direction properties for angle phi
        if ( st_Phi->int16_EstIdx >= st_Phi->int16_Length ) {
            st_Phi->int16_StartIdx = st_Phi->int16_EstIdx - 2 * st_Phi->int16_SearchRes[k];
        }
        else{
            if ( st_Phi->int16_EstIdx  < 0 ) {
                st_Phi->int16_StartIdx = st_Phi->int16_EstIdx;
            }
            else{
                st_Phi->int16_StartIdx = st_Phi->int16_EstIdx - st_Phi->int16_SearchRes[k];
            }
        }

        // Calculate search directions for angle theta
        for (j=0; j < st_Theta->int16_NumOfSearchAngles; j++) {

            st_Theta->int16_Idx[j] = st_Theta->int16_StartIdx + j * st_Theta->int16_SearchRes[k];

            if ( st_Theta->int16_Idx[j] > (st_Theta->int16_Length - 1) ) {
                st_Theta->int16_Idx[j] = st_Theta->int16_Idx[j] - st_Theta->int16_Length ;
            }
        }

        if ( k >= (int16_NumOfLoops-1) ) {
            st_Phi->int16_NumOfSearchAngles = 1;
        }

        // Calculate search directions for angle phi
        for ( j=0; j < st_Phi->int16_NumOfSearchAngles; j++ ) {
            st_Phi->int16_Idx[j] = st_Phi->int16_StartIdx + j * st_Phi->int16_SearchRes[k];
        }

        // Reset minimum of determinant
        f_DetMin = 0;

        // Search across defined area
        for ( i=0; i < st_Phi->int16_NumOfSearchAngles; i++ ) {
            for ( j=0; j < st_Theta->int16_NumOfSearchAngles; j++ ) {

            	// Calculate SDOA's (Sample-Difference-Of-arrival) according to given angle's phi and theta (in rad)
                UCAFunctionTauRound( st_CubeArray,
                                     st_Phi->f_LUT[ st_Phi->int16_Idx[i] ],
                                     st_Theta->f_LUT[ st_Theta->int16_Idx[j] ],
                                     N_CHANNEL_PAIRS,
                                     INV_ACOUSTIC_VILOCITY,
                                     SAMPFREQ );

                // Create Matrix R of size N_CHANNELS x N_CHANNELS according to theoretical delays across all microphone pairs
                Create_R( st_SigBuf->f_SigBufXY,
                          st_SigBuf->f_SigBufVar,
                          st_SigBuf->f_Ra_p,
                          st_CubeArray->int16_DeltaTauRound );


                // Calculate determinant of R
                f_Det = CalcDetNxN( st_SigBuf->f_Ra_p, N_CHANNELS );

                // Check determinant for minimum
                if ( f_Det < f_DetMin ) {
                    f_DetMin = f_Det;

                    // Store index of minimum and use it for next iteration of k
                    if ( k < (int16_NumOfLoops-1) ) {
                    	st_Phi->int16_EstIdx = st_Phi->int16_Idx[i];
                    }
                    st_Theta->int16_EstIdx = st_Theta->int16_Idx[j];
				}
			}
		}
	}
}


#else
/*********************************************************************************************
 void SearchAndFind()

 DESCRIPTION:
    TODO ...
 *********************************************************************************************/
void SearchAndFind( Angle *st_Phi,
                    Angle *st_Theta,
                    Array *st_CubeArray,
                    st_Buffer *st_SigBuf,
                    short int16_NumOfLoops ){

    short i, j;
	float f_Det, f_DetMin;



    // Reset minimum of determinant
    f_DetMin = 10000;

        for ( i=0; i < st_Phi->int16_Length; i++ ) {
            for ( j=0; j < st_Theta->int16_Length; j++ ) {

            	// Calculate SDOA's (Sample-Difference-Of-arrival) according to given angle phi and theta (rad)
                UCAFunctionTauRound( st_CubeArray,
                                     st_Phi->f_LUT[i],
                                     st_Theta->f_LUT[j],
                                     N_CHANNEL_PAIRS,
                                     INV_ACOUSTIC_VILOCITY,
                                     SAMPFREQ );



                // Create Matrix R fo size ( N_CHANNELS x N_CHANNELS ) according to theoretical delays across all microphone pairs
                Create_R( st_SigBuf->f_SigBufXY,
                          st_SigBuf->f_SigBufVar,
                          st_SigBuf->f_Ra_p,
                          st_CubeArray->int16_DeltaTauRound );

                // Calculate determinant of Ra(p)
                f_Det = CalcDetNxN( st_SigBuf->f_Ra_p, N_CHANNELS );
                // RESET_GPIO(28);


                // Check determinant for minimum
                if ( f_Det < f_DetMin ) {
                    f_DetMin = f_Det;

                    // Store index of minimum in destination buffer
                    st_Phi->int16_EstIdx = i;
                    st_Theta->int16_EstIdx = j;

                }
            }
        }
       // ------------------------------------------------------------------------
        asm(" nop"); // place break point here!
       // ------------------------------------------------------------------------
}

#endif




/*********************************************************************************************
 float CalcEnergy( volatile short int16_Scr[N_SAMPLES],
				   short int16_BufLen ){
 
 DESCRIPTION:
    TODO ...
 *********************************************************************************************/
float CalcEnergy( volatile short int16_Scr[N_SAMPLES],
				  short int16_BufLen ){

	short i;
	float f_Dest = 0;	// Reset Energy before loop

	// Calculate energy for EDMA-Frame of channel 0
	for ( i=0; i < int16_BufLen; i++ ) {
		f_Dest += (float) (int16_Scr[i] * int16_Scr[i]);
	}

	return ( f_Dest * INV_N_SAMPLES * CONVERT_INT16_TO_FLOAR );
}


/*********************************************************************************************
 void CreateHistogramm( short int16_HistRingBuf[N_ANGLES][N_HISTOGRAM],
                        Angle *st_Phi,
                        Angle *st_Theta )
 
 DESCRIPTION:
    TODO ...
 *********************************************************************************************/
void CreateHistogram( short int16_HistRingBuf[N_ANGLES][N_HISTOGRAM],
                      Angle *st_Phi,
                      Angle *st_Theta ) {

	// Define locals
	short i;
    volatile short PhiHistCnt = 0;
    volatile short ThetaHistCnt = 0;
    
    // Reset all histogram elements to zero
    memset( st_Phi->int16_Hist, 0, sizeof(short) * PHI_LENGTH );
    memset( st_Theta->int16_Hist, 0, sizeof(short) * THETA_LENGTH );
    
    // Reset estimated index of maximum histogram value
    st_Phi->int16_HistEstIdx = INDEX_INVALID;
    st_Theta->int16_HistEstIdx = INDEX_INVALID;
    
    // Reset estimated histogram maximum value
    st_Phi->int16_HistEstVal = 0;
    st_Theta->int16_HistEstVal = 0;

    /*********************************************************************************************
      Loop over entire histogram-ring-buffer
     ********************************************************************************************/
    for ( i=0; i < N_HISTOGRAM; i++ ) {

    	/*********************************************************************************************
         Create histogram for phi
         ********************************************************************************************/
        // Check angle for validation (voiced)
        if ( int16_HistRingBuf[PHI][i] > INDEX_INVALID ) {

        	// Increment histogram value by one
        	st_Phi->int16_Hist[ int16_HistRingBuf[PHI][i] ]++;

        	// Check maximum / store value and index
        	if ( st_Phi->int16_Hist[ int16_HistRingBuf[PHI][i] ] > st_Phi->int16_HistEstVal ) {
        		st_Phi->int16_HistEstVal = st_Phi->int16_Hist[ int16_HistRingBuf[PHI][i] ];
                st_Phi->int16_HistEstIdx = int16_HistRingBuf[PHI][i];
            }

        	// Increment histogram counter
        	PhiHistCnt++;
        }
        
        /*********************************************************************************************
         Create histogram for theta
         ********************************************************************************************/
        // Check angle for validation (voiced)
        if ( int16_HistRingBuf[THETA][i] > INDEX_INVALID ) {

        	// Increment histogram value by one
        	st_Theta->int16_Hist[ int16_HistRingBuf[THETA][i] ]++;

        	// Check maximum / store value and index
            if ( st_Theta->int16_Hist[ int16_HistRingBuf[THETA][i] ] > st_Theta->int16_HistEstVal ) {
            	st_Theta->int16_HistEstVal = st_Theta->int16_Hist[ int16_HistRingBuf[THETA][i] ];
            	st_Theta->int16_HistEstIdx =  int16_HistRingBuf[THETA][i];
            }

            // Increment histogram counter
            ThetaHistCnt++;
        }
    }
    

    // Check for angle distribution
    if ( st_Phi->int16_HistEstVal < int16_HistogramThreshold ) {
    	st_Phi->int16_HistEstIdx = INDEX_INVALID;
    }


    if ( st_Theta->int16_HistEstVal < int16_HistogramThreshold ) {
        	st_Theta->int16_HistEstIdx = INDEX_INVALID;
    }

}





/*###########################################################################################
 ------------------------------------- I/O OPERATIONS -------------------------------------
############################################################################################*/


/*********************************************************************************************
 void send_string (char *s)

 DESCRIPTION:

    Transmit a 0-terminated string via the UART this function
    makes full use of the UART's transmit FIFOs it can also be
    used to transmit strings located in Flash Memory, because
    the characters are ANDed with FF to mask any undefined bits
    when read from non-32Bit wide memory.

    Parameter	:	*s Pointer to string
    Returns		:	Non
    Calls		:   BIOS function send_char

*********************************************************************************************/
void send_string( char *p_Str ) {

    /*******************************************************************
      Locals
    *******************************************************************/
    char *sp = p_Str;
    int i;

    while ( *sp & 0xFF )
    {
        /***************************************************************
          Wait until transmit hold register = transmit FIFO empty
        ***************************************************************/
        while ( ! send_char(*sp) );

        /***************************************************************
          We can now store up to 31 additional characters in the
          transmit FIFO (First-In-First-Out Buffer)
        ***************************************************************/
        i = 0;
        while ( (*++sp & 0xFF) && (++i < 31) ) UART->UART_THR = *sp;
    }
}


/***********************************************************************

char * Short2ASCII (short x)

    Convert a short integer into a base-10 ASCII string

    Parameter   x - short value to convert
    Returns     pointer to string
    Calls       -

    This function uses floating point multiplication instead of
    integer division and multiplication to prevent interrupt
    blocking: the integer div implementation of the default runtime
    library is compiled without the -mi switch and may block
    interrupts for quite a long time.
 
***********************************************************************/
char *Short2ASCII( short int16_Scr, short int16_Angle ) {
    /*******************************************************************
     Locals
     *******************************************************************/
	static char p_Str[7]; // vorher 7
	char *p = p_Str;
	char sign;
	short i;
	short temp;
    float fmul_1 = 0.001;
    float fmul_2 = 1000.0;
    
    /*******************************************************************
     Select angle prefix
     *******************************************************************/
    switch ( int16_Angle ) {
            
        // Add prefix 'p' for angle phi
        case PHI:
            *p = 'p';
        break;

        // Add prefix 't' for angle theta 
        case THETA:
            *p = 't';
        break;
    }
    
    p++;


    // REIHENFLOGE UMKEHREN IN FORMAT [Val_1 Val_2 Val_3 Val_4 sign] ( 1234- )
	/*******************************************************************
	Calculate sign
	*******************************************************************/
	if ( int16_Scr < 0 ) {
		//*p = '-';
		sign = '-';
		int16_Scr  = -int16_Scr;  // US 25-2-2011 NEGATE x (make it positive)
	}
	else {
		//*p = ' ';
		sign = '+';
	}
	//p++;


    /*******************************************************************
     Calculate 4 digits
     *******************************************************************/
	for ( i=0; i < 4; i++ ) {
        temp = (short) ( (float)int16_Scr * fmul_1 );
		*p++ = temp + '0';
        int16_Scr -= (short) ( (float)temp * fmul_2 );
        fmul_2 = fmul_2 * 0.1;
        fmul_1 = fmul_1 * 10.0;
	}
	*p++ = sign;
	*p = 0;
    
    /*******************************************************************
     Return pointer to ASCII string
    *******************************************************************/
	return ( p_Str );
}



#ifdef C_MODE_ON
/*###########################################################################################
 ------------------------------------- C-MODE FUNCTIONS-------------------------------------
############################################################################################*/

/*********************************************************************************************
C_DSPF_sp_cfftr2_dit(float* x, float* w, short n)

 DESCRIPTION:
    TODO ...
 *********************************************************************************************/
void C_DSPF_sp_cfftr2_dit(float* x, float* w, short n) {

	short n2, ie, ia, i, j, k, m;
	float rtemp, itemp, c, s;

	n2 = n;
	ie = 1;

	for(k=n; k > 1; k >>= 1) {
		n2 >>= 1;
		ia = 0;
		for(j=0; j < ie; j++) {
			c = w[2*j];
			s = w[2*j+1];
			for(i=0; i < n2; i++) {
				m = ia + n2;
				rtemp = c * x[2*m] + s * x[2*m+1];
				itemp = c * x[2*m+1] - s * x[2*m];
				x[2*m] = x[2*ia] - rtemp;
				x[2*m+1] = x[2*ia+1] - itemp;
				x[2*ia] = x[2*ia] + rtemp;
				x[2*ia+1] = x[2*ia+1] + itemp;
				ia++;
			}
			ia += n2;
		}
		ie <<= 1;
	}
}



/*********************************************************************************************
C_DSPF_sp_icfftr2_dif(float* x, float* w, short n)

 DESCRIPTION:
    TODO ...
 *********************************************************************************************/
void C_DSPF_sp_icfftr2_dif(float* x, float* w, short n) {

	short n2, ie, ia, i, j, k, m;
	float rtemp, itemp, c, s;

	n2 = 1;
	ie = n;

	for(k=n; k > 1; k >>= 1) {
		ie >>= 1;
		ia = 0;
		for(j=0; j < ie; j++) {
			c = w[2*j];
			s = w[2*j+1];
			for(i=0; i < n2; i++) {
				m = ia + n2;
				rtemp = x[2*ia] - x[2*m];
				x[2*ia] = x[2*ia] + x[2*m];
				itemp = x[2*ia+1] - x[2*m+1];
				x[2*ia+1] = x[2*ia+1] + x[2*m+1];
				x[2*m] = c*rtemp - s*itemp;
				x[2*m+1] = c*itemp + s*rtemp;
				ia++;
			}
			ia += n2;
		}
		n2 <<= 1;
	}
}



/*********************************************************************************************
C_DSPF_sp_bitrev_cplx(double* x, short* index, int nx)

 DESCRIPTION:
    TODO ...
 *********************************************************************************************/
void C_DSPF_sp_bitrev_cplx(double* x, short* index, int nx) {
	int i;
	short i0, i1, i2, i3;
	short j0, j1, j2, j3;

	double xi0, xi1, xi2, xi3;
	double xj0, xj1, xj2, xj3;
	short t;
	int a, b, ia, ib, ibs;
	int mask;
	int nbits, nbot, ntop, ndiff, n2, halfn;
	nbits = 0;
	i = nx;

	while (i > 1) {
		i = i >> 1;
		nbits++;
	}

	nbot = nbits >> 1;
	ndiff = nbits & 1;
	ntop = nbot + ndiff;
	n2 = 1 << ntop;
	mask = n2 - 1;
	halfn = nx >> 1;

	for (i0 = 0; i0 < halfn; i0 += 2) {
		b = i0 & mask;
		a = i0 >> nbot;
		if (!b) ia = index[a];
		ib = index[b];
		ibs = ib << nbot;
		j0 = ibs + ia;
		t = i0 < j0;
		xi0 = x[i0];
		xj0 = x[j0];
		if (t) {
			x[i0] = xj0;
			x[j0] = xi0;
		}
		i1 = i0 + 1;

		j1 = j0 + halfn;
		xi1 = x[i1];
		xj1 = x[j1];
		x[i1] = xj1;
		x[j1] = xi1;
		i3 = i1 + halfn;
		j3 = j1 + 1;
		xi3 = x[i3];
		xj3 = x[j3];
		if (t) {
			x[i3] = xj3;
			x[j3] = xi3;
		}
	}
}
#endif
