%function [ Aline ] = RunAcousticCyl_AirBubble(  )
% SoundSim - Cylindrical 2.5D Acoustic Simulation - For Academic Use Only
% -------------------------------------------------------------------------------------
% Limited Feature Beta Release of SoundSim's 2.5D Acoustic Engine (www.SoundSim.com)
% Please Send all Questions, Suggestions, and Comments to kevinrudd@SoundSim.com
%
% No Error Checking Yet!  Using incorrect parameters can cause simulations to become unstable
% More documentation will be coming soon, until then email us with any concerns
% -------------------------------------------------------------------------------------
% 5 MHz acoustic reflection from an air bubble in water.  The transducer is 
% 2mm in diameter and emis a 5 cycle 5MHz wave that reflects from a 1mm diameter 
% air bubble.  The returned Aline variable is the pressure amplitude recorded by 
% the transducer.  

% Transducer Parameters
%-------------------------------------------------------------------------
p.tfreq  = 5000;        % transducer frequency in Hz  
p.trad   = 0.3;         % transducer radius in meters (< rsize)
p.pulsecycles = 1;      % number of cycles in the initial tone burst  

% Sphere Scatterer Parameters
%-------------------------------------------------------------------------
p.scat_zpos = 1;        % z position of sphere scatter in meters (< zsize)
p.scat_rad  = 0.05;     % radius of sphere scatterer            (< rsize)
p.scat_c    = 0;        % sound of speed in scatterer (m/s)
p.scat_d    = 1800;     % density of scatterer        (kg/m^3)

% Simulation Space Parameters
%-------------------------------------------------------------------------
p.zsize = 2;            % z-spatial size in meters
p.rsize = 1;            % r-spatial size in meters
p.tsize = 0.0058;       % time length of simulation in seconds

p.c    = 343;           % speed of sound in medium (m/s)
p.den  = 1.2;           % density (kg/m^3)

% Other Parameters
%-------------------------------------------------------------------------
p.plotevery = 1;        % plots the pressure field every <plotevery> timesteps
p.abc       = 10;       % absorbing boundary width (at max r and z)

p.cmax =  300;          % these parameters normalize the color scale of the pcolor plots
p.cmin = -300;          % called using caxis([p.cmin p.cmax])
                      

% Run the simulation
Aline = SoundSim_AcousticEngineCyl(p);
axis([0.5 1.5 -0.5 0.5])
xlabel('x [m]', 'Interpreter','latex','FontSize',11)
ylabel('y [m]', 'Interpreter','latex','FontSize',11)



