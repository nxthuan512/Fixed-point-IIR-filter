% ====================================================================
% HW model of IIR based on 
% https://flylib.com/books/en/2.729.1/improving_iir_filters_with_cascaded_structures.html
%   Ver01 - 2018/11/28 - Thomas
% ====================================================================
function iir_3_fixed_hw
    % 24-bit fixed: 14.16
    % Frequency band
    freq_band = [0.1 5; 4 8; 8 16; 16 32; 32 64];
    freq_band_n = size(freq_band, 1);
     
    % Coefficients
%     gain = [9.958149762e+03; % 8192 + 1024 + 512 + 256 - 32 + 4 + 2 
%             9.304492984e+03; % 8192 + 1024 + 64 + 32 - 8
%             1.274127130e+03; % 1024 + 256 - 4 - 2
%             1.886636902e+02; % 128 + 64 - 2 - 1
%             3.155634425e+01];% 32
    gain = [9984; % 8192 + 1024 + 512 + 256
            9312; % 8192 + 1024 + 64 + 32
            1280; % 1024 + 256
            192;  % 128 + 64
            32];  % 32
    b_iir = 3; % b3 = -b5
    % Floating points
    a_iir = [5.7587466195 -13.8227691780 17.7019179060 -12.7566128880 4.9048156531 -0.7860981126;   % 0.1 -> 5
             5.7478355883 -13.8221029130 17.7995036620 -12.9457799840 5.0421971775 -0.8216600080;
             5.3924043138 -12.3208587720 15.2602541450 -10.8050088170 4.1476380501 -0.6748018873;
             4.4245975081 -8.7977149647  9.9533555744  -6.7532030523  2.6074997172 -0.4535459334;
             1.8469903126 -2.6306019375  2.2163883751  -1.5749123739  0.6229128133 -0.1978251873];
    % Convert to fixed-point 1.5.16
    DIV = 65536*128;
    a_iir_fix = round(a_iir .* DIV);
    
    % Generate inputs 
    samp_freq = 256; % sampling frequency
    t = 0:1/samp_freq:10-(1/samp_freq); % time axis
    rng default                                     %
    f = 20;                                         % 20-Hz sine wave
    %x = (cos(2*pi*f*t))*1024;                       % f-Hz sine wave
    x = round((cos(2*pi*f*t)+0.5*randn(size(t)))*256);    % + white Gaussian noise
        
    n_col = 7;
    n = length(x);
    y = zeros(freq_band_n, length(x)); 

    % Signal energy of n frequency band
    max_yy = 0;
    min_yy = 10000;
    
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
            xx_mac = (xx(7) - xx(1)) + b_iir * (xx(3) - xx(5));
            
            % Convert to fixed-point 1.5.16
            QUANT_Y = 65536;
            yy = round(yy .* QUANT_Y);
            
            yy(1) = yy(2);
            yy(2) = yy(3);
            yy(3) = yy(4);
            yy(4) = yy(5);
            yy(5) = yy(6);
            yy(6) = yy(7);                 
            
            mac1 = (a_iir_fix(j, 6) * (yy(1)));
            mac2 = (a_iir_fix(j, 5) * (yy(2)));
            mac3 = (a_iir_fix(j, 4) * (yy(3)));
            mac4 = (a_iir_fix(j, 3) * (yy(4)));
            mac5 = (a_iir_fix(j, 2) * (yy(5)));
            mac6 = (a_iir_fix(j, 1) * (yy(6)));
            
            mac = round(xx_mac * QUANT_Y) + round((mac1 + mac2 + mac3 + mac4 + mac5 + mac6)/DIV);
            y(j, i) = mac / QUANT_Y;
            yy(7) = y(j, i);  
            
            if max_yy < max(yy)
                max_yy = max(yy);
            elseif min_yy > min(yy)
                min_yy = min(yy);
            end
        end
    end
end