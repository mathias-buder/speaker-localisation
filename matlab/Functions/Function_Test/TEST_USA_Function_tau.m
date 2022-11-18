% FUNCTION TEST


% Envirement
c = 343;                % velocity of sound [m/s]

% Angle according to DOA (for Testing)
phi_1 =   48             % elevation [°] (vertical)
theta_1 = 90             % azimutz [°] (horizotal)
         

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
 
%{ 
% Mic-vector für cylindrisches Mic-Array
D = [0  0  0  0   0   0   0   0  ;  % phi
     0  45 90 135 180 225 270 315  ];  % theta
%}  
 

N = length(D);          % Number of Microphones          

% Distance matrix A [m]
% A is of size 3xN and represents the distance bewteen each pair of 
% microphones accpording to referance microphone m1.
A = calcMicMatrix ( D, r, a, N );
   

L_1 = round( USA_Function_tau(phi_1, theta_1, A, c) * fa );

[ phi_est, theta_est ] = USA_Function_phi_theta (L_1, A, c, fa)