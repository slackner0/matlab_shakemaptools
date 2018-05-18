function [Peak,collumn,row,Num_peak,out] = ShakingCenter(map, SCtroid, EC)
% [Peak,collumn,row,Num_peak,out] = ShakingCenter(map) 
% Calculates the location of the shaking center. If the maximum shaking
% does not have a unique location, take 1-gridcell radius around candidates
% and calculate mean in those areas. If there is still no unique max, keep
% increasing by 1 gridcell until one is found. If the edge of the Shakemap
% is reached, it is assumed that "the missing ring" has the same average
% shaking as the available ring.
%
%  OUTPUT:
%           Peak      Maximum shaking value
%           collumn       collumn position of shaking center in the Shakemap grid
%           row       row position of shaking center in the Shakemap grid
%           Num_peak  Number of maximum shaking grid cells in map
%           out       If it was necessary to extend the range outside
%                     the shakemap to determine the unique shaking center.
%                     Outside => 1
%                     Couldn't find unique center => -1
%                     Couldn't find unique center and same distance to
%                     Shaking centroid => -2
%                     Couldn't find unique center and same distance to
%                     Epicenter => -3
%
%************************************************************
% Stephanie Lackner (Stephanie.lackner@columbia.edu)
% Version 1.1 (3/13/18)
%************************************************************

[mapr, mapc]=size(map);

%Evaluate Max shaking and location(s) of it
[temp, I]=max(map);
[Peak, collumn]=max(temp);
row=I(collumn);

%I=Evaluate number of locations with max shaking
Num_peak=sum(sum((map>=Peak)));
out=0;

% If the maximum shaking does not have a unique location...
if Num_peak>1.1
    %Find all candidates for max shaking
    [rmax, cmax]=size(map);
    [r,c]=find(map>=Peak);
    
    mean=Peak*ones(length(r),1);
    out_temp=zeros(length(r),1);
    k=1;
    Num_peak_new=Num_peak;
    
    while k<=(mapr*mapc/2) && Num_peak_new>1.1
        % For each candidate calculate the mean shaking in designated area
        for i=1:length(r)
            %Find four corner points of this turn
            r1=max(1,r(i)-k);
            c1=max(1,c(i)-k);
            r2=min(rmax,r(i)+k);
            c2=min(cmax,c(i)+k);
            %Find four corner points of previous turn
            r1_kminus1=max(1,r(i)-(k-1));
            c1_kminus1=max(1,c(i)-(k-1));
            r2_kminus1=min(rmax,r(i)+(k-1));
            c2_kminus1=min(cmax,c(i)+(k-1));
            
            %Size of current rectangel
            n=(r2-r1+1)*(c2-c1+1);
            %Size of previous rectangel
            n_kminus1=(r2_kminus1-r1_kminus1+1)*(c2_kminus1-c1_kminus1+1);
            
            %Mean shaking in current rectangel
            av=sum(sum(map(r1:r2,c1:c2)));
            %Mean shaking in previous turn
            av_kminus1=sum(sum(map(r1_kminus1:r2_kminus1,c1_kminus1:c2_kminus1)));
            
            %Change in mean shaking
            if (n-n_kminus1)>0.5
                delta=(av-av_kminus1)/(n-n_kminus1);
            else
                %End of shakemap reached
                delta=0;
                k=mapr*mapc;
            end
            
            if n<(k*2+1)*(k*2+1)
                out_temp(i)=1;
            end
            % Total mean shaking in area
            mean(i)=mean(i)+delta*k*8;        
        end
        
        %Get new candidates based on mean in designated areas
        [PeakN, I]=max(mean);
        out=out_temp(I);
        collumn=c(I);
        row=r(I);      
        Num_peak_new=sum(mean>=PeakN);
 
        k=k+1;
    end 
    
    %If no unique shaking center, pick closest to shaking centroid
    if Num_peak_new>1.1
       out=-1;       
       dist=sqrt((r-SCtroid.row).^2+(c-SCtroid.col).^2);
       mindist_pos = find(dist<= min(dist));
       if length(mindist_pos) == 1
           row = r(mindist_pos);
           collumn = c(mindist_pos);
       %If no unique shaking center, pick closest to epicenter
       else
           out = -2;
           dist=sqrt((r-EC.row).^2+(c-EC.col).^2);
           mindist_pos = find(dist<= min(dist));
           if length(mindist_pos) == 1
               row = r(mindist_pos);
               collumn = c(mindist_pos);
           else
               out = -3;
           end
       end
    end
    
end
     
end

