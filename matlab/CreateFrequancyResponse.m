


%% SELECTION OF RECORDED FILE
Path = GetPathToFolder('Masterarbeit');
PathToRealFiles = [Path 'Matlab' filesep 'TI_DSP' filesep 'Recorded'];
ListOfRealFiles = dir([PathToRealFiles filesep '*.mat']);
NumOfRealFiles = length(ListOfRealFiles);


fprintf('Please select one of the %i recorded file(s):\n', NumOfRealFiles);
disp('------------------------------------------------------------------');
for Count = 1:NumOfRealFiles
    fprintf('[%i] %s\n', Count, ListOfRealFiles(Count).name);
end
disp('------------------------------------------------------------------');

RecordedFileNum = inputs('Select file :', 1);
FileName = ListOfRealFiles(RecordedFileNum).name;
fprintf('Loading file %s ...\n', FileName)
load(ListOfRealFiles(RecordedFileNum).name);
fprintf('File %s loaded!\n', FileName);


[N_Mic, N_Block] = size(y_t);
figure;
plot(1:N_Block, y_t(1,:)),grid

N_Start = 40710;



Block = N_Start:N_Block;
len = length(N_Start:N_Block);

y_t_cut = y_t(:,Block);

figure;
plot(y_t_cut(1,:)),grid


y_t_impuls = diff(y_t_cut);
figure;
plot(y_t_impuls(1,:)),grid

FreqResponse = fft(y_t_impuls(1,:));


plot(abs(FreqResponse))



