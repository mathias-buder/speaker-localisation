figure(100);
axis off, axis equal
hold on;

% FIR-LP-Filter Parameters
a0 = 0.1;
a1 = 0.05;
angle_in_old = 0;
angle_in_new = -pi/2;
angle_out = 0;


%angle_out = a0 * angle_in_new + a1 * angle_in_old;
% Delay angle by one
%angle_in_old = angle_in_new;



% Low-Pass-Filter to smooth angle movement
% y_n = a0*x(n) + a1*x(n-1);
% angle_out = a0*angle_in(n) + a1*angle_in(n-1);
% With a0 = 1;
% angle_out = angle_in(n) + a1*angle_in(n-1);
% abgle_in = angle_out;






while(1)
    
    
    angle_out = angle_in_new + a1 * angle_in_old;
% Delay angle by one
    angle_in_old = angle_in_new;
    angle_in_new = angle_out;
    
    % PlotPolar (Phi, Theta, LineLength, LineWidth, FontSize)
    PlotPolar( angle_out, 0, 1, 3, 12 )
    % Flush pending graphics events
    drawnow
end
