%% Siumulation v0.2
%   - single angle
%   - search optimisation
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
phi =   0;           % elevation [°] (vertical)
theta = 315;     % azimutz [°] (horizotal)

% Room [m]
Room.length = 5;
Room.width = 5;
Room.hight = 3;

%% SIGNAL TYPE

% SimSig = inputs('Choose simulation signal 0: Voice, 1: Noise', 0);

% switch (SimSig)
    % case 0
        % Laod sample data (voiced)
        [y_t, fa] = audioread('Original.wav');

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
 
 
%{
% Microphone matrix D [°] according to cyrcular Array
% D is of size 2xN and represents the microphone position according to
% azimuth and elevation angle.

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
Theta.LUT = Theta.Min:Theta.Res:Theta.Max; % Look-Up-Table-Theta
Theta.Length = length(Theta.LUT);
                                                     
% Phi
Phi.Res = Array.AngleRes;
Phi.Min = -90;
Phi.Max = 90;
Phi.Half = 0:Phi.Res:Phi.Max; % funktioniert so nich wenn Suchbereich eingeschränkt werden soll
Phi.LUT = [(-1) * Phi.Half(length(0:Phi.Res:Phi.Max):-1:2) 0:Phi.Res:Phi.Max]; % Angel LUT-Phi
Phi.Length = length(Phi.LUT);


%% Calculate Cross-Correlations
[ R_xy ] = MCCC_8MicsV2_1( y_t_Synth, length(y_t_Synth) );

%% Set search starting parameters
Theta.NumOfLoops = ceil( log2( Theta.Length/3 ) );
Theta.EstId = ceil( Theta.Length/3 ) + 1 ; % To set Theta.StartId = 1 in first loop
Phi.EstId = 12;
R_xy.NumOfSearchAngles = 3; % Angles/Search


%% Search area and return DOA
[Phi, Theta] = SearchAndFind (R_xy, Phi, Theta, Array.MicDistance, fa, c);

% disp('-------------------------------------------------------')
% disp('-------------------------------------------------------')

fprintf('Given Theta: %i\n', phi);
fprintf('Given Phi: %i\n', theta);
disp('-----Results-with-optimisations-----')
fprintf('Estimated Theta: %i\n', Phi.Est);
fprintf('Estimated Phi: %i\n', Theta.Est);




%{
for Count=0:Theta.NumOfLoops
       disp('+------------------------------------+')
    fprintf('+-------------- LOOP %i --------------+\n',Count + 1);
       disp('+------------------------------------+')
    Theta.SearchRes = ceil( Theta.Length/(3*2^Count) );
    Theta.StartId = Theta.EstId - Theta.SearchRes;
    fprintf('Theta.SearchRes: %i\n', Theta.SearchRes);
    
    Phi.SearchRes = ceil( Phi.Length/(4*2^Count) );
    
    if(Phi.EstId >= Phi.Length)
        Phi.StartId = Phi.EstId - 2*Phi.SearchRes;
    else if(Phi.EstId <=1)
        Phi.StartId = Phi.EstId;
    else
        Phi.StartId = Phi.EstId - Phi.SearchRes;
        end
    end
    
    fprintf('Phi.SearchRes: %i\n', Phi.SearchRes);
    
    if(Theta.StartId <= 0)
        Theta.StartId = Theta.Length + Theta.StartId; %(+ da Theta.StartId nun negativ)
    end
    
    for AngleCount = 0:NumOfSearchAngles-1 % NumOfSearchAngles = 3/Search
        fprintf('--------------- SEARCH LOOP %i -------\n',AngleCount+1);
        Theta.Idx = Theta.StartId + AngleCount*Theta.SearchRes;
        fprintf('Theta Index: %i/%i\n', Theta.Idx, Theta.Length);
        
        Phi.Idx = Phi.StartId + AngleCount*Phi.SearchRes;
        fprintf('Phi Index: %i/%i\n', Phi.Idx, Phi.Length);
        
        if(Theta.Idx > Theta.Length)
            Theta.Idx = Theta.Idx - Theta.Length;
        end
        
        disp('----------------');
        fprintf('Theta: %i\n', Theta.LUT( Theta.Idx ));
        fprintf('Phi: %i\n', Phi.LUT( Phi.Idx ));
    end
    
    % DEBUG
    Theta.EstId = find(Theta.LUT==input('Enter Theta.est:'));
    Phi.EstId = find(Phi.LUT==input('Enter Phi.est:'));
end

%}

%% PLOT det( Ra(p) ) against Azimuth and Elevation
% figure(667);
% mesh( Theta.Min:Theta.Res:Theta.Max, Phi.Min:Phi.Res:Phi.Max, det_Ra_p(1:Phi.Length,1:Theta.Length) ) ; figure(gcf);
% xlabel('Azimuth [°]');
% ylabel('Elevation [°]');
% zlabel('det(Ra(p))');







