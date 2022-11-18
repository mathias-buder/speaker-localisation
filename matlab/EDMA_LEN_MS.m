fs = 48000;
N_EDMA = 1024;
Ts = 1/fs;
T_EDMA_MS = Ts*N_EDMA*10^3;

fprintf('EDMA length at fs=%1.2f -> %1.2f ms, Fs_Graph %1.2f\n',fs, T_EDMA_MS, fs/N_EDMA);



