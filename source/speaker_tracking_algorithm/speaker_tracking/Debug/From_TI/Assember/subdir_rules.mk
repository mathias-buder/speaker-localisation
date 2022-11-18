################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Each subdirectory must supply rules for building sources it contributes
From_TI/Assember/bitrev.obj: ../From_TI/Assember/bitrev.sa $(GEN_OPTS) $(GEN_SRCS)
	@echo 'Building file: $<'
	@echo 'Invoking: C6000 Compiler'
	"C:/ti/ccsv5/tools/compiler/c6000/bin/cl6x" -mv6713 -g -O3 -ms3 --define=CHIP_6713 --include_path="C:/Documents and Settings/test/My Documents/Dropbox/02_Master_IuK/Masterarbeit/C-Code/CCSv5/3D_Speaker_Tracking_C_ONLY/From_TI" --include_path="C:/ti/ccsv5/tools/compiler/c6000/include" --display_error_number --diag_warning=225 --mem_model:data=far --abi=coffabi --preproc_with_compile --preproc_dependency="From_TI/Assember/bitrev.pp" --obj_directory="From_TI/Assember" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '

From_TI/Assember/cfftr2_dit.obj: ../From_TI/Assember/cfftr2_dit.sa $(GEN_OPTS) $(GEN_SRCS)
	@echo 'Building file: $<'
	@echo 'Invoking: C6000 Compiler'
	"C:/ti/ccsv5/tools/compiler/c6000/bin/cl6x" -mv6713 -g -O3 -ms3 --define=CHIP_6713 --include_path="C:/Documents and Settings/test/My Documents/Dropbox/02_Master_IuK/Masterarbeit/C-Code/CCSv5/3D_Speaker_Tracking_C_ONLY/From_TI" --include_path="C:/ti/ccsv5/tools/compiler/c6000/include" --display_error_number --diag_warning=225 --mem_model:data=far --abi=coffabi --preproc_with_compile --preproc_dependency="From_TI/Assember/cfftr2_dit.pp" --obj_directory="From_TI/Assember" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '


