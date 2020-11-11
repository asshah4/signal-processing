clear all
close all


    % 
    % Code for CARRS study - 12 Lead ECG data
    % Signal conversion from XML to .mat / wfdb files
    % The ECG signal is recorded at 1000Hz +/- 2 Hz, no time stamps are provided 
    %  
    %
    % INPUTS :
    %     file_root : path for the *.XML file 
    %     Output_root : folder for saving converted files
    %	  PNG_fig : folder for saving the 12-ECG raw data
    %
    % OUTPUTS :
    %     *.mat, file with the raw ECG signals in microVolts (no time stamps)
    %     *.hea, header of each file, containing Lead information, samples and FS 
    %     wfdb format raw ECG signals 
    %
    % Erick Andres Perez Alday erick@dbmi.emory.edu (last update October 15 2019)
    %




file_root = '/labs/cliffordlab/data/CARRS/CARRS-Emory_ECG_Data/CARRS-Emory_ECG_Data-XML/Ali CARRS 2nd Follow-up (With PID)'

Output_root='/labs/cliffordlab/data/CARRS/CARRS-Emory_ECG_Data/CARRS-Emory_ECG_Data-XML/WFDB_mat'

PNG_fig='/labs/cliffordlab/data/CARRS/CARRS-Emory_ECG_Data/CARRS-EmoryECGData-PNGs/12_lead-ECG';

% Order of which the waveforms are structured in the file - 8 independent leads
lead_name{1}='Lead I';
lead_name{2}='Lead II';
lead_name{7}='V1';
lead_name{8}='V2';
lead_name{9}='V3';
lead_name{10}='V4';
lead_name{11}='V5';
lead_name{12}='V6';

% Calculated leads
lead_name{3}='Lead III';
lead_name{4}='aVR';
lead_name{5}='aVL';
lead_name{6}='aVF';

labels=lead_name;

tachofiles=dir(fullfile(file_root,filesep,'**','*.xml'));
%tachofiles=dir([file_root filesep '*.xml']);

FS=1000; %from XML file, assuming they all have the same frequency, need to check this, the information is in the file.
units='2.52/uV'; % assume but not confirmed, the information is in the file


% Delimiter, it is a n XML file.
delimiter = '>';
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s %s %[^\n\r]';


for file_no = 1:length(tachofiles)

	ECG=[];
%	filename_d = [file_root filesep tachofiles(file_no).name];
        filename_d = [tachofiles(file_no).folder filesep tachofiles(file_no).name];
	
	File_ID = strsplit(tachofiles(file_no).name,'.');

	File_ID=File_ID{1};

    %% Open second part of xml file.
    % Read columns of data as text:
    % For more information, see the TEXTSCAN documentation.
    %% Open the text file.
    fileID = fopen(filename_d,'r');
    %% Read columns of data according to the format.
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false,'HeaderLines',113);
    %% Close the text file.
    fclose(fileID);

	
	for jj =1:12
		B_test=strsplit(dataArray{2}{((jj-1)*10)+1});
		    for ii =1:length(B_test)-1
		        tmp_dat=str2num(B_test{ii});
			ECG(jj,ii) = tmp_dat;
		    end
	end

	
	% Create ann files in '.mat' format and header files in '.hea' format
	val=ECG';
	[length_sample,num_channels]=size(val);

	% check sum - code 
        for ii=1:num_channels
                check_sum_val(ii)=eval_check_sum(val(:,ii));
        end

	File_ID

	% Create ann file
        save([Output_root filesep File_ID '.mat'],'val')

	% Create header
        fID = fopen([Output_root filesep File_ID '.hea'],'w');
        fprintf(fID,'%s %d %d %d\n',File_ID,num_channels,FS,length_sample);
        for ii=1:num_channels
                fprintf(fID,'%s %d %s %d %d %d %d %s\n',[File_ID,'.mat'],0,units,0,0,check_sum_val(ii),0,labels{ii});
        end
        fclose(fID);

	save_figure(PNG_fig,File_ID,val',labels);

%break
close all

end

% Check sum code. Looks more for bin files
function check_sum = eval_check_sum(y)


    bit = 16;
    check_sum = nansum(y);

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

function save_figure(file_root, file_ID,ECG,lead_name)

%fig2=figure('visible','off');
fig2=figure('units','normalized','outerposition',[0 0 1 1],'visible','off')

Time=(1:1:length(ECG(1,:)))*0.001;

        index = reshape(1:12,4,3).';
	for ii=1:12%num_channels
		subplot(3,4,index(ii))
		plot(Time,ECG(ii,:))
		title(lead_name{ii})
		xlabel('Time (seconds)')
		ylabel('Amplitude (microVolts)')
	end

saveas(fig2,[file_root filesep file_ID '.png'])

end
