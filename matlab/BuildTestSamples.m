% BuildTestSamples.m
% 
%   This file builds a C-header-file based on synthetic or redorded
%   signal. The header file contains an array of size Channels x Length
%
% 
%   Datum: 02.06.2013
%   Autor: Mathias Buder

%*************************************************************************
% Parameter
%*************************************************************************
close all;
clear all;

% Path = GetPathToFolder('Masterarbeit');

PathToSynthFiles = [pwd filesep 'Functions' filesep 'GenerateSyntehticSignal' filesep 'SyntheticFiles'];
PathToRealFiles = [pwd filesep 'TI_DSP' filesep 'Recorded'];

ListOfSynthFiles = dir([PathToSynthFiles filesep '*.mat']);
ListOfRealFiles = dir([PathToRealFiles filesep '*.mat']);

NumOfSynthFiles = length(ListOfSynthFiles);
NumOfRealFiles = length(ListOfRealFiles);

% set view angles for figures
View = [45 34;
        0  0; 
        0 90];


fprintf('Available simulation files:\n');
fprintf('(0) Synthetic: %i\n', NumOfSynthFiles);
fprintf('(1) Real: %i\n', NumOfRealFiles);


SimFileType = inputs('Please select file type !', 0);

%% Simulation properties
if(SimFileType)
    ListOfSelectedFiles = ListOfRealFiles;
    fprintf('Please select one of the %i available simulation file(s):\n', NumOfRealFiles);
    for Count = 1:NumOfRealFiles
        fprintf('[%i] %s\n', Count, ListOfRealFiles(Count).name);
    end
else
    ListOfSelectedFiles = ListOfSynthFiles;
    fprintf('Please select one of the %i available simulation file(s):\n', NumOfSynthFiles);
    for Count = 1:NumOfSynthFiles
        fprintf('[%i] %s\n', Count, ListOfSynthFiles(Count).name);
    end
end

% Reset simulation flag
SelSimFileFlag = 0;

while(1)
    % Select simulation file
    SimFile = inputs('Select simulation file:', 1);
    if(SimFile <= length(ListOfSelectedFiles) && SimFile ~= 0 )
        
        FileName = ListOfSelectedFiles(SimFile).name;
        fprintf('Loading file %s ...\n', FileName)
        load(FileName);
        
        % Preview data
        h1 = figure( 100 );
        PlotDate2(Room, Array, Source, 0, AudioField, View, 'all');
        
        % Set window position
        SetWindowPos( 400 );
        
        h2 = figure(101);
        subplot(4,1,1);
        plot(1:length(y_t(1,:)) ,y_t(1,:), 1:length(y_t(2,:)) , y_t(2,:)),grid;
        subplot(4,1,2);
        plot(1:length(y_t(3,:)) ,y_t(3,:), 1:length(y_t(4,:)) , y_t(4,:)),grid;
        subplot(4,1,3);
        plot(1:length(y_t(5,:)) ,y_t(5,:), 1:length(y_t(6,:)) , y_t(6,:)),grid;
        subplot(4,1,4);
        plot(1:length(y_t(7,:)) ,y_t(7,:), 1:length(y_t(8,:)) , y_t(8,:)),grid;
        
        % Check selected file
        SelSimFileFlag = inputs('Start simulation with selected file? (0):No (1):Yes', 1);
        if(SelSimFileFlag)
            break;
        end

        %Close window
        close(h1);
        close(h2);
    else
        fprintf('Filenumber %i is not specified!\n', SimFile);
    end

    
end

N_Start = inputs('Please enter sample starting point:', 1);
N_Samples = inputs('Please enter length:', length(y_t));
N_Stop = N_Start+N_Samples-1;


%if( mod(N_Samples ,2) ~=0 )
%    error('Length %i is not a factor of 2.', N_Samples);
%end

% Cut of desired region and store in new buffer
y_t_cut = y_t(:,N_Start:N_Stop);


% for i=1:8
%     y_t_cut(i,:) = y_t_cut(i,:)/min(y_t_cut(i,:));
% end


%Phi = inputs('Phi?', 0);
%Theta = inputs('Theta?', 0);

%H_FileName = sprintf('Phi_%0.1f_Theta_%0.1f_N_%i', Phi, Theta, N_Samples);

% Create header file in specified direction
GenerateSimFile( y_t_cut, ...
                 'H-Files', ...
                 N_Samples, ...
                 Array.NumOfMics,...
                 FileName,...
                 FileName,...
                 N_Start,...
                 N_Stop,...
                 fa);






