function [SC,SCtroid,EC] = locateEQ(map,ulxmap,ulymap,xdim,ydim,lat,lon)
% [SC,SCtroid,EC] = locateEQ(map,ulxmap,ulymap,xdim,ydim,lat,lon) Calculates location of earthquake from Shakemap information.
% INPUT: 
%
% OUTPUT:   SC          Shaking Center
%           SCtroid     Shaking Centroid
%           EC          Epicenter
%           .col        collumn position of that location in the Shakemap grid
%           .row        row position of that location in the Shakemap grid
%           .value      shaking value at that location
%           .ylat       Latitude coordinate of the location
%           .xlon       Longitude coordinate of the location
%
%           SCtroid.col_value  Shaking Center does not necessarily have "perfect"
%                              gridcell location. This is the "exact" collumn value.
%           SCtroid.row_value  Shaking Center does not necessarily have "perfect"
%                              gridcell location. This is the "exact" row value.
%           SC.Num_peak        Number of maximum shaking grid cells in map
%           SC.out             If it was necessary to extend the range outside
%                              the shakemap to determine the unique shaking center.
%                               Outside => 1
%                               Couldn't find unique center => -1
%
%************************************************************
% Stephanie Lackner (Stephanie.lackner@columbia.edu)
% Version 1.1 (3/13/18)
%************************************************************

%Epicenter
EC.XLON=lon;
EC.YLAT=lat;
if EC.XLON<-180
    EC.XLON=EC.XLON+360;
end

EC.col=round((lon-ulxmap)/xdim+0.5);
EC.row=round((ulymap-lat)/ydim+0.5);

[mr, mc]=size(map);
if EC.row<1 || EC.col<1 || EC.row>mr || EC.col>mc
    EC.value=-1;
else
    EC.value=map(EC.row,EC.col);
end

%Shaking Centroid
[SCtroid.value,SCtroid.col,SCtroid.row,SCtroid.col_value,SCtroid.row_value] = ShakingCentroid(map);

SCtroid.XLON=ulxmap+(SCtroid.col_value-0.5)*xdim;
SCtroid.YLAT=ulymap-(SCtroid.row_value-0.5)*ydim;
if SCtroid.XLON<-180
    SCtroid.XLON=SCtroid.XLON+360;
end

%Shaking Center
[SC.value,SC.col,SC.row,SC.Num_peak,SC.out] = ShakingCenter(map, SCtroid, EC); 

SC.XLON=ulxmap+(SC.col-0.5)*xdim;
SC.YLAT=ulymap-(SC.row-0.5)*ydim;
if SC.XLON<-180
    SC.XLON=SC.XLON+360;
end


end

