function [ c_air ] = CalcCAir( temperature )
k = 1.402;                % Adiabatenexponenten
R = 8.3144621;            % Universelle Gaskonstante
T = 273.15 + temperature; % Temperatur in Kelvin
M = 0.02896;              % mittleren Molmasse

c_air = sqrt( k*R*T / M );

end