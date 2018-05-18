function [xpop1,xpop2,ypop1,ypop2] = evengrid_limit(box,ulx,uly,n)
%Get grid positions 

xpop1=round((box(1,1)-ulx)*n)+1;  
xpop2=round((box(2,1)-ulx)*n);  
ypop2=round((uly-box(1,2))*n); 
ypop1=round((uly-box(2,2))*n)+1;
    
end

