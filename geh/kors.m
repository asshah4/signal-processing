% Kors transformation from 12 lead to 3 lead XYZ access
%
% Input = 12-lead ECG signal with data in 12 columns
% Output = 3-lead transformation into XYZ access 

function transform_k = kors(leads12) %data in columns 12 leads
korsMatrix = [0.38, -0.07, 0, 0, 0, 0, -0.13, 0.05, -0.01, 0.14, 0.06,0.54;
              -0.07, 0.93, 0, 0, 0, 0, 0.06, -0.02, -0.05, 0.06, -0.17, 0.13;
              0.11, -0.23, 0, 0, 0, 0, -0.43, -0.06,-0.14,-0.20,-0.11,0.31];
transform_k = leads12 * korsMatrix';
end