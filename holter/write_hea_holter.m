function write_hea_holter(folder, recordName, fs, numsig,datapoints, date_time, format,gain,ADCzero,baseline, firstSamp,checksum,blocksize)

% write_hea(folder, recordName, fs, datapoints, date_time, gain)
%
% ORIGINAL SOURCE AND AUTHORS:     
%       This script written by Giulia Da Poian
% COPYRIGHT (C) 2018 
% LICENSE:    
%       This software is offered freely and without warranty under 
%       the GNU (v3 or later) public license. See license file for
%       more information

annotator = 'mat';
filename = strcat(recordName, '.', annotator);
unit = 'mV';

fileID = fopen(strcat(folder,filesep,recordName, '.hea'),'w');
fprintf(fileID,'%s %d %d %d %s\n', recordName, numsig, fs, datapoints, date_time);
for i = 1:numsig    
    fprintf(fileID,'%s %s %.3f/%s %i %i %i %i %i MARS Export \n', filename,format, gain(i),unit,ADCzero,baseline,firstSamp(i),checksum(i),blocksize);
    %3001.SIG 16 50/mV 0 0 2 28088 0 MARS export
end
fprintf(fileID,'#Creator: WFDB matlab export');
fclose(fileID);

end
