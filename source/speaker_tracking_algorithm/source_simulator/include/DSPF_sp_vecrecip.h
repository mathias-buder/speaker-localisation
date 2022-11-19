/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  NAME                                                                    */
/*      DSPF_sp_vecrecip -- Single Precision vector reciprocal                   */
/*                                                                          */
/*  USAGE                                                                   */
/*                                                                          */
/*      This routine is C callable, and has the following C prototype:      */
/*                                                                          */
/*      float DSPF_sp_vecrecip(const float *x,                                   */
/*                        float * restrict r,                               */
/*                        int n                                             */
/*                       )                                                  */
/*                                                                          */
/*             x        :  Pointer to input array                           */
/*             r        :  Pointer to output array                          */
/*             n        :  Number of elements in array                      */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*                                                                          */
/*      The DSPF_sp_vecrecip module calculates the reciprocal of each element in */
/*      array x and returns the output in array r. It uses 2 iterations     */
/*      of the Newton-Raphson method to improve the accuracy of the output  */
/*      generated by the RCPSP instruction of the C67x. Each iteration      */
/*      doubles the accuracy. The initial output generated by RCPSP is 8 bi */
/*      So after the first iteration it is 16 bits and after the second it  */
/*      the full 23 bits. The formula used is:                              */
/*                                                                          */
/*               r[n+1] = r[n](2 - v*r[n])                                  */
/*                                                                          */
/*      where v = the number whose reciprocal is to be found.               */
/*      x[0], the seed value for the algorithm, is given by RCPSP.          */
/*                                                                          */
/*   TECHNIQUES                                                             */
/*                                                                          */
/*      1. The inner loop is unrolled four times to allow calculation of    */
/*         four reciprocals in the kernel.                                  */
/*                                                                          */
/*   ASSUMPTIONS                                                            */
/*                                                                          */
/*                                                                          */
/*    C CODE                                                                */
/*      This is the C equivalent of the Assembly Code without               */
/*      restrictions.                                                       */
/*                                                                          */
/*  void DSPF_sp_vecrecip(const    float* x, float* restrict r, int n)           */
/*      {                                                                   */
/*          int i;                                                          */
/*          for(i = 0; i < n; i++)                                          */
/*              r[i] = 1 / x[i];                                            */
/*      }                                                                   */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2002 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSPF_SP_VECRECIP_ASM_H_
#define DSPF_SP_VECRECIP_ASM_H_ 1

void DSPF_sp_vecrecip(const     float * x, float * restrict r, int n);

#endif
/* ======================================================================== */
/*  End of file: DSPF_sp_vecrecip_h.asm                                          */
/* ------------------------------------------------------------------------ */
/*          Copyright (C) 2002 Texas Instruments, Incorporated.             */
/*                          All Rights Reserved.                            */
/* ======================================================================== */