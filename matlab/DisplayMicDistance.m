


% Sphare
r = 50*10^-3;           % radius sphare (m)
c = 343;                % m/s


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
A = CalcMicMatrix ( D, r, a, N );

% Calc Tau
phi = 0;
theta = 0;

fprintf('-----------------------------------------\n');
fprintf('Phi: %i, Theta: %i\n', phi, theta);
fprintf('-----------------------------------------\n');

[ tau, L] = USA_Function_tau (phi, theta, A, c);



M = (N-1)*N/2;
B = zeros (M, 8);
B = char(B);
i = 1;
j = 2;
k = 1;
J = 2;

while(k<=M)
    
    M1 = num2str(i);
    M2 = num2str(j);

    B(k,:) = ['M' M1 ' -> M' M2];
    
    fprintf('[%2.1i] m(%i) -> m(%i) = %6.3f mm, tau = %6.3f ms \n',k , i, j, sqrt(sum(A(:,k).^2))*10^3, tau(k)*10^3);
    
    k = k+1;
    
    if (j==N)
        J = J+1;
        j = J;
        i = i+1;
        fprintf('-----------------------------------------------\n');
    else
        j=j+1;
    end
end




% Calc microphone vector
m = zeros(3,N);
for i=1:N
    m(:,i) = calcMicVec( D(:,i),r,a );
end


% Calc angle between microphone pairs
s = zeros(1,N-1);
for i=2:N
    s(i-1) = VectorAngle( m(:,1), m(:,i) );
end


% Calculate distance between microphone pairs
l = r*10^-3*s;

% Calculate time differance between microphone pairs
tau_neu = l/c;

for i = 1:N-1
    fprintf('[1 -> %i] %5.2f mm %5.2f sec\n',i, l(i), tau_neu(i));
end



