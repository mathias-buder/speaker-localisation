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

% Signal
s_start = 5096;
s_length = 256;         % Length of signal slice [sample]

% Envirement
c = 343;                % velocity of sound [m/s]
SNR = 100;              % Signal-to-Nois-Ratio [dB]

% Room [m]
Room.length = 5;
Room.width = 5;
Room.hight = 3;

%% SIGNAL TYPE

SimSig = inputs('Choose simulation signal 0: Voice, 1: Noise', 0);

switch (SimSig)
    case 0
        % Laod sample data (voiced)
        [y_t, fa] = wavread('Original.wav');

        % Use only left channel and chop out a block of 1 sec.
        if((s_start+s_length)<=length(y_t))
            y_t_chop = y_t(s_start:s_start+s_length-1,1)';
        else
            error('Maximum signal length is %f sample', length(y_t))
        end
    case 1
        % Noise Signal
        fa = 48000;
        y_t_chop = randn(1,s_length);
end




%% Microphone matrix D [°] according to spharical Array
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


%% Structure to handle values according to Theta and Phi
% Theta
Theta.Res = Array.AngleRes;
Theta.Min = 0;                % Steering range
Theta.Max = 359;              % Steering range
Theta.LUT = Theta.Min:Theta.Res:Theta.Max; % Angel LUT for theta
Theta.Length = length(Theta.LUT);

% Phi
Phi.Res = Array.AngleRes;
Phi.Min = -90;
Phi.Max = 90;
Phi.Half = 0:Phi.Res:Phi.Max;
Phi.LUT = [(-1) * Phi.Half(length(0:Phi.Res:Phi.Max):-1:2) 0:Phi.Res:Phi.Max]; % Angel LUT for phi
Phi.Length = length(Phi.LUT);

% Microphone Array [m]
Array.Radius = 50*10^-3;
Array.Holeradius = 5*10^-3;
Array.hight = 1.5;
Array.x = Room.width/2;
Array.y = Room.length/2;
Array.z = Array.hight;
Array.MicAngle = rad2deg( acos(sqrt(2/3)) );


%{

% Spartial Aliasing for circular Array
R = sqrt(sum(MicDistance(:,1).^2))/2;   % Radius circular array
f_max = c/(4*r*sin(pi/3));  % calc f_max
%}


%% SOURCE POSITION

Source.x = inputs('x-coordinate:',1);
Source.y = inputs('y-coordinate:',1);
Source.z = inputs('z-coordinate:',1);

Source.Angle = zeros(1, 2);

Source.phiId = 1;
Source.thetaId = 2;




Source.r = sqrt(( Source.x - Array.x)^2 + (Source.y - Array.y)^2 + (Source.z - Array.z)^2);
Source.Angle(Source.phiId) = asin( (Source.z - Array.z) / Source.r );

if (Source.y < Array.y)
    Source.Angle(Source.thetaId) = 2*pi - acos( (Source.x - Array.x) / (cos(Source.Angle(Source.phiId)) * Source.r) );
else
    Source.Angle(Source.thetaId) = acos( (Source.x - Array.x) / (cos(Source.Angle(Source.phiId)) * Source.r) );
end


phi = rad2deg( Source.Angle(Source.phiId) )
theta = rad2deg( Source.Angle(Source.thetaId) )

%% GENERATE SYNTHETIC SIGNAL OF SIZE [ array.NumOfMics X length(y_t_chop) ]
[y_t_Synth ] = GenerateDelayedSignal(...
	c,...
	Array.MicDistance,...
	Array.NumOfMics,...
	phi,...
  	theta,...
	y_t_chop,...
 	SNR,...
	fa);



%% Add second signal
%{
% Create signal
[y_t_Synth_2 ] = GenerateDelayedSignal(...
	c,...
	A,...
	N,...
	phi_2,...
  	theta_2,...
	y_t_chop,...
 	SNR,...
	fa);


 % Sum and waightg
 y_t_Synth = 1/2*(y_t_Synth_1 + y_t_Synth_2);
%}


%% TEST FUNCTION "GenerateDelayedSignal"
%{

m = zeros(((N*N)-N)/2,1);
n = -length(y_t_Synth):length(y_t_Synth)-1;
CC = zeros(((N*N)-N)/2, 2*length(y_t_chop));
k=1;
for j=1:N-1
    for i=(j+1):N
        CC(k,:) = FXcorr(y_t_Synth(i,:),y_t_Synth(j,:),2*length(y_t_Synth(1,:)));
        %subplot(((N*N)-N)/4,2,k)
        stem(n,CC(k,:)),grid;
        title(sprintf('y_t_Synth(%i,:),y_t_Synth(%i,:)',i,j));
        [Y,I] = max(CC(k,:));
        m(k) = I-length(n)/2-1;
        k=k+1;
        pause();
    end
end   
%} 
 
  

%% CALC det( Ra(p) )
[ det_Ra_p ] = MCCC_8MicsV2_1( y_t_Synth, length(y_t_Synth), Theta, Phi, fa, Array.MicDistance, c);

% [ L ] = Steering_Matrix ( THETA, PHI, A, N, c, fa );
% [ det_Ra_p ] = MCCC_3MicsV1( y_t_Synth, length(y_t_Synth), THETA, PHI, fa, A, c )
% [ det_Ra_p ] = MCCC_8MicsV1_1( y_t_Synth, length(y_t_Synth), THETA, fa, A, c);



%% PLOT det( Ra(p) ) against Azimuth and elevation
figure(667);
mesh( THETA.MIN:THETA.RESOLUTION:THETA.MAX, PHI.MIN:PHI.RESOLUTION:PHI.MAX, det_Ra_p ) ; figure(gcf);
xlabel('Azimuth [°]');
ylabel('Elevation [°]');
zlabel('det(Ra(p))');


%% FIND MINIMUM
[phi_est, theta_est] = EstimateDOA( det_Ra_p, PHI, THETA );

phi_est
theta_est

