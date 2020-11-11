%% Script for exploring .sig and .hea files from MARS Holter

% Will review the file formats that should be WFDB compatible

%% Workspace setup

% Clear workspace
clear; clc; close all;

% Add necessary files to path
% Need to be in highest biobank folder
addpath(genpath(pwd));

% Folder holding data
raw_data = [pwd filesep 'raw_data'];
header = 'test.hea';
signal = 'test.sig';
name = 'test';
headpath = fullfile(raw_data, header);
sigpath = fullfile(raw_data, signal);

%% Header data
% Extract data from first line (patid, channels, fz, XXX, time, date)
fid = fopen(headpath);
A = strsplit(fgetl(fid), ' ');
fclose(fid);


%% Signal data

% These are binary files... need to read them in somehow
fid = fopen(sigpath);
A = fread(fid);
fclose(fid);

% Attempt to use WFDB?
[tm, sig, Fs] = rdsamp(A, 1);
wfdb2mat('test.sig');

% Signal name
load([raw_data filesep name]);
load('C:\Users\asshah4\Downloads\118');



%% Reading in signal and header files

% Load the data
fprintf(1, '\n$> Working on %s...\n', header);

x = fopen(headpath, 'r');
y = fgetl(x);
z = sscanf(y, '%s %d %d %d',[1,3]);

% Header read
fid = fopen(headpath, 'r');

A = textscan(fid, '%s');
