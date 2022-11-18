clear
close all

% Get Path to folder
Path = GetPathToFolder('Masterarbeit');

% set view angles for figures
View = [45 34;
        0  0; 
        0 90];


% Envirement
tempereture = 24;           % Tempereture in °C
c = CalcCAir( tempereture );  % velocity of sound [m/s]

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






%% SELECTION OF RECORDED FILE
PathToRealFiles = [Path 'Matlab' filesep 'TI_DSP' filesep 'Recorded'];
ListOfRealFiles = dir([PathToRealFiles filesep '*.bin']);
NumOfRealFiles = length(ListOfRealFiles);


fprintf('Please select one of the %i recorded file(s):\n', NumOfRealFiles);
for Count = 1:NumOfRealFiles
    fprintf('[%i] %s\n', Count, ListOfRealFiles(Count).name);
end


RecordedFileNum = inputs('Select file :', 1);
FileName = ListOfRealFiles(RecordedFileNum).name;
fprintf('Loading file %s ...\n', FileName)
fid = fopen(ListOfRealFiles(RecordedFileNum).name,'r');
fprintf('File %s loaded!\n', FileName)






%% SOURCE POSITION
PlotDate2(Room, Array, 0, 0 ,AudioField, View, 'non');
title(sprintf('Observation area %im x %im x %im', Room.length, Room.hight, Room.width));
% Set window position
SetWindowPos( 400 );


% if( inputs(sprintf('Source angles (0) or positions (1)?'),1) )

Source.NumOfPos = inputs(sprintf('Please enter number of positions'),1);
Source.PosRes = inputs(sprintf('Please enter number of interpolation points'),1);


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






num_val = inputs('Enter number of values', 64000 );
[A, count] = fread(fid, 8*num_val, 'short');
fclose(fid);
Ax = zeros(8, num_val);
for kx = 1:8
    Ax(kx,:) = A(num_val*(kx-1)+1:num_val*kx)/2^15;
end



InterpolateSignal = inputs('Interpolate signal? (0):No (1):Yes', 0);

if(InterpolateSignal)
    InterpIdent = 'Interpol';
    r = 48/8;
    y_t = zeros(8, r*length(Ax));

        for i=1:8
            y_t(i,:) = interp(Ax(i,:), r);
        end
else
    InterpIdent = 'NoInterpol';
    r = 1;
    y_t = Ax;
end


Source.SigSection = floor(length(y_t)/Source.NumOfInterplPos);


figure;
subplot(4,1,1);
plot(1:num_val*r, y_t(1,:),1:num_val*r, y_t(2,:)),grid
subplot(4,1,2);
plot(1:num_val*r, y_t(3,:),1:num_val*r, y_t(4,:)),grid
subplot(4,1,3);
plot(1:num_val*r, y_t(5,:),1:num_val*r, y_t(6,:)),grid
subplot(4,1,4);
plot(1:num_val*r, y_t(7,:),1:num_val*r, y_t(8,:)),grid


fa = inputs('Enter sampling frequancy (Hz)',r*8000);

PlayFile = inputs('Play File? Yes:[1] No:[0]',1);

if(PlayFile)
    sound(y_t(2,:), fa);
end

SaveFile = inputs('Save File? Yes:[1] No:[0]',1);

ThetaRec = Source.Angle(Source.thetaId, 1);
PhiRec = Source.Angle(Source.phiId, 1);


if( SaveFile )
    FileName =...
    sprintf('Recorded_Theta_%5.2f_Phi_%5.2f_%iHz_%s_%s.%s',...
     rad2deg(ThetaRec), rad2deg(PhiRec), fa, InterpIdent, datestr(now,'dd-mm-yy'), 'mat');

    fprintf('Saving file %s ...\n', FileName);
    
    save([PathToRealFiles filesep FileName],...
    'y_t',...
    'Array',...
    'Source',...
    'Room',...
    'AudioField',...
    'fa');

    fprintf('File %s saved!\n', FileName);
end






