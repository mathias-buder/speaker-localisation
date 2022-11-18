function [ L, THETA, PHI ] = Steering_Matrix ( THETA, PHI, A, N, c, fa )
    % Calculate steering matrix for theta (and later on for phi as well)
    i=1;
    L = zeros( (N-1)*N/2, length(THETA.MIN:THETA.RESOLUTION:THETA.MAX) * length(PHI.MIN:PHI.RESOLUTION:PHI.MAX) );
    for phi = PHI.MIN:PHI.RESOLUTION:PHI.MAX
        for theta = THETA.MIN:THETA.RESOLUTION:THETA.MAX
            L(:,i) = (-1) * round( USA_Function_tau(phi, theta, A, c) * fa );
            i=i+1;
        end
    end
end