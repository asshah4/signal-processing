% Based off of the file 'ConvertRawDataToRRIntervals.m'
% Physionet needs to be on path
% TO BE DONE:
%   Convert RR and T vectors into table
%   Write into a readable file
%
function rri = SaveRRIntervals(directory)

% Get raw signal from text file
VivaLNK_parser_beta([pwd filesep directory], directory);

% Call in the ECG raw signal
raw = load([directory filesep directory '_ecg.mat']);
ecg = raw.ecg;

% Make sure initialized HRV data is available
HRVparams = InitializeHRVparams(directory);

% Call Giulia's HRV toolbox scrpit
[t,rr,jqrs_ann,SQIjw, StartIdxSQIwindows_jw] = ...
    ConvertRawDataToRRIntervals(ecg, HRVparams, directory);

% We only care about time and RR interval (in seconds), write to matrix



% EOF
end
