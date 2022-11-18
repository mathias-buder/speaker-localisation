%% PARAMS
len = 300;
n = 0:1:len-1;
fa = 48000;
f = 1000;

%% FUNCTIONS
noise = randn(1,len);
sinus = sin(2*pi*f/fa*n);

noise_delayed = delaySig(noise, 100);
sinus_delayed = sin(2*pi*f/fa*(n+100));

s = noise_delayed+sinus_delayed;

stem(sinus_delayed)

%% GCC
xx_noise = xcorr(noise, noise_delayed, 'biased');
h_xx_noise = figure;
stem(-length(xx_noise)/2:length(xx_noise)/2-1, xx_noise),grid;
title('$\hat R_{y_1y_2} ~ [Noise]$', 'Interpreter','latex','FontSize',12);
xlabel('$p \rightarrow$', 'Interpreter','latex','FontSize',12);

xx_sinus = xcorr(sinus, sinus_delayed, 'biased');
h_xx_sinus = figure;
stem(-length(xx_sinus)/2:length(xx_sinus)/2-1, xx_sinus),grid;
title('$\hat R_{y_1y_2} ~ [Sine]$', 'Interpreter','latex','FontSize',12);
xlabel('$p \rightarrow$', 'Interpreter','latex','FontSize',12);

%% GCC-PHAT
xx_noise_GCC = FXcorr(noise, noise_delayed, 2*len);
h_xx_noise_GCC = figure;
stem(-length(xx_noise_GCC)/2:length(xx_noise_GCC)/2-1, xx_noise_GCC),grid;
title('$\hat R^{PHAT}_{y_1y_2} ~ [Noise]$', 'Interpreter','latex','FontSize',12);
xlabel('$p \rightarrow$', 'Interpreter','latex','FontSize',12);

xx_sinus_GCC = FXcorr(sinus,sinus_delayed, 2*length(sinus));
h_xx_sinus_GCC = figure;
stem(-length(xx_sinus_GCC)/2:length(xx_sinus_GCC)/2-1, xx_sinus_GCC),grid;
title('$\hat R^{PHAT}_{y_1y_2} ~ [Sine]$', 'Interpreter','latex','FontSize',12);
xlabel('$p \rightarrow$', 'Interpreter','latex','FontSize',12);



saveEPSC(h_xx_noise, 'xx_noise');
saveEPSC(h_xx_sinus, 'xx_sine');
saveEPSC(h_xx_noise_GCC, 'xx_GCC_noise');
saveEPSC(h_xx_sinus_GCC, 'xx_GCC_sine');
