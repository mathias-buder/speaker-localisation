function [ m ] = CalcMicMatrix (D, r , a, N)
    %% Calculate Microphone matix m [x_n y_n z_n] of size 3xN with n=1...N
    % according to elevation and azimuth angle given by matix D
    m = zeros(3,N);
    for i=1:N
        m(:,i) = calcMicVec( D(:,i),r,a );
    end
end