function saveEPSC(figureHandle, fileName)

    path = GetPathToFolder('Masterarbeit');
    filePath = [path 'Matlab' filesep 'EPS_Figures'  filesep fileName];
    
    %set(figureHandle,'position',[0 0, 800 550]); 
    %set(figureHandle,'PaperPositionMode','Auto'); 
    saveas(figureHandle,filePath,'epsc'); 

end