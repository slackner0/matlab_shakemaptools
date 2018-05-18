function [MapX,box,ulxmap,breakswitch] = worldborderswitch(MapX,box,ulxmap)
%When almost the whole world is in the shape, separate at 0 instead of 180,
%otherwise matrix gets too big.
%     box = [x1 y1;         map:  y2 ----
%            x2 y2]                 |    |
%                                   |    |
%                              x1,y1 ---- x2

breakswitch=0;
if box(1,1)<-175 && box(2,1)>175
   ulxmap(ulxmap<0)=360+ulxmap(ulxmap<0); 
   MapX(MapX<0)=360+MapX(MapX<0);
   box(1,1)=min(MapX);
   box(2,1)=max(MapX);
   breakswitch=1;
end  
       
end

