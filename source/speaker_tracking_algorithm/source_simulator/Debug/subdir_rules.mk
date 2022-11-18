################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Each subdirectory must supply rules for building sources it contributes
main.obj: ../main.c $(GEN_OPTS) $(GEN_SRCS)
	@echo 'Building file: $<'
	@echo 'Invoking: C6000 Compiler'
	"C:/CCStudio_v5/ccsv5/tools/compiler/c6000/bin/cl6x" -mv6700 -g -O3 --include_path="C:/CCStudio_v5/ccsv5/tools/compiler/c6000/include" --include_path="D:/Reermann/10_Semester_SS13/TI_DSP_Software/Source_Simulator/Source_Simulator/include" --display_error_number --diag_warning=225 --abi=coffabi --preproc_with_compile --preproc_dependency="main.pp" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '

set_edma.obj: ../set_edma.c $(GEN_OPTS) $(GEN_SRCS)
	@echo 'Building file: $<'
	@echo 'Invoking: C6000 Compiler'
	"C:/CCStudio_v5/ccsv5/tools/compiler/c6000/bin/cl6x" -mv6700 -g -O3 --include_path="C:/CCStudio_v5/ccsv5/tools/compiler/c6000/include" --include_path="D:/Reermann/10_Semester_SS13/TI_DSP_Software/Source_Simulator/Source_Simulator/include" --display_error_number --diag_warning=225 --abi=coffabi --preproc_with_compile --preproc_dependency="set_edma.pp" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '


