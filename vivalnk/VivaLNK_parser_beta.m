function VivaLNK_parser_beta(dataDir, fileName)
% function VivaLink_parser_beta(dataDir, fileName)
%
% Matlab code that parses VivaLink data in .mat format.
%
% Inputs :
%          - dataDir : path to file that need to be converted
%          - fileName: file name of the file to convert, without extension
% Outputs:
%
%          - file containing ECG signal and time stamps, saved as fileName
%            with .mat extansion in the same directory (dir) of raw data
%          - file containing 3 axis acc signal (xyz)  and time stamps,
%            saved as structur in fileName with .mat extansion in the
%            same directory (dir) of raw data
%
% Example :
%         VivaLink_parser_beta('/Users/gdapoia/data', 'demo')
%
% Notes :
% ECG, Sampling rate: 128 Hz, :45 Resolution: 16 bits, gain 1000
% Accelerometer, Sampling rate: 5 Hz Resolution: 14 bit resolution over +/- 4G range.
%
% To dos: change output format for the file, e.g. wfdb
%
% Author: Giulia Da Poian
% email: giulia.dap@gmail.com
% May 2019; Last revision: 05-June-2019
%
% Last edited on 07/15/2019 by Erick Andres Perez Alday
% Smaller edits done by Anish Shah, 07/26/19

% File input, works on both forward and back slash connectors
% Input file has to be '.txt' format
fid = fopen([dataDir filesep fileName '.txt'],'r');


ecg_gain = 1000;
fs_ecg = 128;
ts_ecg = 1000/fs_ecg;
fs_acc = 5;
ts_acc = 1000/fs_acc;

Block = 1;
idx_ecg = 1;
idx_acc = 1;
tic;
while (~feof(fid))
      InputText = textscan(fid,'%s',1,'delimiter','\n');
      HeaderLines{Block,1} = InputText{1};
      linea_hea = strsplit(HeaderLines{Block,1}{:},{'{' , ','});
      tmp_time_stamp = strsplit(linea_hea{2},'=');
      time_stamp(Block) = str2num(tmp_time_stamp{2}); % unix time

      % skip next two lines we do not need now
      tmp = fgetl(fid); tmp = fgetl(fid);

      % read ECG line
      FormatString = '%s%q';
      ecgText = textscan(fid, FormatString, 1,'Delimiter', ':');
      ecg_block = str2num(cell2mat(strsplit(ecgText{1,2}{:},',')));

      for kk = 1:length(ecg_block)
          t(idx_ecg) = time_stamp(Block) + 1*ts_ecg;
          ecg(idx_ecg) = ecg_block(kk);
          idx_ecg = idx_ecg+1;
      end

      % read ACC
      tmp = fgetl(fid); tmp = fgetl(fid);
      accText =  strsplit(fgetl(fid),','); % get blocks of x,y,z acc at 5Hz
      acc_block = vec2mat(str2num([accText{:}]),3);
      for kk = 1:size(acc_block,1)
          acc.time(idx_acc) = time_stamp(Block) + 1*ts_acc;
          acc.x(idx_acc) = acc_block(kk,1);
          acc.y(idx_acc) = acc_block(kk,2);
          acc.z(idx_acc) = acc_block(kk,3);
          idx_acc = idx_acc+1;
      end
      % skip empty line
      tmp = fgetl(fid);

      Block = Block + 1;
end
fclose(fid);
toc

% Sort data
[t_sort,pos_t_sort] = sort(t); % Get the order of B
ecg_sort=ecg(pos_t_sort);

% Save ecg and timestamps
ecg = ecg_sort./ecg_gain; % convert to mV
t = t_sort;
save([dataDir filesep fileName '_ecg.mat'], 't', 'ecg');

% ...repeat for acc

[~, pos_t_sort_acc] = sort(acc.time); % Get the order of B
acc.x = acc.x(pos_t_sort_acc);
acc.y = acc.y(pos_t_sort_acc);
acc.z = acc.z(pos_t_sort_acc);
acc.time = acc.time(pos_t_sort_acc);
% Save acc as mat structure

save([dataDir filesep fileName '_acc.mat'],'acc');
