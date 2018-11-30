% ====================================================================
% Comparison MSE of output signal between FIR and IIR
%   Ver01 - 2018/11/28 - Thomas
% ====================================================================
function fir_vs_iir
% Frequency band
freq_band = [0.1 4; 4 8; 8 16; 16 32; 32 64];
freq_band_n = size(freq_band, 1);

% Sampling frequency and time axis
samp_freq = 256;
t = 0:1/samp_freq:10-(1/samp_freq);

% FIR and IIR orders
fir_fil_order = 64;
b_fir = zeros(freq_band_n, fir_fil_order+1);    % Coefficients
y_fir = zeros(freq_band_n, length(t));          % Output

iir_fil_order = 3;
a_iir = zeros(freq_band_n, iir_fil_order*2+1);  % Coefficients
b_iir = zeros(freq_band_n, iir_fil_order*2+1);  % Coefficients
y_iir = zeros(freq_band_n, length(t));          % Output

err = zeros(1, freq_band_n);                    % MSE

% Signal generation
rng default                                     %
f = 20;                                         % 20-Hz sine wave
x = (cos(2*pi*f*t))*1024;                       % 100-Hz sine wave
%x = (cos(2*pi*f*t)+0.5*randn(size(t)))*256;    % + white Gaussian noise

% Signal energy of n frequency band
for i = 1:freq_band_n
    % FIR/IIR coefficients and their outputs are stored in corresponding
    % arrays
    [b_fir(i,:), y_fir(i,:)] = fir_coefficients(samp_freq, fir_fil_order, x, freq_band(i,:));
    [a_iir(i,:), b_iir(i,:), y_iir(i,:)] = iir_coefficients(samp_freq, iir_fil_order, x, freq_band(i,:));
    % MSE is stored in err array
    err(i) = immse(y_fir(i,:), y_iir(i,:));
end

% Save to files
fx = fopen('input_x.dat','w');
fprintf(fx, '%f\n', x);
fb_fir = fopen('fir_coeff_b.dat','w');
fprintf(fb_fir, '%f\n', b_fir);
fa_iir = fopen('iir_coeff_a.dat','w');
fprintf(fa_iir, '%f\n', a_iir);
fb_iir = fopen('iir_coeff_b.dat','w');
fprintf(fb_iir, '%f\n', b_iir);

end


%%%%%%%%%%%%%%%
function err = immse(y0, y1)

y0_n = size(y0, 2);
accum = 0;

for i = 1:y0_n
    accum = accum + (y0(i) - y1(i))*(y0(i) - y1(i));
end
err = accum / y0_n;

end
