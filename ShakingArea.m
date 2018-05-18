function [ A_P90, A_P50, A_P25, A_P10, A_t] = ShakingArea(grid,areacell,t)
% [ A_P90, A_P50, A_P25, A_P10, A_t] = ShakingArea(grid,areacell,t)
% Calculates area exposed to different shaking levels
%
%************************************************************
% Stephanie Lackner (Stephanie.lackner@columbia.edu)
% Version 1 (12/3/16)
%************************************************************

%% CALCULATION

Peak=max(max(grid));

%Area above threshold
A_t=sum(sum(areacell(grid>=t)));

%Area with % of Peak or higher
A_P90=sum(sum(areacell(grid>=Peak*0.9)));
A_P50=sum(sum(areacell(grid>=Peak*0.5)));
A_P25=sum(sum(areacell(grid>=Peak*0.25)));
A_P10=sum(sum(areacell(grid>=Peak*0.1)));


end

