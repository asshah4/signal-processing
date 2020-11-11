function [tp_points negativeT] = findTp_ECG(maximums, data, markers, q_points, channel_number)
sel_RT = markers(3);
sel_QR = -markers(1);
sel_QT = markers(3)-markers(1);
sel_QJ = markers(2) - markers(1);
if size(maximums,1)==1
    sel_RR = sel_QT;
else
    sel_RR = maximums(2,1) - maximums(1,1);
end
clear tp_points;
testb_tp_b = maximums(1,1) + sel_QR;
testb_tp_e = q_points(1,1);
test_tp_b = maximums(1,1) + round(sel_QJ*1.5);
%if channel_number == 3
%    sel_QJ = sel_QJ - 100;
%end
test_tp_e = maximums(1,1) + sel_RT;
beat1_tp1 = max(data(test_tp_b:test_tp_e));
beat1_tp2 = abs(min(data(test_tp_b:test_tp_e)));
neg = 10;
if channel_number == neg  %|| channel_number == 2
    negativeT = 1;
%     data = -data;
%     maximums(:,2) = -maximums(:,2);
end
if channel_number ~= neg %&& channel_number ~= 2
    if beat1_tp2 > beat1_tp1
        if channel_number == 20% || channel_number == 2
            negativeT = 0;
        else
            negativeT = 1;
%             data = -data;
%             maximums(:,2) = -maximums(:,2);
        end
    else
        negativeT = 0;
    end
end
% 
% if channel_number == 1
%     figure(100);
%     plot(data(1:5000))
%     negativeT = str2num(input('Lead X: Positive T(0)/Negative T(1)', 's'));
%     close(100);
% elseif channel_number == 2
%     figure(100);
%     plot(data(1:5000))
%     negativeT = str2num(input('Lead Y: Positive T(0)/Negative T(1)', 's'));
%     close(100);
% else
%     figure(100);
%     plot(data(1:5000))
%     negativeT = str2num(input('Lead Z: Positive T(0)/Negative T(1)', 's'));
%     close(100);
% end

if negativeT == 1
     data = -data;
     maximums(:,2) = -maximums(:,2);
end

tp_points(:,1) = maximums(:,1);
tp_points(:,2) = maximums(:,2);

[rw cl]=size(q_points);

%Tp Detection
for ii = 1:rw %length(q_points)
    tp_b = tp_points(ii,1) + sel_QJ;
    %if channel_number == 1 || channel_number == 2
    %    tp_e = tp_points(ii,1) + sel_RT-50;
    %else
    tp_e = tp_points(ii,1) + sel_RT;
    %end
    if length(data) >= tp_e
        [tp_val tp_index] = max(data(tp_b:tp_e));
    else
        [tp_val tp_index] = max(data(tp_b:length(data)));
    end
    tp_index = tp_index+tp_b;
    if ~isempty(tp_index)
        tp_points(ii,1) = tp_index-1;
        tp_points(ii,2) = tp_val;
    else
        tp_points(ii,1) = 1;
        tp_points(ii,2) = 1;
    end
end
if negativeT
    tp_points(:,2) = -tp_points(:,2);
end