%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Name:   Mathias Buder
%   Date:   26.11.2012
%   
%   DESCRIPTION
%       Returns distance between two Microphons according to mikrophone
%       vector and sphare radius.
%
%   PARANETERS:
%       MicAngleVec1: Angelvecor of mikrophone 1 [elevation1 azimuth1]   
%       MicAngleVec2: Angelvecor of mikrophone 2 [elevation2 azimuth2] 
%       r: Sphere radius
%       a: Microphone hole radius
%    
%
%   Changelog:
%   
%   26.11.2012  :   Created
%   30.11.2012  :   Added distance loss h according to meterial loss
%                   caused by microphon holes
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function d = getMicDistance (MicAngleVec1, MicAngleVec2, r, a)
    
    % calculate distance loss caused by microphone holes
    h = r - sqrt(r^2 - a^2);
    r = r-h;

    % coordinat Matrix M defined by elevation and azimuth angle
    M_1 = r * [cos(deg2rad(MicAngleVec1(1)))* ... 
               cos(deg2rad(MicAngleVec1(2))); ...
               cos(deg2rad(MicAngleVec1(1)))* ...
               sin(deg2rad(MicAngleVec1(2))); ...
               sin(deg2rad(MicAngleVec1(1)))];
    
    M_2 = r * [cos(deg2rad(MicAngleVec2(1)))* ...
               cos(deg2rad(MicAngleVec2(2))); ...
               cos(deg2rad(MicAngleVec2(1)))* ...
               sin(deg2rad(MicAngleVec2(2))); ...
               sin(deg2rad(MicAngleVec2(1)))];
    
    % calculate vectoe between M_1 und M_2
    M = M_1 - M_2;
    
    % calculate vector norm
    d = sqrt(sum(M.^2));
end