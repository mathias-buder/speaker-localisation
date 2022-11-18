function [det] = det4x4(A)
%DET4x4 Determinst if Matrix with size 4x4
%   DET4x4 returns the determinant of squerd Matrix A with a size of 4.
%
%   Author : Mathias Buder
%   e-mail : mathias.buder@gmail.com

%% CHECK MATRIX SIZE
[m,n] = size(A);

if (m > 4 || n > 4 || m ~= n)
    error(sprintf('Matrix has to be of size 4x4 not %ix%i',m,n));
end

%% CALCULATE DETERMINANT
det = ...
    A(1,1) * det3x3([ A(2,2) A(2,3) A(2,4);
                      A(3,2) A(3,3) A(3,4);
                      A(4,2) A(4,3) A(4,4)]) ...
  - A(1,2) * det3x3([ A(2,1) A(2,3) A(2,4);
                      A(3,1) A(3,3) A(3,4);
                      A(4,1) A(4,3) A(4,4)]) ...
  + A(1,3) * det3x3([ A(2,1) A(2,2) A(2,4);
                      A(3,1) A(3,2) A(3,4);
                      A(4,1) A(4,2) A(4,4)]) ...
  - A(1,4) * det3x3([ A(2,1) A(2,2) A(2,3);
                      A(3,1) A(3,2) A(3,3);
                      A(4,1) A(4,2) A(4,3)]);
end


function [det] = det3x3(A)
%DET3x3 Determinst if Matrix with size 3x3
%   DET3x3 returns the determinant of squerd Matrix A with a size of 3.
%
%   Author : Mathias Buder
%   e-mail : mathias.buder@gmail.com

%% CHECK MATRIX SIZE
[m,n] = size(A);

if (m > 3 || n > 3 || m ~= n)
    error(sprintf('Matrix has to be of size 3x3 not %ix%i',m,n));
end

%% CALCULATE DETERMINANT
det = ...
    A(1,1)*A(2,2)*A(3,3) + ...
    A(1,2)*A(2,3)*A(3,1) + ...
    A(1,3)*A(2,1)*A(3,2) - ...
    A(1,3)*A(2,2)*A(3,1) - ...
    A(1,1)*A(2,3)*A(3,2) - ...
    A(1,2)*A(2,1)*A(3,3);
end