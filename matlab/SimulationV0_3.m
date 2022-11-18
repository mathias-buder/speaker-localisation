%% Siumulation v0.3
%   - no search optimisation
%
%
%
%
%
%    c          :  propagation vilosity [m/s]
%    A          :  Microphone distance matrix 3xN [m]
%    N          :  Number of Microphones
%    theta      :  Azimuth angle [°]
%    phi        :  Elavation angle [°]
%    y_t        :  Signalvektor (row vector)
%    SNR        :  Signal-to-Noise-Ratio [dB]
%    fa         :  Samplig frequancy [Hz]
%
%
%    Author     :  Mathias Buder
%    Date       :  30.01.2013


%% Clear all
close all;
clear all;
clc;


%% PROPERTIES

Path = GetPathToFolder('Masterarbeit');
PathToSynthFiles = [Path 'Matlab' filesep 'Functions' filesep 'GenerateSyntehticSignal' filesep 'SyntheticFiles'];
ListOfSynthFiles = dir([PathToSynthFiles filesep '*.mat']);
% set view angles for figures
View = [45 34;
        0  0; 
        0 90];

% Envirement
c = 343;                % velocity of sound [m/s]


% Simulatuon
DispSimIndex = 100;     % Display every 100's simiulation index

%% Simulation properties

disp('Available simulation file´s:');
for Count = 1:length(ListOfSynthFiles)
    fprintf('[%i] %s\n', Count, ListOfSynthFiles(Count).name);
end

% Reset simulation flag
SelSimFileFlag = 0;

while(1)
    % Select simulation file
    SimFile = inputs('Select simulation file:', 1);
    if(SimFile <= length(ListOfSynthFiles) && SimFile ~= 0 )
        FileName = ListOfSynthFiles(SimFile).name;
        fprintf('Loading file %s ...\n', FileName)
        load(FileName);
        
        % Preview data
        h1 = figure(200);
        PlotDate2(Room, Array, Source, 0, AudioField, View, 'all');

        % Set window position
        SetWindowPos( 400 );

        % Check selected file
        SelSimFileFlag = inputs('Start simulation with selected file? (0):No (1):Yes', 1);
        if(SelSimFileFlag)
            break;
        end

        %Close window
        close(gcf); 
    else
        fprintf('Filenumber %i is not specified!\n', SimFile);
    end

    
end


EDMA.N = 256;
N_FFT  = 512;         % Länge der FFT für Korrelation (Energielimit anpassen)
N_BUF  = N_FFT/2;     % Bufferlänge in Samples


INDEX_INVALID = -1;
ANGLE_INVALID = 0;
ENERGIELIMIT = 0.2;


% Laenge von N_EDMA = NBUF ist gleich, 

EDMA.NumOfCalcs = floor(EDMA.N/N_BUF);                  % Number of calculations per EDMA-Frame
EDMA.NumOfFullBuffer = floor(length(y_t(1,:))/EDMA.N); % Number of full buffer according to simulation signal length


EDMA.NumOFSim = inputs('Enter number of simulations?', EDMA.NumOfFullBuffer);


%% structure to handle values according to Theta and Phi
% Theta
Theta.Res = Array.AngleRes;
Theta.Min = 0;                % Steering range
Theta.Max = 359;              % Steering range
Theta.LUT = Theta.Min:Theta.Res:Theta.Max; % Angel LUT for theta


% Phi
Phi.Res = Array.AngleRes;
Phi.Min = -90;
Phi.Max = 90;
Phi.Half = 0:Phi.Res:Phi.Max;
Phi.LUT = [(-1) * Phi.Half(length(0:Phi.Res:Phi.Max):-1:2) 0:Phi.Res:Phi.Max]; % Angel LUT for phi


% Microphone Array [m]
Array.Radius = 50*10^-3;
Array.Holeradius = 5*10^-3;
Array.hight = 1.5;
Array.x = Room.width/2;
Array.y = Room.length/2;
Array.z = Array.hight;
Array.MicAngle = rad2deg( acos(sqrt(2/3)) );



% Microphone matrix D [°] according to spharical Array
% D is of size 2xN and represents the microphone position according to
% azimuth and elevation angle.
%    m1       m2       m3       m4        m5       m6        m7        m8
 Array.MicPos = [Array.MicAngle  Array.MicAngle  Array.MicAngle  Array.MicAngle  -Array.MicAngle  -Array.MicAngle  -Array.MicAngle  -Array.MicAngle  ;  % phi
                 -45             45              135             225             -45               45               35               225            ];  % theta
 
 % Number of Microphones
 Array.NumOfMics = length( Array.MicPos );           
 
 

% Microphone matrix D [°] according to cyrcular Array
% D is of size 2xN and represents the microphone position according to
% azimuth and elevation angle.
%{
D = [0  0  0  0   0   0   0   0  ;  % phi
     0  45 90 135 180 225 270 315  ];  % theta
%}  
 
      
% Distance matrix A [m]
% A is of size 3x((N-1)*N/2) and represents the distance bewteen each pair of 
% microphones.
Array.MicDistance = calcMicMatrix ( Array.MicPos, Array.Radius, Array.Holeradius, Array.NumOfMics );

% minimum distance between microphones
Array.MinDistance = sqrt(sum(Array.MicDistance(:,1).^2));
Array.AngleRes = round( rad2deg( asin(c/(Array.MinDistance*fa)) ) );




%{
% Spartial Aliasing for circular Array
R = sqrt(sum(MicDistance(:,1).^2))/2;   % Radius circular array
f_max = c/(4*r*sin(pi/3));  % calc f_max
%}
Buf.Phi_Est = zeros(1, EDMA.NumOFSim);
Buf.Theta_Est = zeros(1, EDMA.NumOFSim);
EDMA.y_t_var = zeros(1, EDMA.NumOFSim*EDMA.NumOfCalcs);

disp('Simulation started ...');
%% Start ISR
for countEDMA = 1:EDMA.NumOFSim
    EDMA.y_t = y_t(:,(countEDMA-1)*(EDMA.N)+1:(countEDMA)*EDMA.N);
    
    for countCalcs = 1:EDMA.NumOfCalcs % zunächst 1
        
        if(~mod(countEDMA ,DispSimIndex))  
            fprintf('EDMA Frame %i of %i ...\n', countEDMA, EDMA.NumOFSim);    
        end
     
     % Ausschneiden eines Stückes für die Berechnung auf dem EDMA
     EDMA.y_t_cut = EDMA.y_t(:,(countCalcs-1)*(N_BUF)+1:(countCalcs)*N_BUF);
     
     EDMA.y_t_var(countEDMA) = EDMA.y_t_cut(1,:) * EDMA.y_t_cut(1,:)';

     
     if( EDMA.y_t_var(countEDMA) > ENERGIELIMIT )
        %% CALC det( Ra(p) )
        [ det_Ra_p ] = MCCC_8MicsV2( EDMA.y_t_cut, N_BUF, Theta, Phi, fa, Array.MicDistance, c);
        [Phi_est, Theta_est] = GetDOA( det_Ra_p, Phi, Theta );
        Buf.Phi_Est(countEDMA) = Phi_est;
        Buf.Theta_Est(countEDMA) = Theta_est;
        
     else
        Buf.Phi_Est(countEDMA) = 0;
        Buf.Theta_Est(countEDMA) = 0;
        
     end
    
    end
end

fprintf('Simulation finished!\n'); 


% Get angle referance
EDMA = CalcAngleRef(Source, EDMA, y_t);


h2 = figure(201);
NumOfSubplot = 3;
subplot(NumOfSubplot,1,1);
hold on
plot(1:EDMA.NumOFSim, Buf.Phi_Est,'x');
plot(1:EDMA.NumOFSim, rad2deg(EDMA.Phi),'r');
grid;
ylabel('Elevation $\hat\phi$','Interpreter','latex','FontSize',11);
xlabel(sprintf('EDMA Frames (%i)', EDMA.NumOFSim), 'Interpreter','latex','FontSize',11);
title(strtok(FileName,'.'), 'Interpreter','none');


subplot(NumOfSubplot,1,2);
hold on
plot(1:EDMA.NumOFSim, Buf.Theta_Est,'x');
plot(1:EDMA.NumOFSim, rad2deg(EDMA.Theta),'r');
grid;
ylabel('Azimuth $\hat\theta$','Interpreter','latex','FontSize',11);
xlabel(sprintf('EDMA Frames (%i)', EDMA.NumOFSim), 'Interpreter','latex','FontSize',11);


subplot(NumOfSubplot,1,3);
hold on;
plot(1:EDMA.NumOFSim, EDMA.y_t_var, 'g');
plot(1:EDMA.NumOFSim, ENERGIELIMIT, 'Color', 'r');
grid;
ylabel('Energie','Interpreter','latex','FontSize',11);
xlabel(sprintf('EDMA Frames (%i)', EDMA.NumOFSim), 'Interpreter','latex','FontSize',11);
text(10, ENERGIELIMIT + 1, sprintf('Energielimit %5.2f', ENERGIELIMIT), 'Interpreter','latex','FontSize',9, 'Color','red');

SaveFlag = inputs('Save figures? (0):No (1):Yes', 1);

if( SaveFlag )
    
    %% Create directory to save simulaton results
    
    NewDir = [Path 'Matlab' filesep 'Functions' filesep 'GenerateSyntehticSignal' filesep 'Results' filesep strtok(FileName,'.')];
    fprintf('Creating directory %s ...\n', NewDir);
    [SUCCESS,MESSAGE,MESSAGEID] = mkdir(NewDir);

    if( SUCCESS )
        % Save Figures
        disp('Saving figures ...');
        saveas(h1, [NewDir, filesep, sprintf('3D_Veiw_%s.fig', strtok(FileName,'.'))]);
        fprintf('Figure 3D_Veiw_%s.fig saved!\n', strtok(FileName,'.'));
        saveas(h2, [NewDir, filesep, sprintf('DOA_Est_%s.fig',strtok(FileName,'.'))]);
        fprintf('Figure DOA_Est_%s.fig saved!\n', strtok(FileName,'.'));

        % Save simulation results in mat-file
        disp('Saving MAT-File ...');
        save([NewDir filesep 'Simulation_' strtok(FileName,'.')],...
                'Buf', ...
                'EDMA');

        fprintf('File %s.mat saved!\n', strtok(FileName,'.'));

    
    else
        error('Directory %s could not be created ', NewDir);
    end
end




%{

%% PLOT det( Ra(p) ) against Azimuth and elevation
figure(667);
mesh( Theta.Min:Theta.Res:Theta.Max, Phi.Min:Phi.Res:Phi.Max, det_Ra_p ) ; figure(gcf);
xlabel('Azimuth [°]');
ylabel('Elevation [°]');
zlabel('det(Ra(p))');

%}



