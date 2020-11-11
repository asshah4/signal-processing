function [ BptIndex ] = findiB( DZDT_beat )
%%finds b point based on the maximum of the second derivative of DZDT beat
%% other acceptable ways include: max/min of derivative, inflection point.
%% to check different ways, check out the methods in this paper:
maxs=1;
[maxval maxloc] = max(DZDT_beat(1:end));%max peak in signal

st=80;
if st<0
    BptIndex=[];
else
    before_peak=DZDT_beat(st:maxloc);%before peak, choose somewhere startng from 80 and beyond
    [MB,B]=max(diff(diff(before_peak)));
    BptIndex=st-1+B;
end

end