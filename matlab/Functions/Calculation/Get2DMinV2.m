function [ Phi_Est, Theta_Est ] = Get2DMinV2( det_Ra_p )

    % Do 2D-Minimum search
    [minColVal, minColIdx] = min( det_Ra_p );
    [minRowVal, minRowIdx] = min(minColVal);

    minVal = minRowVal;
    minValIdx = [minColIdx(minRowIdx), minRowIdx];
    
    Phi_Est = minValIdx(1);
     Theta_Est = minValIdx(2);
end