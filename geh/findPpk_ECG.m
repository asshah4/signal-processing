function ppk_points = findPpk_ECG(data, Qonsets, Toffsets, sampling_rate)

[rw cl]=size(Qonsets);

ppk_points=zeros(rw,cl);
length_pr = round(200*sampling_rate/1000); %200ms

%Ppk Detection
for ii = 1:rw %length(q_points)
    if ii==1
        pp_b=max(1,Qonsets(ii)-length_pr);
        pp_e=Qonsets(ii);
    else
        pp_b = max(Toffsets(ii-1),Qonsets(ii)-length_pr);
        pp_e = Qonsets(ii);
    end
    
    if length(data) >= pp_e
        [pp_val pp_index] = max(data(pp_b:pp_e));
    else
        [pp_val pp_index] = max(data(pp_b:length(data)));
    end
    pp_index = pp_index+pp_b;
    if ~isempty(pp_index)
        ppk_points(ii,1) = pp_index-1;
        ppk_points(ii,2) = pp_val;
    else
        ppk_points(ii,1) = 1;
        ppk_points(ii,2) = 1;
    end
end