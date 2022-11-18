function [ y_m_crop_real ] = delaySig(x, m)
%DELAYSIG Delay Signalvector
%   DELAYSIG(X,M) returns a delayed version of vector x by 
%   m sanples using the fouriertransformation correspondence
%   x(n-m) <--> X(k)*exp(-j*2*pi*m*k/N). To force the output
%   vector y to be real either with odd or even signel length
%   the input vector x is made even by mirroring it against
%   the y-axis.
%
%   Editor : Mathias Buder
  
%%   Durch die Verdopplung des Signals mit der Spiegelung wird dafür gesorgt,
%   dass auch bei nicht-ganzzahligen Verzögerungen das Signal reell bleibt.
%   Vorlage von Hrn Svg.
%   Bsp.:
%   [ y_m_crop_real ] = delaySig(x, 3)
%   y_m_crop_real kommt wird um 3 Samples Verzoegert, kommt also später


%% CHECK SIGNAL
[row, column] = size(x);
if row ~= 1
    error('x has to be a row vector')
end

%% MAKE SIGNAL EVEN BY MIRRORING IT AGAINST THE Y-AXIS
g = [x x(length(x):-1:1)];

%% TRANSFORM IT TO FREQUANCY-DOMAIN USING FFT
G = fft(g);

%% COMPLEX PHASE TO APPLY TIME-SHIFT-THEOREM
N = length(G);                  % fft points
k = (0:N-1);                    % frequancy vector
W_m = exp(1i*2*pi*k/N).^(m);   % complex phase
G_m = G .* W_m;                 % shifted frequncy response

%% TRANSFORM BACK IN TIME-DOMAIN
y_m = ifft(G_m);
% crop length of y_m to original length of x
y_m_crop = y_m(1:length(x));
% force y to be real
y_m_crop_real = real(y_m_crop);
end





