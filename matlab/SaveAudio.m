% load handel.mat

filename = 'Record_Theta_0_Phi_0_8kHz.wav';
Fs = 8000;
audiowrite(filename,y,Fs);
clear y Fs