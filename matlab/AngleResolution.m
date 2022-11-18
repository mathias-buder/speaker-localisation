c = 343;
fa = 48000;
%% Microphone Array [m]
Array.Radius = 50*10^-3;
Array.Holeradius = 5*10^-3;
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



%phi = 0;
%theta = 270;

%L = USA_Function_tau (deg2rad(phi), deg2rad(theta), Array.MicDistance, c);

%L(1) % M1->M2
%L(4) % M1->M5


K_phi_theta = zeros(length(-90:90),length(0:359)); 


k=3;
filename = 'M1_M2';

i=1;
j=1;
for phi = -90:90
    j=1;
    for theta = 0:359
        L = round( USA_Function_tau (deg2rad(phi), deg2rad(theta), Array.MicDistance, c) * fa );
        K_phi_theta(i,j) = L(k);
        j=j+1;
    end
    i=i+1;
end


h1 = figure;
mesh(0:359, -90:90, K_phi_theta);
view([75 36]);
colormap(jet);
xlabel('$\theta~/~^\circ$','Interpreter','latex','FontSize',14);
ylabel('$\phi~/~^\circ$','Interpreter','latex','FontSize',14);
zlabel('$K_{\phi,\theta}$','Interpreter','latex','FontSize',14);
axis([0 350 -90 90 min(min(K_phi_theta)) max(max(K_phi_theta))]);
title('$K_{\phi}(\phi,\theta)$','Interpreter','latex','FontSize',14);


if(inputs('Save figure?',0))
saveEPSC(h1, filename);
end
