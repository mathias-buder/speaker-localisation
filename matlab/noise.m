N = 48000;
n = 1:N;
n_xx = -N+1:N-1;
N_xx = length(n_xx);


fa = 48000;

df_n = fa/N;

var = 5;

nn = sqrt(var) * randn(1, N); 

figure(100);
plot(n, nn), grid;
title('Noise x(n)');

figure(101);
xx = 1/N_xx * xcorr(nn, nn);
plot(n_xx, xx), grid;
title('AKF x(n)');

figure(103);
XX = 1/N_xx * fft(xx, N_xx);
stem(-N/2*df_n:df_n/2:(N/2-1)*df_n, fftshift(abs(XX))), grid;
title('PSD x(n)');


load('BPF_SpartialAliasing.mat'); % Fstop1 = 200, Fass1 = 300, Fstop2 = 3000, Fass2 = 3100, dämpfung: 80 80, fs=48000
freqz(BPF_SpartialAliasing,1);
nn_fil = filter(BPF_SpartialAliasing, 1 , nn);
figure(104);
plot(n, nn_fil), grid;
title('Noise x(n) filterd');



figure(105);
xx_fil = xcorr(nn_fil, nn);
plot(n_xx, xx_fil), grid;
title('AKF x(n) filterd');
 
figure(106);
XX_fil = 1/N_xx * fft(xx_fil, N_xx);
stem(-N/2*df_n:df_n/2:(N/2-1)*df_n, fftshift(abs(XX_fil))), grid;
title('PSD x(n) filterd');
ylabel('var');
xlabel('frequancy [Hz]');
 
