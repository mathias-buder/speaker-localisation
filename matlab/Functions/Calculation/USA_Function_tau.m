function [ tau, L] = USA_Function_tau (phi, theta, A, c)
%[ f_n ] = USA_Function_phi_theta (phi, theta, D, r, a, c)
%USA_Function_phi_theta Uniform Spharical Array (approximated with 8 spatial sampling points)
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

%%
% DOA vector (pointing towards source)
d = DOA_vec(phi, theta);


% Calculate Vector L of size (N-1)*N/2x1. L represents the range difference
% between a pair af microphones. L is the projection of the vector joining
% two microphones onto the DOA vector d (inner producct / skalarprodukt).
L = A' * d;

% Calculate f_n using vilosity of propagation (in this case vilosity of
% sound) Thus, f_n represents the time differance between Microphone M_0
% and M_n in seconds according to Angle of arrival phi and theta.
tau = L/c;




end