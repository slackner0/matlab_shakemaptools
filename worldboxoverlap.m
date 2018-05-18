function [res_Boxsample, inBoxArea] = worldboxoverlap(box,ulxmap,ulymap,xdim,ydim,ncols,nrows,res_event,subset,breakswitch)
%Find events that are in the area of interest (Box)
%     box = [x1 y1;         map:  y2 ----
%            x2 y2]                 |    |
%                                   |    |
%                              x1,y1 ---- x2

inBoxArea=zeros(length(ncols),1);
res_Boxsample=[];

for event=1:length(xdim)
    if subset(event)==1
        %If shakemap starts below country or ends above country, do nothing
        if ulymap(event)<=box(1,2) || ulymap(event)-ydim(event)*nrows(event)>=box(2,2)
            %otherwise we know y axis overlap:
            % if shakemap starts to the right of the country AND either
            % ends before the world border, or goes over the border and
            % ends to the left of the country, => do nothing
        elseif ulxmap(event)>=box(2,1) && (ulxmap(event)+xdim(event)*ncols(event)<=180+breakswitch*180 || ulxmap(event)+xdim(event)*ncols(event)-360<=box(1,1))
            %or if shakemap ends to the left of the country => do nothing
        elseif ulxmap(event)+xdim(event)*ncols(event)<=box(1,1)
            %if none of those => there is an overlap
        else
            inBoxArea(event)=1;
            %collect different resolutions
            res_Boxsample=[res_Boxsample res_event(event)];  
        end
    end
end
res_Boxsample=unique(res_Boxsample);


end

