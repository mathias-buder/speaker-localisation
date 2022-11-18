clear

alpha_1 = 0.6;
alpha_2 = 0.8
T = 2;

X=-2.6:0.001:3;
F1=alpha_1 * (abs(X)<=T/2);
F2=alpha_2 * (abs(X)<=T/2);
 
[tmp zero_offset] = min(abs(X));
 
SyncFrames=[1 round(18.67*(1:numel(X)))];
integral=nan(size(X));
frame=1;
frameStep = 3;

figure(100);

for offset_i=1:numel(X);
  offset=X(offset_i);
  shift=offset_i-zero_offset;
  F2_shifted = circshift(F2, [0 shift]);
  product = F2_shifted.*F1;
  integral(offset_i) = sum(product)/numel(X)*(X(end)-X(1));
 
    if offset_i==SyncFrames(frame)
        frame=frame+frameStep;
        area(X, product, 'facecolor', 'yellow');
        hold on
        plot(X, F1, 'b', X, F2_shifted, 'r', X, integral, 'k', [offset offset], [0 2], 'k:')
        hold off
        axis image
        axis([-2.1 2.1 0 (alpha_1 * alpha_2)*T])
        xlabel('\tau & t');
        grid on
        legend('Area under f(\tau)g(t-\tau)', 'f(\tau)', 'g(t-\tau)', '(f\astg)(t)');
        %print('-dpng','-r72',sprintf('tmp/conv_box_box_%06d.png', offset_i));
        drawnow
    end
end