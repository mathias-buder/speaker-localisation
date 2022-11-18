function [ A ] = CalcDistanceMatrix (m, N)
%[ f_n ] = USA_Function_phi_theta (phi, theta, D, r, a, c)
%USA_Function_phi_theta Uniform Spharic Array
%   USA_Function_phi_theta returns the relative time delay f_n between
%   Microphone M_0 and Microphone M_n according to elevation
%   (vertical - phi) and azimuth (horizontal - theta) angle of arrival.
%   Matrix D with size 2xN-1 contains the coordinates of every Microphone
%   of form
%
%   D = |phi_0   phi_1   ... phi_N-1  |
%       |theta_0 theta_1 ... theta_N-1|
%
%
%   r:  Microphone radius
%   a:  Microphone holes radius
%   c:  Propagation vilocity
%
%   Author : Mathias Buder

% %% Calculate Microphone matix m [x_n y_n z_n] of size 3xN with n=1...N
% % according to elevation and azimuth angle given by matix D
% m = zeros(3,N);
% for i=1:N
%     m(:,i) = calcMicVec( D(:,i),r,a );
% end


% Calculate Matrix A of size 3xM, each column represants a vector joining
% a pair of microphones. All possible pairs are given with M = (N 2).

% ALL PAIRS
% Microphone pairs

M = (N-1)*N/2;
i = 1;
j = 2;
k = 1;
J = 2;
A = zeros(3,M);

while(k<=M)
    A(:,k) = m(:,i) - m(:,j);
    
    % fprintf('m(%i) -> m(%i) = %8.3f \n', i, j, A(:,k)'*d*10^3);
    % fprintf('m(%i) -> m(%i) \n', i, j);
    
    k = k+1;
    
    if (j==N)
        J = J+1;
        j = J;
        i = i+1;
        % fprintf('------------------------\n');
    else
        j=j+1;
    end
end



% ONLY M_0 TO M_N PAIRS

%         "0"   
%       |M_X_00   M_X_01    ... M_X_0N|
%   A = |M_Y_00   M_Y_01    ... M_Y_0N|
%       |M_Z_00   M_Z_01    ... M_Z_0N|

%{
k=1;
A = zeros(3,N);
while( k<=N )
    
    A(:,k) = m(:,1) - m(:,(k));
    
    % fprintf('m(0) -> m(%i) = %8.3f \n', k, A(:,k)'*d*10^3);
    
    k = k+1;
end

%}


%{
    i      j
m(:,1)-m(:,2)
m(:,1)-m(:,3)
m(:,1)-m(:,4)
m(:,1)-m(:,5)
m(:,1)-m(:,6)
m(:,1)-m(:,7)
m(:,1)-m(:,8) N

m(:,2)-m(:,3)
m(:,2)-m(:,4)
m(:,2)-m(:,5)
m(:,2)-m(:,6)
m(:,2)-m(:,7)
m(:,2)-m(:,8) N

m(:,3)-m(:,4)
m(:,3)-m(:,5)
m(:,3)-m(:,6)
m(:,3)-m(:,7)
m(:,3)-m(:,8) N

m(:,4)-m(:,5)
m(:,4)-m(:,6)
m(:,4)-m(:,7)
m(:,4)-m(:,8) N

m(:,5)-m(:,6)
m(:,5)-m(:,7)
m(:,5)-m(:,8)

m(:,6)-m(:,7)
m(:,6)-m(:,8) N

m(:,7)-m(:,8) N
%}
end