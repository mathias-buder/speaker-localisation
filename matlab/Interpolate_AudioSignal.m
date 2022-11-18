%% Interpolate Signal
clear
close all
disp('Enter filename');
clc
dir *.mat

r = 48/8;

Ax_intp = zeros(r*length(Ax), 8);

for i=1:8
    Ax_intp(:,i) = interp(Ax(:,i)/2^15,r);
end