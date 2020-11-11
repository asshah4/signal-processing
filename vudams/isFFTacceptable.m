function [ verdict ] = isFFTacceptable( fs,DZDTbeat )

% Checks if DZDT beat is acceptable, according to fft spectrum
%assumes 25 Hz noise (active VNS device). Uses find_fft.
%true: acceptable
%tweak the thresholds if necessary.
warning off;
f_threshold=15; %safe region

[f,P]=find_fft( DZDTbeat,fs );
[maxval maxloc]=max(P);
f_mP=f(maxloc); %the frequency at which max P happens

% s25Hz=knnsearch(f',25);
% s20Hz=knnsearch(f',20);
% s10Hz=knnsearch(f',10);
% 
% [~,peaklocs_25] = findpeaks(P(s25Hz:end),'MinPeakHeight',maxval);  %from 25 hz to the end %threshold is empiric
% [~,peaklocs_20] = findpeaks(P(s20Hz:end),'MinPeakHeight',maxval);  %from 20 hz to the end %threshold is empiric
% [~,peaklocs_10] = findpeaks(P(s10Hz:end),'MinPeakHeight',0.8*maxval);  %from 10 hz to the end %threshold is empiric

if (f_mP<f_threshold) %&& (isempty(peaklocs_20)==1) && (isempty(peaklocs_10)==1) && (isempty(peaklocs_25)==1)
    verdict=true; %acceptable
else
    verdict=false;
end



end

