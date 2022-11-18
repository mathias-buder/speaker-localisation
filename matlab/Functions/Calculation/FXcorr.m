function [ Xcorr ] = FXcorr( sig_1, sig_2, N )
%function [ CC ] = fcc( sig_1, sig_2, N )
%FCC Discrete Fast Cross-Correlation
%   FCC(X,Y,N) returns the cross-correlation between signal vector X and
%   vecot Y using fft-algorithem. Parameter N is the fft length defined 
%   with N = 2^p with p = 1,2,...,L (RADIX-2). Both signal vectors have
%   to be the same length. 
%
%   Author : Markus Müller
%   Editor : Mathias Buder


%% DEBUG FUNCTION
%{
close all;
x = [0 0 0 0 6 0 0 0]; % N=8
y = [1 0 0 0 0 0 0 0];
sig_1 = x;
sig_2 = y;
N = 2*length(sig_1);
%}

%% CHECK SIGNAL LENGTH
% Check signal length maching to FFT lenght N
if (2*length(sig_1)) ~= N
    error(['N has to be double size, ',...
    'Signal length (sig_1): ' num2str( length(sig_1)),...
    ', FFT length: ' num2str(N) ]);
end
if (2*length(sig_2)) ~= N
    error(['Error: ',...
    'FFT has to be double size ',...
    'Signal length (sig_2): ' num2str( length(sig_2)),...
    ' FFT length: ' num2str(N) ]);
end

%% ZEROPADDING
% Sinc the transformation into frequancy-domain using DFT is producing 
% periodic repetitions in time-domain, both signals with length M have to 
% be zeropadded to the length 2*M (Not 2*M-1 because the FFT-lenght N for
% the Radix-2-Algorithem is defined with N = 2^p with p = 1,2,...,L). 
% This will avoid the overlapping effect coused by successiv shifts to one
% of the signals in time-domain which is also called cyclic convolution
% (For more details see "Signale und Systeme",Martin Werner, S214-222).

sig_1 = [sig_1 zeros(1,length(sig_1))];
sig_2 = [sig_2 zeros(1,length(sig_2))];

%% TRANSFORMATION INTO FREQUANZY-DOMAIN USING FFT-ALGORITHEM (KOMPLEX)
Y_sig_1 = fft(sig_1,N);
Y_sig_2 = fft(sig_2,N);

% Calcualting correlation product by multiplying signal 1 with the
% complex conjugate of signal 2
Y_mul_complex = Y_sig_1 .* conj(Y_sig_2);

% Computing GCC-PHAT
%Y_mul_complex = Y_mul_complex ./ abs(Y_sig_1 .* conj(Y_sig_2));

%% TRANSFORMATION BACK IN TIME-DOMAIN USING FFT-ALGORITHEM (NOT IFFT)
% According to the usage fo FFT the fist vector element will be zero
% and has to be ignored. In order to reduce processing time the scaling-
% factor 1/N which is used to equalize the FFT gain will be omitted.

%y_mul_complex_unsort_noShift = 1/N * fft(Y_mul_complex);


% shift zero-correlation component to center of time axis
%y_mul_complex_unsort = fftshift(y_mul_complex_unsort_noShift);

% Coss-Correlation has to be real
%y_mul_unsort = real(y_mul_complex_unsort);

% Resort correlation vector according to FFT-Algorithem
% First vector elemet is located right, thefolowing elements have to be 
% resorded in reverse order.
%Xcorr = [y_mul_unsort(1) y_mul_unsort(length(y_mul_unsort):-1:2)];
% Xcorr = y_mul_unsort(length(y_mul_unsort):-1:2);

Xcorr = real(fftshift(ifft(Y_mul_complex)));

%end

%{
figure(100);
k = -N/2+1:1:N/2-1;
stem(Xcorr),grid
% title(sprintf('CC using FFT with length %i', length(CC)));


figure(101);
xcc = xcorr(sig_1,sig_2);
stem(xcc),grid
% axis([0 length(xcc)-1 0 max(xcc)])
title(sprintf('CC using xcorr with length %i', length(xcc)));
%}
end
