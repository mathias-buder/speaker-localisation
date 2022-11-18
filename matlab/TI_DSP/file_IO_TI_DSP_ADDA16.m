clear
close all
disp('Enter filename');
clc
dir *.bin
filename = input('Enter filename (without extension) : ','s');
filename_bin = [filename,'.bin'];
disp(filename_bin),pause
%fid = fopen('B48_UPV_Feature_D_Mod_C6713_plus_D_Mod_PCM_EDMA_SDRAM.bin','r')
fid = fopen(filename_bin,'r');
num_val = inputs('number of values', 160000 );
[A, count] = fread(fid, 1*num_val, 'short');
fclose(fid);
size(A)
Ax = zeros(num_val,1);
Ax = A;
Fs = inputs('Fs', 32000);
plot(1:num_val, Ax),grid

Ax(1)=0;
disp('Enter ...');
pause
disp('sound(Ax/32768, Fs);');
sound(Ax/32768, Fs);
str = ['save ', filename,'.mat Ax'];
disp('writing MAT and WAV Stereo file');
pause
eval(['save ', filename,'.mat Ax']);
Ax_wav = Ax/32768;
%YY=[Ax_wav,Ax_wav];
YY = Ax_wav(1:1:length(Ax_wav));
audiowrite(YY, Fs, [filename,'.wav']);