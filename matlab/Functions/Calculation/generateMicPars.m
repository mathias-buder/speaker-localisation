function [ B ] = generateMicPars( N )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


M = (N-1)*N/2;
L = length(['M' num2str(N-1) ' -> M' num2str(N) ]);
B = zeros (M,L);
B = char(B);
i = 1;
j = 2;
k = 1;
J = 2;

while(k<=M)
    
    M1 = num2str(i);
    M2 = num2str(j);

    B(k,:) = ['M' M1 ' -> M' M2];
    
    k = k+1;
    
    if (j==N)
        J = J+1;
        j = J;
        i = i+1;
    else
        j=j+1;
    end
end


end

