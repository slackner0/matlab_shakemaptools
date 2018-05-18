function [box] = box_limit(MapX,MapY,resolution)
%Find box limits with grids being at 1 degree divided by resolution.
%     box = [x1 y1;         map:  y2 ----
%            x2 y2]                 |    |
%                                   |    |
%                              x1,y1 ---- x2
%due to machine calculation error, I need to round at N decimal
%precision.
N=6;

box=NaN(2,2);

box(1,1)=floor(round(min(MapX)*resolution,N))/resolution;
box(2,1)=ceil(round(max(MapX)*resolution,N))/resolution;
box(1,2)=floor(round(min(MapY)*resolution,N))/resolution;
box(2,2)=ceil(round(max(MapY)*resolution,N))/resolution;


end

