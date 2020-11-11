function te_points = findTe_ECG(data, q_points, tp_points, negativeT, sampling_rate)
if negativeT
    tp_points(:,2) = -tp_points(:,2);
    data = -data;
end
length_data = length(data);
te_points = zeros(length(tp_points),2);
length_t = round(200*sampling_rate/1000);

[rw,cl]=size(tp_points);

for ii = 1:rw %length(tp_points)
    p = polyfit([tp_points(ii,1) tp_points(ii,1)+length_t], [tp_points(ii,2) 0], 1);
    linedif = [];
    for jj = 1:length_t%round(.7*(q_points(ii,1)-tp_points(ii,1)))
        if jj+tp_points(ii,1)<= length_data
            linedif(jj) = polyval(p,jj+tp_points(ii,1))-data(jj+tp_points(ii,1));
        else
            linedif(jj) = polyval(p,jj+tp_points(ii,1))-data(jj);
        end
    end
    [te_val te_index]= max(linedif);
    if te_index+tp_points(ii,1)-1<=length(data)
        te_points(ii,1) = te_index+tp_points(ii,1)-1;
        te_points(ii,2) = data(te_points(ii,1));
    else
        break;
    end
end
if negativeT
    te_points(:,2) = -te_points(:,2);
end
