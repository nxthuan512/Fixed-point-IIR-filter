% ====================================================================
% Setting IIR coefficients
%   Ver01 - 2018/11/25 - Thomas
% ====================================================================
function [a, b, y] = iir_coefficients(samp_freq, fil_order, x, freq_band)

% Filter parameters
fs = samp_freq;  % sampling frequency
fl = freq_band(1);
fh = freq_band(2);
Wl = (2 * fl)/fs;
Wh = (2 * fh)/fs;
[b, a] = butter(fil_order, [Wl, Wh], 'bandpass'); % filter order = 2*fil_order

% plot magnitude response
w = 0:0.01:pi;
[h, om] = freqz(b, a, w);
m = 20*log10(abs(h));
%figure, plot(om/pi * (fs/2), m);
%axis([0 127 -40 100])
%ylabel('Gain (dB)');
%xlabel('Frequency (Hz)');

% Signal filtered
t = 0:1/fs:10-(1/fs);
y = filter(b, a, x);
fig = figure(2);
clf(fig);
plot(t, x, t, y)
xlabel('Time (s)')
ylabel('Amplitude')
legend('Original Signal','IIR Filtered Data')

end