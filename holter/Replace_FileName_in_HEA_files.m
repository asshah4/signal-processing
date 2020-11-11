function Replace_FileName_in_HEA_files(fileName)

% Replace_FileName_in_HEA_files(fileName)
%
% OVERVIEW This function correct the header files replacing the '000' and
%          'MITSIG.000' with string with the correct number\name of the file
%          making possible to open the corresponding .SIG file using the 
%          'rdsamp' function 
%          It also replaces the wrong time and date using the one from .qrs
%          files
%
% INPUT    fileName - name of the file without extansion
%
% Written by Giulia Da Poian (giulia.dap@gmail.com)
% Modified by Erick Andres Perez Alday (erick@dbmi.emory.edu)

%Input__Folder_qrs = '/Volumes/epicore-ts/epiprojs/epicore/ETSF - Emory Twin Study Follow-up/DATA/Holter Research Export/QRSDK format exports (QRS)'; 
%Input__Folder_qrs =  '/Volumes/epicore-ts/epiprojs/epicore/ETSF - Emory Twin Study Follow-up/DATA/Holter Research Export/Re-exported QRSDK format (QRS)';
%Input__Folder_qrs = '/run/user/1035700618/gvfs/smb-share:server=nasn2acts.cc.emory.edu,share=epicore-ts/epiprojs/epicore/ETSF - Emory Twin Study Follow-up/DATA/Holter Research Export/QRSDK format exports (QRS)';
Input__Folder_qrs = [pwd filesep 'raw_data'];

ext = '.HEA';


fileID = fopen([Input__Folder_qrs filesep fileName ext],'r');

i = 1;
% Get first line and replace '000' with signal name
tline = fgetl(fileID);
A{i} = tline;
A{i} = [ fileName, ' ', A{1}(4 + size(A{1},1):end)]; % Replace  '000' with file name

% Now change time and date with the one from the  .qrs file 
% if .qrs file exist

try
    
    try
       [~,~,~,~,~,~,~,tstart, datestart] = read_qrs([Input__Folder_qrs filesep fileName '.QRS']);
    catch
        [~,~,~,~,~,~,~,tstart, datestart] = read_qrs([Input__Folder_qrs filesep fileName 'C.qrs']);
    end   
   
    cc  = strsplit(A{i});
    % tmp{5} time
    % tmp{6} date
    cc{5} = tstart';
    formatOut = 'dd/mm/yyyy';
    cc{6} = datestr(datestart',formatOut);
    A{i} = strjoin(cc);   
	e=1
catch
    fid_log = fopen('NotQRSdate.txt','a');
    fprintf(fid_log,'%s \n', fileName);
    fclose(fid_log);
	e=2
end

fileName

% Get other lines and replace with sigName.SIG
while ischar(tline)
    i = i+1;
    tline = fgetl(fileID);
    A{i} = strrep(tline, 'MITSIG.000', [fileName '.SIG']); 
end
fclose(fileID);

% Write cell into txt
fileID = fopen([fileName ext], 'w');
for i = 1:numel(A)
    if A{i+1} == -1
        fprintf(fileID,'%s', A{i});
        break
    else
        fprintf(fileID,'%s\n', A{i});
    end
end
fclose(fileID);
