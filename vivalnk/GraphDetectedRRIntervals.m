% File to visualize ECG morphology and labeled RR peaks
function patient = GraphDetectedRRIntervals(directory)

% Add all necessary files to path
% Presume in vivaLNK folder
Folder = pwd();
Folder = fullfile(Folder, '..');
addpath(genpath(Folder));

% Remove pre-existing parameter files
delete([directory filesep 'Parameters*']);
delete([directory filesep '*.fig']);

% VivaLNK parser to run
VivaLNK_parser_beta([pwd filesep directory], directory);

% Load ECG signal, leave time stamps behind
ecg = load([directory filesep directory '_ecg.mat'], 'ecg');
ecg = ecg.ecg;

% Load basic paramaters of HRV Analysis, including sample frequency
HRVparams = InitializeHRVparams(directory);
Fs = HRVparams.Fs;

% Create time vector for visualizing data
tm = 0:1/Fs:(length(ecg)-1)/Fs;

% plot the signal
figure(1);
plot(tm,ecg);
xlabel('[s]');
ylabel('[mV]');

% call the function that perform peak detection
% added a multiplier of a 1000 to get a detection of value
r_peaks = jqrs(ecg,HRVparams);

% plot the detected r_peaks on the top of the ecg signal
figure(1);
hold on;
plot(r_peaks./Fs, ecg(r_peaks),'o');
legend('ecg signal', 'detected R peaks');

% Save file
saveas(figure(1), [directory filesep directory '.fig'])

% end of file
end
