function [Qpeakslocs,t_Qpeaks] = find_Qpeaks(fs,threshold,mindist,ecg)


[~,Rpeakslocs] = findpeaks(ecg,'MinPeakHeight',threshold,...
                                    'MinPeakDistance',mindist);
ts=1/fs;
samples=1:length(ecg);
%t_ecg=0:ts:ts*(length(ecg)-1);

figure();
% subplot(211);
hold on;
plot(samples,ecg);
plot(Rpeakslocs,ecg(Rpeakslocs),'rv','MarkerFaceColor','r');
grid on;
xlabel('Sample #');
ylabel('ECG');
% legend('ECG','R-peaks')

%find minimum before the peak (around 50-100 samples before)
Qpeakslocs=[];
Qploc_current=[];
temp=[];
Rploc_current=[];
lookback=50;
for i=1:length(Rpeakslocs)
    %search the area 50-samples before each peak and find its local min
    
   Rploc_current=Rpeakslocs(i);
   temp=ecg((Rploc_current-lookback):Rploc_current);
   [~,temp_minloc] = min(temp);
   Qploc_current=Rploc_current-lookback+temp_minloc;
   Qpeakslocs=[Qpeakslocs Qploc_current];
   Qploc_current=[];
   temp=[];
   Rploc_current=[];
end

% subplot(212);
hold on;
plot(Qpeakslocs,ecg(Qpeakslocs),'go','MarkerFaceColor','b');
grid on;
xlabel('Sample #');
ylabel('ECG');
% legend('ECG','Q-peaks')

t_Qpeaks=Qpeakslocs/fs; %in seconds)





end

