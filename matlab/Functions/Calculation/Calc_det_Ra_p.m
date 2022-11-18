function [ det_Ra_p, count ] = Calc_det_Ra_p (R_xy, Phi, Theta, A, fa, c, count)
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
    %% Find the MAXIMUM of 1-det(R_a(p)) or the MINIMUM of R_a(p)

    % Deklaration für die Berechnung der Determinanten in Abhängigkeit von p

    det_Ra_p = zeros( Phi.NumOfSearchAngles, Theta.NumOfSearchAngles );
 
    % Offset, damit Steering im richtigen Bereich gemacht wird
    Offset = R_xy.N_FFT/2+1; 

    % Berechnen aller Determinanten mit index p (max. Index : N_FFT)
    % Hier müssen zwei Schleifen, für Elevation (p_phi)- und Azimuthwinkel
    % (p_theta) über der Determinante laufen. 

    j=1;
    for p_phi = 1:Phi.NumOfSearchAngles
        i=1;
        for p_theta = 1:Theta.NumOfSearchAngles

            % L defines the Steering parameter according to theta and phi
            % fprintf('Phi: %3.1i, Theta: %3.1i\n',Phi.LUT(Phi.Idx(p_phi)), Theta.LUT(Theta.Idx(p_theta)));
            count = count + 1;
            L = (-1) * round( USA_Function_tau(Phi.LUT(Phi.Idx(p_phi)), Theta.LUT(Theta.Idx(p_theta)), A, c) * fa );

            % M1-M2
            %   .
            %   .
            %   .
            % M7-M8

            Ra_p =  (...       
                                    [R_xy.sigma_y(1)          R_xy.r_xy(1,Offset+L(1))   R_xy.r_xy(2,Offset+L(2))   R_xy.r_xy(3,Offset+L(3))    R_xy.r_xy(4,Offset+L(4))    R_xy.r_xy(5,Offset+L(5))    R_xy.r_xy(6,Offset+L(6))    R_xy.r_xy(7,Offset+L(7))   ;...
                                    R_xy.r_xy(1,Offset+L(1))  R_xy.sigma_y(2)            R_xy.r_xy(8,Offset+L(8))   R_xy.r_xy(9,Offset+L(9))    R_xy.r_xy(10,Offset+L(10))  R_xy.r_xy(11,Offset+L(11))  R_xy.r_xy(12,Offset+L(12))  R_xy.r_xy(13,Offset+L(13)) ;...
                                    R_xy.r_xy(2,Offset+L(2))  R_xy.r_xy(8,Offset+L(8))   R_xy.sigma_y(3)            R_xy.r_xy(14,Offset+L(14))  R_xy.r_xy(15,Offset+L(15))  R_xy.r_xy(16,Offset+L(16))  R_xy.r_xy(17,Offset+L(17))  R_xy.r_xy(18,Offset+L(18)) ;...
                                    R_xy.r_xy(3,Offset+L(3))  R_xy.r_xy(9,Offset+L(9))   R_xy.r_xy(14,Offset+L(14)) R_xy.sigma_y(4)             R_xy.r_xy(19,Offset+L(19))  R_xy.r_xy(20,Offset+L(20))  R_xy.r_xy(21,Offset+L(21))  R_xy.r_xy(22,Offset+L(22)) ;...
                                    R_xy.r_xy(4,Offset+L(4))  R_xy.r_xy(10,Offset+L(10)) R_xy.r_xy(15,Offset+L(15)) R_xy.r_xy(19,Offset+L(19))  R_xy.sigma_y(5)             R_xy.r_xy(23,Offset+L(23))  R_xy.r_xy(24,Offset+L(24))  R_xy.r_xy(25,Offset+L(25)) ;...
                                    R_xy.r_xy(5,Offset+L(5))  R_xy.r_xy(11,Offset+L(11)) R_xy.r_xy(16,Offset+L(16)) R_xy.r_xy(20,Offset+L(20))  R_xy.r_xy(23,Offset+L(23))  R_xy.sigma_y(6)             R_xy.r_xy(26,Offset+L(26))  R_xy.r_xy(27,Offset+L(27)) ;...
                                    R_xy.r_xy(6,Offset+L(6))  R_xy.r_xy(12,Offset+L(12)) R_xy.r_xy(17,Offset+L(17)) R_xy.r_xy(21,Offset+L(21))  R_xy.r_xy(24,Offset+L(24))  R_xy.r_xy(26,Offset+L(26))  R_xy.sigma_y(7)             R_xy.r_xy(28,Offset+L(28)) ;...
                                    R_xy.r_xy(7,Offset+L(7))  R_xy.r_xy(13,Offset+L(13)) R_xy.r_xy(18,Offset+L(18)) R_xy.r_xy(22,Offset+L(22))  R_xy.r_xy(25,Offset+L(25))  R_xy.r_xy(27,Offset+L(27))  R_xy.r_xy(28,Offset+L(28))  R_xy.sigma_y(8)           ...
                                    ] ...
                                );
                            
                            
            det_Ra_p(j,i) = det( Ra_p );
            i=i+1;
        end
        j=j+1;
    end
    
    
      %%%%%%%%%%%%% DEBUG %%%%%%%
        
%     det_Ra_p = zeros( Phi.Length, Theta.Length );    
%      j=1;
%     for p_phi = 1:Phi.Length
%         i=1;
%         for p_theta = 1:Theta.Length
% 
%             % L defines the Steering parameter according to theta and phi
%             fprintf('Phi: %3.1i, Theta: %3.1i\n',Phi.LUT(p_phi), Theta.LUT(p_theta) );
%             count = count + 1;
%             L = (-1) * round( USA_Function_tau( Phi.LUT(p_phi), Theta.LUT(p_theta), A, c) * fa );
% 
%             % M1-M2
%             %   .
%             %   .
%             %   .
%             % M7-M8
% 
%             Ra_p =  (...       
%                                    [R_xy.sigma_y(1)           R_xy.r_xy(1,Offset+L(1))   R_xy.r_xy(2,Offset+L(2))   R_xy.r_xy(3,Offset+L(3))    R_xy.r_xy(4,Offset+L(4))    R_xy.r_xy(5,Offset+L(5))    R_xy.r_xy(6,Offset+L(6))    R_xy.r_xy(7,Offset+L(7))   ;...
%                                     R_xy.r_xy(1,Offset+L(1))  R_xy.sigma_y(2)            R_xy.r_xy(8,Offset+L(8))   R_xy.r_xy(9,Offset+L(9))    R_xy.r_xy(10,Offset+L(10))  R_xy.r_xy(11,Offset+L(11))  R_xy.r_xy(12,Offset+L(12))  R_xy.r_xy(13,Offset+L(13)) ;...
%                                     R_xy.r_xy(2,Offset+L(2))  R_xy.r_xy(8,Offset+L(8))   R_xy.sigma_y(3)            R_xy.r_xy(14,Offset+L(14))  R_xy.r_xy(15,Offset+L(15))  R_xy.r_xy(16,Offset+L(16))  R_xy.r_xy(17,Offset+L(17))  R_xy.r_xy(18,Offset+L(18)) ;...
%                                     R_xy.r_xy(3,Offset+L(3))  R_xy.r_xy(9,Offset+L(9))   R_xy.r_xy(14,Offset+L(14)) R_xy.sigma_y(4)             R_xy.r_xy(19,Offset+L(19))  R_xy.r_xy(20,Offset+L(20))  R_xy.r_xy(21,Offset+L(21))  R_xy.r_xy(22,Offset+L(22)) ;...
%                                     R_xy.r_xy(4,Offset+L(4))  R_xy.r_xy(10,Offset+L(10)) R_xy.r_xy(15,Offset+L(15)) R_xy.r_xy(19,Offset+L(19))  R_xy.sigma_y(5)             R_xy.r_xy(23,Offset+L(23))  R_xy.r_xy(24,Offset+L(24))  R_xy.r_xy(25,Offset+L(25)) ;...
%                                     R_xy.r_xy(5,Offset+L(5))  R_xy.r_xy(11,Offset+L(11)) R_xy.r_xy(16,Offset+L(16)) R_xy.r_xy(20,Offset+L(20))  R_xy.r_xy(23,Offset+L(23))  R_xy.sigma_y(6)             R_xy.r_xy(26,Offset+L(26))  R_xy.r_xy(27,Offset+L(27)) ;...
%                                     R_xy.r_xy(6,Offset+L(6))  R_xy.r_xy(12,Offset+L(12)) R_xy.r_xy(17,Offset+L(17)) R_xy.r_xy(21,Offset+L(21))  R_xy.r_xy(24,Offset+L(24))  R_xy.r_xy(26,Offset+L(26))  R_xy.sigma_y(7)             R_xy.r_xy(28,Offset+L(28)) ;...
%                                     R_xy.r_xy(7,Offset+L(7))  R_xy.r_xy(13,Offset+L(13)) R_xy.r_xy(18,Offset+L(18)) R_xy.r_xy(22,Offset+L(22))  R_xy.r_xy(25,Offset+L(25))  R_xy.r_xy(27,Offset+L(27))  R_xy.r_xy(28,Offset+L(28))  R_xy.sigma_y(8)           ...
%                                     ] ...
%                                 );
%                             
%                             
%             det_Ra_p(j,i) = det( Ra_p );
%             i=i+1;
%         end
%         j=j+1;
%     end   
%         
%         
%         
%         
%         
% 
%     
%     figure(667);
%     mesh(Theta.LUT, Phi.LUT, det_Ra_p ); figure(gcf);
%     
%     xlabel('Azimuth [°]');
%     ylabel('Elevation [°]');
    
    
    
end