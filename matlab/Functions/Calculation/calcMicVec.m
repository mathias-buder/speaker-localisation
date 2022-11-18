%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Name:   Mathias Buder
%   Date:   26.11.2012
%   
%   DESCRIPTION
%       Returns 3-dimensional milrophone vector according to elevation,
%       azimuth angle and sphare radius.
%
%   PARANETERS:
%       MicAngleVec: Angelvecor of mikrophone [elevation azimuth]   
%       r: Sphere radius
%       a: Microphone hole radius
%    
%
%   Changelog:
%   
%   10.01.2013  :   Created
%   13.02.2013  :   Changed angle refarance (to x-axise)
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function M = calcMicVec ( MicAngleVec, r, a )
    
    % OLD
    % calculate distance loss caused by microphone holes
    % h = r - sqrt(r^2 - a^2);
    % r = r-h;

    % coordinat Matrix M defined by elevation and azimuth angle
    M = r * [  cos(deg2rad(MicAngleVec(1)))* ... 
               cos(deg2rad(MicAngleVec(2))); ...
               cos(deg2rad(MicAngleVec(1)))* ...
               sin(deg2rad(MicAngleVec(2))); ...
               sin(deg2rad(MicAngleVec(1)))    ];
end