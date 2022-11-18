function [ R_xy ] = MCCC_8MicsV2_1( y_t, N_SIGBLOCK )
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


    R_xy.N = 8;
    R_xy.N_FFT = 2 * N_SIGBLOCK;

    % Berechnung der Leistung Sigma2 zwecks Rechenzeitoptimierung wird auf 
    % 1/N_SIGBLOCK verzichtet. Beachten bei Korrelationen, dass es dort
    % auch vermieden wird.
    R_xy.sigma_y = zeros(R_xy.N,1);
    for k=1:R_xy.N
        % R_xy.sigma_y(k) = ( y_t(k,:) * y_t(k,:)' );
        R_xy.sigma_y(k) = 1/N_SIGBLOCK *  ( y_t(k,:) * y_t(k,:)' );
    end



    % Beispiel
    % r_y0y1 = fftshift(ifft(Y1.*conj(Y0))); % covarianz von y0y1

    % Zu Berechnende Kovarianzen
    num_covar = (R_xy.N-1) * R_xy.N/2;
    R_xy.r_xy = zeros(num_covar, R_xy.N_FFT);

    n = 1;                  % Loop-Counter
    for k=1:(R_xy.N-1)      % Row
        for j=(k+1):R_xy.N  % Columns (start at position k+1)

            % (1,2) (1,3) (1,4), (1,5) (1,6) (1,7) (1,8)
            % (2,3) (2,4) (2,5), (2,6) (2,7) (2,8)
            % (3,4) (3,5) (3,6), (3,7) (3,8)
            % (4,5) (4,6) (4,7), (4,8)
            % (5,6) (5,7) (5,8)
            % (6,7) (6,8)
            % (7,8)
            % ------------------------------------------
            % For N=8 -> N^2-N/2 = 28

            % Calculate Cross-Correlation-Functions across all microphone
            % pairs
            R_xy.r_xy(n,:) = FXcorrV2( y_t(k,:), y_t(j,:), R_xy.N_FFT );
            % R_xy.r_xy(n,:) = R_xy.r_xy(n,:) / ( sqrt(R_xy.sigma_y(j)) * sqrt(R_xy.sigma_y(k)) );

            n = n+1;
        end
    end


    % R_xy.sigma_y(:) = 1;




end