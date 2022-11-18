//
//  setup.h
//  3D_Speaker_Tracking
//
//  Created by Mathias Buder on 29.05.13.
//  Copyright (c) 2013 Mathias Buder. All rights reserved.

#ifndef _D_Speaker_Tracking_setup_h
#define _D_Speaker_Tracking_setup_h

//-------------------------------------------------------------------------------------------------------------
// Select operation mode [MULTIPLE OPTIONS ALLOWED]
//-------------------------------------------------------------------------------------------------------------
//#define C_MODE_ON							// defined: 	Program runs in C-Mode, all hardware settings
											//				will be disabled. Additional one of the simulation
											//				h-files provided in "main.c" has to be included!

										    // undefined:	Program runs in DSP-Mode, all hardware settings
											//				will be set, ADC-Buffer is used to collect values.

#define PROFILE_MODE_ON						// Profile function using General Purpose In/Out pins (GPIO) 	(DO NOT ENABLE IN C_MODE !!!)
#define ADC_LOOP_THROUGH_MODE_ON			// Loop through ADC to DAC
#define UART_MODE_ON						// Send angle values over UART interface 						(DO NOT ENABLE IN C_MODE !!!)
#define HISTOGRAM_MODE_ON					// Use histogram-smoothing and reduce angle distribution
#define SEARCH_OPT_MODE_ON					// Activate spatial search speed optimization (if disabled, no real-time)

#endif
