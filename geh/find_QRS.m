function [q_points s_points] = find_QRS(data, sampling_rate, pcent, mode, r_points, channel_number)
%QRS detection using curve length transformation
data_o = data;
% data = flipud(data_o);
data = smooth(data);
data = smooth(data);
data = smooth(data);

fNorm = [2/(sampling_rate/2) 40/(sampling_rate/2)];
[b,a]=butter(2,fNorm,'bandpass');
data = filtfilt(b,a,data);

data_H = hilbert(data);
env = sqrt(data.^2 + imag(data_H).^2);
r = round(sampling_rate / 250);
ecg_e_prime(1:2*r) = 0;
for ii = 2* r +1:length(env)-2 * r
    ecg_e_prime(ii) = 1/10 * (2*(env(ii+2*r) - env(ii - 2*r))+env(ii + r) - env(ii-r));
end

AS = 2*(ecg_e_prime.^2)';
AS = [AS; zeros(2*r,1)];

for ii = 1:length(r_points(:,1))
    mu_0 = mean(AS(max(1,r_points(ii,1)-round(150 * sampling_rate/1000)):max(1,r_points(ii,1)-round(250 * sampling_rate/1000))));
    mu_1 = mean(AS(max(1,r_points(ii,1)-round(150 * sampling_rate/1000)):r_points(ii,1)));
    lambda = mu_1/mu_0;
    
    find_max_bg = r_points(ii,1) - round(150 * sampling_rate/1000);
    if find_max_bg < 1
        find_max_bg = 1;
    end
    find_max_end = min(r_points(ii,1)+round(25 * sampling_rate/1000),length(AS));
    [pks frqs] = findpeaks(AS(find_max_bg:find_max_end));
    frqs = frqs + find_max_bg -1;
    frqs (pks<max(pks)/5) = [];
    if ii==1 && isempty(frqs)
        ind(ii,1) = r_points(ii,1);
        ind(ii,2) = r_points(ii,2);
    else 
        peak = frqs(1);
    %     find_max_bg = r_points(ii,1) - round(150 * sampling_rate/1000);
    %     if find_max_bg < 1
    %         find_max_bg = 1;
    %     end
        xpts = [find_max_bg peak];
        ypts = AS(xpts)';
        p = polyfit(xpts,ypts, 1);
        length_t = xpts(2) - xpts(1) + 1;
        linedif = [];
        for jj = 1:length_t%round(.7*(q_points(ii,1)-tp_points(ii,1)))
            linedif(jj) = point_to_line([min(jj+find_max_bg,length(AS)) AS(min(jj+find_max_bg,length(AS))) 0], [xpts(1) ypts(1) 0], [xpts(2) ypts(2) 0]);
        end
        [val index]= max(linedif);
        ind(ii,1) = index+find_max_bg-1;
        ind(ii,2) = data_o(ind(ii,1));
    end

end
q_points = ind;


for ii = 1:length(r_points(:,1))
    find_max_bg = r_points(ii,1)-round(25 * sampling_rate/1000);
    if find_max_bg < 1
        find_max_bg = 1;
    end
    find_max_end = r_points(ii,1)+ round(150 * sampling_rate/1000);
    if find_max_end > length(AS)
        find_max_end = length(AS);
    end
    [pks frqs] = findpeaks(AS(find_max_bg:find_max_end));
    frqs = frqs + find_max_bg -1;
    frqs (pks<max(pks)/15) = [];
  
%     if isempty(peak)
%         [pks frqs] = findpeaks(AS(find_max_bg:find_max_end));
%         frqs = frqs + find_max_bg -1;
%         frqs (pks<max(pks)/5) = [];
%     end
    
    find_max_end = r_points(ii,1)+ round(150 * sampling_rate/1000);
    if find_max_end > length(AS)
        find_max_end = length(AS);
    end
    
    if ii==length(r_points(:,1)) && isempty(frqs)
        ind(ii,1) = r_points(ii,1);
        ind(ii,2) = r_points(ii,2);
    else
        peak = frqs(end);
        xpts = [peak find_max_end];
        ypts = AS(xpts)';

        p = polyfit(xpts,ypts, 1);
        length_t = xpts(2) - xpts(1) + 1;
        linedif = [];
        for jj = 1:length_t%round(.7*(q_points(ii,1)-tp_points(ii,1)))
            linedif(jj) = point_to_line([min(jj+peak,length(AS)) AS(min(jj+peak,length(AS))) 0], [xpts(1) ypts(1) 0], [xpts(2) ypts(2) 0]);
        end
        [val index]= max(linedif);
        ind(ii,1) = index+peak-1;
        ind(ii,2) = data_o(ind(ii,1));
    end
end
s_points = ind;
%
% for ii = 1:length(r_points(:,1))
%     g(1) = 0;
%     k = 2;
%     n_1 = r_points(ii,1)-round(300 * sampling_rate/1000);
%     % lambda = max(AS(r_points(ii,1)-round(300 * sampling_rate/1000):r_points(ii,1)-round(250 * sampling_rate/1000)));
%     mu_0 = mean(AS(r_points(ii,1)-round(300 * sampling_rate/1000):r_points(ii,1)-round(250 * sampling_rate/1000)));
%     mu_1 = mean(AS(r_points(ii,1)-round(300 * sampling_rate/1000):r_points(ii,1)));
%     lambda = mu_1/mu_0;
%     while g(k-1) <  lambda
%         %     g(k) = g(k-1) + log(pdf('Normal', AS(k), mu_1,1)/pdf('Normal', AS(k), mu_0, 1));
%         g(k) = AS(k+ n_1);
%         k = k + 1;
%     end
%     q_points(ii,1) = k-1 + n_1;
% end
% q_points(:,2) = data_o(q_points(:,1));
% 
% 
% for ii = 1:length(r_points(:,1))
%     g(1) = 0;
%     k = 2;
%     n_1 = r_points(ii,1)+round(100 * sampling_rate/1000);
%     % lambda = max(AS(r_points(ii,1)-round(300 * sampling_rate/1000):r_points(ii,1)-round(250 * sampling_rate/1000)));
%     mu_0 = mean(AS(r_points(ii,1)+round(100 * sampling_rate/1000):r_points(ii,1)+round(150 * sampling_rate/1000)));
%     mu_1 = mean(AS(r_points(ii,1):r_points(ii,1)+round(150 * sampling_rate/1000)));
%     lambda = mu_1/mu_0;
%     while g(k-1) >  lambda
%         %     g(k) = g(k-1) + log(pdf('Normal', AS(k), mu_1,1)/pdf('Normal', AS(k), mu_0, 1));
%         g(k) = AS(n_1+k);
%         k = k + 1;
%     end
%     s_points(ii,1) = k-1 + n_1;
% end
% s_points(:,2) = data_o(s_points(:,1));


% 
% figure;
% subplot(2,1,1)
% plot(data);
% hold on;
% plot(1:length(env), env, 'r');
% plot(data_o, 'k')
% plot(q_points(:,1), q_points(:,2),'m*');
% plot(s_points(:,1), s_points(:,2),'c*');
% % xlim([300 1000])
% % AS(AS>1000) = 1000;
% % plot(1:length(AS), AS, 'k');
% subplot(2,1,2)
% plot(1:length(AS), AS, 'k');
% % xlim([300 1000])
% pause;

%%

%{
w = round(130 * (sampling_rate/1000));

data = smooth(data);
data = smooth(data);
if mode == 's'
    fNorm = [.01/(sampling_rate/2)];
    [b,a]=butter(2,fNorm,'high');
    data_filter = filtfilt(b,a,data);
    data_filter = [zeros(w,1); data_filter];
    data_filter = smooth(data_filter);
    data_filter = smooth(data_filter);
    data_filter = smooth(data_filter);
else
    data_filter = [zeros(w,1); data];
end
% if mode == 's'
%     data_filter = [zeros(w,1); data];
% end
deltay = diff(data_filter);
L = zeros(length(data),1);
for jj = 1:w+1
    L(1)= L(1) + sqrt(1+deltay(jj)^2);
end
for ii = w+2:length(data_filter)-1
    L(ii-w) = L(ii-w-1) + sqrt(1+deltay(ii)^2)-sqrt(1+deltay(ii-w-1)^2);
end
%
% if mode == 'q'
%     fNorm = [1.2/(sampling_rate/2) 30/(sampling_rate/2)];
%     [b,a]=butter(2,fNorm,'bandpass');
%     L = filtfilt(b,a,L);
% else
%     if channel_number == 1
%         fNorm = [1.2/(sampling_rate/2) 30/(sampling_rate/2)];
%     elseif channel_number == 2
%         fNorm = [1.2/(sampling_rate/2) 30/(sampling_rate/2)];
%     else
%         fNorm = [1.2/(sampling_rate/2) 30/(sampling_rate/2)];
%     end
%     [b,a]=butter(2,fNorm,'bandpass');
%     L = filtfilt(b,a,L);
% end

[temp s_points] = findR_ECG_new(round(130* sampling_rate), L, sampling_rate);
s_points(:,2) = data(s_points(:,1));
for ii = 1:length(s_points)
    xpts = [s_points(ii,1)-round(400*sampling_rate/1000) s_points(ii,1)];
    begpt = s_points(ii,1)-round(400*sampling_rate/1000);
    if begpt < 1
        begpt = 1;
        xpts = [begpt s_points(ii,1)];
    end
    ypts = L(xpts)';
    
    p = polyfit(xpts,ypts, 1);
    length_t = s_points(ii,1) - begpt + 1;
    linedif = [];
    for jj = 1:length_t%round(.7*(q_points(ii,1)-tp_points(ii,1)))
        linedif(jj) = polyval(p,jj+begpt)-L(jj+begpt);
        if linedif(jj) > 0
            linedif(jj) = point_to_line([jj+begpt L(jj+begpt) 0], [xpts(1) ypts(1) 0], [xpts(2) ypts(2) 0]);
        else
            linedif(jj) = 0;
        end
    end
    [val index]= max(linedif);
    ind(ii,1) = index+begpt-1;
    ind(ii,2) = data(ind(ii,1));
end

% figure;
% subplot(2,1,1);
% plot(data_filter(w:end));
% hold on;
% plot(data,'r');
% plot(L,'k');
% plot(s_points(:,1),s_points(:,2),'g*')
% % subplot(2,1,2);
% % plot(L);
% hold on
% plot(ind(:,1),ind(:,2),'c*');
%
% pause;



% if channel_number == 10
%     if mode == 'q'
%         L = data;
%     end
% end
%
% ind2 = zeros(length(r_points(:,1)),2);
% for ii = 1:length(r_points(:,1))
%     if mode == 'q'
%         bg = r_points(ii,1)-round(120*sampling_rate/1000);
%         en = r_points(ii,1);
%     elseif mode == 's'
%         bg = r_points(ii,1)-round(140*sampling_rate/1000);
%         en = r_points(ii,1)-round(40*sampling_rate/1000);
%     end
%     [val in] = min(L(bg:en));
%     in = in + bg - 1;
%     ind2(ii,1) = in;
%     ind2(ii,2) = data(in);
% end
% thresh = L(1) + pcent * max(L);
% L(L<thresh) = 0;
% L(L>=thresh) = 1;
% del = diff(L);
% ind = find(del == 1) - w;
% ind(ind<1) = 1;
% ind2 = [ind data(ind)];
% plot(L,'r');

%}
