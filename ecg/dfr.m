%% Data intake

% Clear workspace
clear; clc; close all;

% Add necessary files to path
% Need to be in highest biobank folder
addpath(genpath(pwd));

% Data
name = 'dfr-clean';
loc = [pwd filesep 'data' filesep name '.mat'];
raw = load(loc);
data = raw.EKG;
leads = data.original;
ekg = leads(1,1).volt;
t = leads(1,1).time;
Fs = 300;


%% Set up HRV
HRVparams = InitializeHRVparams(name);
HRVparams.Fs = Fs; 
HRVparams.PeakDetect.REF_PERIOD = 0.150;
HRVparams.preprocess.lowerphysiolim = 60/200;
HRVparams.preprocess.upperphysiolim = 60/30; 
HRVparams.readdata = [pwd filesep 'data' filesep name];
HRVparams.writedata = [pwd filesep 'data' filesep name];
HRVparams.MSE.on = 0; % No MSE analysis for this demo
HRVparams.DFA.on = 0; % No DFA analysis for this demo
HRVparams.HRT.on = 0; % No HRT analysis for this demo
HRVparams.output.separate = 1; % Write out results per patient

%% Clean up data first
% Remove artifact
A = ekg;
A(A < 1.1) = NaN;
B = medfilt1(A, 3, 'truncate');
B = fillmissing(A, 'movmean', 50);
C = medfilt1(B, 20);
C = smooth(B);
plot(tm, C);


%% Plot
ecg = ekg;

% Identify good plot...
figure(1);
tm = 0:1/Fs:(length(ecg)-1)/Fs;
plot(tm, ecg);
xlabel('[s]');
ylabel('[mV]');

r_peaks = jqrs(ecg, HRVparams);

% plot the detected r_peaks on the top of the ecg signal
figure(1);
hold on;
plot(r_peaks./Fs, ecg(r_peaks),'o');
legend('ecg signal', 'detected R peaks');

%% Make HRV
[results, resFilenameHRV] = ...
  Main_HRV_Analysis(ecg, [], 'ECGWaveform', HRVparams, name);