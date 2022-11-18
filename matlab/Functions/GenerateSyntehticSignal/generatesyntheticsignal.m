%   GenerateDelayedSignal creates a vector of size NxR where R represents
%   the length of signal vector y_t. Each row N>1 is delayed according to
%   azimuth and elevation (N=1 is the reference microphone).
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

%% PROPERTIES
clc;
clear all;
close all;
CurrentFileName = [mfilename() '.m'];

disp('--------------------------------------------------');
fprintf('%s is running ...\n', CurrentFileName);
disp('--------------------------------------------------');
disp('DISCRIPTION:');
disp('This file creates a synthetic signal accordig');
disp('to a variable amount of N room positions.');
disp('The script creates M interpolation points between')
disp('two postions. The resulting signal will be saved') 
disp('under the give filename in format:');
disp ('FileName_SignalType_N-Pos-M-Intpl_SNR-SdB.mat');
disp('In case FileName is empty current timestamp is');
disp('used insted.')
disp('--------------------------------------------------');


% Get Path to folder
Path = GetPathToFolder('Masterarbeit');

% set view angles for figures
View = [45 34;
        0  0; 
        0 90];


% Envirement
tempereture = 20;               % Tempereture in °C
c = CalcCAir( tempereture );    % velocity of sound [m/s]

% Room [m]
Room.length = 5;
Room.width = 5;
Room.hight = 3;

% Farfield condition
% k * r >> 1
% k = 2*pi*f/c
% 2*pi*f *r/c >> 1 
% r >> c/2*pi*f

AudioField.f_min = 500; % f_min
AudioField.Radius = (c / (2*pi*AudioField.f_min)) * 3; % *3 because '>> 1'


%% Define SNR
SNR = inputs('Enter Signal-to-Noise-Ratio (DB)',100);

% Microphone Array [m]
Array.Radius = 50*10^-3;
Array.Holeradius = 5*10^-3;
Array.hight = 1.5;
Array.x = Room.width/2;
Array.y = Room.length/2;
Array.z = Array.hight;
Array.MicAngle = rad2deg( acos(sqrt(2/3)) );



%% Microphone matrix D [°] according to spharical Array
% D is of size 2xN and represents the microphone position according to
% azimuth and elevation angle.
%    m1       m2       m3       m4        m5       m6        m7        m8
 Array.MicPos = [Array.MicAngle  Array.MicAngle  Array.MicAngle  Array.MicAngle  -Array.MicAngle  -Array.MicAngle  -Array.MicAngle  -Array.MicAngle  ;  % phi
                 -45             45              135             225             -45               45               135              225            ];  % theta
 
          

 %% Number of Microphones
 Array.NumOfMics = length( Array.MicPos ); 

%% Calculate Microphone matix m [x_n y_n z_n] of size 3xN with n=1...N
% according to elevation and azimuth angle given by matix D
Array.MicVecor = CalcMicMatrix (Array.MicPos, Array.Radius , Array.Holeradius, Array.NumOfMics);

% Distance matrix A [m]
% A is of size 3x((N-1)*N/2) and represents the distance bewteen each pair of 
% microphones.
Array.MicDistance = CalcDistanceMatrix (Array.MicVecor, Array.NumOfMics);




%% SOURCE POSITION
PlotDate2(Room, Array, 0, 0 ,AudioField, View, 'non');
title(sprintf('Observation area %im x %im x %im', Room.length, Room.hight, Room.width));
% Set window position
SetWindowPos( 400 );


Source.NumOfPos = inputs(sprintf('Please enter number of positions'),2);
Source.PosRes = inputs(sprintf('Please enter number of interpolation points'),5);


Source.Pos = zeros(3, Source.NumOfPos);
Source.NumOfInterplPos = ((Source.NumOfPos-1) * Source.PosRes) + 1;
Source.PosInterpolated = zeros(3, Source.NumOfInterplPos);
Source.Angle = zeros(2, Source.NumOfInterplPos);

Source.Xmotion = zeros(1,Source.NumOfPos-1);
Source.Ymotion = zeros(1,Source.NumOfPos-1);
Source.Zmotion = zeros(1,Source.NumOfPos-1);

% X-Y-Z position in array
Source.X = 1;
Source.Y = 2;
Source.Z = 3;


fprintf('Please enter position coordiantes [x y z] for %i positions: \n', Source.NumOfPos);


for CountPos=1:Source.NumOfPos
    fprintf('Position %i of %i\n', CountPos, Source.NumOfPos);
    Source.Pos(Source.X,CountPos) = inputs(sprintf('x [0m-%im]',Room.width),0);
    Source.Pos(Source.Y,CountPos) = inputs(sprintf('y [0m-%im]',Room.length),0);
    Source.Pos(Source.Z,CountPos) = inputs(sprintf('z [0m-%im]',Room.hight),0);
    PlotDate2(Room, Array, Source, CountPos, AudioField, View, 'PosOnly');
end


for CountPos = 2:Source.NumOfPos
    Source.Xmotion(CountPos-1) = (Source.Pos(Source.X,CountPos) - Source.Pos(Source.X,CountPos-1)) / Source.PosRes;
    Source.Ymotion(CountPos-1) = (Source.Pos(Source.Y,CountPos) - Source.Pos(Source.Y,CountPos-1)) / Source.PosRes;
    Source.Zmotion(CountPos-1) = (Source.Pos(Source.Z,CountPos) - Source.Pos(Source.Z,CountPos-1)) / Source.PosRes;
end


% Set first position
Source.PosInterpolated(:,1) = Source.Pos(:,1);

%% Calculate all interpolated positions
for CountPos = 1:Source.NumOfPos-1
    for CountPosInter = 2:Source.PosRes+1
        Source.PosInterpolated(Source.X,CountPosInter + Source.PosRes*(CountPos-1)) = Source.PosInterpolated(Source.X,CountPosInter-1 + Source.PosRes*(CountPos-1)) + Source.Xmotion(CountPos);
        Source.PosInterpolated(Source.Y,CountPosInter + Source.PosRes*(CountPos-1)) = Source.PosInterpolated(Source.Y,CountPosInter-1 + Source.PosRes*(CountPos-1)) + Source.Ymotion(CountPos);
        Source.PosInterpolated(Source.Z,CountPosInter + Source.PosRes*(CountPos-1)) = Source.PosInterpolated(Source.Z,CountPosInter-1 + Source.PosRes*(CountPos-1)) + Source.Zmotion(CountPos);
    end
end

% Plot deta in observaion area
PlotDate2(Room, Array, Source, 0, AudioField, View, 'all');

Source.phiId = 1;
Source.thetaId = 2;

for countPos = 1:Source.NumOfInterplPos
    Source.r = sqrt(( Source.PosInterpolated(Source.X,countPos) - Array.x)^2 + (Source.PosInterpolated(Source.Y,countPos) - Array.y)^2 + (Source.PosInterpolated(Source.Z,countPos) - Array.z)^2);
    Source.Angle(Source.phiId, countPos) = asin( (Source.PosInterpolated(Source.Z,countPos) - Array.z) / Source.r );
    
    if ((Source.PosInterpolated(Source.Y,countPos) < Array.y) && (abs(Source.PosInterpolated(Source.Y,countPos) - Array.y) > 0.001))
        Source.Angle(Source.thetaId, countPos) = 2*pi - acos( (Source.PosInterpolated(Source.X,countPos) - Array.x) / (cos(Source.Angle(Source.phiId, countPos)) * Source.r) );
    else
        Source.Angle(Source.thetaId, countPos) = acos( (Source.PosInterpolated(Source.X,countPos) - Array.x) / (cos(Source.Angle(Source.phiId, countPos)) * Source.r) );
    end
end


[~, Source.NumOfAngles] = size(Source.Angle);

%% Create synthetic Signal of size [ array.NumOfMics x length(y_t) ]
while(1)
    CreateSigFlag = inputs('Create signal (1) or display positions only and quite (0) ?',0);
    if( CreateSigFlag )
        clear praefix
        Praefix = input('Enter Filename: ','s');
        if isempty(Praefix)
            % Use timestamp as name
            Praefix = datestr(clock);
        end

        % Choose signal type
        SimSig = inputs('Choose signal type (0):Male, (1):Female, (2):Recorded, (3):Noise', 0);

        switch(SimSig)
            case 0
                SoundFileName = 'Original.wav';
                [waveData, fa] = audioread( SoundFileName );        
                y_t_all = waveData(:,1)';
                SigType = 'Male';
            case 1
                SoundFileName = 'Original.wav';
                [waveData, fa] = audioread( SoundFileName );        
                y_t_all = waveData(:,2)';
                SigType = 'Female';
           case 2
                SoundFileName = 'Recorded';
                load([Path 'Matlab' filesep 'Functions' filesep 'GenerateSyntehticSignal' filesep 'Recorded_0_0.mat']);
                y_t_all = y(1,:);
                fa = 48000;
                SigType = 'Recorded';
                
            case 3
                %N = Source.NumOfInterplPos * 256; % to get a 256 sample slice/angle
                N = 737216;
                nn = randn(1, N);
                fa = 48000;
                SoundFileName = 'non';
                SigType = 'Noise';
                load('BPF_300_2900.mat') % Fstop1 = 200, Fass1 = 300, Fstop2 = 3400, Fass2 = 3500, dämpfung: 80 80, fs=48000
                y_t_all = filter(BPF_300_2900, 1 , nn);
                y_t_all = y_t_all/max(y_t_all);
                
            otherwise
                error('Choise not available!')
        end
        
        
        fprintf('Creating synthetic signal with %i channels of length %i ...\n',Array.NumOfMics ,length(y_t_all));

        Source.SigSection = floor(length(y_t_all)/Source.NumOfInterplPos); 

        % Variable for output signal
        y_t = zeros( Array.NumOfMics, length(y_t_all) );
        Source.AngleRef = zeros( 2, length(y_t_all) );

        for countPos=1:Source.NumOfInterplPos

            fprintf('Creating signal part %i of %i ...\n',countPos, Source.NumOfInterplPos)

            phi = Source.Angle(Source.phiId, countPos);
            theta = Source.Angle(Source.thetaId, countPos);

            [y_t_Synth ] = GenerateDelayedSignal(...
                c,...
                Array.MicDistance,...
                Array.NumOfMics,...
                phi,...
                theta,...
                y_t_all,...
                SNR,...
                fa);

            part = ((countPos-1)*Source.SigSection + 1):(countPos*Source.SigSection); 
            y_t(:,part) = y_t_Synth(:,part);
            
            % Store angle referance
            Source.AngleRef(1, part) = phi;
            Source.AngleRef(2, part) = theta;
        end

        fprintf('Ready!\n')

        % Print angles to console
        fprintf('    Phi      Theta\n');
        fprintf('   ---------------\n');
        
        for countAngle = 1:Source.NumOfAngles
            fprintf('%8.1f°  %8.1f°\n', rad2deg( Source.Angle(Source.phiId,countAngle)), rad2deg( Source.Angle(Source.thetaId,countAngle)));
        end

        fprintf('   ---------------\n');
        fprintf('        Sum: %i\n', Source.NumOfInterplPos);

        SaveFile = inputs('Save File? Yes:[1] No:[0]',1);

        if( SaveFile )
            FileName =...
            sprintf('%s_%s_%i-Pos_%i-Pos_Intpl_SNR-%idB.%s',...
             Praefix, SigType, Source.NumOfPos, Source.NumOfInterplPos, SNR, 'mat');

            fprintf('Saving file %s ...\n', FileName);


            save([Path 'Matlab' filesep 'Functions' filesep 'GenerateSyntehticSignal' filesep 'SyntheticFiles' filesep FileName],...
                'SoundFileName',...
                'y_t',...
                'Array',...
                'Source',...
                'Room',...
                'AudioField',...
                'SNR',...
                'fa');

            fprintf('File %s saved!\n', FileName);
        end
        
    else
        % Print Angles
        fprintf('    Phi      Theta\n');
        fprintf('   ---------------\n');
        for countAngle = 1:Source.NumOfAngles
            fprintf('%8.1f°  %8.1f°\n', rad2deg( Source.Angle(Source.phiId,countAngle)), rad2deg( Source.Angle(Source.thetaId,countAngle)));
        end
        fprintf('   ---------------\n');
        fprintf('        Sum: %i\n', Source.NumOfInterplPos);
        fprintf('%s finished !\n', CurrentFileName);
        break;
    end    
end