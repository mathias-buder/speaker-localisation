function [ EDMA ] = CalcAngleRef(Source, EDMA, y_t)

    [non, AngleLen]=size(Source.Angle);
    len = length(y_t(1,:))/AngleLen;
    StepLen = ceil(len/EDMA.N);

    EDMA.Phi = zeros(1,EDMA.NumOfSim);
    EDMA.Theta = zeros(1,EDMA.NumOfSim);
    
    j=1;
    for i = 1:EDMA.NumOfSim       
        EDMA.Phi(i) = Source.Angle(1,j);
        EDMA.Theta(i) = Source.Angle(2,j);
        if(~mod(i ,StepLen))
            j = j + 1;
        end
    end

end