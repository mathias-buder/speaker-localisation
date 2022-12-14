function [ det_Ra_p ] = MCCC_8MicsV2( y_t, N_SIGBLOCK, Phi, Theta, fa, A, c, phi_theory, theta_theory )
%MCCC_4Mics_flexV2 calculates the J_MCCC(p)-Funktion
%
%   Filename        :   MCCC_4Mics_flexV2.m
%   Matlab-Version  :   Matlab 7.8.0 (R2009a)
%   Date            :   26.05.2012
%   Author          :   Markus Mueller
%   e-mail          :   markus.mueller1@haw-hamburg.de
%   description     :   
%   MCCC Algorithmus mit Aufrufm?glichkeit von unterschiedlichen
%   Korrelationsalgorithmen. (corr_mfile)
%   
%
% Input:
% N_SIGBLOCK: L?nge des Signalblock (Halbe FFT-L?nge)
% y_t       : Signalvektoren an den Mikrophonen L x N_SIGBLOCK
% p_min     : untere Grenze Suchbereich, Steuerungsparameter (z.B. 180?)
%             nur im bereich von p_min bis p_max m?ssen die Determinanten 
%             berechnet werden!
% p_max     : ober Grenze Suchbereich, Steuerungsparameter (z.B. 0?)
%             (maximaler Wert, alle m?glichen, nicht unbedingt 
%              sinnvollen Werte w?ren von p_min=1 bis p_max=NFFT)
%
% Output:
% det_Ra_p  : alle berechneten Determinanten in abh?ngigkeit von p


N = 8;
N_FFT = 2 * N_SIGBLOCK;

% Offset, damit Steering im richtigen Bereich gemacht wird
Offset = N_FFT/2+1;
%% Berechnung der MCCC (multichannel cross corellation coefficient)
% Signale im Frequenzbereich 
%(mit doppelter L?nge, da Kreuzkorrelation mittels schneller Faltung)
%Y_f = zeros(L,N_FFT);

% Berechnen der Elemente der Spatial Correlation Matrix
% HINWEIS: wenn Korrelation im Frequenzbereich durch complex-konjugierte
% Multiplikation, dann auch FFT-Shift n?tig. Erstes Element kann Ignoriert
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

Da die Matrix R_a symmetrisch ist entf?llt die Berechnung aller Elemente
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

sigma_sq_y = zeros(N,1);
for k=1:N
      % sigma_sq_y(k) = 1/length(y_t) * ( y_t(k,:) * y_t(k,:)' );
      sigma_sq_y(k) = 1/length(y_t) * sum(y_t(k,:).^2);
      % sigma_y(k,1) = y_t(k,:) * y_t(k,:)';
end

% Zu Berechnende Kovarianzen
num_covar = (N-1)*N/2;    % bei L=8 --> 28
r_xy = zeros(num_covar, N_FFT);
n = 1; % Z?hler innerhalb der Schleife
nn = -length(y_t):length(y_t)-1;


ccf_flag = inputs('Show CCF?: Y[1] N[0]:', 0);
L_theory = -round( USA_Function_tau( phi_theory, theta_theory, A, c) * fa );

for i=1:(N-1) %Zeile
    for j=(i+1):N %Spalte(f?ngt immer von Position k+1 an, nach der Diagonalen)
        
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
        %r_xy_t(n,:) = xcorr( y_t(i,:), y_t(j,:), 'bias' );
        r_xy(n,:) = 1/N_SIGBLOCK *  FXcorr( y_t(j,:), y_t(i,:), N_FFT );
        if(ccf_flag)
            figure(200);
            subplot(2,1,1);
            stem(nn, r_xy(n,:)), grid
            hold on;
            stem(nn, r_xy(n,:)),plot(L_theory(n), r_xy(n,Offset+L_theory(n)), 'x', 'Color', 'r');
            title(sprintf('$r_{y%iy%i}[p]$',i,j), 'Interpreter','latex','FontSize', 16');
            xlabel('$p \rightarrow$', 'Interpreter','latex','FontSize', 16);
            hold off;
            r_xy(n,:) = r_xy(n,:) / sqrt(sigma_sq_y(j) * sigma_sq_y(i));
            subplot(2,1,2);
            stem(nn, r_xy(n,:)), grid
            hold on;
            stem(nn, r_xy(n,:)),plot(L_theory(n), r_xy(n,Offset+L_theory(n)), 'x', 'Color', 'r');
            title(sprintf('$r_{y%iy%i}[p]$ - Korrkoeff',i,j), 'Interpreter','latex','FontSize', 16');
            xlabel('$p \rightarrow$', 'Interpreter','latex','FontSize', 16);
            hold off;
            pause();
        else
            % Norm to standart deviation
            r_xy(n,:) = r_xy(n,:) / sqrt(sigma_sq_y(i) * sigma_sq_y(j));
        end
        n = n+1;
    end
end

sigma_sq_y(:) = 1;
%% Find the MAXIMUM of 1-det(R_a(p))
%  ... or the MINIMUM of R_a(p)

% Deklaration f?r die Berechnung der Determinanten in Abh?ngigkeit von p

det_Ra_p = zeros( Phi.Length, Theta.Length );

% Berechnen aller Determinanten mit index p (max. Index : N_FFT)
% Hier m?ssen zwei Schleifen, f?r Elevation (p_phi)- und Azimuthwinkel
% (p_theta) ?ber der Determinante laufen. 

p_phi=1;
% for phi = Phi.LUT
for phi = -pi/2:pi/180:pi/2
    p_theta=1;
    %for theta = Theta.LUT
    for theta = 0:2*pi/360:2*pi
        
        % L defines the Steering parameter according to phi and theta
        L = -round( USA_Function_tau( phi, theta, A, c) * fa );

        % M1-M2
        % M1-M3
        %   .
        %   .
        %   .
        % M7-M8

         Ra_p = [sigma_sq_y(1)        r_xy(1,Offset+L(1))   r_xy(2,Offset+L(2))   r_xy(3,Offset+L(3))    r_xy(4,Offset+L(4))    r_xy(5,Offset+L(5))    r_xy(6,Offset+L(6))    r_xy(7,Offset+L(7))   ;...
                 r_xy(1,Offset+L(1))  sigma_sq_y(2)            r_xy(8,Offset+L(8))   r_xy(9,Offset+L(9))    r_xy(10,Offset+L(10))  r_xy(11,Offset+L(11))  r_xy(12,Offset+L(12))  r_xy(13,Offset+L(13)) ;...
                 r_xy(2,Offset+L(2))  r_xy(8,Offset+L(8))   sigma_sq_y(3)            r_xy(14,Offset+L(14))  r_xy(15,Offset+L(15))  r_xy(16,Offset+L(16))  r_xy(17,Offset+L(17))  r_xy(18,Offset+L(18)) ;...
                 r_xy(3,Offset+L(3))  r_xy(9,Offset+L(9))   r_xy(14,Offset+L(14)) sigma_sq_y(4)             r_xy(19,Offset+L(19))  r_xy(20,Offset+L(20))  r_xy(21,Offset+L(21))  r_xy(22,Offset+L(22)) ;...
                 r_xy(4,Offset+L(4))  r_xy(10,Offset+L(10)) r_xy(15,Offset+L(15)) r_xy(19,Offset+L(19))  sigma_sq_y(5)             r_xy(23,Offset+L(23))  r_xy(24,Offset+L(24))  r_xy(25,Offset+L(25)) ;...
                 r_xy(5,Offset+L(5))  r_xy(11,Offset+L(11)) r_xy(16,Offset+L(16)) r_xy(20,Offset+L(20))  r_xy(23,Offset+L(23))  sigma_sq_y(6)             r_xy(26,Offset+L(26))  r_xy(27,Offset+L(27)) ;...
                 r_xy(6,Offset+L(6))  r_xy(12,Offset+L(12)) r_xy(17,Offset+L(17)) r_xy(21,Offset+L(21))  r_xy(24,Offset+L(24))  r_xy(26,Offset+L(26))  sigma_sq_y(7)             r_xy(28,Offset+L(28)) ;...
                 r_xy(7,Offset+L(7))  r_xy(13,Offset+L(13)) r_xy(18,Offset+L(18)) r_xy(22,Offset+L(22))  r_xy(25,Offset+L(25))  r_xy(27,Offset+L(27))  r_xy(28,Offset+L(28))  sigma_sq_y(8)           ...
                ];
            
            
 %{ 
 
            Ra_p = [sigma_sq_y(1)     r_xy(1,Offset+L(1))   r_xy(2,Offset+L(2))   r_xy(3,Offset+L(3));       ...    
                    r_xy(1,Offset+L(1))  sigma_sq_y(2)         r_xy(4,Offset+L(4))   r_xy(5,Offset+L(5));    ...    
                    r_xy(2,Offset+L(2))  r_xy(4,Offset+L(4))   sigma_sq_y(3)         r_xy(6,Offset+L(6));    ...  
                    r_xy(3,Offset+L(3))  r_xy(5,Offset+L(5))   r_xy(6,Offset+L(6))   sigma_sq_y(4)           ...            
                    ];
%}
%{   
            Ra_p = [sigma_sq_y(1)           r_xy(1,Offset+L(1));  ...    
                    r_xy(1,Offset+L(1))     sigma_sq_y(2);        ...        
                    ];
%} 
            

        det_Ra_p(p_phi,p_theta) = det(Ra_p);
        
        % fprintf('Phi: %f, Theta: %f, det(Ra_p)=%f\n', rad2deg(phi), rad2deg(theta), det(Ra_p));
        
        p_theta = p_theta + 1;
    end
    p_phi = p_phi + 1;
end

 
end