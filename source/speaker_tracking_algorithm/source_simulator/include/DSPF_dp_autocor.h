/* ======================================================================= */
/* TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                         */
/* NAME                                                                    */
/*     DSPF_dp_autocor -- double Precision autocorrelation                      */
/*                                                                         */
/*  USAGE                                                                   */
/*                                                                          */
/*      This routine has the following C prototype:                         */
/*                                                                          */
/*      void DSPF_dp_autocor                                                     */
/*      (                                                                   */
/*          double    *  restrict r,                                        */
/*          double    *  restrict x,                                        */
/*          int       nx,                                                   */
/*          int       nr                                                    */
/*      )                                                                   */
/*                                                                          */
/*      r  = Pointer to output array of autocorrelation of length nr        */
/*      x  = Pointer to input array of length nx+nr. Input data must        */
/*           be padded with nr consecutive zeros at the beginning.          */
/*      nx = Length of autocorrelation vector.                              */
/*      nr = Length of lags.                                                */
/*                                                                          */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*                                                                          */
/*      This routine performs the autocorrelation of the input array x.     */
/*      is assumed that the length of the input array, x, is a              */
/*      multiple of 2 and the length of the output array, r, is a           */
/*      multiple of 4. The assembly routine computes 4 output samples       */
/*      at a time. It is assumed that input vector x is padded with nr      */
/*      no of zeros in the beginning.                                       */
/*                                                                          */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*                                                                          */
/*      1. The inner loop is unrolled twice and the outer loop is unrolled  */
/*      four times.                                                         */
/*                                                                          */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*                                                                          */
/*      1. nx is a multiple of 2 and greater than or equal to 4.            */
/*      2. nr is a multiple of 4 and greater than or equal to 4.            */
/*      3. nx is greater than or equal to nr                                */
/*                                                                          */
/*                                                                          */
/*  C CODE                                                                  */
/*                                                                          */
/*      This is the C equivalent of the assembly code.  Note that           */
/*      the assembly code is hand optimized and restrictions may apply.     */
/*                                                                          */
/*      void DSPF_dp_autocor                                                     */
/*      (                                                                   */
/*          double    *  restrict r,                                        */
/*          double    *  restrict x,                                        */
/*          int       nx,                                                   */
/*          int       nr                                                    */
/*      )                                                                   */
/*      {                                                                   */
/*          int i,k;                                                        */
/*          double sum;                                                     */
/*          for (i = 0; i < nr; i++)                                        */
/*          {                                                               */
/*              sum = 0;                                                    */
/*              for (k = nr; k < nx+nr; k++)                                */
/*                  sum += x[k] * x[k-i];                                   */
/*              r[i] = sum ;                                                */
/*          }                                                               */
/*      }                                                                   */
/*                                                                          */
/*                                                                          */
/*  NOTES                                                                   */
/*                                                                          */
/*      1. Endian: This code is LITTLE ENDIAN.                              */
/*      2. Interruptibility: This code is interrupt-tolerant but not        */
/*      interruptible.                                                      */
/*                                                                          */
/*                                                                          */
/*  CYCLES                                                                  */
/*                                                                          */
/*      2*nx*nr + 5/2*nr + 32                                               */
/*      For nx=32 and nr=64, cycles=4258                                    */
/*      For nx=24 and nr=32, cycles=1648                                    */
/*                                                                          */
/*                                                                          */
/*  CODESIZE                                                                */
/*                                                                          */
/*      576 bytes                                                           */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2004 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSPF_DP_AUTOCOR_H_
#define DSPF_DP_AUTOCOR_H_ 1

void DSPF_dp_autocor
(
    double    *  restrict r,
    double    *  restrict x,
    int       nx,
    int       nr
);

#endif
/* ======================================================================== */
/*  End of file:  DSPF_dp_autocor.h                                              */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2004 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
