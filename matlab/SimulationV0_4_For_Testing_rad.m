%% Siumulation v0.4
%   - Search optimisations (speed)
%   - Histogramm (robustness)NumOfSim
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
%    Date       :  04.04.2013


%% Clear and close all
close all;
% clear all;
clc;
CurrentFileName = [mfilename() '.m'];
FigureCount = 100;
% Simulatuon
DispSimIndex = 100;     % Display every 100's simiulation index


disp('--------------------------------------------------');
fprintf('%s is running ...\n', CurrentFileName);
disp('--------------------------------------------------');
disp('DISCRIPTION:');
disp('TODO....');
disp(' ');



% DEBUG
% DEBUG_HIST = 1;


%% PROPERTIES

Path = GetPathToFolder('Masterarbeit');

PathToSynthFiles = [Path 'Matlab' filesep 'Functions' filesep 'GenerateSyntehticSignal' filesep 'SyntheticFiles'];
PathToRealFiles = [Path 'Matlab' filesep 'TI_DSP' filesep 'Recorded'];

ListOfSynthFiles = dir([PathToSynthFiles filesep '*.mat']);
ListOfRealFiles = dir([PathToRealFiles filesep '*.mat']);

NumOfSynthFiles = length(ListOfSynthFiles);
NumOfRealFiles = length(ListOfRealFiles);

% set view angles for figures
View = [45 34;
        0  0; 
        0 90];

% Envirement
tempereture = 20;           % Tempereture in °C
c = CalcCAir( tempereture );  % velocity of sound [m/s]


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
        h1 = figure( FigureCount );
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
N_FFT  = 2048;         % Länge der FFT für Korrelation (Energielimit anpassen)
N_BUF  = 128;     % Bufferlänge in Samples

EDMA.Motion = floor(Source.SigSection/EDMA.N); % Number of EDMA-Frames per Position

PHI = 1;
THETA = 2;

INDEX_INVALID = -1;
% ANGLE_INVALID = 0;
% ENERGIELIMIT_DB = inputs('Enter energie limit [dB]', -10);

% ENERGIELIMIT_DB = -10; %dB
% ENERGIELIMIT = 10^(ENERGIELIMIT_DB/10);
% Laenge von N_EDMA = NBUF ist gleich, 

EDMA.NumOfCalcs = floor(EDMA.N/N_BUF);                  % Number of calculations per EDMA-Frame
EDMA.NumOfFullBuffer = floor(length(y_t(1,:))/EDMA.N); % Number of full buffer according to simulation signal length


% EDMA.NumOfSim = inputs('Enter number of simulations?', EDMA.NumOfFullBuffer);


%% Microphone Array [m]
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
%                m1               m2             m3              m4              m5                m6               m7               m8
 Array.MicPos = [Array.MicAngle  Array.MicAngle  Array.MicAngle  Array.MicAngle  -Array.MicAngle  -Array.MicAngle  -Array.MicAngle  -Array.MicAngle  ;  % phi
                 -45             45              135             225             -45               45               135              225            ];  % theta
 
% Number of Microphones
Array.NumOfMics = length( Array.MicPos );           
 

%% Calculate Microphone matix m [x_n y_n z_n] of size 3xN with n=1...N
% according to elevation and azimuth angle given by matix D
Array.MicVecor = CalcMicMatrix (Array.MicPos, Array.Radius , Array.Holeradius, Array.NumOfMics);

% OLD
%{
b = 10*10^-2;
h= 10*10^-2;
%                  M1   M2   M3
Array.MicVecor = [ b/2  b/2 -b/2  -b/2  b/2  b/2 -b/2  -b/2;    
                  -b/2  b/2  b/2  -b/2 -b/2  b/2  b/2  -b/2;   
                   h/2  h/2  h/2   h/2 -h/2 -h/2 -h/2  -h/2;
];
%}
      
% Distance matrix A [m]
% A is of size 3x((N-1)*N/2) and represents the distance bewteen each pair of 
% microphones.
Array.MicDistance = CalcDistanceMatrix (Array.MicVecor, Array.NumOfMics);

% Minimum distance between two microphones
Array.MinDistance = sqrt(sum(Array.MicDistance(:,1).^2));
Array.AngleRes = asin( c/(Array.MinDistance * fa ) );


%% Structure to handle values according to Theta and Phi
% Theta
Theta.Res = Array.AngleRes;
Theta.Min = 0;                % Steering range
Theta.Max = 2*pi;              % Steering range
Theta.LUT = Theta.Min:Theta.Res:Theta.Max; % Angel LUT for theta
Theta.Length = length(Theta.LUT);
Theta.HistEstId = 0;
% Theta.NumOfSearchAngles = 3; % Angles/Search

% Phi
Phi.Res = Array.AngleRes;
Phi.Min = -pi/2;
Phi.Max = pi/2;
Phi.Half = 0:Phi.Res:Phi.Max;
Phi.LUT = [(-1) * Phi.Half(length(0:Phi.Res:Phi.Max):-1:2) 0:Phi.Res:Phi.Max]; % Angel LUT for phi
Phi.Length = length(Phi.LUT);
% Phi.NumOfSearchAngles = 3; % Angles/Searc
% Hier noch alle Componenten inizialisieren

Phi.HistEstId = 0;

%% Signalbuffer to hold histogramm values
Hist.BufIndex = 1;
Hist.NumOfFrames = 50;
Hist.RingBuf = INDEX_INVALID * ones(2, Hist.NumOfFrames);
Hist.Phi = zeros(1, Phi.Length);
Hist.Theta = zeros(1, Theta.Length);

%{
% Spartial Aliasing for circular Array

R = sqrt(sum(MicDistance(:,1).^2))/2;   % Radius circular array
f_max = c/(4*r*sin(pi/3));  % calc f_max
%}

% Buf.Phi_Est = zeros(1, EDMA.NumOfSim);
% Buf.Phi_EstId = zeros(1, EDMA.NumOfSim);
% Buf.Phi_Hist_Est_Id = zeros(1, EDMA.NumOfSim);
% 
% Buf.Theta_Est = zeros(1, EDMA.NumOfSim);
% Buf.Theta_EstId = zeros(1, EDMA.NumOfSim);
% Buf.Theta_Hist_Est_Id = zeros(1, EDMA.NumOfSim);
% 
% EDMA.y_t_var = zeros(1, EDMA.NumOfSim * EDMA.NumOfCalcs);

plot(y_t(1,:));

N_Start = inputs('Please enter sample starting point:', 150000);
N_Samples = inputs('Please enter length:', 1024);

if( mod(N_Samples ,2) ~=0 )
    error('Length %i is not a factor of 2.', N_Samples);
end

% Cut of desired region and store in new buffer
y_t_cut = y_t(:,N_Start:N_Start+N_Samples-1);





% count = 1;

disp('Simulation started ...');
%% Start ISR
% for countEDMA = 1:EDMA.NumOfSim
    % EDMA.y_t = y_t(:,(countEDMA-1)*(EDMA.N)+1:(countEDMA)*EDMA.N);
    
    % for countCalcs = 1:EDMA.NumOfCalcs % zunächst 1
        
    
       %  if(~mod(countEDMA ,DispSimIndex))  
       %      fprintf('EDMA Frame %i of %i ...\n', countEDMA, EDMA.NumOfSim);    
       %  end
     
     % Ausschneiden eines Stückes für die Berechnung auf dem EDMA
     % EDMA.y_t_cut = EDMA.y_t(:,(countCalcs-1)*(N_BUF)+1:(countCalcs)*N_BUF);
     
     % EDMA.y_t_var(countEDMA) = EDMA.y_t_cut(1,:) * EDMA.y_t_cut(1,:)';
     
     
     % if( EDMA.y_t_var(countEDMA) > ENERGIELIMIT )
        %% Calculate Cross-Correlations

        [ R_xy ] = MCCC_8MicsV2_1( y_t_cut, N_BUF );
        R_xy.NumOfLoops = ceil( log2( Theta.Length/3 ) );
        
        %% Set search starting parameters
        % Theta.NumOfLoops = ceil( log2( Theta.Length/3 ) );
        Theta.EstId = ceil( Theta.Length/3 ) + 1 ; % To set Theta.StartId = 1 in first loop
        
        % Phi.MidId = (Phi.Length-1)/2+1;
        Phi.EstId = (Phi.Length-1)/2+1;
        
        
        Theta.NumOfSearchAngles = 3;
        Phi.NumOfSearchAngles = 3;
        

        count = 0; 
       %% Search area and return DOA

       

       [Phi, Theta] = SearchAndFind( R_xy, Phi, Theta, Array.MicDistance, fa, c );  
        
        fprintf('Phi: %3.1f, Theta: %3.1f\n',Phi.LUT(Phi.EstId), Theta.LUT(Theta.EstId));
       




