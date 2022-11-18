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



for phi = -90:90;
   for theta = 0:359;
  
    % Es entstehen Abweichungen beim Runden von maximal einem Sample

    %L = round( USA_Function_tau (deg2rad(phi), deg2rad(theta), Array.MicDistance, c) * fa );
    L = USA_Function_tau (deg2rad(phi), deg2rad(theta), Array.MicDistance, c);

    L_tmp = L(1:7);

    k=1;

    for i=1:7
        for j=i+1:7
            L_new(k) = L_tmp(j) - L_tmp(i);
            k=k+1;
        end
    end

    L_n = [L(1:7)' L_new]';

    L_check = [L L_n L-L_n]
    
   end
end
