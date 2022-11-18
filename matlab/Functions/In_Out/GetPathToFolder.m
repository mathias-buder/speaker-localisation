function [ CurrentPathToBreakPoint ] = GetPathToFolder( Folder )
    remain= pwd;
    BreakPoint = Folder;
    
    if(~strcmp(getenv('OS'), 'Windows_NT'))
        CurrentPathToBreakPoint = filesep;
        
        while(1)
        [token, remain] = strtok(remain, filesep);
        
        CurrentPathToBreakPoint = [CurrentPathToBreakPoint token filesep];
        
        if(strcmp(token, BreakPoint))
            break;
        end 
    end
        
    else
        CurrentPathToBreakPoint = '';
        
        while(1)
        [token, remain] = strtok(remain, filesep);
        
        CurrentPathToBreakPoint = [CurrentPathToBreakPoint token filesep];
        
        if(strcmp(token, BreakPoint))
            [token CurrentPathToBreakPoint] = strtok(CurrentPathToBreakPoint, filesep);
            break;
        end 
    end
        
    end
    
    
end