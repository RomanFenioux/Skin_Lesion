function [IpostProc] = postProc(I)
%POSTPROC Summary of this function goes here
%   Detailed explanation goes here

    %% Image filling
    %fill the holes in the regions
    I_filled=imfill(I,'holes');

    %% Connected component analysis
    % connected component
    CC=bwconncomp(I_filled);
    % Compute the areas and the bounding box of each component
    stats=regionprops('table',CC,'Area','BoundingBox');
    % keep only the components with a sufficient area and that don't touch
    % the border of the image
    idx=find([stats.Area]>1000 &  ...
        stats.BoundingBox(:,1)>2 & stats.BoundingBox(:,2)>2 & ...
        stats.BoundingBox(:,1)+stats.BoundingBox(:,3)<size(I_filled,2)-1 & ...
        stats.BoundingBox(:,2)+stats.BoundingBox(:,4)<size(I_filled,1)-1);

    if numel(idx)==0 % default if no region can fulfill the conditions
        idx=find([stats.Area]>1000);
    end
    IpostProc=double(ismember(labelmatrix(CC),idx));
    
end