//
//  functions.h
//  3D_Speaker_Tracking
//
//  Created by Mathias Buder on 29.05.13.
//  Copyright (c) 2013 Mathias Buder. All rights reserved.

#ifndef _D_Speaker_Tracking_functions_h
#define _D_Speaker_Tracking_functions_h
/******************************************************************************************
******************************* FUNCTION PROTOTYPS  ***************************************
*******************************************************************************************
FUNCTION NAME            	VARIABLE TYPE	ARGUMENTS
*******************************************************************************************/
float rad2deg(              float   		rad );
/******************************************************************************************/
float deg2rad(              float   		deg );
/******************************************************************************************/
void CalcMicMatrix(         Array   		*st_CubeArray,
                            short   		int16_NumOfMics,
                            float   		f_ArrayRadius );
/******************************************************************************************/
void CalcMicDistance(       Array   		*st_CubeArray,
                            short   		int16_NumOfMics,
                            short   		int16_NumOfMicPairs,
                            short   		int16_NumOfCoords );
/******************************************************************************************/
void CalcAngleLUTs(         Array   		*st_CubeArray,
                            float   		*PhiLUT,
                            float   		*ThetaLUT,
                            short   		int16_ThetaLen,
                            short   		int16_PhiLen );
/******************************************************************************************/
float CalcDetNxN(           float   		f_Scr[N_CHANNELS][N_CHANNELS],
                            short   		int16_Len );
/******************************************************************************************/
void UCAFunctionTauRound(   Array   		*st_CubeArray ,
                            float   		f_phi,
                            float   		f_theta,
                            short   		int16_NumOfMicPairs,
                            float   		f_InvAcousticVilocity,
                            unsigned short 	int16_SamplingFrequancy );
/******************************************************************************************/
void CmplxConjMul(          st_complex 		*st_Sig_1,
                            st_complex 		*st_Sig_2,
                            st_complex 		*DestBuf,
                            short 			int16_BufLen );
/******************************************************************************************/
void FastCrossCorrelation( st_complex 		st_Scr[N_CHANNELS][N_CORRELATION],
                           st_complex 		st_Helper[N_CORRELATION],
						   float 			st_Dest[N_CHANNEL_PAIRS][MAX_DELAY],
                           short 			int16_NumOfMics,
                           short 			int16_NumOfMicPairs,
                           short 			int16_BufLen );
/******************************************************************************************/
void Copy2CmplxStruct(      volatile short 	int16_Scr[N_SAMPLES],
                            st_complex 		st_Dest[N_CORRELATION],
                            short 			int16_ScrLen);
/******************************************************************************************/
void CalcVariance(          st_complex 		st_Scr[N_CHANNELS][N_CORRELATION],
                            float 			*f_Dest,
                            short 			int16_BufLen,
                            short 			int16_NumOfMics,
                            float 			f_NormVariance);
/******************************************************************************************/
void Create_R(		   		float 			f_Scr[N_CHANNEL_PAIRS][MAX_DELAY],
							float 			f_Scr_Var[N_CHANNELS],
							float 			f_Dest[N_CHANNELS][N_CHANNELS],
							short 			int16_DeltaTau[N_CHANNEL_PAIRS] );
/******************************************************************************************/
void SearchAndFind(         Angle 			*st_Phi,
                            Angle 			*st_Theta,
                            Array 			*st_CubeArray,
                            st_Buffer 		*st_SigBuf,
                            short 			int16_NumOfLoops );
/******************************************************************************************/
void CreateHistogram(      	short 			int16_HistRingBuf[N_ANGLES][N_HISTOGRAM],
                            Angle 			*st_Phi,
                            Angle 			*st_Theta );
/******************************************************************************************/
float CalcEnergy( 			volatile short 	int16_Scr[N_SAMPLES],
				  	  	  	short 			int16_BufLen);
/******************************************************************************************/
void send_string (			char 			*p_Str);
/******************************************************************************************/
char *Short2ASCII( 			short 			int16_Scr,
							short 			int16_Angle );
/******************************************************************************************/
void SendAngleValue( 		float 			f_Phi,
							float 			f_Theta );
/******************************************************************************************/
void digitrev_index(		short 			*index,
							int 			n,
							int 			radix );
/******************************************************************************************/
#ifdef C_MODE_ON
void C_DSPF_sp_cfftr2_dit(	float			*x,
							float 			*w,
							short 			n );
/******************************************************************************************/
void C_DSPF_sp_icfftr2_dif(	float			*x,
							float			*w,
							short 			n );
/******************************************************************************************/
void C_DSPF_sp_bitrev_cplx(	double			*x,
							short			*index,
							int 			nx );
#endif
/******************************************************************************************/
#endif
