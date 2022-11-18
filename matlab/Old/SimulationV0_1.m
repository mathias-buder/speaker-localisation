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

% Angle according to DOA (for Testing)
phi =   45 ;           % elevation [°] (vertical)
theta = 22 ;     % azimutz [°] (horizotal)



% Room [m]
Room.length = 5;
Room.width = 5;
Room.hight = 3;




%% SIGNAL TYPE

% SimSig = inputs('Choose simulation signal 0: Voice, 1: Noise', 0);

% switch (SimSig)
    % case 0
        % Laod sample data (voiced)
        [y_t, fa] = wavread('Original.wav');

        % Use only left channel and chop out a block of 1 sec.
        if((s_start+s_length)<=length(y_t))
            y_t_chop = y_t(s_start:s_start+s_length-1,1)';
        else
            error('Maximum signal length is %f sample', length(y_t))
        end
    % case 1
        % Noise Signal
        % fa = 48000;
        % y_t_chop = randn(1,s_length);
% end



% Microphone Array [m]
Array.Radius = 50*10^-3;
Array.Holeradius = 5*10^-3;
Array.hight = 1.6;
Array.x = Room.width/2;
Array.y = Room.length/2;
Array.z = Array.hight;
Array.MicAngle = rad2deg( acos(sqrt(2/3)) );



% Microphone matrix D [°] according to spharical Array
% D is of size 2xN and represents the microphone position according to
% azimuth and elevation angle.
%    m1       m2       m3       m4        m5       m6        m7        m8
 Array.MicPos = [Array.MicAngle  Array.MicAngle  Array.MicAngle  Array.MicAngle  -Array.MicAngle  -Array.MicAngle  -Array.MicAngle  -Array.MicAngle  ;  % phi
                 -45             45              135             225             -45               45               135               225            ];  % theta
 
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
Array.MinDistance = sqrt( sum(Array.MicDistance(:,1).^2) );
Array.AngleRes = round( rad2deg( asin(c/(Array.MinDistance*fa)) ) );




%{
% Spartial Aliasing for circular Array
R = sqrt(sum(MicDistance(:,1).^2))/2;   % Radius circular array
f_max = c/(4*r*sin(pi/3));  % calc f_max



filter_sig = inputs('Filter signal 0: Yes, 1: No', 1);
switch (filter_sig)
    case 0
        f_g = inputs('Cutoff frequancy ?', f_max);
        % Filter Signal
        C = kaiserord( [20 f_g], [1 0], [0.001 0.1], fa, 'cell' );
        b = fir1(C{:});
        y_t_chop = filter(b,1,y_t_chop);
end

%}





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


%{
%% TEST FUNCTION "GenerateDelayedSignal"
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
 


               
%% structure to handle values according to Theta and Phi
% Theta
Theta.Res = Array.AngleRes;
Theta.Min = 0;                % Steering range
Theta.Max = 359;              % Steering range
Theta.LUT = Theta.Min:Theta.Res:Theta.Max; % Look-Up-Table for theta
Theta.Length = length(Theta.LUT);
                                                     
% Phi
Phi.Res = Array.AngleRes;
Phi.Min = -90;
Phi.Max = 90;
Phi.Half = 0:Phi.Res:Phi.Max; % funktioniert so nich wenn Suchbereich eingeschränkt werden soll
Phi.LUT = [(-1) * Phi.Half(length(0:Phi.Res:Phi.Max):-1:2) 0:Phi.Res:Phi.Max]; % Angel LUT for phi
Phi.Length = length(Phi.LUT);



%% CALC det( Ra(p) )
[ R_xy ] = MCCC_8MicsV2_1( y_t_Synth,  length(y_t_Synth) );
[ det_Ra_p, count ] = Calc_det_Ra_p ( R_xy, Phi, Theta, A, fa, c, count );


% [ det_Ra_p, NumOfLoops ] = MCCC_8MicsV2_1( y_t_Synth, length(y_t_Synth), Theta, Phi, fa, Array.MicDistance, c);

%% FIND MINIMUM
[Phi.EstId, Theta.EstId] = GetDOA( det_Ra_p );

fprintf('Phi est: %i', Phi.EstId);
fprintf('Phi est: %i', Theta.EstId);

%{
[ L ] = Steering_Matrix ( THETA, PHI, A, N, c, fa );
[ det_Ra_p ] = MCCC_3MicsV1( y_t_Synth, length(y_t_Synth), THETA, PHI, fa, A, c )
[ det_Ra_p ] = MCCC_8MicsV1_1( y_t_Synth, length(y_t_Synth), THETA, fa, A, c);
%}


%% PLOT det( Ra(p) ) against Azimuth and Elevation
% figure(667);
% mesh( Theta.Min:Theta.Res:Theta.Max, Phi.Min:Phi.Res:Phi.Max, det_Ra_p(1:Phi.Length,1:Theta.Length) ) ; figure(gcf);
% xlabel('Azimuth [°]');
% ylabel('Elevation [°]');
% zlabel('det(Ra(p))');







