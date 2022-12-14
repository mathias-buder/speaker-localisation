/* ======================================================================= */
/* TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                         */
/* NAME                                                                    */
/*     DSPF_dp_mat_trans -- Double Precision matrix transpose                   */
/*                                                                         */
/* USAGE                                                                    */
/*                                                                          */
/*       This routine has the following C prototype:                        */
/*                                                                          */
/*       void DSPF_dp_mat_trans(const double *restrict x,                        */
/*                         int rows,                                        */
/*                         int cols,                                        */
/*                         double *restrict r                               */
/*                         )                                                */
/*                                                                          */
/*          x       :  Input matrix containing rows*cols Double Precision   */
/*                     floating point numbers.                              */
/*          rows    :  No. of rows in matrix x.                             */
/*                     Also no. of columns in matrix r                      */
/*          cols    :  No. of columns in matrix x.                          */
/*                     Also no. of rows in matrix r.                        */
/*          r       :  Output matrix containing cols*rows Double Precision  */
/*                     floating point numbers.                              */
/*                                                                          */
/* DESCRIPTION                                                              */
/*                                                                          */
/*    This function transposes the input matrix x[] and writes the          */
/*    result to matrix r[].                                                 */
/*                                                                          */
/* ASSUMPTIONS                                                              */
/*                                                                          */
/*    1. The number of rows and columns is > 0.                             */
/*                                                                          */
/* C CODE                                                                   */
/*                                                                          */
/*       This is the C equivalent of the assembly code.  Note that          */
/*       the assembly code is hand optimized and restrictions may apply.    */
/*                                                                          */
/*       void DSPF_dp_mat_trans(const double *restrict x, int rows,              */
/*       int cols, double *restrict r)                                      */
/*       {                                                                  */
/*          int i,j;                                                        */
/*                                                                          */
/*          for(i=0; i<cols; i++)                                           */
/*             for(j=0; j<rows; j++)                                        */
/*                r[i * rows + j] = x[i + cols * j];                        */
/*       }                                                                  */
/*                                                                          */
/* NOTES                                                                    */
/*                                                                          */
/*    1. Endian: This code is LITTLE ENDIAN.                                */
/*    2. Interruptibility: This code is interrupt-tolerant but not          */
/*       interruptible.                                                     */
/*                                                                          */
/* CYCLES                                                                   */
/*                                                                          */
/*      2 * rows * cols + 15                                                */
/*      For rows=10 and cols=20, cycles=415                                 */
/*      For rows=15 and cols=20, cycles=615                                 */
/*                                                                          */
/* CODESIZE                                                                 */
/*                                                                          */
/*      256  bytes                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2004 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSPF_DP_MAT_TRANS_H_
#define DSPF_DP_MAT_TRANS_H_ 1

void DSPF_dp_mat_trans(const     double *restrict x,
                  int rows,
                  int cols,
                  double *restrict r
                  );

#endif
/* ======================================================================== */
/*  End of file:  DSPF_dp_mat_trans.h                                            */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2004 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
