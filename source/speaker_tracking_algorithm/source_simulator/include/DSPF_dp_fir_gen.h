/* ======================================================================= */
/* TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                         */
/* NAME                                                                    */
/*     DSPF_dp_fir_gen -- Double Precision Generic FIR filter                   */
/*                                                                         */
/*   USAGE                                                                  */
/*                                                                          */
/*   This routine is C Callable and can be called as:                       */
/*                                                                          */
/*       void DSPF_dp_fir_gen(const double *x, const double *h,                  */
/*                              double * restrict r,int nh, int nr);        */
/*                                                                          */
/*       x : Pointer to array holding the input floating point array        */
/*       h : Pointer to array holding the coefficient floating point        */
/*           array                                                          */
/*       r : Pointer to output array                                        */
/*       nh: Number of coefficents                                          */
/*       nr: Number of output values                                        */
/*                                                                          */
/*   DESCRIPTION                                                            */
/*                                                                          */
/*       This routine implements a block FIR filter.  There are "nh"        */
/*       filter coefficients, "nr" output samples, and "nh+nr-1"            */
/*       input samples.    The coefficients need to be placed in the "h"    */
/*       array in reverse order {h(nh-1), ... , h(1), h(0)} and the         */
/*       array "x" starts at x(-nh+1) and ends at x(nr-1).  The             */
/*       routine calculates y(0) through y(nr-1) using the following        */
/*       formula:                                                           */
/*                                                                          */
/*       r(n) = h(0)*x(n) + h(1)*x(n-1) + ... + h(nh-1)*x(n-nh+1)           */
/*                                                                          */
/*       where n = {0, 1, ... , nr-1}.                                      */
/*                                                                          */
/*   TECHNIQUES                                                             */
/*                                                                          */
/*       1.  The outer loop is unrolled 4 times.                            */
/*       2.  The inner loop is unrolled 2 times and software pipelined.     */
/*       3.  Register sharing is used to make optimum utilisation of        */
/*           available registers                                            */
/*       4.  Outerlop instructions and Prolog for next stage are scheduled  */
/*           in parallel with last iteration of kernel                      */
/*                                                                          */
/*   ASSUMPTIONS                                                            */
/*                                                                          */
/*       1.  Little Endian is assumed for LDDW instructions.                */
/*       2.  The number of coefficients must be greater than                */
/*           or equal to 4.                                                 */
/*       3.  The number of outputs must be greater than or equal to 4       */
/*                                                                          */
/*   C CODE                                                                 */
/*                                                                          */
/*       This is the C equivalent for the assembly code.  Note that         */
/*       the assembly code is hand optimized and restrictions may           */
/*       apply.                                                             */
/*                                                                          */
/*       void DSPF_dp_fir_gen(const double *x, const double *h,                  */
/*                   double * restrict r, int nh, int nr)                   */
/*       {                                                                  */
/*          int i, j;                                                       */
/*          double sum;                                                     */
/*                                                                          */
/*          for(i=0; i < nr; i++)                                           */
/*          {                                                               */
/*             sum = 0;                                                     */
/*             for(j=0; j < nh; j++)                                        */
/*             {                                                            */
/*                 sum += x[i+j] * h[j];                                    */
/*             }                                                            */
/*             r[i] = sum;                                                  */
/*          }                                                               */
/*       }                                                                  */
/*                                                                          */
/*                                                                          */
/*   NOTES                                                                  */
/*                                                                          */
/*      1. Endian: This code is LITTLE ENDIAN.                              */
/*      2. Interruptibility: This code is interrupt tolerant but not        */
/*         interruptible.                                                   */
/*                                                                          */
/*   CYCLES                                                                 */
/*                                                                          */
/*   (16*floor((nh+1)/2)+10)*(ceil(nr/4)) + 32                              */
/*    for nh=26, nr=42, cycles=2430 cycles.                                 */
/*                                                                          */
/*   CODESIZE                                                               */
/*                                                                          */
/*    672 bytes                                                             */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2004 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSPF_DP_FIR_GEN_H_
#define DSPF_DP_FIR_GEN_H_ 1

void DSPF_dp_fir_gen(const     double *x, const double *h,
                       double * restrict r,int nh, int nr);

#endif
/* ======================================================================== */
/*  End of file:  DSPF_dp_fir_gen.h                                              */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2004 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
