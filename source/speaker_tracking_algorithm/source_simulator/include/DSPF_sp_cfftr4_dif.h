/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  NAME                                                                    */
/*      DSPF_sp_cfftr4_dif -- DSPF_sp_cfftr4_dif                                      */
/*                                                                          */
/*  �USAGE�                                                                 */
/*                                                                          */
/*  This routine is C Callable and can be called as:                        */
/*  ��                                                                      */
/*  ��void cfftr4_dif(float* x, float* w, short n)                          */
/*                                                                          */
/*  ��x is pointer to an array holding the input and output floating        */
/*  ��   point array which contains 'n' complex points                      */
/*  ��w is pointer to an array holding the coefficient floating point       */
/*  ��   array which contains 3*n/4 complex numbers                         */
/*  ��n is the number of complex points in x                                */
/*                                                                          */
/*  ��If the routine is not to be used as a C callable function,            */
/*  ��then you need to initialize values for all of the parameters          */
/*  ��passed to the function since these are assumed to be in               */
/*  ��registers as defined by the calling convention of the                 */
/*  ��compiler, (refer to the TMS320C6x Optimizing C Compiler               */
/*  ��User's Guide).                                                        */
/*                                                                          */
/*                                                                          */
/*  �DESCRIPTION                                                            */
/*                                                                          */
/*  ��This routine implements the DIF (decimation in frequency)             */
/*  ��complex radix 4 FFT with digit-reversed output and normal             */
/*  ��order input.  The number of points, 'n', must be a power              */
/*  ��of 4 {4, 16, 64, 256, 1024, ...}.  This routine is an                 */
/*  ��in-place routine in the sense that the output is written              */
/*  ��over the input.  It is not an in-place routine in the                 */
/*  ��sense that the input is in normal order and the output is             */
/*  ��in digit-reversed order.                                              */
/*                                                                          */
/*  ��There must be n complex points (2*n values), and 3*n/4 complex        */
/*  ��coefficients (3*n/2 values).                                          */
/*                                                                          */
/*  ��Each real and imaginary input value is interleaved in the             */
/*  ��'x' array {rx0, ix0, rx1, ix2, ...} and the complex numbers           */
/*  ��are in normal order.  Each real and imaginary output value            */
/*  ��is interleaved in the 'x' array and the complex numbers are           */
/*  ��in digit-reversed  order {rx0, ix0, ...}.  The real and               */
/*  ��imaginary values of the coefficients are interleaved in the           */
/*  ��'w' array {rw0, -iw0, rw1, -iw1, ...} and the complex numbers         */
/*  ��are in normal order.                                                  */
/*                                                                          */
/*  ��Note that the imaginary coefficients are negated                      */
/*  ��{cos(d*0),  sin(d*0),  cos(d*1),   sin(d*1), ...} rather than         */
/*  ��{cos(d*0), -sin(d*0),  cos(d*1),  -sin(d*1), ...}                     */
/*  ��where d = 2*PI/n.  The value of w(n,k) is usually written             */
/*  ��w(n,k) = e^-j(2*PI*k/n) = cos(2*PI*k/n) - sin(2*PI*k/n).              */
/*                                                                          */
/*  ��The routine can be used to implement an inverse FFT by                */
/*  ��performing the complex conjugate on the input complex numbers         */
/*  ��(negating the imaginary value), and dividing the result by n.         */
/*  ��Another method to use the FFT to perform an inverse FFT, is to        */
/*  ��swap the real and imaginary values of the input and the result,       */
/*  ��and divide the result by n.  In either case, the input is still       */
/*  ��in normal order and the output is still in digit-reversed order.      */
/*                                                                          */
/*  ��Note that you can not make the radix 4 FFT into an inverse            */
/*  ��FFT by using the complex conjugate of the coefficients as             */
/*  ��you can do with the complex radix 2 FFT.                              */
/*                                                                          */
/*  ��If you label the input locations from 0 to (n-1) (normal order),      */
/*  ��the digit-reversed locations can be calculated by reversing the       */
/*  ��order of the bit pairs of the labels.  For example, for a 1024        */
/*  ��point FFT, the digit reversed location for                            */
/*  ��617d = 1001101001b = 10 01 10 10 01  is                               */
/*  ��422d = 0110100110b = 01 10 10 01 10  and visa versa.                  */
/*                                                                          */
/*  ��TI plans to provide an inverse complex radix 4 FFT with digit-        */
/*  ��reversed input and normal order output.  With these 2 routines,       */
/*  ��the digit-reversed output of the FFT can be the input to the          */
/*  ��inverse FFT without performing digit-reversing on the data.           */
/*                                                                          */
/*  ��TI also plans to provide a complex digit reverse routine.             */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSPF_SP_CFFTR4_DIF_ASM_H_
#define DSPF_SP_CFFTR4_DIF_ASM_H_ 1

void DSPF_sp_cfftr4_dif(float     * x, float * w, short n);

#endif
/* ======================================================================== */
/*  End of file: DSPF_sp_cfftr4_dif_h.asm                                        */
/* ------------------------------------------------------------------------ */
/*          Copyright (C) 2002 Texas Instruments, Incorporated.             */
/*                          All Rights Reserved.                            */
/* ======================================================================== */
