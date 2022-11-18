function savePDF(figureHandle, fileName)
    
    %% Select directory
    path = GetPathToFolder('Masterarbeit');
    filePath = [path 'Matlab' filesep 'PDF-Figures'  filesep fileName '.pdf'];
    
    %% centimeters units
    X = 12;                     % width
    Y = 12;                     % hight
    xMargin = -0.2;             % left/right margins from page borders
    yMargin = -0.3;             % bottom/top margins from page borders
    xSize = X - 2*xMargin;      % figure size on paper (widht & hieght)
    ySize = Y - 2*yMargin;      % figure size on paper (widht & hieght)
    
    %% figure size printed on paper   
    set(figureHandle, 'PaperUnits','centimeters')
    set(figureHandle, 'PaperSize',[X Y])
    set(figureHandle, 'PaperPosition',[xMargin yMargin xSize ySize])
    set(figureHandle, 'PaperOrientation','portrait')
    
    %% Save file to directory
    saveas(figureHandle, filePath, 'pdf'); 
    
end