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
%clear all;
%close all;


% Signal
s_start = 5096;
s_length = 1024;         % Length of signal slice [sample]

% Envirement
c = 343;                % velocity of sound [m/s]
SNR = 100;              % Signal-to-Nois-Ratio [dB]

% Angle according to DOA (for Testing)
phi_sig =   0;              % elevation [°] (vertical)
theta_sig = 180;              % azimutz [°] (horizotal)



%% SIGNAL TYPE
 switch ( inputs('Choose simulation signal:  Voice[0], Noise[1], Sinus[2]', 1) )
     case 0
        % Laod sample data (voiced)
        [y_t, fa] = audioread('Original.wav');

        % Use only left channel and cut out a block of 1 sec.
        if((s_start+s_length)<=length(y_t))
            y_t_cut_unfilterd = y_t(s_start:s_start+s_length-1,1)';
           % y_t_cut = filter(BP_Filter_num, 1 , y_t_cut_unfilterd);
            y_t_cut = y_t_cut_unfilterd;
        else
            error('Maximum signal length is %f sample', length(y_t))
        end
     case 1
         %Noise Signal
         fa = 48000;
         y_t_cut_unfilterd = randn(1,s_length); % var = 1
         y_t_cut_unfilterd = y_t_cut_unfilterd/max(y_t_cut_unfilterd);
         %y_t_cut = 100 * randn(1,s_length);
        load('BPF_SpartialAliasing.mat'); % Fstop1 = 200, Fass1 = 300, Fstop2 = 3400, Fass2 = 3500, dämpfung: 80 80, fs=48000
        %freqz(BPF_SpartialAliasing,1);
        % y_t_cut = filter(BPF_SpartialAliasing, 1 , y_t_cut_unfilterd);
        y_t_cut = y_t_cut_unfilterd;
        
     case 2
         f = 1000;
         fa = 48000;
         y_t_cut_unfilterd = sin(2*pi*f/fa*[1:s_length]);
 end

 
 
subplot(2,1,1)
stem(1:s_length, y_t_cut_unfilterd),grid
title('Signal - unfilterd'); 
subplot(2,1,2)
stem(1:s_length, y_t_cut),grid
title('Signal - filterd');

% Microphone Array [m]
Array.Radius = 50*10^-3;
Array.Holeradius = 0;
Array.MicAngle = rad2deg( acos(sqrt(2/3)) );



% Microphone matrix D [°] according to spharical Array
% D is of size 2xN and represents the microphone position according to
% azimuth and elevation angle.
%    m1       m2       m3       m4        m5       m6        m7        m8
 Array.MicPos = [Array.MicAngle  Array.MicAngle  Array.MicAngle  Array.MicAngle  -Array.MicAngle  -Array.MicAngle  -Array.MicAngle  -Array.MicAngle  ;  % phi
                 -45             45              135             225             -45               45               135               225            ];  % theta
 
 % Number of Microphones
 Array.NumOfMics = length( Array.MicPos );           
 N = Array.NumOfMics;
 
 
%% Calculate Microphone matix m [x_n y_n z_n] of size 3xN with n=1...N
% according to elevation and azimuth angle given by matix D
Array.MicVecor = CalcMicMatrix (Array.MicPos, Array.Radius , Array.Holeradius, Array.NumOfMics);
 
% A is of size 3x((N-1)*N/2) and represents the distance bewteen each pair of 
% microphones.
Array.MicDistance = CalcDistanceMatrix (Array.MicVecor, Array.NumOfMics);

% minimum distance between microphones
Array.MinDistance = sqrt( sum(Array.MicDistance(:,1).^2) );
Array.AngleRes = asin( c/(Array.MinDistance*fa) );


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
[y_t_Synth, L_Synth] = GenerateDelayedSignal(...
	c,...
	Array.MicDistance,...
	Array.NumOfMics,...
	deg2rad(phi_sig),...
  	deg2rad(theta_sig),...
	y_t_cut,...
 	SNR,...
	fa);

L_Synth

%{
if ( inputs('Show CCF?: Y[1] N[0]:', 0) )
    
    sigma_y = zeros(N,1);

    for k=1:N
      sigma_y(k) = 1/length(y_t_Synth) * ( y_t_Synth(k,:) * y_t_Synth(k,:)' );
      % sigma_y(k,1) = y_t(k,:) * y_t(k,:)';
    end
    
    %% TEST FUNCTION "GenerateDelayedSignal"
    m = zeros(((N*N)-N)/2,1);
    n = -length(y_t_Synth):length(y_t_Synth)-1;
    CC = zeros(((N*N)-N)/2, 2*length(y_t_cut));
    k=1;
    
    for j=1:N-1
        for i=(j+1):N
            CC(k,:) = 1/length(y_t_Synth) * ( FXcorr(y_t_Synth(j,:), y_t_Synth(i,:), 2*length(y_t_Synth) ) );
            % CC(k,:) = ( FXcorr(y_t_Synth(i,:), y_t_Synth(j,:), 2*length(y_t_Synth(1,:))) );
            subplot(2,1,1);
            stem(n,CC(k,:)),grid;
            title(sprintf('y_t_Synth(%i,:),y_t_Synth(%i,:)',i,j));
            CC(k,:) = CC(k,:) / sqrt(sigma_y(j) * sigma_y(i));
            subplot(2,1,2);
            stem(n,CC(k,:)),grid;
            title(sprintf('y_t_Synth(%i,:),y_t_Synth(%i,:) - Norm',i,j));
            
            [Y,I] = max(CC(k,:));
            m(k) = I-length(n)/2-1;
            k=k+1;
            pause();
        end
    end   
end
%}
             
%% structure to handle values according to Theta and Phi
% Theta
Theta.Res = Array.AngleRes;
Theta.Min = 0;                % Steering range
Theta.Max = 2*pi;              % Steering range
Theta.LUT = Theta.Min:Theta.Res:Theta.Max; % Look-Up-Table-Theta
Theta.Length = length(Theta.LUT);
                                                     
% Phi
Phi.Res = Array.AngleRes;
Phi.Min = -pi/2;
Phi.Max = pi/2;
Phi.Half = 0:Phi.Res:Phi.Max; % funktioniert so nich wenn Suchbereich eingeschränkt werden soll
Phi.LUT = [(-1) * Phi.Half(length(0:Phi.Res:Phi.Max):-1:2) 0:Phi.Res:Phi.Max]; % Angel LUT-Phi
Phi.Length = length(Phi.LUT);
% 
% 
%% Calculate Cross-Correlations
det_Ra_p = MCCC_8MicsV2( y_t_Synth, length(y_t_Synth), Phi, Theta, fa, Array.MicDistance, c, deg2rad(phi_sig), deg2rad(theta_sig) );


%% PLOT det( Ra(p) ) against Azimuth and Elevation
figure(101);
mesh( rad2deg(Theta.LUT), rad2deg(Phi.LUT), det_Ra_p(1:Phi.Length,1:Theta.Length) ); figure(gcf);
xlabel('$\hat\theta~/~^\circ$', 'Interpreter','latex','FontSize', 12);
ylabel('$\hat\phi~/~^\circ$', 'Interpreter','latex','FontSize', 12);
zlabel('$\det(R_a(p))$', 'Interpreter','latex','FontSize', 12');


figure(102);
mesh( rad2deg(Theta.LUT), rad2deg(Phi.LUT), 10*log10(det_Ra_p(1:Phi.Length,1:Theta.Length)) ); figure(gcf);
xlabel('$\hat\theta~/~^\circ$', 'Interpreter','latex','FontSize', 12);
ylabel('$\hat\phi~/~^\circ$', 'Interpreter','latex','FontSize', 12);
zlabel('$10 \cdot \log_{10}\det[R_a(p)]$', 'Interpreter','latex','FontSize', 12);

