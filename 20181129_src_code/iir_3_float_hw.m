% ====================================================================
% HW model of IIR based on 
% https://flylib.com/books/en/2.729.1/improving_iir_filters_with_cascaded_structures.html
%   Ver01 - 2018/11/28 - Thomas
% ====================================================================
function iir_3_float_hw
    % Frequency band
    freq_band = [0.1 5; 4 8; 8 16; 16 32; 32 64];
    freq_band_n = size(freq_band, 1);
     
    % Coefficients
    gain = [9.958149762e+03; 9.304492984e+03; 1.274127130e+03; 1.886636902e+02; 3.155634425e+01];
    b_iir = 3; % b3 = -b5
    a_iir = [%5.8079313778 -14.0583204454 18.1530768930 -13.1886259895 5.1116461828 -0.8257080186;  % a6 .. a1, 0.1 -> 4
             5.7587466195 -13.8227691780 17.7019179060 -12.7566128880 4.9048156531 -0.7860981126;   % 0.1 -> 5
             5.7478355883 -13.8221029130 17.7995036620 -12.9457799840 5.0421971775 -0.8216600080;
             5.3924043138 -12.3208587720 15.2602541450 -10.8050088170 4.1476380501 -0.6748018873;
             4.4245975081 -8.7977149647  9.9533555744  -6.7532030523  2.6074997172 -0.4535459334;
             1.8469903126 -2.6306019375  2.2163883751  -1.5749123739  0.6229128133 -0.1978251873];
    
    % Generate inputs 
    samp_freq = 256; % sampling frequency
    t = 0:1/samp_freq:10-(1/samp_freq); % time axis
    rng default                                     %
    f = 20;                                         % 20-Hz sine wave
    %x = (cos(2*pi*f*t))*1024;                       % 100-Hz sine wave
    x = (cos(2*pi*f*t)+0.5*randn(size(t)))*8;    % + white Gaussian noise
        
    n_col = 7;
    n = length(x);
    y = zeros(freq_band_n, length(x)); 

    % Signal energy of n frequency band
    for j = 1:freq_band_n
    %for j = 1:1
        xx = zeros(1, n_col);
        yy = zeros(1, n_col);
        for i = 1:n     
            xx(1) = xx(2);
            xx(2) = xx(3);
            xx(3) = xx(4);
            xx(4) = xx(5);
            xx(5) = xx(6);
            xx(6) = xx(7);
            xx(7) = x(i)/gain(j);
            
            yy(1) = yy(2);
            yy(2) = yy(3);
            yy(3) = yy(4);
            yy(4) = yy(5);
            yy(5) = yy(6);
            yy(6) = yy(7);                 
            yy(7) =  (xx(7) - xx(1)) + b_iir * (xx(3) - xx(5)) ...
                 + ( a_iir(j, 6) * yy(1)) + ( a_iir(j, 5) * yy(2)) ...
                 + ( a_iir(j, 4) * yy(3)) + ( a_iir(j, 3) * yy(4)) ...
                 + ( a_iir(j, 2) * yy(5)) + ( a_iir(j, 1) * yy(6));
               
            y(j, i) = yy(7);
                                     
        end
    end
end