function [Phi, Theta] = SearchAndFind (R_xy, Phi, Theta, A, fa, c)

count = 0;

for Count=0:R_xy.NumOfLoops
    % disp('+------------------------------------+')
    % fprintf('+-------------- LOOP %i --------------+\n',Count + 1);
    % disp('+------------------------------------+')
    Theta.SearchRes = ceil( Theta.Length/(3*2^Count) );
    Theta.StartId = Theta.EstId - Theta.SearchRes;
   
    if(Theta.StartId < 1)       % Matlab-Array starts at Idx=1, C-Array at Idx=0
    %if(Theta.StartId <= 0)
        Theta.StartId = Theta.Length + Theta.StartId; %(+ da Theta.StartId nun negativ)
    end
    
    % fprintf('Theta.SearchRes: %i\n', Theta.SearchRes);
    
    Phi.SearchRes = floor( Phi.Length/(4*2^Count) ); % eventuell mit Cast in C
    
    if(Phi.EstId >= Phi.Length)
        Phi.StartId = Phi.EstId - 2*Phi.SearchRes;
    else if(Phi.EstId <=1)
            Phi.StartId = Phi.EstId;
        else
            Phi.StartId = Phi.EstId - Phi.SearchRes;
        end
    end
    
    
    if (Phi.SearchRes < 1)
         Phi.NumOfSearchAngles = 1;
    end
    
    % Phi.StartId = Phi.MidId - Phi.SearchRes;
    
    % fprintf('Phi.SearchRes: %i\n', Phi.SearchRes);
    
    
    
    for AngleCount = 1:Theta.NumOfSearchAngles % NumOfSearchAngles = 3/Search
        % fprintf('--------------- SEARCH LOOP %i -------\n',AngleCount+1);
        Theta.Idx(AngleCount) = Theta.StartId + (AngleCount-1) * Theta.SearchRes;
        % fprintf('Theta Index: %i/%i\n', Theta.Idx(AngleCount+1), Theta.Length);
        
       % Phi.Idx(AngleCount) = Phi.StartId + (AngleCount-1) * Phi.SearchRes;
        % fprintf('Phi Index: %i/%i\n', Phi.Idx(AngleCount+1), Phi.Length);
        
        if(Theta.Idx(AngleCount) > Theta.Length)
            Theta.Idx(AngleCount) = Theta.Idx(AngleCount) - Theta.Length;
        end
    end
    
    
    
    for AngleCount = 1:Phi.NumOfSearchAngles
        Phi.Idx(AngleCount) = Phi.StartId + (AngleCount-1) * Phi.SearchRes;
        % fprintf('Phi Index: %i/%i\n', Phi.Idx(AngleCount+1), Phi.Length);
    end
    
    
    
    
    
    
    [ det_Ra_p, count ] = Calc_det_Ra_p ( R_xy, Phi, Theta, A, fa, c, count );
    
    % DEBUG
%     disp('-------------------------');
%     fprintf('Loops: %i\n', count);
%     disp('-------------------------');
    
    
    [ Phi, Theta ] = Get2DMin( det_Ra_p, Phi, Theta );
    
    %[ minVal, minValIdx ] = Get2DMinV2( det_Ra_p );
    
    
    %fprintf( 'MinVal: %3.3e, MinValIdx: %2.3i, %2.3i\n', minVal, minValIdx(1), minValIdx(2) );
    
    %fprintf('Phi: Id: %i, Angle: %i°\n', Phi.EstId, Phi.LUT(Phi.EstId));
    %fprintf('Theta: Id: %i, Angle: %i°\n', Theta.EstId, Theta.LUT(Theta.EstId));
end

% Get Angle in Degree
Phi.Est = Phi.LUT(Phi.EstId);
Theta.Est = Theta.LUT(Theta.EstId);

end