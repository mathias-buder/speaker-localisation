function GenerateSimFile( Data,...
                          H_File_Folder,...
                          N_Samples,... 
                          N_Channels,...
                          H_FileName,...
                          S_FileName,...
                          N_Start,...
                          N_Stop,...
                          fa )
% GenerateSimFile creates a C compatible H-file to be used to run the DSP
% program in simulation mode.
%
%   Interface:  GenerateSimFile( Data,...
%                                H_File_Folder,...
%                                N_Samples,... 
%                                N_Channels,...
%                                H_FileName,...
%                                S_FileName,...
%                                N_Start,...
%                                N_Stop,...
%                                fa )

   
Data = Data * (2^15);
H_FileName = [pwd filesep H_File_Folder filesep H_FileName '.h'];

fprintf('Chacking channel values ... ');                        
for ch = 1:N_Channels                                       
    % Check if values bigger the (1) / smaler ten (-1)
    if( max(Data(ch,:)) > (2^15) ) 
        error('No file could be generated because the maximum value of Channel %i is > 32768', ch);
    end
    
    if( min(Data(ch,:)) < (-2^15) ) 
        error('No file could be generated because the minimum value of Channel %i is < -32768', ch);
    end
end
fprintf('ok!\n');

% Generate include-file
fprintf('Creating H-File %s\n', H_FileName);
filname = fopen(H_FileName, 'w');      
fprintf(filname,'/******************************************************\n');
fprintf(filname,'        Header File to run simulation on DSP\n');
fprintf(filname,'*******************************************************/');
fprintf(filname, '\n');
fprintf(filname,'// Simulation file: ');
fprintf(filname,S_FileName);
fprintf(filname, '\n');
fprintf(filname,'// Created: ');
fprintf(filname, datestr(clock));
fprintf(filname, '\n\n');
fprintf(filname,'// Start  : %d [Sample]\n', N_Start);
fprintf(filname,'// Stop   : %d [Sample]\n', N_Stop);
fprintf(filname,'// Length : %d [Sample]\n', N_Samples);
fprintf(filname, '\n\n');
fprintf(filname,'#define SIM_SAMFREQ       (%d) //Hz\n', fa);
fprintf(filname,'#define N_SIM_CHANNELS    (%d)\n', N_Channels);
fprintf(filname,'#define N_SIM_SAMPLES     (%d)\n', N_Samples);
fprintf(filname,'#pragma DATA_SECTION( int16_Sim_File, ".sdram" )\n');
fprintf(filname,'short int16_Sim_File[N_SIM_CHANNELS][N_SIM_SAMPLES]={\n');
fprintf('H-File %s created!\n', H_FileName);

% ************************************************************************
% Write samples to file
% ************************************************************************
fprintf('Writing channel values ...\n');

for k=1:N_Channels
    fprintf('CH%i ...\n', k);
    fprintf(filname, '/*CH%i*/ {', k);
    
    for i=1:N_Samples;
       fprintf( filname,' %6.0f,', Data(k,i) );
    end
    
    if(k<N_Channels)
        fprintf(filname, '},\n');
    else
        fprintf(filname, '}\n');
    end
end

fprintf(filname,'};\n');
fprintf(filname, '\n');
fprintf('Writing finished!\n');
fclose(filname);
fprintf('File %s closed!\n', H_FileName);
fprintf('Done!\n');
