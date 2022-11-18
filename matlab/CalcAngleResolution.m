% This script calculates the angle resolution and plots the real angle
% against the sampled one


% Envirement
c = 343;                % velocity of sound [m/s]
fa = 48000;

% Sphare
r = 50*10^-3;           % radius sphare (m)
a = 5*10^-3;            % radius microphone holes (m)

% Microphone Angle
phi_mic = rad2deg( acos(sqrt(2/3)) );

% Microphone matrix D [°]
% D is of size 2xN and represents the microphone position according to
% azimuth and elevation angle.
%    m1       m2       m3       m4        m5       m6        m7        m8
D = [phi_mic  phi_mic  phi_mic  phi_mic  -phi_mic  -phi_mic  -phi_mic  -phi_mic  ;  % phi
     -45      45       135      225      -45        45       135        225      ];  % theta

N = length(D);          % Number of Microphones          

% Distance matrix A [m]
% A is of size 3xN and represents the distance bewteen each pair of 
% microphones accpording to referance microphone m1.
A = calcMicMatrix ( D, r, a, N );

B = generateMicPars( N );

% structure to handle values according to THETA and PHI  

% THETA
THETA.RESOLUTION = 0;
THETA.MIN = 0;                % Steering range
THETA.MAX = 359;              % Steering range
THETA.RANGE = length(THETA.MIN:THETA.MAX);
THETA.DELAYBOUNDS.MIN = 0;
THETA.DELAYBOUNDS.MAX = 0;


% PHI
PHI.RESOLUTION = 0;
PHI.MIN = -90;
PHI.MAX = 90;
PHI.RANGE = length(PHI.MIN:PHI.MAX);
PHI.DELAYBOUNDS.MIN = 0;
PHI.DELAYBOUNDS.MAX = 0;


MicPaar = 5;
d = sqrt(sum(A(:,MicPaar).^2));   
THETA.RESOLUTION =  round ( rad2deg( asin(c/(d*fa)) ) );
% PHI.RESOLUTION = THETA.RESOLUTION;

L = zeros(PHI.RANGE, THETA.RANGE);

j=1;
for phi = PHI.MIN:PHI.MAX
    i=1;
    for theta = THETA.MIN:THETA.MAX
        L(j,i) = (-1) * round( USA_Function_tau_single(phi, theta, A, c, MicPaar) * fa );
        i=i+1;
    end
    j=j+1;
end
    
figure(600);
imagesc(THETA.MIN:THETA.MAX, PHI.MIN:PHI.MAX, L);figure(gcf); colormap('lines');
xlabel('Azimuth [°]')
ylabel('Elevation [°]')
title(sprintf('%s, d=%f mm, fa=%i Hz', B(MicPaar,:), (d*10^3), fa));
  
    
   

%{

for k=1:((N-1)*N/2)

    MicPaar = k;
    d = sqrt(sum(A(:,MicPaar).^2));   
    % THETA.RESOLUTION =  round ( rad2deg( asin(c/(d*fa)) ) );
    % PHI.RESOLUTION = THETA.RESOLUTION;

    L = zeros(PHI.RANGE, THETA.RANGE);

    j=1;
    for phi = PHI.MIN:PHI.MAX
        i=1;
        for theta = THETA.MIN:THETA.MAX
            L(j,i) = (-1) * round( USA_Function_tau_single(phi, theta, A, c, MicPaar) * fa );
            i=i+1;
        end
        j=j+1;
    end

    imagesc(THETA.MIN:THETA.MAX, PHI.MIN:PHI.MAX, L);figure(gcf); colormap('lines');
    xlabel('Azimuth [°]')
    ylabel('Elevation [°]')
    title(sprintf('%s, d=%f mm, fa=%i Hz', B(MicPaar,:), (d*10^3), fa));
    
    
    
    % Grafik speichern
path = '/Users/Nano/Dropbox/02_Master_IuK/Masterarbeit/Matlab/Figures/save/';
saveas(gcf, [path, filesep, sprintf('Array_%s.png',B(MicPaar,:))]);
end

%}

%{
figure;
mesh(THETA.MIN:THETA.MAX, PHI.MIN:PHI.MAX, L);figure(gcf); colormap('lines');
% axis([THETA.MIN THETA.MAX PHI.MIN PHI.MAX]);
xlabel('Azimuth [°]');
ylabel('Elevation [°]');
zlabel('SDOA');
title(sprintf('Mic-Paar %i, d=%f ,fa=%i', MicPaar, (d*10^3), fa));
%}




