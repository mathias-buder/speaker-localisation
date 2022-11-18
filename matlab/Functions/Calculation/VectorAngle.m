function [ angle ] = VectorAngle(a ,b)
%% VectorAngle returns the angle between column vector a and column vector
% b in radiant

    angle = acos((a'*b)/(norm(a) * norm(b)));

end