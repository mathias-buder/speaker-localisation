/* ======================================================================= */
/* TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                         */
/* NAME                                                                    */
/*     DSPF_dp_fir_cplx -- Double Precision complex Finite Impulse Response     */
/*     Filter                                                              */
/*                                                                         */
/* USAGE                                                                    */
/*                                                                          */
/*       This routine has the following C prototype:                        */
/*                                                                          */
/*       void DSPF_dp_fir_cplx(                                                  */
/*                        const double * restrict x,                        */
/*                        const double * restrict h,                        */
/*                        double *       restrict r,                        */
/*                        int   nh,                                         */
/*                        int   nr                                          */
/*                       )                                                  */
/*                                                                          */
/*            x[2*(nr+nh-1)]: Pointer to complex input array.               */
/*                            The input data pointer x must point to the    */
/*                           (nh)th complex element, i.e. element 2*(nh-1). */
/*            h[2*nh]       : Pointer to complex coefficient array          */
/*                            (in normal order).                            */
/*            r[2*nr]       : Pointer to complex output array.              */
/*            nh            : Number of complex coefficients in vector h.   */
/*            nr            : Number of complex output samples to           */
/*                           calculate.                                     */
/*                                                                          */
/* DESCRIPTION                                                              */
/*                                                                          */
/*       This function implements the FIR filter for complex input data.    */
/*       The filter has nr output samples and nh coefficients. Each array   */
/*       consists of an even and odd term with even terms representing the  */
/*       real part and the odd terms the imaginary part of the element.     */
/*       The coefficients are expected in normal order.                     */
/*                                                                          */
/*                                                                          */
/*     TECHNIQUES                                                           */
/*                                                                          */
/*    1. The outer loop is unrolled twice.                                  */
/*    2. Outer loop instructions are executed in parallel with inner loop.  */
/*    3. Register Sharing is used to make optimal use of available register *
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*                                                                          */
/*    1. nr is a multiple of 2 and greater than or equal to 2.              */
/*    2. nh is greater than or equal to 4.                                  */
/*    3. x points to 2*(nh-1)th input element.                              */
/*                                                                          */
/*                                                                          */
/* C CODE                                                                   */
/*                                                                          */
/*  This is the C equivalent of the assembly code.  Note that               */
/*  the assembly code is hand optimized and restrictions may apply.         */
/*                                                                          */
/*  void DSPF_dp_fir_cplx(const double * x, const double * h,                    */
/*                   double * restrict r, int nh, int nr)                   */
/*  {                                                                       */
/*       int i,j;                                                           */
/*       double imag, real;                                                 */
/*       for (i = 0; i < 2*nr; i += 2)                                      */
/*       {                                                                  */
/*           imag = 0;                                                      */
/*           real = 0;                                                      */
/*           for (j = 0; j < 2*nh; j += 2)                                  */
/*           {                                                              */
/*               real += h[j] * x[i-j] - h[j+1] * x[i+1-j];                 */
/*               imag += h[j] * x[i+1-j] + h[j+1] * x[i-j];                 */
/*           }                                                              */
/*           r[i] = real;                                                   */
/*           r[i+1] = imag;                                                 */
/*       }                                                                  */
/*  }                                                                       */
/*                                                                          */
/*                                                                          */
/* NOTES                                                                    */
/*                                                                          */
/*   1. Endian: This code is LITTLE ENDIAN.                                 */
/*   2. Interruptibility: This code is interrupt-tolerant but not           */
/*      interruptible.                                                      */
/*                                                                          */
/* CYCLES                                                                   */
/*                                                                          */
/*  8*nh*nr + 5*nr + 30                                                     */
/*  For nh=24 and nr=48, cycles=9486                                        */
/*  For nh=16 and nr=36, cycles=4818                                        */
/*                                                                          */
/* CODESIZE                                                                 */
/*                                                                          */
/*  608 bytes                                                               */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2004 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSPF_DP_FIR_CPLX_H_
#define DSPF_DP_FIR_CPLX_H_ 1

void DSPF_dp_fir_cplx(
                 const double * restrict x,
                 const double * restrict h,
                 double *       restrict r,
                 int   nh,
                 int   nr
                );

#endif
/* ======================================================================== */
/*  End of file:  DSPF_dp_fir_cplx.h                                             */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2004 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
