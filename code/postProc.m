function [IpostProc] = postProc(I, fill_param, CCA_param, clear_border_param)
%POSTPROC Summary of this function goes here
%   Detailed explanation goes here
    
% INIT
IpostProc = I;
    
%% PARAMS
if exist('fill_param','var')
    fill = fill_param;
else
    fill = true;
end
if exist('CCA_param','var') 
    CCA = CCA_param;
else
    CCA = true;
end
if exist('clear_border_param','var') 
    clear_border = clear_border_param;
else
    clear_border = true;
end

%% Image filling
%fill the holes in the regions
if fill
    IpostProc=imfill(I,'holes');
end
%% Connected component analysis
if CCA
    % connected component
    CC=bwconncomp(IpostProc);

    % Compute the areas and the bounding box of each component

    stats=regionprops('table',CC,'Area','BoundingBox');
    % keep only the components with a sufficient area and that don't touch
    % the border of the image
    if clear_border
        idx=find([stats.Area]>1000 &  ...
            stats.BoundingBox(:,1)>2 & stats.BoundingBox(:,2)>2 & ...
            stats.BoundingBox(:,1)+stats.BoundingBox(:,3)<size(IpostProc,2)-1 & ...
            stats.BoundingBox(:,2)+stats.BoundingBox(:,4)<size(IpostProc,1)-1);
    end
    if ~clear_border || numel(idx)==0 % default if no region can fulfill the conditions
        idx=find([stats.Area]>1000);
    end
    IpostProc=double(ismember(labelmatrix(CC),idx));
end
end