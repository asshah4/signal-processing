%% Overview
% 
% Requires the use of several steps
%   1. ECG must be in a 12 lead format, likely in a certain order
%   1. 12 Lead ECG must be converted to a 3-Lead XYZ axis
%   2. The XYZ ECG must have R-peaks identified (can use HRV toolbox)
%   3. The combination of a 12-lead with identified R-peaks are used to
%   generate a "median" XYZ beat using time-coherence
% 	4. From this median XYZ beat the origin point is generated
% 	5. From this median XYZ beat the fiducial points of the QRS complexes are generated

