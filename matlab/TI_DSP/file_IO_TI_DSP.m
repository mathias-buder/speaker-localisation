clear
close all
disp('Enter filename');
clc
dir *.bin
filename = input('Enter filename (without extension) : ','s');
filename=[filename,'.bin'];
disp(filename),pause
%fid = fopen('B48_UPV_Feature_D_Mod_C6713_plus_D_Mod_PCM_EDMA_SDRAM.bin','r')
fid = fopen(filename,'r');
num_val = inputs('number of values', 64000 );
[A, count] = fread(fid, 8*num_val, 'short');
fclose(fid);
size(A)
Ax = zeros(num_val,8);
for kx = 1:8
    Ax(:,kx) = A(num_val*(kx-1)+1:num_val*kx);
end;
Fs = inputs('Fs',8000);
subplot(4,1,1);
plot(1:num_val,Ax(:,1),1:num_val,Ax(:,2)),grid
subplot(4,1,2);
plot(1:num_val,Ax(:,3),1:num_val,Ax(:,4)),grid
subplot(4,1,3);
plot(1:num_val,Ax(:,5),1:num_val,Ax(:,6)),grid
subplot(4,1,4);
plot(1:num_val,Ax(:,7),1:num_val,Ax(:,8)),grid

disp('Enter ...');
pause
disp('sound(Ax(:,2)/32768, Fs);');
sound(Ax(:,2)/32768, Fs);
str = ['save ', filename,'.mat Ax'];
pause
eval(['save ', filename,'.mat Ax']);