function [Peak,MeanShaking,A_P,A_thr,maxarea] = eventshaking(map,area_map,area_thresh,threshold,pthresh)
% Determines information about earthquake shaking
%
%************************************************************
% Stephanie Lackner (Stephanie.lackner@columbia.edu)
% Version 2 (5/13/18)
%************************************************************

%clean
[nr nc]=size(map);

%% PEAK (Maximum)
Peak=max(max(map));

%% MEAN SHAKING/POPULATION/GECON IN SPECIFIED AREA

%create empty variables
MeanShaking=NaN(1,length(area_thresh));

%sort cells by intensity
[temp, I]=sort(reshape(map,nr*nc,1),'descend');
kick=isnan(temp);
map_vec_sort=temp;
map_vec_sort(kick==1)=[];
% sort area the same way
temp=reshape(area_map,nr*nc,1);
area_map_vec_sort=temp(I);
area_map_vec_sort(kick==1)=[];

%Get vector of shaking intensities sorted by intensity and then
%weighted by area
map_vec_sort_weighted=area_map_vec_sort.*map_vec_sort;
total_area=cumsum(area_map_vec_sort);
maxarea=total_area(end);

for j=1:length(area_thresh)
    if total_area(end)>=area_thresh(j)
        %number of cells under or equal to the threshold
        nut=length(total_area(total_area<=area_thresh(j)));
        %Gridcells usually don't fullfill area threshold
        %exactly. Therefore extracell
        if nut>0
            %Mean Shaking
            extracell_map=map_vec_sort(nut+1)*(area_thresh(j)- total_area(nut));
            MeanShaking(j)=(sum(map_vec_sort_weighted(1:nut))+extracell_map)/area_thresh(j);
        else
            MeanShaking(j)=map_vec_sort(1);
        end
    else
        MeanShaking(j)=sum(map_vec_sort_weighted)/area_thresh(j);
    end
end

%% AREA/POPULATION ABOVE THRESHOLD
A_thr=NaN(1,length(threshold));
for j=1:length(threshold)
    t=threshold(j);
    SAMPLE=(map>=t);
    A_thr(j)=sum(sum(area_map(SAMPLE)));
end

A_P=NaN(1,length(pthresh));

%in area with % of Peak or higher
for j=1:length(pthresh)
    pt=pthresh(j);
    SAMPLE=(map>=Peak*pt);
    A_P(j)=sum(sum(area_map(SAMPLE)));
end



end
