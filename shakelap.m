function [ mpga, number_quakes, sum_lpga, sum_pga, sum_pga_square, magnitude_map, inArea] = shakelap(grid,box,resolution,inBoxArea,breakswitch,ShakeMap,xdim,ulxmap,ulymap,res_event,magnitude)
% Gives shaking summary for area
%  INPUTS:
%
%     box = [x1 y1;         map:  y2 ----
%            x2 y2]                 |    |
%                                   |    |
%                              x1,y1 ---- x2
%
% OUTPUTS:
%   mpga
%   number_quakes
%   sum_lpga
%   sum_pga
%   sum_pga_square
%   magnitude_map
%   inArea
%
% Updated: 4/20/18
%grid=area_grid;
%resolution=reso;
%inBoxArea=subset;
%ShakeMap=PGALand;

mpga=[]; %Maximum PGA over time in location (matrix)
number_quakes=[];
sum_lpga=[];
sum_pga=[];
sum_pga_square=[];
magnitude_map=[];
inArea=[];

mapsize=size(grid);
inBoxArea=find(inBoxArea>0.1);

%% STEP 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Go through events and fit to matrix to see if they are atually in the
%grid
for i=1:length(inBoxArea)
    event=inBoxArea(i);
    %map is shakemap sample
    eval(['map=ShakeMap.id' num2str(event) ';']);
    ncols=size(map,2);

    % resize to correct resolution, if artifical lowering of resolution
    % to 120 was necessary, then use resizem_by_max
    if resolution==120 && round(resolution/res_event(event))~=resolution/res_event(event)
        map=resizem_by_max(map,resolution/res_event(event));
    else
        map=resizem(map,resolution/res_event(event));
    end

    %distance in cells from grid box upper left border to shakemap upper left border
    %(negative when shakemap starts further north/west than grid box)
    ydist=round((box(2,2)-ulymap(event))*resolution);
    xdist=round((ulxmap(event)-box(1,1))*resolution);

    [a,b]=size(map);
    %prep for problem that shakemap might cross "world border"
    %old, but same: xdist2=(360-round((180-ulxmap(event))))*resolution-xdist;
    %xdist2 is distance in cells from left wordl border to grid box
    %xdist3 is distance in cells from left world border to end of
    %shakemap (if shakemap crosses world border)
    xdist2=round((box(1,1)+180-180*breakswitch)*resolution);
    xdist3=b-round((180+180*breakswitch-ulxmap(event))*resolution);

    %sample from area grid
    if (ulxmap(event)+xdim(event)*ncols<180+breakswitch*180) % check if shakemap crosses worldborder
        sample=grid(max(ydist+1,1):min(ydist+a,mapsize(1)),max(xdist+1,1):min(xdist+b,mapsize(2)));
    else  % Shakemap crosses world border
        if xdist>=mapsize(2) %left part of shakemap does not overlap with grid
            sample=grid(max(ydist+1,1):min(ydist+a,mapsize(1)),1:min(mapsize(2),xdist3-xdist2));
        elseif xdist2>xdist3 %right part of shakemap does not overlap with grid
            sample=grid(max(ydist+1,1):min(ydist+a,mapsize(1)),max(xdist+1,1):mapsize(2));
        else %both overlap
            left=grid(max(ydist+1,1):min(ydist+a,mapsize(1)),max(xdist+1,1):mapsize(2));
            right=grid(max(ydist+1,1):min(ydist+a,mapsize(1)),1:min(mapsize(2),xdist3-xdist2));
            sample=[left right];
        end
    end

    %IF MAP HAS ONES THEN INAREA otherwise NO
    if sum(sum(sample==1))>=1
        inArea=[inArea event];
    end
end

%% STEP 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Go through events that are in the grid and fit to matrix
if isempty(inArea)==0
    mpga=grid-1;
    number_quakes=grid-1;
    sum_lpga=grid-1;
    sum_pga=grid-1;
    sum_pga_square=grid-1;
    magnitude_map=grid-1;
end

%Go through events and fit to matrix
for i=1:length(inArea)
    event=inArea(i);
    %map is shakemap sample
    eval(['map=ShakeMap.id' num2str(event) ';']);
    ncols=size(map,2);

    % resize to correct resolution, if artifical lowering of resolution
    % to 120 was necessary, then use resizem_by_max
    if resolution==120 && round(resolution/res_event(event))~=resolution/res_event(event)
        map=resizem_by_max(map,resolution/res_event(event));
    else
        map=resizem(map,resolution/res_event(event));
    end

    %y-distance from grid box upper border to shakemap
    ydist=round((box(2,2)-ulymap(event))*resolution);
    xdist=round((ulxmap(event)-box(1,1))*resolution);

    [a,b]=size(map);
    %prep for problem that shakemap might cross "world border"
    %old, but same: xdist2=(360-round((180-ulxmap(event))))*resolution-xdist;
    %xdist2 is distance in cells from left wordl border to grid box
    %xdist3 is distance in cells from left world border to end of
    %shakemap (if shakemap crosses world border)
    xdist2=round((box(1,1)+180-180*breakswitch)*resolution);
    xdist3=b-round((180+180*breakswitch-ulxmap(event))*resolution);
    if (ulxmap(event)+xdim(event)*ncols<180+breakswitch*180) % check if shakemap crosses worldborder
        cross=0;
    else  % Shakemap crosses world border
        if xdist>=mapsize(2) %left part of shakemap does not overlap with grid
            cross=1;
        elseif xdist2>xdist3 %right part of shakemap does not overlap with grid
            cross=2;
        else %both overlap
            cross=3;
        end
    end

    %assign values
    for ypos=1:size(map,1)
        for xpos=1:size(map,2)
            cypos=ypos+ydist;
            if cross==0 || cross==2 || (cross==3 && ulxmap(event)+xpos/resolution<180+breakswitch*180)
                cxpos=xpos+xdist;
            elseif cross==1 || (cross==3 && ulxmap(event)+xpos/resolution>=180+breakswitch*180)
                    cxpos=xpos+xdist-360;
            end
            if cypos>0 && cypos<=mapsize(1) && cxpos>0 && cxpos<=mapsize(2)
                if mpga(cypos,cxpos)~=-1
                    mpga(cypos,cxpos)=max(mpga(cypos,cxpos),map(ypos,xpos));
                    if map(ypos,xpos)>1 % PGA has to be at least one to be registered!!!
                        magnitude_map(cypos,cxpos)=max(magnitude(event),magnitude_map(cypos,cxpos));
                        if map(ypos,xpos)>10
                            number_quakes(cypos,cxpos)=number_quakes(cypos,cxpos)+1;
                        end
                        sum_lpga(cypos,cxpos)=sum_lpga(cypos,cxpos)+log(map(ypos,xpos));
                        sum_pga(cypos,cxpos)=sum_pga(cypos,cxpos)+map(ypos,xpos);
                        sum_pga_square(cypos,cxpos)=sum_pga_square(cypos,cxpos)+map(ypos,xpos)^2;
                    end
                end
            end
        end
    end
end

end
