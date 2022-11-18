function [ Aline ] = RunAcousticCyl_OilDroplet()
% SoundSim - Cylindrical 2.5D Acoustic Simulation - For Academic Use Only
% -------------------------------------------------------------------------------------
% Limited Feature Beta Release of SoundSim's 2.5D Acoustic Engine (www.SoundSim.com)
% Please Send all Questions, Suggestions, and Comments to kevinrudd@SoundSim.com
%
% No Error Checking Yet!  Using incorrect parameters can cause simulations to become unstable
% More documentation will be coming soon, until then email us with any concerns
% -------------------------------------------------------------------------------------
% 5 MHz acoustic reflection from an oil droplet in water.  The transducer is 
% 2mm in diameter and emits a 5 cycle 5MHz wave that reflects from a 1.5mm diameter 
% oil droplet.  The returned Aline variable is the pressure amplitude recorded by 
% the transducer.  

% Transducer Parameters
%-------------------------------------------------------------------------
p.tfreq  = 5000000;    % transducer frequency in Hz  
p.trad   = 0.001;      % transducer radius in meters (< rsize)
p.pulsecycles = 5;     % number of cycles in the initial tone burst  

% Sphere Scatterer Parameters
%-------------------------------------------------------------------------
p.scat_zpos = 0.005;   % z position of sphere scatter in meters (< zsize)
p.scat_rad  = 0.00075; % radius of sphere scatterer            (< rsize)
p.scat_c    = 1740;    % sound of speed in scatterer (m/s)
p.scat_d    = 870;     % density of scatterer        (kg/m^3)

% Simulation Space Parameters
%-------------------------------------------------------------------------
p.zsize = 0.01;        % z-spatial size in meters
p.rsize = 0.005;       % r-spatial size in meters
p.tsize = 0.000008;    % time length of simulation in seconds

p.c    = 1560;         % speed of sound in medium (m/s)
p.den  = 1058;         % density (kg/m^3)

% Other Parameters
%-------------------------------------------------------------------------
p.plotevery = 10;     % plots the pressure field every <plotevery> timesteps
p.abc       = 20;     % absorbing boundary width (at max r and z)

p.cmax =  1800000;    % these parameters normalize the color scale of the pcolor plots
p.cmin = -1800000;    % called using caxis([p.cmin p.cmax])
                      

% Run the simulation
Aline = SoundSim_AcousticEngineCyl( p )