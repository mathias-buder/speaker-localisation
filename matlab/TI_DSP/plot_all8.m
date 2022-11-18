close all
%NNx=(10000:10020);
first_sample = inputs('last sample', 8000);
last_sample = inputs('last sample', 8020);
NNx=(first_sample:last_sample);

figure(1);
set(gcf,'Units','normal','Position',[0.1 0.4 0.5 0.5])
k=1;
subplot(4,2,1);
plot(NNx,Ax(NNx,k),'b*-'),grid
ylabel(num2str(k));

k=2;
subplot(4,2,k);
plot(NNx,Ax(NNx,k),'b*-'),grid
ylabel(num2str(k));

k=3;
subplot(4,2,k);
plot(NNx,Ax(NNx,k),'b*-'),grid
ylabel(num2str(k));

k=4;
subplot(4,2,k);
plot(NNx,Ax(NNx,k),'b*-'),grid
ylabel(num2str(k));

k=5;
subplot(4,2,k);
plot(NNx,Ax(NNx,k),'b*-'),grid
ylabel(num2str(k));

k=6;
subplot(4,2,k);
plot(NNx,Ax(NNx,k),'b*-'),grid
ylabel(num2str(k));

k=7;
subplot(4,2,k);
plot(NNx,Ax(NNx,k),'b*-'),grid
ylabel(num2str(k));

k=8;
subplot(4,2,k);
plot(NNx,Ax(NNx,k),'b*-'),grid
ylabel(num2str(k));


figure(2);
set(gcf,'Units','normal','Position',[0.2 0.4 0.5 0.5])
%NNx=(10000:10020);
k=2;
plot(   NNx,Ax(NNx,1)/max(abs(Ax(NNx,1))),'b-o',...
        NNx,Ax(NNx,k)/max(abs(Ax(NNx,2))),'g-*',...
        NNx,Ax(NNx,k+1)/max(abs(Ax(NNx,3))),'r-+',...
        NNx,Ax(NNx,k+2)/max(abs(Ax(NNx,4))),'c-x',...
        NNx,Ax(NNx,k+3)/max(abs(Ax(NNx,5))),'m-o',...
        NNx,Ax(NNx,k+4)/max(abs(Ax(NNx,6))),'y-*',...
        NNx,Ax(NNx,k+5)/max(abs(Ax(NNx,7))),'k-+',...
        NNx,Ax(NNx,k+6)/max(abs(Ax(NNx,8))),'k-*'),grid
    title('1 blue 2 green 3 red 4 cyan 5 mag 6 yell 7 black+ 8 black*');
    
figure(3);
set(gcf,'Units','normal','Position',[0.3 0.4 0.5 0.5])
plot(   NNx,Ax(NNx,1),'b-o',NNx,Ax(NNx,2),'g-*',NNx,Ax(NNx,3),'r-+',NNx,Ax(NNx,4),'c-x',...
        NNx,Ax(NNx,5),'m-o',NNx,Ax(NNx,6),'y-*',NNx,Ax(NNx,7),'k-+',NNx,Ax(NNx,8),'k-*'),grid
    title('1 blue 2 green 3 red 4 cyan 5 mag 6 yell 7 black+ 8 black*');
    %,NNx,Ax(NNx,8));