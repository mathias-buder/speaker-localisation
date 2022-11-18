 [y_t, fa] = audioread('Aber.wav');
 Ta = 1/fa;
 offset = 11000;
 y_t_cut = y_t(offset:offset+2250,1);
 len = length(y_t_cut);
 
 BLOCKSIZE = 256;
 
 N_part = round(len/BLOCKSIZE)-1;
 
 figure(100);
 subplot(3,1,1)
 plot(0:Ta:(len-1)*Ta, y_t_cut, '.-m');
 axis([0 (len-1)*Ta -1 1]);
 xlabel('$t [s]$', 'Interpreter', 'latex','FontSize', 12);
 ylabel('$s(n)$', 'Interpreter', 'latex','FontSize', 12);
 
 grid;
 
 energie = zeros(length(0:(N_part-1)),1);
 
 for sigPart = 0:(N_part-1)
            
            % Select signal part  
            y_part = y_t_cut( (BLOCKSIZE*sigPart)+1:(BLOCKSIZE*sigPart)+BLOCKSIZE ); 
            
            energie(sigPart+1) = 1/BLOCKSIZE * sum(y_part.^2);
            
 end
 
% Norm energie
energie_norm = energie / (max(energie));
  
subplot(3,1,2)
plot(energie_norm, '.-b'),grid;
xlim([0 N_part]);
xlabel('$Block$', 'Interpreter', 'latex','FontSize', 12);
ylabel('$E(k)$', 'Interpreter', 'latex','FontSize', 12);
 
 
subplot(3,1,3)
plot(10*log10(energie_norm), '.-b'),grid
xlim([0 N_part]);
xlabel('$Block$', 'Interpreter', 'latex','FontSize', 12);
ylabel('$10 \log_{10}~E(k) [dB]$', 'Interpreter', 'latex','FontSize', 12);