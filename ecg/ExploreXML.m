%% Explore WFDB analysis of ECG XML formats

InputFolder = ['raw_data'];
patid = 'sample.mat';

ECG_w = ECGwrapper();
ECG_w.recording_name = [InputFolder filesep patid];
ECG_w.ECGtaskHandle = 'QRS_detection';

tmp = load([InputFolder filesep patid]);