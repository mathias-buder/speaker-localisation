/***********************************************************************

  pcm3003.cmd - D.Module.C671x Linker Command File

  Revision  1.0
  Company   D.SignT
  Author    Adolf Klemenz
  Created   2005-02-17

  Hardware  D.Module.C6713
  Compiler
  Options

  History   1.0 initial release  2005-02-17

***********************************************************************/

/*----------------------------------------------------------------------
   DSK6713 command file                                                 
  ----------------------------------------------------------------------*/
/* these two steps must be done for each project manually*/
/* set in "Compiler -> Basic -> target version C671x" -mv6710 */
/* set in "Compiler -> Preprocessor -> define symbols -d" _debug;CHIP_6713 */

/* these two steps must be done for each project, using CCS 3.1 or 3.3*/
/* set in "Compiler -> Preprocessor -> include search path -i" $(Install_dir)\C6000\dsk6713\include */
/* (CCS 3.1:) set in "Linker -> library search path -i" $(Install_dir)\C6000\dsk6713\lib */
/* (CCS 3.3:) set in "Linker -> Libraries -> Search Path -i" $(Install_dir)\C6000\dsk6713\lib */

/* for AIC23-project:*/
/* set in "Compiler -> Advanced -> Memory Models" Far (--mem_model:data=far) 

/***********************************************************************
  Code Composer: remove the following entries and use the Code Composer
  Project Options Dialog instead
***********************************************************************/
/*dmod-c6713_dmod-pcm_test.obj*/  /* never use c++ comments '//' in cmd-file! */
-c
-x
-w

-stack 0x400
-heap 0x1000

/*-o debug/dmod_c6713_dmod_pcm_test_EDMA.out*/  /* no '-' allowed in the path */
/*-m debug/dmod_c6713_dmod_pcm_test_EDMA.map*/

-l rts6700.lib

/***********************************************************************
  MEMORY defines the available physical memory areas
***********************************************************************/
MEMORY
{
    VECT    : org = 0x00000000, len = 0x00000200

    /*
       the following memory areas are reserved for the BIOS functions
       BIOSTEXT: org = 0x00000200, len = 0x00000F00
       BIOSDATA: org = 0x00001100, len = 0x00000100
    */

    /*
       the following memory areas are reserved for the CONFIG
       utility functions
       CFGTEXT : org = 0x00001200, len = 0x00001F00
       CFGDATA : org = 0x00003100, len = 0x00000400

       use this IRAM mapping if you want to use the Config Utility
       functions in your program

    IRAM    : org = 0x00003500, len = 0x0002CB00

       use this IRAM mapping if you do NOT use the Config Utility
       functions in your program
    */
    IRAM    : org = 0x00001200, len = 0x0002EE00


/* US 10-Jun-10, SBSRAM geht nur bis 0x80000 siehe http://www.dsignt.de/save/dmodule/ugd6713.pdf */
/* dsignT*/

	SBSRAM  : org = 0x80000000, len = 0x00080000

    SDRAM   : org = 0xB0000000, len = 0x01000000
}

/***********************************************************************
  SECTIONS defines the mapping of compiler sections to physical memory
***********************************************************************/
SECTIONS
{
    .vect     > VECT        /* only required if you link your own IVT */
    .text     > IRAM
    .stack    > IRAM
    .data     > IRAM        /* .data is not used by the C compile     */
    .far      > IRAM
    .bss      > IRAM
    .const    > IRAM
    .switch   > IRAM
    .sysmem   > IRAM /*SBSRAM*/
    .cio      > IRAM /*SBSRAM*/
    .sbsram   > SBSRAM /*SBSRAM*/
    .sdram    > SDRAM /* 10-Jun-10 IRAM */ /*SBSRAM*/

    /*******************************************************************
      DO NOT CHANGE THE FOLLOWING LINES NOR ADD SECTIONS BELOW THESE
      LINES IF SDTIO FUNCTIONS FROM THE RUNTIME LIBRARY ARE USED

      it is however allowed to change the destination memory area for
      all four sections simultaneously, e.g. to SDRAM

      Depending on your program, .const or .switch sections may not be
      used by the run-time lib. The linker will generate a warning
      if one of these sections is not used - ignore this warning.
    *******************************************************************/
    .cinit                              > IRAM /*SBSRAM*/
    .rtstext { -lrts6700.lib(.text)   } > IRAM /*SBSRAM*/
    .rtsbss  { -lrts6700.lib(.bss)
               -lrts6700.lib(.far)    } > IRAM /*SBSRAM*/
    .rtsdata { -lrts6700.lib(.const)
               -lrts6700.lib(.switch) } > IRAM /*SBSRAM*/
}



