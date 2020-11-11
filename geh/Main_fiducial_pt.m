clear all
clc
close all
warning('OFF');

tic


%% Code to automatically calculated Fiducial points for single ECG beat.

% Input:
% single ECG beat
%
% Output:
% Fiducial points



% This code includes different methods, such as:
% Pan Thompkins and time series analysis
% distance to point line, maximum or minimum dv/dt


%% load mat files and create directories

% path to file
pname='';

%% file name
filename='test.mat';

file=strcat(pname,filename);
name0=strsplit(filename,'.');
matfile=load(file);

Fid_pnt_main(matfile,file,name0)

   


%% Main analysis Function: Fid_pnt_main

function Fid_pnt_main(matfile,filename,name0)


% The method is based on Pan Thompkins and time series analysis
%% Set up markers and Vicinities ad_hoc physiological values for fs=500

	fs=500;
	markers = round([-32 26 206] * (fs/500));

	Rvic    = 299;
	Rp_vic  = 50;
	Qof_vic1 = 40;
	Qof_vic2 = 50;
	Qef_vic1 = 15;
	Qef_vic2 = 50;
	Up_vic   = [20,100];
	Ue_vic = 50;
	Ts_vic   = 80;
	Ue_vic   = 70;
	Pe_vic   = 50;
	Ps_vic   = 40;


	% load the variable, val = ECG beat
	% check the dimension this may produce errors, transpose if it is not Nx1
        VecMag = matfile.val';
   
       
	%% previous code to compute the fidutial points. Used as a started point for the rest of the computation.

	[R_VM,q_points_VM,s_points_VM,tp_points_VM,te_points_VM,ts_points_VM,Ppeaks_VM,pe_points_VM,ps_points_VM]=Find_fid_fast(VecMag,Rvic,Rp_vic,Qof_vic1,fs,Qof_vic2,Qef_vic2,markers,Ts_vic,Ps_vic);

	%% plot the first version of the fid point

	figure(1)

        plot(VecMag);
        hold on;
        plot(R_VM,VecMag(R_VM),'ro');
        plot(q_points_VM(1,1),VecMag(q_points_VM(1,1)),'r*');
        plot(s_points_VM(1,1),VecMag(s_points_VM(1,1)),'k*');

        plot(tp_points_VM(1,1),VecMag(tp_points_VM(1,1)),'y*');
        plot(te_points_VM(1,1),VecMag(te_points_VM(1,1)),'c*');
        plot(ts_points_VM(1,1),VecMag(ts_points_VM(1,1)),'r*');


        plot(Ppeaks_VM(1,1),VecMag(Ppeaks_VM(1,1)),'c*');
        plot(pe_points_VM(1,1),VecMag(pe_points_VM(1,1)),'g*');
        plot(ps_points_VM(1,1),VecMag(ps_points_VM(1,1)),'r*');


      
	%% find P end based on distance to point line
	[pe_points_VM,q_points_VM]=find_P_2_app(VecMag,Ppeaks_VM,pe_points_VM,q_points_VM);

	%% find begining of QRS complex base on distance to point line
	[pe_points_VM,q_points_VM2]=find_QRS_dist_approach(VecMag,R_VM,pe_points_VM,q_points_VM);

	%% second approach to find end of P-wave, this can be used as a loop in case something is modifyied 
	if q_points_VM2(1,1) ~= q_points_VM(1,1)
		q_points_VM(1,1)=q_points_VM2(1,1);
		%[pe_points_VM]=find_p_end_2_approach(VecMag,Ppeaks_VM,q_points_VM,pe_points_VM);
	end

	[pe_points_VM]=find_p_end_2_approach(VecMag,Ppeaks_VM,q_points_VM,pe_points_VM);

	%% find the end of QRS complex (s_point) based on distance to point line[s_points_VM]=find_Qs_off_2_approach(VecMag,R_VM,s_points_VM);

	[s_points_VM]=find_Qs_off_2_approach(VecMag,R_VM,s_points_VM);	

	%% find the beginning of the T wave base on the distance to point line, it also includes de end of the T wave, but I'm not currently using it

	[ts_points_VM2]=find_T_2_approach(VecMag,ts_points_VM,tp_points_VM, s_points_VM);

	if ts_points_VM2>ts_points_VM
		ts_points_VM=ts_points_VM2;
	end


	%% find the beginning of the P-wave base on distance to point line
	[ps_points_VM,Ppeaks_VM]=find_P_2_approach(VecMag,Ppeaks_VM,pe_points_VM,ps_points_VM);

	%% plot the fidutial points again to compare
	plot_fid_pnt(VecMag,R_VM,q_points_VM,s_points_VM,tp_points_VM,te_points_VM,ts_points_VM,Ppeaks_VM,pe_points_VM,ps_points_VM,name0);


%	close all
end

%% first approach to calculate fidutial points 
function [R_VM,q_points_VM,s_points_VM,tp_points_VM,te_points_VM,ts_points_VM,Ppeaks_VM,pe_points_VM,ps_points_VM]=Find_fid_fast(VecMag,Rvic,Rp_vic,Qof_vic1,fs,Qof_vic2,Qef_vic2,markers,Ts_vic,Ps_vic)

	ind0=[];   
        %find R peak
	
	beat_L  = length(VecMag); 
        [~,R_VM] = max(VecMag);
%        R_VM = R_VM + Rvic-Rp_vic-1;


        % Find Qend Fast
        Qef_Rp = smooth(VecMag(R_VM:R_VM+Qof_vic1));
        D_Qef  = diff(Qef_Rp);    
        F_Qef = find(D_Qef<-15);
        F_Qef_inv = flipud(F_Qef);
        temp2 = []; S2 = 4; % 4 consecutive samples

 
        for i=1:length(F_Qef)-S2
            if sum(diff(F_Qef(i:i+S2)))==S2
                temp2 = [temp2;F_Qef(i)];
                Qef  = max(temp2)+R_VM+S2;            
            end        
        end    


        VM_maximums=[]; 
        VM_maximums(1:length(R_VM),1)=R_VM;
        VM_maximums(1:length(R_VM),2)=VecMag(R_VM); 


        % QRS onset and offset
 
        [q_points_VM s_points_VM] = find_QRS(VecMag, fs, .08, 'q', VM_maximums,1);
        D_Qsf = diff(VecMag(q_points_VM(1,1)-Qof_vic2:q_points_VM(1,1)));
        F_Qsf = find(flipud(D_Qsf)>0);
        for i=1:length(F_Qsf)-2
            if (F_Qsf(i+1)-F_Qsf(i)==1)&&(F_Qsf(i+2)-F_Qsf(i+1)~=1)
                ind0=i+1;
                break;                  
            end        
        end

        if isempty(ind0)
            q_points_VM(1,1) = q_points_VM(1,1);
        else
            q_points_VM(1,1) = q_points_VM(1,1)-ind0;
        end

        D_Qef = diff(VecMag(s_points_VM(1,1):s_points_VM(1,1)+Qef_vic2));
        F_Qef = find(flipud(D_Qef)<-15); 
        ind1=0;
        if ~isempty(F_Qef)        
            for i=1:length(F_Qef)-2
                if (F_Qef(i+1)-F_Qef(i)==1)&&(F_Qef(i+2)-F_Qef(i+1)~=1)
                    ind1=i+1;
                    break;  
                elseif (F_Qef(i+1)-F_Qef(i)==1)&&(F_Qef(i+2)-F_Qef(i+1)==1)
                    ind1=i+1;
                end        
            end 
            s_points_VM(1,1) = s_points_VM(1,1)+ind1;        
        end


        % Tpeak
        [tp_points_VM negativeT_VM] = findTp_ECG(VM_maximums, VecMag, markers, q_points_VM, 1);

        % Tend
        te_points_VM = findTe_ECG(VecMag, q_points_VM, tp_points_VM, negativeT_VM, fs);

        % Ton

        [ts_points_VM(1,2),ts_points_VM(1,1)]= min(VecMag(tp_points_VM(1,1)-Ts_vic:tp_points_VM(1,1))); 
        ts_points_VM(1,1)=tp_points_VM(1,1)-Ts_vic+fix(ts_points_VM(1,1));


        % Find Pwave

	pp_test=q_points_VM(1,1)-10;
 
        Ppeaks_VM = findPpk_ECG(VecMag, pp_test, te_points_VM(1,1), fs);

        if Ppeaks_VM(1,1) <Ps_vic +10           
	  	Ppeaks_VM=q_points_VM(1,1)-20;
        end

        [max_p_pos max_p_val]=max(VecMag(Ppeaks_VM(1,1)-20:Ppeaks_VM(1,1)+20));

        if max_p_pos>1
	        Ppeaks_VM(1,1)=max_p_val+Ppeaks_VM(1,1)-20;
		pp_test=Ppeaks_VM(1,1)+30;
        end
 
        %P start and end points
    %     pe_points_VM = findPe_ECG(VecMag, q_points_VM(1,1), Ppeaks_VM, 0, fs);
        [pe_points_VM(1,2),pe_points_VM(1,1)]= min(smooth(VecMag(Ppeaks_VM(1,1):Ppeaks_VM(1,1)+20)));
        pe_points_VM(1,1)=fix(pe_points_VM(1,1))+Ppeaks_VM(1,1);
 

    %     ps_points_VM = findPs_ECG(VecMag, Ppeaks_VM, 0, fs);
        [ps_points_VM(1,2),ps_points_VM(1,1)]= min(smooth(VecMag(Ppeaks_VM(1,1)-Ps_vic:Ppeaks_VM(1,1))));
        ps_points_VM(1,1)=Ppeaks_VM(1,1)-Ps_vic+fix(ps_points_VM(1,1));


end


%find P peak and the end of the P wave base on distance to point line

function [pe_points_VM,q_points_VM]=find_P_2_app(VecMag,Ppeaks_VM,pe_points_VM,q_points_VM)
%        L3   = Ppeaks_VM(1,1_):R_VM;
	
        pp_test=Ppeaks_VM(1,1)+30;
	L3=Ppeaks_VM(1,1):pp_test;

        d    = nan(length(L3),1);
        C    = nan(length(L3),2);    
        a    = 0.6;
%        a1   = fix(L3(1)+a*(L3(end)-L3(1)));
	a1=pp_test;
        P2 = [a1,VecMag(a1)];    
        PpP2 = [(L3(1):P2(1,1))', VecMag(L3(1):P2(1,1))'];

        for i=1:length(Ppeaks_VM(1,1):P2(1,1))
            [d(i), C(i,:), t0] = distancePoint2Line([L3(1),VecMag(L3(1))], P2, PpP2(i,:), 'line');
        end
        [d_m,ind_d_m] = max(d);
        pe_points_VM2 = fix(C(ind_d_m,:));

        [~,pe_Val] = min([pe_points_VM(1,2),pe_points_VM2(1,2)]);
        
	if pe_Val==1
		pe_points_VM=pe_points_VM(1,1);
	else
		pe_points_VM=pe_points_VM2(1,1);
	end

      	if pe_points_VM(1,1)>q_points_VM(1,1)
		q_points_VM(1,1)=pe_points_VM(1,1)+1;
	end

end


%Find Q onset 2

function [pe_points_VM,q_points_VMR2]=find_QRS_dist_approach(VecMag,R_VM,pe_points_VM,q_points_VM)

	Rp_d_2=find(VecMag(100:R_VM)>(VecMag(R_VM)/2),1,'first');
	Rp_d_2=Rp_d_2+100;

	d_R2=[];
	C_R2=[];

	if pe_points_VM >= Rp_d_2
		pe_points_VM=Rp_d_2-30;
	end
    
	L_R2=pe_points_VM:Rp_d_2;

	PpP2_R2 = [(L_R2(1):Rp_d_2(1))', VecMag(pe_points_VM:Rp_d_2)'];

	P1_R2=[pe_points_VM,VecMag(pe_points_VM)];
	P2_R2=[Rp_d_2,VecMag(Rp_d_2)];

	for ii=1:length(pe_points_VM:Rp_d_2)
		[d_R2(ii), C_R2(ii,:),t0_R2]=distancePoint2Line(P1_R2,P2_R2,PpP2_R2(ii,:),'line');
	end

        [d_m_R2,ind_d_m_R2] = max(d_R2);
        R_VM_R2 = fix(C_R2(ind_d_m_R2,:));

	% QRS onset and offset
        q_points_VM2=[];ind02=[];

	if (q_points_VM(1,1)<R_VM_R2(1,1)) && (abs(q_points_VM(1,1)-R_VM_R2(1,1))<20)
		q_points_VM2=q_points_VM(1,1)-5;
	else
		q_points_VM2=R_VM_R2(1,1)-20;

	end

        
        D_Qsf_R2 = diff(smooth(VecMag(q_points_VM2:R_VM_R2(1,1))));

	D_D_Qsf=diff(diff(smooth(VecMag)));

	ind03=[];
	for ii=1:length(D_Qsf_R2)-1

		if abs(D_Qsf_R2(ii))>10 && abs(D_Qsf_R2(ii+1))>10
			ind03=ii;
			break;
		end
	end

        if isempty(ind03)
            q_points_VMR2(1,1) = R_VM_R2(1,1);
        else
            q_points_VMR2(1,1) = q_points_VM2+ind03;
        end


	if R_VM_R2(1,1)==q_points_VMR2(1,1) && D_D_Qsf(q_points_VMR2(1,1))<0
		q_points_VMR2(1,1)=q_points_VM(1,1);
	end

end


%% P_end if q_on changed

function [pe_points_VM]=find_p_end_2_approach(VecMag,Ppeaks_VM,q_points_VMR2,pe_points_VM1)

	if Ppeaks_VM(1,1)>=q_points_VMR2(1,1)
	    Ppeaks_VM(1,1)=q_points_VMR2(1,1)-30;
	end

	L3=Ppeaks_VM(1,1):q_points_VMR2(1,1);

        d    = nan(length(L3),1);
        C    = nan(length(L3),2);

%        a1   = fix(L3(1)+a*(L3(end)-L3(1)));
        a1=q_points_VMR2(1,1);
        P2 = [a1,VecMag(a1)];
        PpP2 = [(L3(1):P2(1,1))', VecMag(L3(1):P2(1,1))'];

        for i=1:length(Ppeaks_VM(1,1):P2(1,1))
            [d(i), C(i,:), t0] = distancePoint2Line([L3(1),VecMag(L3(1))], P2, PpP2(i,:), 'line');
        end
        [d_m,ind_d_m] = max(d);
        pe_points_VM = fix(C(ind_d_m,:));

        %[pe_points_VM,~] = min([pe_points_VM1(1,1),pe_points_VM2(1,1)]);

end



%% Qs offset

function [s_points_VM2]=find_Qs_off_2_approach(VecMag,R_VM,s_points_VM)

	ind0s3=[];

	Qs_2=find(VecMag(1:R_VM)>(VecMag(R_VM)/2),1,'last');

	L_S2=Qs_2:s_points_VM(1,1);

	PpP2_S2 = [(L_S2(1):s_points_VM(1,1))', VecMag(Qs_2:s_points_VM(1,1))'];

	P1_S2=[Qs_2,VecMag(Qs_2)];
	P2_S2=[s_points_VM(1,1),VecMag(s_points_VM(1,1))];

	for ii=1:length(L_S2)
		[d_S2(ii), C_S2(ii,:),t0_S2]=distancePoint2Line(P1_S2,P2_S2,PpP2_S2(ii,:),'line');
	end

        [d_m_S2,ind_d_m_S2] = max(d_S2);
        R_VM_S2 = fix(C_S2(ind_d_m_S2,:));

	if s_points_VM(1,1)<R_VM_S2(1,1)
		s1_VM2=s_points_VM(1,1)-5;
		s2_VM2=R_VM_S2(1,1)+5;
	else
		s1_VM2=R_VM_S2(1,1)-5;
		s2_VM2=s_points_VM(1,1)+5;
	end

	[max_s_pos max_s_val]=max(VecMag(s1_VM2+5:s2_VM2-5));

	if max_s_val>1
		s1_VM2=max_s_val+s1_VM2+5;
		s2_VM2=max_s_val+40+s1_VM2;
	end

	D_Qsf_S2 = flip(diff(smooth(VecMag(s1_VM2:s2_VM2))));
	D_D_Qsf_S2=diff(diff(smooth(VecMag)));

	for ii=1:length(D_Qsf_S2)-1

        	if abs(D_Qsf_S2(ii))>5 && abs(D_Qsf_S2(ii+1))>5
		        ind0s3=ii;
		        break;
	        end
	end

        if isempty(ind0s3)
            s_points_VM2(1,1) = R_VM_S2(1,1);
        else
            s_points_VM2(1,1) = s2_VM2-ind0s3;
        end

end


%% T_begining

function [ts_points_VM]=find_T_2_approach(VecMag,ts_points_VM,tp_points_VM,s_points_VM)

	if s_points_VM(1,1) > tp_points_VM(1,1)
		s_points_VM(1,1)=tp_points_VM(1,1)-90;
	end
	Ls_T2=s_points_VM(1,1):tp_points_VM(1,1);
   
	PpP2_T2s = [(Ls_T2(1):Ls_T2(end))', VecMag(Ls_T2(1):Ls_T2(end))'];

	P2_T2s=[tp_points_VM(1,1),VecMag(tp_points_VM(1,1))];
	P1_T2s=[Ls_T2(1),0];

	for ii=1:length(Ls_T2)
		[ds_T2(ii), Cs_T2(ii,:),t0_T2s]=distancePoint2Line(P1_T2s,P2_T2s,PpP2_T2s(ii,:),'line');
	end

        [d_s_T2,ind_d_s_T2] = max(ds_T2);
       ts_points_VM = fix(Cs_T2(ind_d_s_T2,:));


	%% Tend offset

	L_T2=tp_points_VM(1,1):length(VecMag);

	PpP2_T2 = [(L_T2(1):length(VecMag))', VecMag(tp_points_VM(1,1):end)'];

	P1_T2=[tp_points_VM(1,1),VecMag(tp_points_VM(1,1))];
	P2_T2=[L_T2(end),0];

	for ii=1:length(L_T2)
		[d_T2(ii), C_T2(ii,:),t0_T2]=distancePoint2Line(P1_T2,P2_T2,PpP2_T2(ii,:),'line');
	end

        [d_m_T2,ind_d_m_T2] = max(d_T2);
        tp_points_VM = fix(C_T2(ind_d_m_T2,:));


end



%% P_onset offset

function [ps_points_VM,Ppeaks_VM]=find_P_2_approach(VecMag,Ppeaks_VM,pe_points_VM,ps_points_VM)

	[lp_p,ps_p]=min(VecMag(ps_points_VM(1,1)-20:ps_points_VM(1,1)+10));

	ps_p=ps_p+ps_points_VM(1,1)-20;

	if ps_p > Ppeaks_VM(1,1)
	    [lp_max,ps_max]=max(VecMag(ps_p:ps_p+100));
	    Ppeaks_VM(1,1)=ps_max+ps_p;
	end

	L_P2=ps_p-20:Ppeaks_VM(1,1);

	PpP2_P2 = [(L_P2(1):Ppeaks_VM(1,1))', VecMag(L_P2(1):Ppeaks_VM(1,1))'];

	P1_P2=[L_P2(1),0];
	P2_P2=[Ppeaks_VM(1,1),VecMag(Ppeaks_VM(1,1))];
	
	for ii=1:length(L_P2)
		[d_P2(ii), C_P2(ii,:),t0_P2]=distancePoint2Line(P1_P2,P2_P2,PpP2_P2(ii,:),'line');
	end	

	if isnan(d_P2)==1
		ps_points_VM=ps_points_VM;
	else
	        [d_m_P2,ind_d_m_P2] = max(d_P2);
        	ps_points_VM = fix(C_P2(ind_d_m_P2,:));
	end

	[val_p pos_p]=max(VecMag(ps_points_VM:pe_points_VM));

	if val_p>VecMag(Ppeaks_VM(1,1))
		Ppeaks_VM(1,1)=pos_p+ps_points_VM(1,1)-1;
	end

	if abs(lp_p-VecMag(ps_points_VM(1,1)))>30
		 ps_points_VM(1,1)=ps_p;
	end
end


function plot_fid_pnt(VecMag,R_VM,q_points_VM,s_points_VM,tp_points_VM,te_points_VM,ts_points_VM,Ppeaks_VM,pe_points_VM,ps_points_VM,name0)

      

        Fid_Pnts_Fig = figure('visible','on');%,'units','normalized','outerposition',[0 0 1 1]);

        plot(VecMag);hold on;

        pp=plot([Ppeaks_VM(1,1) Ppeaks_VM(1,1)],[0 VecMag(R_VM)+10],'Color',[0 0 0],'LineStyle','--','DisplayName','P peak');

        pe=plot([pe_points_VM(1,1) pe_points_VM(1,1)],[0 VecMag(R_VM)+10],'Color',[0.5 0.5 0.5],'LineStyle','--','DisplayName','P end');

        ps=plot([ps_points_VM(1,1) ps_points_VM(1,1)],[0 VecMag(R_VM)+10],'Color',[0.75 0.75 0.75],'LineStyle','--','DisplayName','P onset');



        r1=plot([R_VM R_VM],[0 VecMag(R_VM)+10],'r--', 'DisplayName','R peak');

        q1=plot([q_points_VM(1,1) q_points_VM(1,1)],[0 VecMag(R_VM)+10],'m--', 'DisplayName','QRS onset');

        s1=plot([s_points_VM(1,1) s_points_VM(1,1)],[0 VecMag(R_VM)+10],'b--', 'DisplayName','QRS end');

        tp=plot([tp_points_VM(1,1) tp_points_VM(1,1)],[0 VecMag(R_VM)+10],'y--', 'DisplayName',' T peak');
        te=plot([te_points_VM(1,1) te_points_VM(1,1)],[0 VecMag(R_VM)+10],'c--','DisplayName','T end'); 




        ts=plot([ts_points_VM(1,1) ts_points_VM(1,1)],[0 VecMag(R_VM)+10],'g--','DisplayName','T onset');    

        lgd = legend([ps pp pe q1 r1 s1 ts tp te],'location','eastoutside');

	hold off


end
