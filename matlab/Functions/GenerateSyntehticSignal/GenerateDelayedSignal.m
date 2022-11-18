function [ y_t_Synth, L] = GenerateDelayedSignal(...
    c,...
    A,...
    N,...
    phi,...
    theta,...
    y_t,...
    SNR,...
    fa)
%function [ y_t_Synth ] = GenerateDelayedSignal(...
%    c,...
%    A,...
%    N,...
%    phi,...
%    theta,...
%    y_t,...
%    SNR,...
%    fa)
%
%   GenerateDelayedSignal creates a vector of size NxR where R represents
%   the length of signal vector y_t. Each row N>1 is delayed according to
%   azimuth and elevation (N=1 is the reference microphone).
%
%
%    c          :  propagation vilosity [m/s]
%    A          :  Microphone distance matrix 3xN [m]
%    N          :  Number of Microphones
%    theta      :  Azimuth [°]
%    phi        :  Elavation [°]
%    y_t        :  Signalvektor (row vector)
%    SNR        :  Signal-to-Noise-Ratio [dB]
%    fa         :  Samplig frequancy [Hz]
%
%
%    Author     :  Mathias Buder
%    Date       :  30.01.2013



%% Calculate relative delay between Microphone M_0 and M_n
tau_vec = USA_Function_tau ( phi, theta, A, c );


%% Calculate delay in samples (rounded)
L = round( tau_vec * fa );


%% Signal properties

% Calculate signal RMS (Root Mean Square)
signal_RMS = sqrt(1/length(y_t) * sum(y_t.^2) );
        
% Calculate noise amplitude according to given SNR and signal RMS
noise_amp = signal_RMS/( 10^(SNR/20) );


%% Create delayed Signalvectors acording to delay vector
y_t_Synth = zeros( N,length(y_t) );

% Do not delay signal at referance Microphone (channel 1)
y_t_Synth(1,:) = y_t(1,:);
for k=2:N
    y_t_Synth(k,:) = delaySig( y_t, L(k-1) );
end


%% Apply additive zero-mean uncorrelated white noise
for k=1:N
    y_t_Synth(k,:) = y_t_Synth(k,:) + noise_amp * randn(1,length(y_t_Synth));
end


end
