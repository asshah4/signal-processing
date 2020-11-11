function [ t_PEP,PEP,t_PEP_corrected,PEP_corrected] = find_PEP(fs,chunkdzdt,t_Rpeaks)

%corrected outputs: 5%-95% corrected version of raw PEP values

% optional: exponential moving average. if M_dzdt=1 beats, regular ensemble
% averaging.
%make sure M is not high to lose the transient changes. For 3-min long
%signal, I think M=10 beats is good 
M_dzdt=10;
I_dzdt=zeros(size(chunkdzdt,1),size(chunkdzdt,2));
E_dzdt=zeros(size(chunkdzdt,1),size(chunkdzdt,2));
alpha=2/(M_dzdt+1);
for i=1:size(chunkdzdt,2)   
    I_dzdt(:,i)=chunkdzdt(:,i);
    if i==1
        E_dzdt(:,i)=I_dzdt(:,i);
    else
        E_dzdt(:,i)=alpha*I_dzdt(:,i)+(1-alpha)*E_dzdt(:,i-1);
    end
end

figure(8);
subplot(211);
hold on;
for i=1:size(E_dzdt,2)
    plot(E_dzdt(:,i));
end
title('EMA');
ylabel('DZDT (ohm/s)');
grid on;
subplot(212);
hold on;
for i=1:size(chunkdzdt,2)
    plot(chunkdzdt(:,i));
end
xlabel('Sample #');
title('Raw Beats');
ylabel('DZDT (ohm/s)');
grid on;
%%%%%

a=0;
r=0;
accepted_index=[];
rejected_index=[];
Bpt=zeros(1,size(chunkdzdt,2));
PEP_dummy=zeros(1,size(chunkdzdt,2));

%%these thresholds should be tunes according to patient. To automatize it,
%%operations from the mean/max/min of the beat could also be carried out
%%but either way we're watching everything manually patient by patient 
maxval_dzdt_th=1.2;
minval_dzdt_th=-0.8;
maxloc_dzdt_th=200; 
Bptmin=1;
Bptmax=200;

f1=figure(11);%for PEP
f2=figure(12); %rejected
f3=figure(13); %to plot values

% analyzing each beats starts here

hold on;
for i=1:size(chunkdzdt,2)
    
    temp_dzdt=E_dzdt(:,i);%dzdt matrix
    samples=1:length(temp_dzdt); 
    [maxval_dzdt,maxloc_dzdt]=max(temp_dzdt);
    [minval_dzdt,~]=min(temp_dzdt);
    Bpt=findiB(temp_dzdt); %try to find a b point

    if  (isempty(Bpt)==0) && (maxloc_dzdt<maxloc_dzdt_th) && (maxloc_dzdt>Bpt) && (Bpt>Bptmin*1000/fs) && (Bpt<Bptmax*1000/fs ) && (isFFTacceptable( fs,temp_dzdt )==1) && (maxval_dzdt<maxval_dzdt_th) && (minval_dzdt>minval_dzdt_th) 
        a=a+1;
        accepted_index(a)=i;                
        PEP_dummy(i) =Bpt*1000/fs; %in ms;     
        set(0, 'CurrentFigure', f1)
        hold on;
        plot(samples,temp_dzdt);
        plot(Bpt,temp_dzdt(Bpt),'gv','MarkerFaceColor','b');
        plot(maxloc_dzdt,temp_dzdt(maxloc_dzdt),'bv','MarkerFaceColor','m');
        ylabel('Accepted');
        xlabel('sample #');     
        
    else
         PEP_dummy(i)=-1;
        r=r+1;
        rejected_index(r)=i;
        set(0, 'CurrentFigure', f2)
        hold on;
        plot(samples,temp_dzdt);
        ylabel('Rejected');        
        xlabel('sample #');
    end
end
grid on;

t_PEP=t_Rpeaks(accepted_index);
PEP=PEP_dummy(accepted_index); %in ms, already multiplied above

set(0, 'CurrentFigure', f3);
subplot(211);
plot(t_PEP,PEP,'ko');
ylabel( 'PEP (ms)');
str2=sprintf(' PEP mean= %.2f, std=%.2f',mean(PEP),std(PEP));
title(str2);
grid on;

%delete outliers 
PEP_corrected = PEP;
t_PEP_corrected=t_PEP;
percntiles_PEP = prctile(PEP_corrected,[5 95]); %5th and 95th percentile
outlierIndex_PEP = PEP_corrected < percntiles_PEP(1) | PEP_corrected > percntiles_PEP(2);
%remove outlier values
PEP_corrected(outlierIndex_PEP) = [];
t_PEP_corrected(outlierIndex_PEP) = [];

subplot(212);
plot(t_PEP_corrected,PEP_corrected,'ko');
ylabel( 'PEP interval corrected (ms) ');
xlabel('Time (s)');
str2=sprintf(' PEP corrected mean= %.2f, std=%.2f',mean(PEP_corrected),std(PEP_corrected));
title(str2);
grid on;

end



