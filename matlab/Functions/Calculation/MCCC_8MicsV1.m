% function [ det_Ra_p ] = MCCC_8MicsV1( y_t, N_SIGBLOCK, p_min_theta, p_max_theta )
function [ det_Ra_p ] = MCCC_8MicsV1( y_t, N_SIGBLOCK, THETA, fa, A, c )
%MCCC_4Mics_flexV2 calculates the J_MCCC(p)-Funktion
%
%   Filename        :   MCCC_4Mics_flexV2.m
%   Matlab-Version  :   Matlab 7.8.0 (R2009a)
%   Date            :   26.05.2012
%   Author          :   Markus Mueller
%   e-mail          :   markus.mueller1@haw-hamburg.de
%   description     :   
%   MCCC Algorithmus mit Aufrufmöglichkeit von unterschiedlichen
%   Korrelationsalgorithmen. (corr_mfile)
%   
%
% Input:
% N_SIGBLOCK: Länge des Signalblock (Halbe FFT-Länge)
% y_t       : Signalvektoren an den Mikrophonen L x N_SIGBLOCK
% p_min     : untere Grenze Suchbereich, Steuerungsparameter (z.B. 180°)
%             nur im bereich von p_min bis p_max müssen die Determinanten 
%             berechnet werden!
% p_max     : ober Grenze Suchbereich, Steuerungsparameter (z.B. 0°)
%             (maximaler Wert, alle möglichen, nicht unbedingt 
%              sinnvollen Werte wären von p_min=1 bis p_max=NFFT)
%
% Output:
% det_Ra_p  : alle berechneten Determinanten in abhängigkeit von p


N = 8;
N_FFT = 2 * N_SIGBLOCK;

%% Berechnung der MCCC (multichannel cross corellation coefficient)
% Signale im Frequenzbereich 
%(mit doppelter Länge, da Kreuzkorrelation mittels schneller Faltung)
%Y_f = zeros(L,N_FFT);

% Berechnen der Elemente der Spatial Correlation Matrix
% HINWEIS: wenn Korrelation im Frequenzbereich durch complex-konjugierte
% Multiplikation, dann auch FFT-Shift nötig. Erstes Element kann Ignoriert
% werden, da =0 (ist sozusagen eines zu viel).

% Kovarianzmatrix bei 8 Mikrophonen:
%{
        sigma(1,1)  ry1y2(1,2)  ...   ry1y2(1,8)
R_a =   ry1y2(2,1)  sigma(2,2)  ...   ry1y2(2,8) 
        ry1y2(3,1)  ry1y2(3,2)  ...   ry1y2(3,8)
            .           .       .
            .           .        .
            .           .     
        ry1y2(8,1)  ry1y2(8,2)  ...   sigma(8,8)

Da die Matrix R_a symmetrisch ist entfällt die Berechnung aller Elemente
unterhalb der Hauptdiagonalen.


        sigma(1,1)  ry1y2(1,2)  ...   ry1y2(1,8)
R_a =   xxxxx(2,1)  sigma(2,2)  ...   ry1y2(2,8) 
        xxxxx(3,1)  xxxxx(3,2)  ...   ry1y2(3,8)
            .           .       .
            .           .         .
        xxxxx(8,1)  xxxxx(8,2)  ...   sigma(8,8)

%}


% Berechnung der Leistung Sigma2 zwecks Rechenzeitoptimierung wird auf 
% 1/(length(y_t(k,:)) verzichtet. Beachten bei Korrelationen, dass es dort
% auch vermieden wird.
sigma_y = zeros(N,1);
for k=1:N
      sigma_y(k,1) = 1/(length(y_t(:,k))) * (y_t(k,:)*y_t(k,:)');
   %  sigma_y(k,1) = y_t(k,:)*y_t(k,:)';
end

% Beispiel
% r_y0y1 = fftshift(ifft(Y1.*conj(Y0))); % covarianz von y0y1

% Zu Berechnende Kovarianzen
num_covar = (N-1)*N/2;    % bei L=8 --> 28
r_xy = zeros(num_covar, N_FFT);
n = 1; % Zähler innerhalb der Schleife

for k=1:(N-1) %Zeile
    for j=(k+1):N %Spalte(fängt immer von Position k+1 an, nach der Diagonalen)
        
        % (1,2) (1,3) (1,4), (1,5) (1,6) (1,7) (1,8)
        % (2,3) (2,4) (2,5), (2,6) (2,7) (2,8)
        % (3,4) (3,5) (3,6), (3,7) (3,8)
        % (4,5) (4,6) (4,7), (4,8)
        % (5,6) (5,7) (5,8)
        % (6,7) (6,8)
        % (7,8)
        % ------------------------------------------
        % For N=8 -> N^2-N/2 = 28
        
        % Korrelationen berechnen
       
        r_xy(n,:) = FXcorr( y_t(j,:), y_t(k,:), N_FFT );
        %feval(corr_mfile, y_t(j,:), y_t(k,:), N_FFT); (hier noch GCC-PHAT implementieren!)
        n = n+1;
    end
end

%% Find the MAXIMUM of 1-det(R_a(p))
%  ... or the MINIMUM of R_a(p)

% Deklaration für die Berechnung der Determinanten in Abhängigkeit von p

det_Ra_p = zeros( 1, length(THETA.MIN:THETA.RESOLUTION:THETA.MAX) );
% det_Ra_p_phi = zeros(1,length(phi_min:phi_max));

% Offset, damit Steering im richtigen Bereich gemacht wird
Offset = N_FFT/2+1; 

% Berechnen aller Determinanten mit index p (max. Index : N_FFT)
% Hier müssen zwei Schleifen, für Elevation (p_phi)- und Azimuthwinkel
% (p_theta) über der Determinante laufen. 


i=1;
for theta = THETA.MIN:THETA.RESOLUTION:THETA.MAX

    % L defines the Steering parameter according to theta and phi
     L = (-1) * round( USA_Function_tau(0, theta, A, c) * fa );

    %            M1-M1
    %           M1-M2
    %             .
    %             .
    %             .
    %           M7-M8


        % L(1,k)



 det_Ra_p(i) =  det(...       
                        [sigma_y(1,1)          r_xy(1,Offset+L(1))   r_xy(2,Offset+L(2))   r_xy(3,Offset+L(3))    r_xy(4,Offset+L(4))    r_xy(5,Offset+L(5))    r_xy(6,Offset+L(6))    r_xy(7,Offset+L(7))   ;...
                        r_xy(1,Offset+L(1))  sigma_y(2,1)            r_xy(8,Offset+L(8))   r_xy(9,Offset+L(9))    r_xy(10,Offset+L(10))  r_xy(11,Offset+L(11))  r_xy(12,Offset+L(12))  r_xy(13,Offset+L(13)) ;...
                        r_xy(2,Offset+L(2))  r_xy(8,Offset+L(8))   sigma_y(3,1)            r_xy(14,Offset+L(14))  r_xy(15,Offset+L(15))  r_xy(16,Offset+L(16))  r_xy(17,Offset+L(17))  r_xy(18,Offset+L(18)) ;...
                        r_xy(3,Offset+L(3))  r_xy(9,Offset+L(9))   r_xy(14,Offset+L(14)) sigma_y(4,1)             r_xy(19,Offset+L(19))  r_xy(20,Offset+L(20))  r_xy(21,Offset+L(21))  r_xy(22,Offset+L(22)) ;...
                        r_xy(4,Offset+L(4))  r_xy(10,Offset+L(10)) r_xy(15,Offset+L(15)) r_xy(19,Offset+L(19))  sigma_y(5,1)             r_xy(23,Offset+L(23))  r_xy(24,Offset+L(24))  r_xy(25,Offset+L(25)) ;...
                        r_xy(5,Offset+L(5))  r_xy(11,Offset+L(11)) r_xy(16,Offset+L(16)) r_xy(20,Offset+L(20))  r_xy(23,Offset+L(23))  sigma_y(6,1)             r_xy(26,Offset+L(26))  r_xy(27,Offset+L(27)) ;...
                        r_xy(6,Offset+L(6))  r_xy(12,Offset+L(12)) r_xy(17,Offset+L(17)) r_xy(21,Offset+L(21))  r_xy(24,Offset+L(24))  r_xy(26,Offset+L(26))  sigma_y(7,1)             r_xy(28,Offset+L(28)) ;...
                        r_xy(7,Offset+L(7))  r_xy(13,Offset+L(13)) r_xy(18,Offset+L(18)) r_xy(22,Offset+L(22))  r_xy(25,Offset+L(25))  r_xy(27,Offset+L(27))  r_xy(28,Offset+L(28))  sigma_y(8,1)             ...
                        ] ...
                    );

i=i+1;


end




% DEBUGGING % 16.05.2012
% ------------------------------------------------------------------------
% figure(666), NSubFigs = 6; 
% for iSubFig =1:6
%     subplot(NSubFigs,1,iSubFig)
%     %plot(-N_FFT/2:((N_FFT/2)-1),r_y1y2(iSubFig,:)) % Korrelation 1 und 2
%     plot(3*p_min:(3*p_max),r_y1y2(iSubFig,Offset+(3*p_min:3*p_max))) % Korrelation 1 und 2
%     hold on 
%     % Zeichne vom Steering Parameter getroffene werte ein
%     switch(iSubFig)
%         case 1 
%             m = 1;
%         case 2
%             m = 2;
%         case 3
%             m = 3;
%         case 4
%             m = 1;
%         case 5
%             m = 2;
%         case 6
%             m = 1;
%     end
%     plot(m*(p_min:p_max),r_y1y2(iSubFig,Offset+m*(p_min:p_max)),'rs')
%     hold off
%     title('Einzelne Korralation (1,2)(1,3)(1,4)(2,3)...(3,4)')
% end
% 
% 

%{
figure(667);
mesh( THETA.MIN:THETA.RESOLUTION:THETA.MAX, PHI.MIN:PHI.RESOLUTION:PHI.MAX, det_Ra_p ); figure(gcf);
xlabel('Azimuth [°]');
ylabel('Elevation [°]');
%}



 figure(667);
 % subplot(2,1,1)
 stem(THETA.MIN:THETA.RESOLUTION:THETA.MAX,det_Ra_p);
 grid on
 xlabel('DOA-Theta [°]')
 title('Ergebniss der MCCC')
 
 %{
 
 subplot(2,1,2)
 semilogy(THETA.MIN:THETA.RESOLUTION:THETA.MAX,det_Ra_p_theta);
 grid on
 xlabel('DOA-Theta [°]')
 title('Ergebniss der MCCC [dB]')
 %}
 
end