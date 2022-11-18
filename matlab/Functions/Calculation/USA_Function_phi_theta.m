function [ phi_est, theta_est ] = USA_Function_phi_theta (L, A, c, fa)
%USA_Function_phi_theta Uniform Spharic Array
%   USA_Function_phi_theta returns the estimeted azimuth theta_est und
%   elevation phi_est according to the estimeted DOA-vector d_est of size
%   3x1.

%
%            | cos(phi_est) cos(theta_est) |         | x |
%   d_est =  | cos(phi_est) sin(theta_est) |      =  | y |
%            | sin(phi_est)                |3x1      | z |
%
%
%   L:  relative SDOA-Vector of size Mx1
%   A:  Microphone matrix of size 3xM
%   c:  Propagation vilocity
%
%   Author : Mathias Buder

%%

% Calculate Vector d_est of size 3x1. d_est represents the estimated
% DOA-Vector.
d_est = (inv(A*A')*A) * L * c* 1/fa;


phi_est = rad2deg( asin( d_est(3)) );
% theta_est = rad2deg( atan( d_est(2)/d_est(1) ) );
theta_est = rad2deg( acos( d_est(1)/cos(phi_est) ) );


end