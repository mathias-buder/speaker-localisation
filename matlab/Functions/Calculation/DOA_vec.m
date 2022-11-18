function [ d ] = DOA_vec (phi, theta)
d = [cos(phi)* ... 
     cos(theta); ...
     cos(phi)* ...
     sin(theta); ...
     sin(phi)
    ];

end