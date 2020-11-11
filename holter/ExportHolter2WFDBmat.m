% This script convert holter files in MIT (.SIG and .HEA files) into Matlab
% wfdb compatible files (note use of wfdb2mat returns corrupted files)

%% Prepare workspace
% Clean data space
clear;
clc;

% Establish path to umbrella folder (holter folder)
addpath(genpath(pwd));

% Path for WFDB for matlab
addpath(genpath('C:\Users\asshah4\Documents\MATLAB\mcode'));


%% Identify data folders

% Path to raw and processed data
InputFolder = ['raw_data'];
OutFolder = ['proc_data'];


% File names
fileNames = dir([InputFolder filesep '*.SIG']);


%% Loop to execute

% For loop to go through files for conversion
for idx = 1:1%length(fileNames)
    
    conv_error = 0; 
    tmp = strsplit(fileNames(idx).name,'.')
    patid = tmp{1};
    clear val;
    clear sigInfo;
    clear gain;
    clear check_sum;
    clear ecg;
    
    if ~exist([OutFolder filesep patid '.mat']) || ~exist([OutFolder filesep patid '.hea'])
       
        sigInfo = wfdbdesc(['raw_data' filesep patid]); 
        Nleads = size(sigInfo,2);
        B = str2double(sigInfo(1).Format);
        try
            for iLead = 1:Nleads
                 [ecg(iLead,:),Fs] = rdsamp([InputFolder filesep patid] , iLead);
                 tmpgain = strsplit(sigInfo(iLead).Gain,' ');
                 gain(iLead) = str2double(tmpgain{1});
                 val(iLead,:) = (ecg(iLead,:).*gain(iLead))+sigInfo(iLead).Baseline;
                 check_sum(iLead) = eval_check_sum(val(iLead,:));
                 if check_sum(iLead) ~= sigInfo(iLead).CheckSum
                     fid = fopen([OutFolder filesep 'ConversionLog.txt'],'a');
                     fprintf(fid,'%s \t Error \n ',patid);
                     fclose(fid);
                     conv_error = 1;
                 end
            end
        catch
            conv_error = 1;
        end

        if ~conv_error
            try
                save([OutFolder filesep patid '.mat'] , 'val');
                write_hea_holter(OutFolder, patid, Fs, size(val,1), size(val,2), ...
                                sigInfo(1).StartTime(2:end-1), sigInfo(1).Format,gain, ...
                                sigInfo(1).AdcZero,sigInfo(1).Baseline, round(val(:,1)),round(check_sum),0)

                fid = fopen([OutFolder filesep 'ConversionLog.txt'],'a');
                fprintf(fid,'%s \t Successful \n ',patid);
                fclose(fid);
                            
            catch
                 fid = fopen([OutFolder filesep 'ConversionLog.txt'],'a');
                 fprintf(fid,'%s \t Error \n ',patid);
                 fclose(fid);
            end

        end
    end

end



function check_sum = eval_check_sum(y)
    
    bit = 16;
    check_sum = sum(y);
    M = check_sum/(2^(bit-1));
    if(M<0)
        check_sum = mod(check_sum,-2^(bit-1));
        if(~check_sum && abs(M)<1)
            check_sum = -2^(bit-1);
        elseif (mod(ceil(M),2))
            check_sum = 2^(bit-1) + check_sum;
        end
    else
        check_sum = mod(check_sum,2^(bit-1));
        if(mod(floor(M),2))
            check_sum = -2^(bit-1)+check_sum;
        end
    end
end
