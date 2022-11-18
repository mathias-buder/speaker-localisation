function PlotPolar (Phi, Theta, LineLength, LineWidth, FontSize )
    %% Polar plot for Phi
    subplot(2,1,1);
    h1 = polar([0 Phi],[0 LineLength], '.-b');
    title('$\hat\phi~/~^\circ$','Interpreter','latex','FontSize',FontSize);
    set(h1,'Color','red','LineWidth', LineWidth)
    text(LineLength/2*cos(Phi), LineLength/2*sin(Phi), sprintf('%1.1f°',rad2deg(Phi)), 'Color','b', 'FontSize', 13);
    %% Polar plot for Theta
    subplot(2,1,2);
    h2 = polar([0 Theta],[0 LineLength], '.-b');
    title('$\hat\theta~/~^\circ$','Interpreter','latex','FontSize',FontSize);
    set(h2,'Color','red','LineWidth', LineWidth)
    text(LineLength/2*cos(Theta), LineLength/2*sin(Theta), sprintf('%1.1f°',rad2deg(Theta)), 'Color','b', 'FontSize', 13);
end