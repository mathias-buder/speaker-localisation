/* ======================================================================= */
/* TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                         */
/* NAME                                                                    */
/*     DSPF_sp_icfftr2_dif -- DSPF_sp_icfftr2_dif                                    */
/*                                                                         */
/*  USAGE                                                                   */
/*                                                                          */
/*      This routine is C-callable and can be called as:                    */
/*                                                                          */
/*          void DSPF_sp_icfftr2_dif(                                            */
/*                              float* x,                                   */
/*                              float* w,                                   */
/*                              short n                                     */
/*                             );                                           */
/*                                                                          */
/*          x : input and output sequences (dim-n)      (input/output)      */
/*              x has n complex numbers (2*n SP values).                    */
/*              The real and imaginary values are interleaved in memory.    */
/*              The input is in Bit reversed order nad output is in Normal  */
/*              Order.                                                      */
/*          w : FFT coefficients (dim-n/2)              (input)             */
/*              w has n/2 complex numbers (n SP values).                    */
/*              FFT coeficients must be in bit-reversed order               */
/*              The real and imaginary values are interleaved in memory     */
/*          n : FFT size                                (input)             */
/*                                                                          */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*                                                                          */
/*      This routine is used to compute the Inverse, Complex, Radix-2,      */
/*      Decimation-in-Frequency Fast Fourier Transform of a single          */
/*      precision complex sequence of size n, and a power of 2. The         */
/*      routine requires bit-reversed input and bit-reversed coefficents    */
/*      (twiddle factors) and produces results that are in normal order.    */
/*      Final scaling by 1/N is not done in this function.                  */
/*                                                                          */
/*      How To Use                                                          */
/*                                                                          */
/*          void main(void)                                                 */
/*          {                                                               */
/*              gen_w_r2(w, N);      // Generate coefficient table          */
/*              bit_rev(w, N>>1);    // Bit-reverse coefficient table       */
/*              cfftr2_dit(x, w, N); // This is the radix 2 FFT benchmark   */
/*                                   // from TI available                   */
/*                                   // input in normal order, output in    */
/*                                   // order bit-reversed                  */
/*                                   // coefficient table in bit-reversed   */
/*                                   // order                               */
/*                                                                          */
/*              icfftr2_dif(x, w, N);// Inverse radix 2 FFT                 */
/*                                   // input in bit-reversed order,        */
/*                                   // order output in normal              */
/*                                   // coefficient table in bit-reversed   */
/*                                   // order                               */
/*                                                                          */
/*              divide(x, N);        // scale inverse FFT output            */
/*                                   // result is same as original input    */
/*          }                                                               */
/*                                                                          */
/*                                                                          */
/*  TECHNIQUES                                                              */
/*                                                                          */
/*      1. Loading input x as well as coefficient w in double word.         */
/*      2. mpy was used to perform a mv.  EX. mpy x, 1, y <=> mv x, y       */
/*      3. Because the data loads are 1 itteration ahead of the             */
/*         coefficent loads, counter i was copied so that the actual        */
/*         count could live longer for the coefficent loads.                */
/*      4. 2 Inner loops are callapsed into one loop.                       */
/*      5. prolog and epilog are done in parallel with the outermost loop.  */
/*                                                                          */
/*                                                                          */
/*  ASSUMPTIONS                                                             */
/*                                                                          */
/*      1. Both input x and coefficient w should be aligned on double word  */
/*         boundary.                                                        */
/*      2. x should be padded with 4 words.                                 */
/*      3. n should be greater than 8.                                      */
/*                                                                          */
/*                                                                          */
/*  C CODE                                                                  */
/*                                                                          */
/*      This is the C equivalent of the assembly code without               */
/*      restrictions. Note that the assembly code is hand optimized         */
/*      and restrictions may apply.                                         */
/*                                                                          */
/*          void icfftr2_dif(float* x, float* w, short n)                   */
/*          {                                                               */
/*              short n2, ie, ia, i, j, k, m;                               */
/*              float rtemp, itemp, c, s;                                   */
/*                                                                          */
/*              n2 = 1;                                                     */
/*              ie = n;                                                     */
/*              for(k=n; k > 1; k >>= 1)                                    */
/*              {                                                           */
/*                  ie >>= 1;                                               */
/*                  ia = 0;                                                 */
/*                  for(j=0; j < ie; j++)                                   */
/*                  {                                                       */
/*                      c = w[2*j];                                         */
/*                      s = w[2*j+1];                                       */
/*                      for(i=0; i < n2; i++)                               */
/*                      {                                                   */
/*                          m = ia + n2;                                    */
/*                          rtemp     = x[2*ia]   - x[2*m];                 */
/*                          x[2*ia]   = x[2*ia]   + x[2*m];                 */
/*                          itemp     = x[2*ia+1] - x[2*m+1];               */
/*                          x[2*ia+1] = x[2*ia+1] + x[2*m+1];               */
/*                          x[2*m]    = c*rtemp   - s*itemp;                */
/*                          x[2*m+1]  = c*itemp   + s*rtemp;                */
/*                          ia++;                                           */
/*                      }                                                   */
/*                      ia += n2;                                           */
/*                  }                                                       */
/*                  n2 <<= 1;                                               */
/*              }                                                           */
/*          }                                                               */
/*                                                                          */
/*      The follwoing C code is used to generate the coefficient table      */
/*      (non-bit reversed).                                                 */
/*                                                                          */
/*          #include <math.h>                                               */
/*          // generate real and imaginary twiddle                          */
/*             table of size n/2 complex numbers //                         */
/*                                                                          */
/*          gen_w_r2(float* w, int n)                                       */
/*          {                                                               */
/*              int i;                                                      */
/*              float pi = 4.0*atan(1.0);                                   */
/*              float e = pi*2.0/n;                                         */
/*                                                                          */
/*              for(i=0; i < ( n>>1 ); i++)                                 */
/*              {                                                           */
/*                  w[2*i]   = cos(i*e);                                    */
/*                  w[2*i+1] = sin(i*e);                                    */
/*              }                                                           */
/*          }                                                               */
/*                                                                          */
/*      The follwoing C code is used to bit-reverse the coefficents.        */
/*                                                                          */
/*          bit_rev(float* x, int n)                                        */
/*          {                                                               */
/*              int i, j, k;                                                */
/*              float rtemp, itemp;                                         */
/*                                                                          */
/*              j = 0;                                                      */
/*              for(i=1; i < (n-1); i++)                                    */
/*              {                                                           */
/*                  k = n >> 1;                                             */
/*                  while(k <= j)                                           */
/*                  {                                                       */
/*                      j -= k;                                             */
/*                      k >>= 1;                                            */
/*                  }                                                       */
/*                  j += k;                                                 */
/*                  if(i < j)                                               */
/*                  {                                                       */
/*                      rtemp    = x[j*2];                                  */
/*                      x[j*2]   = x[i*2];                                  */
/*                      x[i*2]   = rtemp;                                   */
/*                      itemp    = x[j*2+1];                                */
/*                      x[j*2+1] = x[i*2+1];                                */
/*                      x[i*2+1] = itemp;                                   */
/*                  }                                                       */
/*              }                                                           */
/*          }                                                               */
/*                                                                          */
/*      The follwoing C code is used to perform the final scaling           */
/*      of the IFFT.                                                        */
/*                                                                          */
/*          // divide each element of x by n //                             */
/*          divide(float* x, int n)                                         */
/*          {                                                               */
/*              int i;                                                      */
/*              float inv = 1.0 / n;                                        */
/*                                                                          */
/*              for(i=0; i < n; i++)                                        */
/*              {                                                           */
/*                  x[2*i]   = inv * x[2*i];                                */
/*                  x[2*i+1] = inv * x[2*i+1];                              */
/*              }                                                           */
/*          }                                                               */
/*                                                                          */
/*                                                                          */
/*  NOTES                                                                   */
/*                                                                          */
/*      x should be padded with 4 words at the end.                         */
/*                                                                          */
/*      Since the twiddle table is in bit-reversed order, it turns out      */
/*      that the same twiddle table will also work for smaller IFFTs.This   */
/*      means that if you need to do both 512 and 1024 point IFFTs in the   */
/*      same application, you only need to have the 1024 point twiddle      */
/*      table.  The 512 point FFT will use the first half of the 1024       */
/*      point twiddle table.                                                */
/*                                                                          */
/*                                                                          */
/*  CYCLES                                                                  */
/*                                                                          */
/*       2*n*log2(n) + 37                                                   */
/*       eg. IF n = 64, cycles = 805                                        */
/*       eg. IF n = 128, cycles = 1829                                      */
/*                                                                          */
/*                                                                          */
/*  CODESIZE                                                                */
/*                                                                          */
/*       1600 bytes                                                         */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2003 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSPF_SP_ICFFTR2_DIF_H_
#define DSPF_SP_ICFFTR2_DIF_H_ 1

void DSPF_sp_icfftr2_dif(
                    float* x,
                    float* w,
                    short n
                   );

#endif
/* ======================================================================== */
/*  End of file:  DSPF_sp_icfftr2_dif.h                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2003 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
