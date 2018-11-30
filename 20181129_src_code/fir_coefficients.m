% ====================================================================
% Setting FIR coefficients
%   Ver01 - 2018/11/25 - Thomas
% ====================================================================

function [b, y] = fir_coefficients(samp_freq, fil_order, x, freq_band)

% Filter parameters
fs = samp_freq;  % sampling frequency
fl = freq_band(1);
fh = freq_band(2);
Wl = (2 * fl)/fs;
Wh = (2 * fh)/fs;
b = fir1(fil_order, [Wl, Wh]); % order=20
%fvtool(b, 1, 'fs', Fs)

% Signal filtered
% t = linspace(0, 5, fs);
t = 0:1/fs:10-(1/fs);
y = filter(b, 1, x);
fig = figure(3);
clf(fig);
plot(t, x, t, y)
xlabel('Time (s)')
ylabel('Amplitude')
legend('Original Signal','FIR Filtered Data')

end