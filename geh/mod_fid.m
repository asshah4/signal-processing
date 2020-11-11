
tachofiles=dir('/home/perezald/Desktop/AHA_grant_data/BIDMC_GEHCO_ECGs/All_data_for_GEH/Fid_pts_images/fix_mat_files/*.mat');

for file_dat=1:length(tachofiles)

A=[];

file_no=strsplit(tachofiles(file_dat).name,'.')



root_dat='/home/perezald/Desktop/AHA_grant_data/BIDMC_GEHCO_ECGs/All_data_for_GEH/Fid_pts_images/fix_mat_files/';

images_filanem=strcat('/home/perezald/Desktop/AHA_grant_data/BIDMC_GEHCO_ECGs/All_data_for_GEH/Fid_pts_images/fix_mat_files/Images/',file_no{1},'FidPnt.jpg');

filename=strcat(root_dat,file_no{1},'.mat')
A=load(filename);

VecMag=A.VecMag_ML;
R_VM_T=A.R_VM_T;
pe_points_VM_T=A.pe_points_VM_T;
ps_points_VM_T=A.ps_points_VM_T;
Ppeaks_VM_T=A.Ppeaks_VM_T;
q_points_VM_T=A.q_points_VM_T;
s_points_VM_T=A.s_points_VM_T;
ts_points_VM_T=A.ts_points_VM_T;
te_points_VM_T=A.te_points_VM_T;
tp_points_VM_T=A.tp_points_VM_T;

XYZ_M=A.XYZ_M_T;


Fid_Pnts_Fig=figure('units','normalized','outerposition',[0 0 1 1]);

        subplot(2,1,1)
        plot(VecMag,'LineWidth',2);
	hold on;
	r1=plot([R_VM_T R_VM_T],[0 VecMag(R_VM_T)+10],'r--','LineWidth',2, 'DisplayName','R peak');

        q1=plot([q_points_VM_T(1,1) q_points_VM_T(1,1)],[0 VecMag(q_points_VM_T(1,1))+10],'m--','LineWidth',2, 'DisplayName','QRS onset');

        s1=plot([s_points_VM_T(1,1) s_points_VM_T(1,1)],[0 VecMag(s_points_VM_T(1,1))+10],'b--','LineWidth',2, 'DisplayName','QRS offset');

        tp=plot([tp_points_VM_T(1,1) tp_points_VM_T(1,1)],[0 VecMag(tp_points_VM_T(1,1))+10],'k--','LineWidth',2, 'DisplayName','T peak ');

        te=plot([te_points_VM_T(1,1) te_points_VM_T(1,1)],[0 VecMag(te_points_VM_T(1,1))+10],'c--','LineWidth',2, 'DisplayName','T end');

%        plot(Ppeaks_VM_T(1,1),VecMag(Ppeaks_VM_T(1,1)),'c*');

%        plot(pe_points_VM_T(1,1),VecMag(pe_points_VM_T(1,1)),'g*');

%        plot(ps_points_VM_T(1,1),VecMag(ps_points_VM_T(1,1)),'m*');

        ts=plot([ts_points_VM_T(1,1) ts_points_VM_T(1,1)],[0 VecMag(ts_points_VM_T(1,1))+10],'g--','LineWidth',2, 'DisplayName','T onset');
%        lgd = legend([q1 r1 s1 ts tp te],'location','eastoutside');
        lgd = legend([q1 r1 s1 ts tp te],'location','northeast');

        hold off

        subplot(2,1,2)
        plot(XYZ_M(:,1))
        hold on
        plot(XYZ_M(:,2))
        plot(XYZ_M(:,3))
        hold off

%break
filename
waitforbuttonpress
%pe_points_VM(1,1)=201;
%ps_points_VM(1,1)=144;

%R_VM_T=251;

%Ppeaks_VM(1,1)=166;
q_points_VM_T(1,1)=270;
s_points_VM_T(1,1)=356;
ts_points_VM_T(1,1)=442;
tp_points_VM_T(1,1)=491;
te_points_VM_T(1,1)=559;

    save(filename,'-append','q_points_VM_T','s_points_VM_T','ts_points_VM_T','te_points_VM_T','tp_points_VM_T');


	save(filename,'-append','R_VM_T')


        Fid_Pnts_Fig = figure('units','normalized','outerposition',[0 0 1 1]);


        subplot(2,1,1)
        plot(VecMag,'LineWidth',2);
        hold on;
        r1=plot([R_VM_T R_VM_T],[0 VecMag(R_VM_T)+10],'r--','LineWidth',2, 'DisplayName','R peak');

        q1=plot([q_points_VM_T(1,1) q_points_VM_T(1,1)],[0 VecMag(q_points_VM_T(1,1))+10],'m--','LineWidth',2, 'DisplayName','QRS onset');

        s1=plot([s_points_VM_T(1,1) s_points_VM_T(1,1)],[0 VecMag(s_points_VM_T(1,1))+10],'b--','LineWidth',2, 'DisplayName','QRS offset');

        tp=plot([tp_points_VM_T(1,1) tp_points_VM_T(1,1)],[0 VecMag(tp_points_VM_T(1,1))+10],'k--','LineWidth',2, 'DisplayName','T peak ');

        te=plot([te_points_VM_T(1,1) te_points_VM_T(1,1)],[0 VecMag(te_points_VM_T(1,1))+10],'c--','LineWidth',2, 'DisplayName','T end');

%        plot(Ppeaks_VM_T(1,1),VecMag(Ppeaks_VM_T(1,1)),'c*');

%        plot(pe_points_VM_T(1,1),VecMag(pe_points_VM_T(1,1)),'g*');

%        plot(ps_points_VM_T(1,1),VecMag(ps_points_VM_T(1,1)),'m*');

        ts=plot([ts_points_VM_T(1,1) ts_points_VM_T(1,1)],[0 VecMag(ts_points_VM_T(1,1))+10],'g--','LineWidth',2, 'DisplayName','T onset');
        lgd = legend([q1 r1 s1 ts tp te],'location','northeast');

        hold off

        subplot(2,1,2)
        plot(XYZ_M(:,1))
        hold on
        plot(XYZ_M(:,2))
        plot(XYZ_M(:,3))
        hold off


waitforbuttonpress

movefile(filename,'/home/perezald/Desktop/AHA_grant_data/BIDMC_GEHCO_ECGs/All_data_for_GEH/Fid_pts_images/fix_mat_files/reviewed/')

saveas(Fid_Pnts_Fig,images_filanem)

close all

end
