% animations of a acoustic monopole
[theta,r] = meshgrid(0:pi/20:2*pi,0.005:pi/40:14*pi);
[x,y] = pol2cart(theta,r);
%pressure = (100/8)*exp(1i*(0-r))./r;
pressure = exp(1i*(0-r))./r;
% 100/8 is just to adjust colour scheme rpressure = real(pressure);
% taking the real part of the pressure surf(x,y,rpressure);
axis([-30 30 -30 30]);
caxis([-1 1]);
shading interp
colorbar
k = 1000;
M=moviein(k);


% a structure moviein is created set(gca, 'NextPlot','replacechildren')
for ii = 1:k
    [theta,r] = meshgrid(0:pi/20:2*pi,0.005:pi/80:14*pi);
    [x,y] = pol2cart(theta,r);
    pressure = (100/8)*exp(1i*(ii*pi/5-r))./r;
    rpressure = real(pressure);
    surf(x,y,rpressure);
    view([30,30]);
    axis([-30 30 -30 30]);
    caxis([-1 1]);
    shading interp
    colorbar
    M(:,ii) = getframe;
end

movie(M,1,15)
% this plays the movie with 15 frames per sec
movie2avi(M,'mymovie')
% it will make a file mymovie which can be played in any player
