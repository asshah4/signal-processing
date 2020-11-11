function [d, C, t0] = distancePoint2Line(A, B, P, varargin)
% distancePoint2Line  Calculate the distance between a point and a line
%   D = distancePoint2Line(A, B, P) returns the distance from point P to the
%   line through A and B in an N-dimensional space. 
%
%   D = distancePoint2Line(A, B, P, LineType) returns the distance from 
%   point P to 
%   - a line through A and B, 
%   - a ray which starts at A and passes through B, or 
%   - a line segment AB.
%   The definition of distance D depends on LineType, see below.
%
%   [D, C, t0] = distancePoint2Line(A, B, P, ..) returns in addition the 
%   closest point C and the running parameter t0 that defines the intersection  
%   point of the line through A,B and the perpendicular through P. The 
%   definition of closest point depends on LineType, see below. 
%
%   Definitions of distance (D) and closest point (C):
%
%   If LineType is 'line' (the default):
%   - C is the intersection point.
%   - D is the distance from P to closest point C.  
% 
%   If LineType is 'segment', there are two cases:
%   (1) the intersection point is on line segment AB
%       - C is the intersection point, 
%       - D is the distance from P to the closest point C.
%   (2) the intersection point is outside line segment AB
%       - closest point C is the end of the segment,
%       - D is the distance from P to the end of the segment.
%
%   If LineType is 'ray', there are two cases:
%   (1) the intersection point is on the ray through A and B
%       - C is the intersection point, 
%       - D is the distance from P to the closest point C.
%   (2) the intersection point is not on the ray (behind source A)
%       - C is the source at point A,
%       - D is the distance from P to the source at point A.
%
% Inputs:
%   A	     Starting point. N-element vector.
%   B        End point. N-element vector.
%   P        Independent point. N-element vector.
%   LineType Line type definition: 'line' (default), 'segment' or 'ray'.
% 
% Outputs:
%   D        Distance between the independent point and the line, segment or ray. Scalar.
%   C        Point on the line, segment or ray closest to the independent point. N-element vector.
%   t0       Running parameter that defines the intersection point of the line through
% 			 A and B and the perpendicular through P. At point A, t0 = 0. At point B, t0 = 1. Scalar. 
%
% Example:
%    A = [1, 1];
%    B = [5, 4];
%    P = [-1, 2];
%    % To calculate distance from P to line through A and B:
%    [D, C, t0] = distancePoint2Line(A, B, P)
%    % To calculate distance from P to segment AB: 
%    [D, C, t0] = distancePoint2Line(A, B, P, 'segment')
%
% For more information and background, see the <a href="matlab: web('http://monkeyproofsolutions.nl/en/how-to-calculate-the-shortest-distance-between-a-point-and-a-line', '-browser')">MonkeyProof blog item</a>.

% Copyright (C) 2008-2016 MonkeyProof Solutions BV

%% Checks: 
% - number of inputs
narginchk(3, 4);

% - points defined as vectors
if ~(isvector(A) && isvector(B) && isvector(P))
    error('distancePoint2Line:InvalidVectorInput', ...
            'Points A, B and P should be defined as vectors.');
end

% - points all defined in N-dimensional space
N = length(A); 
if ~(length(B) == N && length(P) == N)
    error('distancePoint2Line:VectorLengthMismatch', ...
            'A, B and P should be vectors of the same length.');
end

% - at least a 2D problem
if N < 2
     error('distancePoint2Line:VectorLengthLimit', ...
            'Vectors A, B and P must have 2 or more elements.');
end

% - lineType definition
if (nargin < 4)
    lineType = 'line';
else
    lineType = varargin{1};
    if ~ischar(lineType)
        error('distancePoint2Line:InvalidLineType', ...
            'Line type must be a character array.'); 
    end
    if ~any(strcmp(lineType, {'line', 'segment', 'ray'}))
        error('distancePoint2Line:LineTypeNotSpecified', ...
            ['Line type "' lineType '" is not recognized as a valid entry.']);
    end
end

%% Algorithm

% Direction vector 
M = B - A;

% Running parameter t0 defines the intersection point of line through A and B
% and the perpendicular through P

%M(1)
%P(1)-A(1)




%t0  = dot(M, P - A) / dot(M, M)

t0=(P(1)-A(1))/M(1);

% Intersection point of the perpendicular and line through A and B
intersectPnt = A + t0 * M;

switch lower(lineType)
    case 'line'
        % Line: intersection point is always closest.
        C   = intersectPnt;

    case 'segment'
        % Line segment
        if t0 < 0
            % Start point is closest.
            C   = A;
        elseif t0 > 1
            % End point is closest.
            C   = B;
        else
            % Intersection point is closest.
            C   = intersectPnt;
        end     
    
    case 'ray'
        % Ray
        if t0 < 0
            % Start point is closest.
            C   = A;
        else
            % Intersection point is closest.
            C   = intersectPnt;
        end
    
end

% Distance between independent point and closest point
d   = norm(P-C);

end
