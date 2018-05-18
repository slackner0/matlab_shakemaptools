function [value,col,row,cc,cr] = ShakingCentroid(map)
% [value,col,row,cc,cr] = ShakingCentroid(map)
% Calculates the location of the shaking centroid. Only shaking that is at
% least 50% of the maximum shaking is considered and the intensity is
% quadratically weighted.
%
%  OUTPUT:
%           value      shaking value at the shaking centroid
%           col        collumn position of shaking centroid in the Shakemap grid
%           row        row position of shaking centroid in the Shakemap grid
%           cc  Shaking Center does not necessarily have "perfect" gridcell location. 
%               This is the "exact" collumn value.
%           cr  Shaking Center does not necessarily have "perfect" gridcell location. 
%               This is the "exact" row value.
%
%************************************************************
% Stephanie Lackner (Stephanie.lackner@columbia.edu)
% Version 1 (12/3/16)
%************************************************************

maxv=max(max(map));
t=maxv*0.5;
%Different approaach idea: t=min(maxv*0.5,10); 
map(map<t)=0;

%regionprops(true(size(map)), map,  'WeightedCentroid')
% Just for testing that I get how it should work. Works!
%%cx = (v1x*m1 + v2x*m2 + ... vnx*mn) / (m1 + m2 .... mn) 
%%cy = (v1y*m1 + v2y*m2 + ... vny*mn) / (m1 + m2 .... mn)

[r,c]=size(map);
cr=0;
cc=0;
w=0;
for i=1:r
    for j=1:c
        cr = cr+i*(map(i,j)^2); 
        cc = cc+j*(map(i,j)^2);
        w = w + (map(i,j)^2);
    end
end

cr=cr/w;
cc=cc/w;

row=round(cr);
col=round(cc);
value=map(row,col);

end

