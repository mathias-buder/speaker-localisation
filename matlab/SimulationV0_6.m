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
%close all;
%clear all;
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

% Font size for figures
FigFontSize = 12;    
    

%% Envirement
c = 343;                    % velocity of sound [m/s]

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
N_FFT  = 512;         % Länge der FFT für Korrelation (Energielimit anpassen)
N_BUF  = N_FFT/2;     % Bufferlänge in Samples

EDMA.Motion = floor(Source.SigSection/EDMA.N); % Number of EDMA-Frames per Position

% Array Idx
PHI = 1;
THETA = 2;

INDEX_INVALID = -1;
% ANGLE_INVALID = 0;
ENERGIELIMIT_DB = inputs('Enter energie limit [dB]', -10);

% ENERGIELIMIT_DB = -10; %dB
ENERGIELIMIT = 10^(ENERGIELIMIT_DB/10);
% Laenge von N_EDMA = NBUF ist gleich, 

EDMA.NumOfCalcs = floor(EDMA.N/N_BUF);                  % Number of calculations per EDMA-Frame
EDMA.NumOfFullBuffer = floor(length(y_t(1,:))/EDMA.N); % Number of full buffer according to simulation signal length


EDMA.NumOfSim = inputs('Enter number of simulations?', EDMA.NumOfFullBuffer);



%% Debug flags
DEBUG_R = inputs('Show R(p,t) debug? (0):No (1):Yes', 0);
DEBUG_HIST = inputs('Show histogram debug? (0):No (1):Yes', 0);


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

      
% Distance matrix A [m]
% A is of size 3x((N-1)*N/2) and represents the distance bewteen each pair of 
% microphones.
Array.MicDistance = CalcDistanceMatrix (Array.MicVecor, Array.NumOfMics);

% Minimum distance between two microphones
Array.MinDistance = sqrt(sum(Array.MicDistance(:,1).^2));
Array.AngleRes = asin( c/(Array.MinDistance * fa) );


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
Hist.NumOfFrames = inputs('Enter histogramm buffer length! (0):No (1):Yes', 50);
Hist.ThresholdPercentage = inputs('Enter histogramm threshold in percentage! (0):No (1):Yes', 20);
Hist.Threshold = round(Hist.NumOfFrames/100*Hist.ThresholdPercentage);
Hist.RingBuf = INDEX_INVALID * ones(2, Hist.NumOfFrames);
Hist.Phi = zeros(1, Phi.Length);
Hist.Theta = zeros(1, Theta.Length);

Buf.Phi_Est = zeros(1, EDMA.NumOfSim);
Buf.Phi_Est_non = zeros(1, EDMA.NumOfSim);
Buf.Phi_EstId = zeros(1, EDMA.NumOfSim);
Buf.Phi_EstId_non = zeros(1, EDMA.NumOfSim);
Buf.Phi_Hist_Est_Id = zeros(1, EDMA.NumOfSim);

Buf.Theta_Est = zeros(1, EDMA.NumOfSim);
Buf.Theta_Est_non = zeros(1, EDMA.NumOfSim);
Buf.Theta_EstId = zeros(1, EDMA.NumOfSim);
Buf.Theta_EstId_non = zeros(1, EDMA.NumOfSim);
Buf.Theta_Hist_Est_Id = zeros(1, EDMA.NumOfSim);

EDMA.y_t_var = zeros(1, EDMA.NumOfSim * EDMA.NumOfCalcs);

count = 1;

disp('Simulation started ...');
%% Start ISR
for countEDMA = 1:EDMA.NumOfSim
    EDMA.y_t = y_t(:,(countEDMA-1)*(EDMA.N)+1:(countEDMA)*EDMA.N);
    
    for countCalcs = 1:EDMA.NumOfCalcs % zunächst 1
        
        if(~mod(countEDMA ,DispSimIndex))  
            fprintf('EDMA Frame %i of %i ...\n', countEDMA, EDMA.NumOfSim);    
        end
     
     % Ausschneiden eines Stückes für die Berechnung auf dem EDMA
     EDMA.y_t_cut = EDMA.y_t(:,(countCalcs-1)*(N_BUF)+1:(countCalcs)*N_BUF);
     
     EDMA.y_t_var(countEDMA) = EDMA.y_t_cut(1,:) * EDMA.y_t_cut(1,:)';
     
     
     if( EDMA.y_t_var(countEDMA) > ENERGIELIMIT )
        %% Calculate Cross-Correlations
        [ R_xy ] = MCCC_8MicsV2_11( EDMA.y_t_cut, N_BUF );
        
    
       %% Search area and return DOA
       %[Phi, Theta] = SearchAndFind( R_xy, Phi, Theta, Array.MicDistance, fa, c );  
        
       det_R = Calc_det_Ra_p1(R_xy, Phi, Theta, Array.MicDistance, fa, c);
       
       det_R_tmp = det_R - min(min(det_R));
       det_R_norm = 10*log10(det_R_tmp/max(max(det_R_tmp)));
       
        
       if(DEBUG_R) 
           figure(101);
           mesh( rad2deg(Theta.LUT), rad2deg(Phi.LUT), det_R_norm );
           ylabel('$\phi~/~^\circ$','Interpreter','latex','FontSize',FigFontSize);
           xlabel('$\theta~/~^\circ$','Interpreter','latex','FontSize',FigFontSize);
           zlabel('$\det \left[ R_{\phi, \theta} \right]$','Interpreter','latex','FontSize',FigFontSize);
           pause();
       end
       
       [ Phi_EstIdx, Theta_EstIdx ] = Get2DMinV2( det_R_norm );
       
       
        % Store estimated angles in buffer
        Buf.Phi_Est(countEDMA) = Phi.LUT(Phi_EstIdx);
        Buf.Theta_Est(countEDMA) = Theta.LUT(Theta_EstIdx);
        
        % Store estimated index in buffer
        Buf.Phi_EstId(countEDMA) = Phi_EstIdx;
        Buf.Theta_EstId(countEDMA) = Theta_EstIdx;
        
     else
        Buf.Phi_Est(countEDMA) = INDEX_INVALID;
        Buf.Theta_Est(countEDMA) = INDEX_INVALID;
        
        Buf.Phi_EstId(countEDMA) = INDEX_INVALID;
        Buf.Theta_EstId(countEDMA) = INDEX_INVALID;
     end
     
     
      % ------------------------------------------------------------------------
      % Store angels in Hist-Ringbuffer
      % ------------------------------------------------------------------------    
      Hist.RingBuf(PHI, Hist.BufIndex) = Buf.Phi_EstId(countEDMA);
      Hist.RingBuf(THETA, Hist.BufIndex) = Buf.Theta_EstId(countEDMA);
      
      Hist.BufIndex = Hist.BufIndex + 1;
      % Reset counter
     if( Hist.BufIndex > Hist.NumOfFrames )
         Hist.BufIndex = 1;  
     end
    
    end
    
    
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Estimate angle using histogram buffer
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    % Reset/Init histogram
    Hist.Phi(:) = 0;
    Hist.Theta(:) = 0;
    
    Hist.CountPhi = 0;
    Hist.CountTheta = 0;
    
    Hist.Phi_max_val = 0;
    Hist.Theta_max_val = 0;
   
    for Count=1:Hist.NumOfFrames
        
        TmpPhi = Hist.RingBuf(PHI,Count);
        TmpTheta = Hist.RingBuf(THETA,Count);
        
        % Create histogramm for Phi
        if  TmpPhi > INDEX_INVALID
            Hist.CountPhi = Hist.CountPhi + 1;
            Hist.Phi(TmpPhi) = Hist.Phi(TmpPhi) + 1;
            
            if(Hist.Phi(TmpPhi) > Hist.Phi_max_val)
                Hist.Phi_max_val = Hist.Phi(TmpPhi);
            end
        end
        
        % Create histogramm for Theta
        if  TmpTheta > INDEX_INVALID
            Hist.CountTheta = Hist.CountTheta + 1;
            Hist.Theta(TmpTheta) = Hist.Theta(TmpTheta) + 1;
            if(Hist.Theta(TmpTheta) > Hist.Theta_max_val)
                Hist.Theta_max_val = Hist.Theta(TmpTheta);
            end
        end
         
    end
    
    
    if ( DEBUG_HIST )
        % Plot histogramm according to angle Phi
        figure( 600 );
        %title(sprintf('Frame %i of %i', countEDMA, EDMA.NumOfSim));
%         subplot(4,1,1), stem(1:Hist.NumOfFrames, Hist.RingBuf(PHI,:)), grid;
%         xlabel('Frames','Interpreter','latex','FontSize',11);
%         ylabel('$\hat\phi$-Ringbuffer', 'Interpreter','latex','FontSize',11);
%         title(sprintf('EDMA Frame %i of %i / HistCounter %i\n', countEDMA, EDMA.NumOfSim, Hist.CountPhi), 'Interpreter','latex','FontSize',11);
        
        
        subplot(2,1,1);
        
        stem(rad2deg(Phi.LUT), Hist.Phi, ...
                'mo', ...
                'Color','b' , ...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor',[.49 1 .63],...
                'MarkerSize',5);
        xlim([-90 90]);
        grid;
        xlabel('$\hat\phi ~/~^\circ$','Interpreter','latex','FontSize',11);
        ylabel('$\hat\phi_{Dist}$', 'Interpreter','latex','FontSize',11);
        title(sprintf('Frame %i of %i', countEDMA, EDMA.NumOfSim),'Interpreter','latex','FontSize',11);
%         hold on;
%         plot( Phi.HistEstId , Hist.Phi(Phi.HistEstId), 'rs' )
%         hold off;
        
        % Plot histogramm according to angle Theta
%         subplot(4,1,3), stem(1:Hist.NumOfFrames, Hist.RingBuf(THETA,:)), grid;
%         xlabel('Frames','Interpreter','latex','FontSize',11);
%         ylabel('$\hat\theta$-Ringbuffer','Interpreter','latex','FontSize',11);
%         title(sprintf('HistCounter %i\n', Hist.CountTheta), 'Interpreter','latex','FontSize',11);
        
        subplot(2,1,2);
        stem(rad2deg(Theta.LUT), Hist.Theta, ...
                'mo', ...
                'Color','b' , ...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor',[.49 1 .63],...
                'MarkerSize',5);
        xlim([0 359]);
        grid;
        xlabel('$\hat\theta ~/~^\circ$','Interpreter','latex','FontSize',11);
        ylabel('$\hat\theta_{Dist}$', 'Interpreter','latex','FontSize',11);
        
%         hold on;
%         plot( Theta.HistEstId , Hist.Theta(Theta.HistEstId), 'rs' )
%         hold off
        
        %disp('Press any key to continue ...');
        %pause();
    end
    
    
    
   
    % ------------------------------------------------------------------------
    % Sind genügend SDOA für eine statistische Abschätzung berechnet
    % worden? (Mindestens NUMOFFRAMESFORHIST/2 gültige (wg. Energie) Werte)
    % ------------------------------------------------------------------------
    if(  Hist.Theta_max_val >= Hist.Threshold )
        
        [~, Phi.HistEstId] = max( Hist.Phi );
        if ( DEBUG_HIST )
            figure(600);
            subplot(2,1,1);
            hold on
            plot( rad2deg(Phi.LUT(Phi.HistEstId)) , Hist.Phi(Phi.HistEstId), ...
                    'mo', ...
                    'Color','b' , ...
                    'MarkerEdgeColor','b',...
                    'MarkerFaceColor','r',...
                    'MarkerSize',10);
            text( rad2deg(Phi.LUT(Phi.HistEstId))+5 , Hist.Phi(Phi.HistEstId), num2str(Hist.Phi(Phi.HistEstId)), 'Interpreter','latex','FontSize',11);
            hold off
            % pause();
        end
        
    else 
        Phi.HistEstId = INDEX_INVALID;
    end
    
 
    if( Hist.Theta_max_val >= Hist.Threshold )
        
        [~, Theta.HistEstId] = max( Hist.Theta );
       
        if ( DEBUG_HIST )
            figure(600);
            subplot(2,1,2);
            hold on
            plot( rad2deg(Theta.LUT(Theta.HistEstId)) , Hist.Theta(Theta.HistEstId), ...
                    'mo', ...
                    'Color','b' , ...
                    'MarkerEdgeColor','b',...
                    'MarkerFaceColor','r',...
                    'MarkerSize',10);
            text( rad2deg(Theta.LUT(Theta.HistEstId))+9 , Hist.Theta(Theta.HistEstId), num2str(Hist.Theta(Theta.HistEstId)), 'Interpreter','latex','FontSize',11);
            hold off
            % pause();
        end
    else
        Theta.HistEstId = INDEX_INVALID;
    end

    Buf.Phi_Hist_Est_Id(countEDMA) = Phi.HistEstId;
    Buf.Theta_Hist_Est_Id(countEDMA) = Theta.HistEstId;
    
    %pause();  
end


%% ------------------------------------------------------------------------
% Visualize all results
% ------------------------------------------------------------------------

% Norm energie to 1
EDMA.y_t_var = EDMA.y_t_var / max(EDMA.y_t_var);

%% Calculate angle detection error
Phi_AngleRef = Source.AngleRef(PHI,1:EDMA.N:length(Source.AngleRef(1,:))-EDMA.N);
Theta_AngleRef = Source.AngleRef(THETA,1:EDMA.N:length(Source.AngleRef(1,:))-EDMA.N);
Buf.Phi_Est_error = Buf.Phi_Est - Phi_AngleRef;
Buf.Theta_Est_error = Buf.Theta_Est - Theta_AngleRef;

%% Create pots
disp('Creating figures ...');
FigureCount = FigureCount + 1;
h2 = figure( FigureCount );
NumOfSubplot = 3;
subplot(NumOfSubplot,1,1);
errorbar(rad2deg(Buf.Phi_Est) ,rad2deg(Buf.Phi_Est_error), '.-r', 'LineWidth', 0.1);
hold on
plot(rad2deg( Buf.Phi_Est ),'.-b', 'LineWidth', 0.1);

%plot(1:EDMA.NumOfSim, rad2deg(Source.AngleRef(1,1:EDMA.N:length(Source.AngleRef(1,:))-EDMA.N)),'r');
grid;
ylabel('$\hat\phi~/~^\circ$','Interpreter','latex','FontSize',FigFontSize);
xlabel(sprintf('EDMA Frames (%i)', EDMA.NumOfSim), 'Interpreter','latex','FontSize',FigFontSize);
%title(FileName, 'Interpreter','none');
axis([0 EDMA.NumOfSim -90 90]);

subplot(NumOfSubplot,1,2);
errorbar(rad2deg(Buf.Theta_Est) ,rad2deg(Buf.Theta_Est_error), '.-r', 'LineWidth', 0.1);
hold on
plot(rad2deg( Buf.Theta_Est ),'.-b', 'LineWidth', 0.1);

%plot(1:EDMA.NumOfSim, rad2deg(Source.AngleRef(2,1:EDMA.N:length(Source.AngleRef(1,:))-EDMA.N)),'r');
grid;
ylabel('$\hat\theta~/~^\circ$','Interpreter','latex','FontSize',FigFontSize);
xlabel(sprintf('Frames (%i)', EDMA.NumOfSim), 'Interpreter','latex','FontSize',FigFontSize);
axis([0 EDMA.NumOfSim 0 359]);

% Plot signal energie
subplot(NumOfSubplot,1,3);
hold on;
plot(1:EDMA.NumOfSim, db(EDMA.y_t_var, 'power'), 'g');
plot(1:EDMA.NumOfSim, ENERGIELIMIT_DB, 'Color', 'r');
grid;
ylabel('Energie [dB]','Interpreter','latex','FontSize',FigFontSize);
xlabel(sprintf('Frames (%i)', EDMA.NumOfSim), 'Interpreter','latex','FontSize',FigFontSize);
text(30, ENERGIELIMIT_DB+5 , sprintf('%i dB', ENERGIELIMIT_DB), 'Interpreter','latex','FontSize',9, 'Color','red');
axis([0 EDMA.NumOfSim -20 0]);


%% Create histogramm plots
FigureCount = FigureCount + 1;
h3 = figure( FigureCount );
NumOfSubplot = 3;
subplot(NumOfSubplot,1,1);
hold on;
for i=1:EDMA.NumOfSim
    
    if( Buf.Phi_Hist_Est_Id(i) == INDEX_INVALID )
        plot(i, -90,'.-m');
    else
        stem(i, rad2deg( Phi.LUT(Buf.Phi_Hist_Est_Id(i)) ),'.-b')
    end
end
plot(1:EDMA.NumOfSim, rad2deg(Phi_AngleRef),'r');
hold off;
grid;
ylabel('$\hat\phi_{Hist}~/~^\circ$','Interpreter','latex','FontSize',FigFontSize);
xlabel(sprintf('Frames (%i)', EDMA.NumOfSim), 'Interpreter','latex','FontSize',FigFontSize);
axis([0 EDMA.NumOfSim -90 90]);


subplot(NumOfSubplot,1,2);
hold on
for i=1:EDMA.NumOfSim
    if( Buf.Theta_Hist_Est_Id(i) == INDEX_INVALID )
         plot(i, 0,'.-m'); 
    else
        stem(i, rad2deg( Theta.LUT(Buf.Theta_Hist_Est_Id(i)) ),'.-b');
    end
end
plot(1:EDMA.NumOfSim, rad2deg(Theta_AngleRef),'r');
grid;
hold off;
ylabel('$\hat\theta_{Hist}~/~^\circ$','Interpreter','latex','FontSize',FigFontSize);
xlabel(sprintf('Frames (%i)', EDMA.NumOfSim), 'Interpreter','latex','FontSize',FigFontSize);
axis([0 EDMA.NumOfSim 0 359]);



% Plot signal energie
subplot(NumOfSubplot,1,3);
hold on;
plot(1:EDMA.NumOfSim, db(EDMA.y_t_var, 'power'), 'g');
plot(1:EDMA.NumOfSim, ENERGIELIMIT_DB, 'Color', 'r');
grid;
ylabel('Energie [dB]','Interpreter','latex','FontSize',FigFontSize);
xlabel(sprintf('Frames (%i)', EDMA.NumOfSim), 'Interpreter','latex','FontSize',FigFontSize);
text(30, ENERGIELIMIT_DB+5 , sprintf('%i dB', ENERGIELIMIT_DB), 'Interpreter','latex','FontSize',9, 'Color','red');
axis([0 EDMA.NumOfSim -60 0]);


%% Create plot to compare between normal and histogram
% Normal plot for phi
FigureCount = FigureCount + 1;
h4 = figure( FigureCount );
subplot(2,2,1);
hold on;
for i=1:EDMA.NumOfSim
    
    if( Buf.Phi_Est(i) == INDEX_INVALID )
        plot(i, -90,'.-m');
    else
        stem(i, rad2deg( Buf.Phi_Est(i) ),'.-b', 'LineWidth', 0.1);
    end
end

plot(1:EDMA.NumOfSim, rad2deg(Phi_AngleRef),'r');
hold off;
grid;
ylabel('$\hat\phi~/~^\circ$','Interpreter','latex','FontSize',FigFontSize);
xlabel(sprintf('Frames (%i)', EDMA.NumOfSim), 'Interpreter','latex','FontSize',FigFontSize);
axis([0 EDMA.NumOfSim -90 90]);

% Histogramm plot for phi
subplot(2,2,3);

hold on;
for i=1:EDMA.NumOfSim
    
    if( Buf.Phi_Hist_Est_Id(i) == INDEX_INVALID )
        plot(i, -90,'.-m');
    else
        stem(i, rad2deg( Phi.LUT(Buf.Phi_Hist_Est_Id(i)) ),'.-b')
    end
end
plot(1:EDMA.NumOfSim, rad2deg(Phi_AngleRef),'r');
hold off;
grid;
ylabel('$\hat\phi_{Hist}~/~^\circ$','Interpreter','latex','FontSize',FigFontSize);
xlabel(sprintf('Frames (%i)', EDMA.NumOfSim), 'Interpreter','latex','FontSize',FigFontSize);
axis([0 EDMA.NumOfSim -90 90]);


% Normal plot for theta
subplot(2,2,2);
plot(1:EDMA.NumOfSim, rad2deg(Theta_AngleRef),'r');
hold on
for i=1:EDMA.NumOfSim
    
    if( Buf.Theta_Est(i) == INDEX_INVALID )
        plot(i, 0,'.-m');
    else
        stem(i, rad2deg( Buf.Theta_Est(i) ),'.-b', 'LineWidth', 0.1);
    end
end
hold off;
grid;
ylabel('$\hat\theta~/~^\circ$','Interpreter','latex','FontSize',FigFontSize);
xlabel(sprintf('Frames (%i)', EDMA.NumOfSim), 'Interpreter','latex','FontSize',FigFontSize);
axis([0 EDMA.NumOfSim 0 359]);

% Histogramm plot for theta
subplot(2,2,4);
hold on
for i=1:EDMA.NumOfSim
    if( Buf.Theta_Hist_Est_Id(i) == INDEX_INVALID )
         plot(i, 0,'.-m'); 
    else
        stem(i, rad2deg( Theta.LUT(Buf.Theta_Hist_Est_Id(i)) ),'.-b');
    end
end
plot(1:EDMA.NumOfSim, rad2deg(Theta_AngleRef),'r');
grid;
hold off;
ylabel('$\hat\theta_{Hist}~/~^\circ$','Interpreter','latex','FontSize',FigFontSize);
xlabel(sprintf('Frames (%i)', EDMA.NumOfSim), 'Interpreter','latex','FontSize',FigFontSize);
axis([0 EDMA.NumOfSim 0 359]);




%% Save results
if(  inputs('Save figures? (0):No (1):Yes', 0) )
    
    %% Create directory
    NewDir = [Path 'Matlab' filesep 'Simulation results' filesep FileName];
    fprintf('Creating directory %s ...\n', NewDir);
    [SUCCESS,MESSAGE,MESSAGEID] = mkdir(NewDir);

    if( SUCCESS )
        % Save Figures
        disp('Saving figures ...');
        saveas(h1, [NewDir, filesep, sprintf('3D_Veiw_%s.fig', strtok(FileName,'.'))]);
        fprintf('Figure 3D_Veiw_%s.fig saved!\n', strtok(FileName,'.'));
        saveas(h2, [NewDir, filesep, sprintf('DOA_Est_%s.fig',strtok(FileName,'.'))]);
        fprintf('Figure DOA_Est_%s.fig saved!\n', strtok(FileName,'.'));
        saveas(h3, [NewDir, filesep, sprintf('DOA_Est_Hist_%s.fig',strtok(FileName,'.'))]);
        fprintf('Figure DOA_Est_Hist_%s.fig saved!\n', strtok(FileName,'.'));
        saveas(h4, [NewDir, filesep, sprintf('DOA_Est_Hist_Comp_%s.fig',strtok(FileName,'.'))]);
        fprintf('Figure DOA_Est_Hist_Comp_%s.fig saved!\n', strtok(FileName,'.'));

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

fprintf('%s finished !\n', CurrentFileName);

