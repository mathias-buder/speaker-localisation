function [ y_t ] = ChannelCorrection ( y_t_uncorreced, N )

y_t = zeros(N, length(y_t_uncorreced) );
y_t_uncorreced = y_t_uncorreced';

correction = [7 1 3 5 8 2 4 6];

    for i = 1:N
        y_t( i,: ) = y_t_uncorreced( correction(i) , : )/2^15;
    end

end