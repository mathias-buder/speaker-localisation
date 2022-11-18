/*
 * set_edma.h: all functions/interrupts for EDMA-handling
 * @author Jens Reermann
 * @version 1.0
 * @date 30.06.2013
 *
 * @based on:
 * PCM3003 Demo Program (8 channels, EDMA ping-pong buffer processing)
 * author    A.Klemenz
 * company   D.SignT
 * revision  1.1
 * date      2008-11-06
 * hardware  D.Module.6713
 * compiler  TI CCS 3.3
 * history   1.0 intial release 2005-02-17 by AK
 *           1.1 changed buffer signalling to allow buffer display in CCS
 *               2008-11-06 by AK
 *           1.2 adapted for D.Module.6713+PCM3003 with EDMA
 *               2009-11-03 by US
 */

#ifndef SET_EDMA_H_
#define SET_EDMA_H_

#include "global_defines.h"

/**
 *   set_edma: set all EDMA-parameters
 *
 *   all EDMA-paremters are set
 */
void set_edma();


#endif /* SET_EDMA_H_ */
