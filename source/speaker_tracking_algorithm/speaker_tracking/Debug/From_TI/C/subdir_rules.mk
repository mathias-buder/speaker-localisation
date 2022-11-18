################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Each subdirectory must supply rules for building sources it contributes
From_TI/C/CFFT_bitreversal.obj: ../From_TI/C/CFFT_bitreversal.c $(GEN_OPTS) $(GEN_SRCS)
	@echo 'Building file: $<'
	@echo 'Invoking: C6000 Compiler'
	"C:/ti/ccsv5/tools/compiler/c6000/bin/cl6x" -mv-mv6710 -g -O3 -ms3 --define=CHIP_6713 --include_path="C:/ti/ccsv5/tools/compiler/c6000/include" --display_error_number --diag_warning=225 --mem_model:data=far --abi=coffabi --preproc_with_compile --preproc_dependency="From_TI/C/CFFT_bitreversal.pp" --obj_directory="From_TI/C" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '

From_TI/C/CFFT_digitrev_index.obj: ../From_TI/C/CFFT_digitrev_index.c $(GEN_OPTS) $(GEN_SRCS)
	@echo 'Building file: $<'
	@echo 'Invoking: C6000 Compiler'
	"C:/ti/ccsv5/tools/compiler/c6000/bin/cl6x" -mv-mv6710 -g -O3 -ms3 --define=CHIP_6713 --include_path="C:/ti/ccsv5/tools/compiler/c6000/include" --display_error_number --diag_warning=225 --mem_model:data=far --abi=coffabi --preproc_with_compile --preproc_dependency="From_TI/C/CFFT_digitrev_index.pp" --obj_directory="From_TI/C" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '

From_TI/C/CFFT_fromTI.obj: ../From_TI/C/CFFT_fromTI.c $(GEN_OPTS) $(GEN_SRCS)
	@echo 'Building file: $<'
	@echo 'Invoking: C6000 Compiler'
	"C:/ti/ccsv5/tools/compiler/c6000/bin/cl6x" -mv-mv6710 -g -O3 -ms3 --define=CHIP_6713 --include_path="C:/ti/ccsv5/tools/compiler/c6000/include" --display_error_number --diag_warning=225 --mem_model:data=far --abi=coffabi --preproc_with_compile --preproc_dependency="From_TI/C/CFFT_fromTI.pp" --obj_directory="From_TI/C" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '


