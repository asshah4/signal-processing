function [f,P] = find_fft( ECGraw_interval,Fs )
%   ORIGINAL SOURCE AND AUTHORS:     
%       Nil Z. Gurel   - 06.29.2018
% Finds fft of signal

            % Sampling frequency
T = 1/Fs;             % Sampling period
L = length(ECGraw_interval);             % Length of signal
%t = (0:L-1)*T;        % Time vector

R_fft=fft(ECGraw_interval);
P2 = abs(R_fft/L);
P = P2(1:L/2+1);
P(2:end-1) = 2*P(2:end-1);

f = Fs*(0:(L/2))/L;
end

