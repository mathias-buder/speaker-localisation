function [ Phi, Theta ] = Get2DMin( det_Ra_p, Phi, Theta )

    % Do 2D-Minimum search
    [minColVal, minColIdx] = min(det_Ra_p);
    [~, minRowIdx] = min(minColVal);
    
    Phi.EstId = Phi.Idx( minColIdx(minRowIdx) );
    Theta.EstId = Theta.Idx( minRowIdx );
    
    
    % Phi.EstId = minColIdx(minRowIdx);
    % Theta.EstId = minRowIdx;
    
    
end