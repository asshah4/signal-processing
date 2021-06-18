%% Analysis of Biostamp HRV data

% Notes from Neeti
%{ 
Hey Anish,

Sorry for the late response to your questions. No worries if you don't have the
chance to analyze today! I appreciate it regardless. Regarding your questions,
I'm not very familiar with these systems (this is a side project I'm working
on), but I hope these answers are helpful:


 1. The first 6 subjects (199-229) were on Biostamp RC, and the last 8
    (240-261) were recorded with the Biostamp nPoint sensors
 2. I believe the measurements are simply Volts.
 3. Absolute time does not matter; however, we were interested in looking at
    24-hour data (similar to something Amit had done in the past in veterans
    with depression I believe).
 4. The recording frequency is 250Hz for the Biostamp nPoint subjects; however,
    for the RC subjects, I'm not 100% sure, but based on the files the elec
    recording timepoints are 8ms apart, so 125 Hz.
 5. It would be nice to have the accelerometry data analyzed at some point, but
    since that is not the main focus, it is totally fine if it is later. The
    sampling frequency is 31.25 Hz +/- 16G.

Please let me know if you have any other questions!

Neeti
%}

%% Set up workspace
% Clear workspace
clear; clc; close all;

% Add necessary files to path in home folder
% Should be in github directory level
addpath(genpath(pwd));
raw_data = [fileparts(fileparts(pwd)) filesep 'data' filesep 'biostamp' filesep 'raw_data'];
proc_data = [fileparts(raw_data) filesep 'proc_data'];


% Plotting variable
plotting = 0;

%% Single File Run

% Data intake
files = dir(fullfile(raw_data, '*.csv'));
i = 3;
filename = regexprep(files(i).name, '.csv', '');
mkdir(proc_data, filename);

% Extract number to determine frequency
num = sscanf(filename, 'elec_%d');
if num <= 229
    Fs = 125;
else
    Fs = 250;
end

% Voltage and ECG signal
T = readtable([raw_data filesep filename '.csv']);
ecg = T{:, 2} * 1000; % Adjust voltage to milivolts
tm = 0:1/Fs:(length(ecg)-1)/Fs;

% Set up HRV parameters
HRVparams = InitializeHRVparams(filename);
HRVparams.Fs = Fs; 
HRVparams.PeakDetect.REF_PERIOD = 0.250;
HRVparams.PeakDetect.THRES = .7;    
HRVparams.preprocess.lowerphysiolim = 60/240;
HRVparams.preprocess.upperphysiolim = 60/30; 
HRVparams.windowlength = 30;	      % Default: 300, seconds
HRVparams.increment = 30;             % Default: 30, seconds increment
HRVparams.numsegs = 5;                % Default: 5, number of segments to collect with lowest HR
HRVparams.RejectionThreshold = .30;   % Default: 0.2, amount (%) of data that can be rejected before a
HRVparams.MissingDataThreshold = .15;
HRVparams.increment = 10;
HRVparams.readdata = [proc_data filesep filename];
HRVparams.writedata = [proc_data filesep filename];
HRVparams.MSE.on = 0; % No MSE analysis for this demo
HRVparams.DFA.on = 0; % No DFA analysis for this demo
HRVparams.HRT.on = 0; % No HRT analysis for this demo
HRVparams.output.separate = 1; % Write out results per patient

% Clean up newly created files
movefile(['data' filesep 'proc_data' filesep '*.csv'], [proc_data filesep filename]);
movefile(['data' filesep 'proc_data' filesep '*.tex'], [proc_data filesep filename]);

% Plot
figure(1)
plot(tm, ecg);
xlabel('[s]');
ylabel('[mV]');
r_peaks = jqrs(ecg, HRVparams);
hold on;
plot(r_peaks./Fs, ecg(r_peaks),'o');
legend('ecg signal', 'detected R peaks');

% Run HRV analysis
[results, resFilenameHRV] = ... 
    Main_HRV_Analysis(ecg, [], 'ECGWaveform', HRVparams, filename);

%% Analysis for all patients

tstart = tic;

% Data intake
files = dir(fullfile(raw_data, '*.csv'));

parfor i = 1:length(files)
    
    tloop = tic;

    filename = regexprep(files(i).name, '.csv', '');
    mkdir(proc_data, filename);

    % Extract number to determine frequency
    num = sscanf(filename, 'elec_%d');
    if num <= 229
        Fs = 125;
    else
        Fs = 250;
    end

    % Voltage and ECG signal
    T = readtable([raw_data filesep filename '.csv']);
    ecg = T{:, 2} * 1000;
    tm = 0:1/Fs:(length(ecg)-1)/Fs;

    % Set up HRv parameters
    HRVparams = InitializeHRVparams(filename);
    HRVparams.Fs = Fs; 
    HRVparams.PeakDetect.REF_PERIOD = 0.250;
    HRVparams.PeakDetect.THRES = .6;    
    HRVparams.preprocess.lowerphysiolim = 60/160;
    HRVparams.preprocess.upperphysiolim = 60/30; 
    HRVparams.windowlength = 30;	      % Default: 300, seconds
    HRVparams.increment = 30;             % Default: 30, seconds increment
    HRVparams.numsegs = 5;                % Default: 5, number of segments to collect with lowest HR
    HRVparams.RejectionThreshold = .20;   % Default: 0.2, amount (%) of data that can be rejected before a
    HRVparams.MissingDataThreshold = .15;
    HRVparams.increment = 10;
    HRVparams.readdata = [proc_data filesep filename];
    HRVparams.writedata = [proc_data filesep filename];
    HRVparams.MSE.on = 0; % No MSE analysis for this demo
    HRVparams.DFA.on = 0; % No DFA analysis for this demo
    HRVparams.HRT.on = 0; % No HRT analysis for this demo
    HRVparams.output.separate = 1; % Write out results per patient

    % Clean up newly created files
    movefile(['data' filesep 'proc_data' filesep '*.csv'], [proc_data filesep filename]);
    movefile(['data' filesep 'proc_data' filesep '*.tex'], [proc_data filesep filename]);
    
    % Run HRV analysis
    [results, resFilenameHRV] = ... 
        Main_HRV_Analysis(ecg, [], 'ECGWaveform', HRVparams, filename);
    
    fprintf('HRV analysis done for %s.\n', filename);
	toc(tloop)
    
end


fprintf('Total Run Time...');
toc(tstart)

