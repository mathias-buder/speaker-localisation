/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  NAME                                                                    */
/*      DSPF_blk_eswap32 -- C67x Endian-swap of a block of 32-bit values         */
/*                                                                          */
/* USAGE                                                                    */
/*       This routine has the following C prototype:                        */
/*                                                                          */
/*       void DSPF_blk_eswap32                                                   */
/*                     (                                                    */
/*                         float * restrict x,                              */
/*                         float * restrict r,                              */
/*                         int             nx,                              */
/*                     )                                                    */
/*                                                                          */
/*       x[nx]:   Pointer to source data.                                   */
/*       r[nx]:   Pointer to destination array.                             */
/*       nx:      Number of words (32-bit values) to endian-swap.           */
/*                                                                          */
/*                                                                          */
/* DESCRIPTION                                                              */
/*      The date in the x array is endian swapped, meaning that the         */
/*      byte-order of the bytest within wach word of x is                   */
/*      reversed in the array r. This routine is used to facilitate moving  */
/*      big-endian data to a little-endian system or vice-versa.            */
/*                                                                          */
/*      When the r pointer is non-NULL, the endian-swap occurs              */
/*      out-of-place, similar to a block move. When the r pointer is NULL,  */
/*      the endian-swap occurs in-place, allowing the swap to occure        */
/*      without using any additional memory.                                */
/*                                                                          */
/*                                                                          */
/* TECHNIQUES                                                               */
/*                                                                          */
/*                                                                          */
/* ASSUMPTIONS                                                              */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2003 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSPF_BLK_ESWAP32_ASM_H_
#define DSPF_BLK_ESWAP32_ASM_H_ 1

void DSPF_blk_eswap32(float     * restrict x, float * restrict r, int nx);

#endif
/* ======================================================================== */
/*  End of file: DSPF_blk_eswap32_h.asm                                          */
/* ------------------------------------------------------------------------ */
/*          Copyright (C) 2003 Texas Instruments, Incorporated.             */
/*                          All Rights Reserved.                            */
/* ======================================================================== */
