/* ======================================================================= */
/* TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                         */
/* NAME                                                                    */
/*     DSPF_dp_iirlat -- Double Precision All-Pole IIR lattice filter           */
/*                                                                         */
/*   USAGE                                                                  */
/*                                                                          */
/*        This routine has following C prototype:                           */
/*                                                                          */
/*            void DSPF_dp_iirlat(                                               */
/*                          double *x,                                      */
/*                          int nx,                                         */
/*                          const double * restrict k,                      */
/*                          int nk,                                         */
/*                          double * restrict b,                            */
/*                          double * r                                      */
/*                          )                                               */
/*         x[nx]   : Input vector                                           */
/*         nx      : Length of input vector.                                */
/*         k[nk]   : Reflection coefficients                                */
/*         nk      : Number of reflection coefficients/lattice stages       */
/*                   Must be multiple of 2 and >=6.                         */
/*         b[nk+1] : Delay line elements from previous call. Should be      */
/*                   initialized to all zeros prior to the first call.      */
/*         r[nx]   : Output vector                                          */
/*                                                                          */
/*     DESCRIPTION                                                          */
/*                                                                          */
/*         This routine implements a real all-pole IIR filter in lattice    */
/*     structure (AR lattice). The filter consists of nk lattice stages.    */
/*     Each  stage  requires one  reflection coefficient  k and one delay   */
/*     element b. The routine takes an input vector x[] and returns the     */
/*     filter output in r[]. Prior to the first call of the outine the      */
/*     delay elements in b[]  should be set to zero. The input data may     */
/*     have to be pre-scaled to avoid overflow or achieve better SNR. The   */
/*     reflections  coefficients lie  in  the range -1.0 < k < 1.0. The     */
/*     order of the coefficients is such that k[nk-1] corresponds to the    */
/*     first lattice stage after the input and k[0] Corresponds to the      */
/*     last stage.                                                          */
/*                                                                          */
/*    TECHNIQUES                                                            */
/*                                                                          */
/*         1.  The loop has been unrolled by 4 times.                       */
/*                                                                          */
/*         2.  Register sharing has been used to optimize on the            */
/*             use of registers.                                            */
/*                                                                          */
/*    ASSUMPTIONS                                                           */
/*                                                                          */
/*        1. nk is a multiple of 2 and >=6.                                 */
/*        2. Extraneous loads are allowed (80 bytes) before the start of    */
/*           array.                                                         */
/*                                                                          */
/*                                                                          */
/*   C CODE                                                                 */
/*                                                                          */
/*   void DSPF_dp_iirlat(double * x, int nx, const double * restrict k, int nk,  */
/*                   double * restrict b, double * r)                       */
/*   {                                                                      */
/*                                                                          */
/*      double rt;     // output       //                                   */
/*      int i, j;                                                           */
/*                                                                          */
/*      for (j = 0; j < nx; j++)                                            */
/*      {                                                                   */
/*         rt = x[j];                                                       */
/*                                                                          */
/*         for (i = nk - 1; i >= 0; i--)                                    */
/*         {                                                                */
/*             rt = rt - b[i] * k[i];                                       */
/*             b[i + 1] = b[i] + rt * k[i];                                 */
/*         }                                                                */
/*                                                                          */
/*         b[0] = rt;                                                       */
/*         r[j] = rt;                                                       */
/*      }                                                                   */
/*    }                                                                     */
/*                                                                          */
/*  NOTES                                                                   */
/*                                                                          */
/*      1. Endian: This code is LITTLE ENDIAN.                              */
/*      2. Interruptibility: This code is interrupt-tolerant but not        */
/*         interruptible.                                                   */
/*                                                                          */
/*  CYCLES                                                                  */
/*                                                                          */
/*      (24*Ceil(nk/4) + 19)* nx + 33                                       */
/*       For nk = 14, nx = 64 cycles = 7393                                 */
/*                                                                          */
/*  CODESIZE                                                                */
/*                                                                          */
/*        832 bytes                                                         */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2004 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSPF_DP_IIRLAT_H_
#define DSPF_DP_IIRLAT_H_ 1

void DSPF_dp_iirlat(
              double *x,
              int nx,
              const double * restrict k,
              int nk,
              double * restrict b,
              double * r
              );

#endif
/* ======================================================================== */
/*  End of file:  DSPF_dp_iirlat.h                                               */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2004 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
