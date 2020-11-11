%% PEP testing script for Anish Shah
%% Nil Z. Gurel - nil@gatech.edu 
%% Created: 8.23.2019
%% uses sample DZDT and ECG data to derive PEP
%% run section-by-section to see the generated plots to understand what's going on.
%% click the section and hit 'Run section' from Editor above to run only the separate code sections
%% the last two sections are optional for use in your scripts for extracting data/parsing


%% load data
load('test_PEP.mat')

%% Sampling rate
fs=1000;
ts=1/fs;
t=0:ts:ts*(length(ECG_TEST)-1);

figure(); plot(t,ECG_TEST); hold on; plot(t,DZDT_TEST);
legend('ECG Test','DZDT Test');

%% Filter -filtering takes sometime
f_icg=filter_icg;
dzdt_f=filtfilthd(f_icg, DZDT_TEST);
clear f_icg;

f_ecg=filter_ecg;
ecg_fqrs=filtfilthd(f_ecg, ECG_TEST);
clear f_ecg;


%% find Qpeaks - Q and R peaks are marked
threshold=0.15;
mindist=50;
[Qpeakslocs,t_Qpks] = find_Qpeaks(fs,threshold,mindist,ecg_fqrs);
% t_Qpks=t_Qpks+tstart;

%% Ensemble averaging 
threshold=0.15; %for locating R-peaks
mindist=50;
beatlen=600; % sample length
[cecgf,cdzdtf ] = find_EA_Qpks( ecg_fqrs, Qpeakslocs,dzdt_f,beatlen );

%% find PEP
[tPEP,PEP,tPEPc,PEPc] = find_PEP(fs,cdzdtf,t_Qpks);

%% TO BE MODIFIED FOR YOUR SCRIPTS:extracting VU-AMS data (.txt) to MATLAB vector, these files should be inside the same MATLAB path/folder

fid = fopen('11031048_ECG.txt'); %filename
d=textscan(fid, '%*s%s%*s%*[^\n]');  % loads only the second column
fclose(fid);
ECG_cell=d{:};
ECG=str2double(ECG_cell);
ECG=ECG(4:end); %ignore info columns
clear ECG_cell;

fid = fopen('11031048_DZDT.txt'); %filename
C=textscan(fid, '%*s%s%*s%*[^\n]'); % loads only the second column
fclose(fid);
DZDT_cell=C{:};
DZDT=str2double(DZDT_cell);
DZDT=DZDT(4:end);
clear DZDT_cell;

%% TO BE MODIFIED FOR YOUR SCRIPTS: parsing a vector

% made-up start and end timestamps in sec
rests=150;
reste=180;

%find the corresponding sample numbers in t-vector
Srests = knnsearch(t',rests); 
Sreste = knnsearch(t',reste);

% extract these intervals from ECG and DZDT vectors (or from filtered
% versions, whichever makes more sense to you)
ECG_Rest=ECG_TEST(Srests:Sreste);
DZDT_Rest=DZDT_TEST(Srests:Sreste);

%after parsing, go on with regular processing (filtering, ensemble averaging
%etc..)

