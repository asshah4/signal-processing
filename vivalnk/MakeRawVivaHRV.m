function patientSelect = MakeRawVivaHRV(directory)
% Summary function that completes multiple tasks in sequence
%   1. will clean the directory of where raw VivaLNK log is held (*.txt)
%   2. it will parse the raw file into a MAT file that has ECG signal
%   3. Loads HRV parameters from the toolbox
%   4. Creates teh HRV using main analysis from toolbox
%
% Currently it takes 2-10 minutes to run per file, based on length of recording
% Before running, check quality of file using the GraphDetectedRRIntervals() fn
%
% Written by Anish Shah, 07/31/19
% Contact: mrshahman@gmail.com

% Add all necessary files to path
% Presume in vivaLNK folder
Folder = pwd();
Folder = fullfile(Folder, '..');
addpath(genpath(Folder));

% Remove pre-existing files
delete([directory filesep '*.csv']);
delete([directory filesep '*.mat']);
delete([directory filesep '*.tex']);
delete([directory filesep 'File*']); % prior success file
delete([directory filesep 'Analysis*']); % analysis failure file
OldFolder = [pwd filesep directory filesep 'Annotation'];
if exist(OldFolder, 'dir')
    rmdir(OldFolder, 's');
end

% Allow VivaLNK parser to run
VivaLNK_parser_beta([pwd filesep directory], directory);

% Extract RR and T vectors
raw_ecg = load([pwd filesep directory filesep directory '_ecg.mat'], 'ecg');
ecg = raw_ecg.ecg;
t = load([pwd filesep directory filesep directory '_ecg.mat'], 't');

% Load HRV paramaters
HRVparams = InitializeHRVparams(directory);
HRVparams.MSE.on = 0; % No MSE analysis for this demo
HRVparams.DFA.on = 0; % No DFA analysis for this demo
HRVparams.HRT.on = 0; % No HRT analysis for this demo
HRVparams.output.separate = 0;   % For this demo write all the results in one file

% Running HRV Analysis
[results, resFilenameHRV] = Main_HRV_Analysis(ecg,[],'ECGWaveform',HRVparams,directory);

% End of program
end
