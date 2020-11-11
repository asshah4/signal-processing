function [chunk_ecgf,chunksignal ] = find_EA_Qpks( ecg_fqrs, Qpkslocs,signal,samples)

%   from Q peak

chunkecg_samples=samples; 
chunk_ecgf=zeros(chunkecg_samples,length(Qpkslocs)); 

%%%%%%%% fill the new matrix
ind=1;
while ind<length(Qpkslocs)
    chunk_ecgf(:,ind) = ecg_fqrs(Qpkslocs(ind):Qpkslocs(ind) + chunkecg_samples -1);

    ind=ind+1;
end

chunk_ecgf(:, ind:end) = []; 

mean_ecg_filtered=mean(chunk_ecgf');

figure(11);
hold on;
for i=1:size(chunk_ecgf,2)
    plot(chunk_ecgf(:,i));
end
hold on;
plot(mean_ecg_filtered,'LineWidth',3);
xlabel('Samples'); ylabel('ECG ');
grid on;


%any signal you wanna ensemble average wrt ECG Qpkslocs
chunksignal=zeros(chunkecg_samples,length(Qpkslocs)); 

%%%%%%%% fill the new matrix
ind=1;
while ind<length(Qpkslocs)
    chunksignal(:,ind) = signal(Qpkslocs(ind):Qpkslocs(ind) + chunkecg_samples -1);
    ind=ind+1;
end

chunksignal(:, ind:end) = []; %remove the latest unfilled one
Qpkslocs = Qpkslocs(1:ind-1);

mean_signal=mean(chunksignal');

figure(12);
hold on;
for i=1:size(chunksignal,2)
    plot(chunksignal(:,i));
end
plot(mean_signal,'LineWidth',3,'MarkerFaceColor','w');
xlabel('Samples'); ylabel('Chunk Signal');
grid on;
end

