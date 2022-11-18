%% ArrayMeasuring.m
%
%    Author     :  Mathias Buder
%    Date       :  23.07.2013

% This file reads the .mat file produced by the java GUI and displays the
% result.

%% Clear and close all
close all;
clear all;
clc;
CurrentFileName = [mfilename() '.m'];

disp('--------------------------------------------------');
fprintf('%s is running ...\n', CurrentFileName);
disp('--------------------------------------------------');
disp('DISCRIPTION:');
disp('TODO....');
disp(' ');

% Font size for figures
FigFontSize = 12; 

Path = GetPathToFolder('Masterarbeit');
PathToMeasuringFiles = [Path 'Matlab' filesep 'MeasuringFiles'];
ListOfMeasuringFiles = dir([PathToMeasuringFiles filesep '*.mat']);
NumOfMeasuringFiles = length(ListOfMeasuringFiles);

%% Select audio file
ListOfSelectedFiles = ListOfMeasuringFiles;
fprintf('Please select one of the %i available file(s):\n', NumOfMeasuringFiles);
for Count = 1:NumOfMeasuringFiles
    fprintf('[%i] %s\n', Count, ListOfMeasuringFiles(Count).name);
end
        
% Reset simulation flag
SelSimFileFlag = 0;

while(1)
    % Select simulation file
    SimFile = inputs('Select file:', 1);
    if(SimFile <= length(ListOfSelectedFiles) && SimFile ~= 0 )
        
        FileName = ListOfSelectedFiles(SimFile).name;
        fprintf('Loading file %s ...\n', FileName)
        load(FileName);

        % Check selected file
        % SelSimFileFlag = inputs('Use selected file? (0):No (1):Yes', 1);
        SelSimFileFlag = 1;
        if(SelSimFileFlag)
            break;
        end
    else
        fprintf('Filenumber %i is not specified!\n', SimFile);
    end 
end

%% Select audio type
SoundFileName = 'Original.wav';
[waveData, fa] = audioread( SoundFileName ); 

if( strcmp(audioType, 'MALE') )
    y_t = waveData(:,1);
else if( strcmp(audioType, 'FEMALE') )
    y_t = waveData(:,2);
    else
        error('Audio type not specified');
    end
end



%% Create figures
h1 = figure(100);
set(h1, 'Position', [500 500 450 400]);
subplot(2,1,1);
plot(rad2deg(phi),'.-b');
grid;
hold on;
plot([1 100], [anglesSetUp(1) anglesSetUp(1)],'Color','m')
hold off;
ylabel('$\hat\phi~/~^\circ$','Interpreter','latex','FontSize',FigFontSize);
xlabel('Messung', 'Interpreter','latex','FontSize',FigFontSize);
axis([1 100 -90 90]);
%title(FileName, 'Interpreter','none');

subplot(2,1,2);
stem(rad2deg(theta),'.-b');
grid;
hold on;
plot([1 100], [anglesSetUp(2) anglesSetUp(2)],'Color','m')
hold off;
ylabel('$\hat\theta~/~^\circ$','Interpreter','latex','FontSize',FigFontSize);
xlabel('Messung', 'Interpreter','latex','FontSize',FigFontSize);
axis([1 100 0 359]);

% subplot(3,1,3);
% plot(y_t);
% grid;
% ylabel('Amplitude','Interpreter','latex','FontSize',FigFontSize);
% axis([0 length(y_t) min(y_t) max(y_t)]);
% xlabel('Sample', 'Interpreter','latex','FontSize',FigFontSize);


%SaveFlag = inputs('Save figures? (0):No (1):Yes', 0);

% if( inputs('Save figures? (0):No (1):Yes', 0) )
%     
%     %% Create directory to save simulaton results
%     
%     NewDir = [Path 'Matlab' filesep 'MeasuringFiles' filesep strtok(FileName,'.')];
%     fprintf('Creating directory %s ...\n', NewDir);
%     [SUCCESS,MESSAGE,MESSAGEID] = mkdir(NewDir);
% 
%     if( SUCCESS )
%         h1 = figure(100);
%         stem(rad2deg(phi));
%         grid;
%         hold on;
%         plot(1:length(phi), anglesSetUp(1),'-x','Color','m');
%         hold off;
%         ylabel('$\hat\phi~/~^\circ$','Interpreter','latex','FontSize',FigFontSize);
%         xlabel('Values', 'Interpreter','latex','FontSize',FigFontSize);
%         axis([0 length(phi) -90 90]);
%         title(FileName, 'Interpreter','none');
%         
%         h2 = figure(101);
%         stem(rad2deg(theta));
%         grid;
%         hold on;
%         plot(1:length(phi), anglesSetUp(2),'-x','Color','m')
%         hold off;
%         ylabel('$\hat\theta~/~^\circ$','Interpreter','latex','FontSize',FigFontSize);
%         xlabel('Values', 'Interpreter','latex','FontSize',FigFontSize);
%         axis([0 length(theta) 0 359]);
%         title(FileName, 'Interpreter','none');
%         
%         
%         % Save Figures
%         disp('Saving figures ...');
%         saveas(h1, [NewDir, filesep, sprintf('Phi_%s.fig', strtok(FileName,'.'))]);
%         fprintf('Figure Phi_%s.fig saved!\n', strtok(FileName,'.'));
%         saveas(h2, [NewDir, filesep, sprintf('Theta_%s.fig',strtok(FileName,'.'))]);
%         fprintf('Figure Theta_%s.fig saved!\n', strtok(FileName,'.'));
%         
%         close(h1);
%         close(h2);
%     else
%         error('Directory %s could not be created ', NewDir);
%     end
% end

 

%if( inputs('Save as PDF ? (0):No (1):Yes', 0) )
    savePDF(h1, FileName);
%end
fprintf('%s finished !\n', CurrentFileName);










