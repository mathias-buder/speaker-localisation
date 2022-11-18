%% This file implements the RS232-Communication between DSP ans Matlab

%Create Serial Port Object
fprintf('Creating serial object ...\n');
s = serial('COM1', 'BaudRate', 9600, 'Terminator', 'CR', 'Parity','even');
disp(s);
fprintf('Opening serial object ...\n');
fopen(s)
% str = 'This is a RS232 Test-String!';
% fprintf('Sending String: "%s" ...\n', str);
% fprintf(s, str);

N_ANGLES = 11;
ReceivedAngles = zeros(2,N_ANGLES);
counter = 1;
N_COUNTS = 10000;
receive_flag = 1;
RcvTmp = zeros(2,1);


fprintf('Reiceiving on Port: %s ...\n', s.Port);
while( receive_flag )
    % Plot Polar diagram
    % PlotPolar( RcvTmp(1), RcvTmp(2), 1, 3, 12 );
    % drawnow;
    
    msg = fgets(s); %get data from serial port
    fprintf('Received: %s', msg);
    
    %if( ~isempty(msg) && all(ismember(msg,'0123456789.- ')) )
        
     %    RcvTmp(1) = sscanf(msg,'%f');
    %end
    
    
    % msg = fgets(s); %get data from serial port
    % fprintf('Received: %s', msg);
    
    %if( ~isempty(msg) && all(ismember(msg,'0123456789.- ')) )
        
     %    RcvTmp(2) = sscanf(msg,'%f');
    %end
    
    
    
    
    % disp(RcvTmp);
    % ReceivedAngles(1,counter) = RcvTmp(1);
    % ReceivedAngles(2,counter) = RcvTmp(2);
    counter = counter + 1;
    % receive_flag = inputs('Continue? [0]:N [1]:Y', 1);

    if(counter > N_COUNTS)
        receive_flag = 0;
    end
    
end

fprintf('Close serial object ...\n');
fclose(s)
fprintf('Delete serial object ...\n');
delete(s)
fprintf('Done!\n');