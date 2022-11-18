function [phi_est, theta_est] = GetDOA( det_Ra_p, PHI, THETA )

    % Do 2D-Minimum search
    [minColVal, minColIdx] = min(det_Ra_p);
    [minRowVal, minRowIdx] = min(minColVal);

    azimuth_Index = minRowIdx;
    elevation_Index = minColIdx(minRowIdx);
    
    % Pick DOA-Angle ou fo LUT's according to index found by 2D-Minimum
    % search
    phi_est = PHI.LUT(elevation_Index);
    theta_est = THETA.LUT(azimuth_Index);

end