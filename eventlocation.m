function [SC,SCtroid,EC] = eventlocation(map,country_map,ulx,uly,xd,yd,lat,lon,hourmin)
% [SC,SCtroid,EC] = eventlocation(map,country_map,ulx,uly,xd,yd,lat,lon,hourmin)
% Determines information about earthquake locations
%
%************************************************************
% Stephanie Lackner (Stephanie.lackner@columbia.edu)
% Version 1 (12/28/16)
%************************************************************

%% LOCATIONS
[SC,SCtroid,EC]=locateEQ(map,ulx,uly,xd,yd,lat,lon);

%% COUNTRY OF LOCATIONS
SC.country=country_map(SC.row,SC.col);
SCtroid.country=country_map(SCtroid.row,SCtroid.col);

if EC.value==-1
    EC.country=-1;
else
    EC.country=country_map(EC.row,EC.col);
end

%% TIME OF DAY AT LOCATIONS
SC.TOD=hourmin+SC.XLON*24/360;
if SC.TOD<0
    SC.TOD=SC.TOD+24;
end

SCtroid.TOD=hourmin+SCtroid.XLON*24/360;
if SCtroid.TOD<0
    SCtroid.TOD=SCtroid.TOD+24;
end

EC.TOD=hourmin+EC.XLON*24/360;
if EC.TOD<0
    EC.TOD=EC.TOD+24;
end

end

