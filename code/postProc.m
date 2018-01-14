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
    % keep only the components with a sufficient area and centered (heuristic,
    % but this is not very sensitive, because lesions are way bigger, and noise
    % is way smaller than 80)
    idx=find([stats.Area]>1000 &  ...
        stats.BoundingBox(:,1)>2 & stats.BoundingBox(:,2)>2 & ...
        stats.BoundingBox(:,1)+stats.BoundingBox(:,3)<size(I_filled,2)-1 & ...
        stats.BoundingBox(:,2)+stats.BoundingBox(:,4)<size(I_filled,1)-1);

    if numel(idx)==0
        idx=find([stats.Area]>1000);
    end

    % To choose among the big areas, we keep those with a small bounding box
    % (this avoids choosing the black margins)
    %boundingBoxSizes=max([stats.BoundingBox(:,3), stats.BoundingBox(:,4)],[],2);
    %[~,argmin]=min(boundingBoxSizes(idx));
    IpostProc=double(ismember(labelmatrix(CC),idx));
    
end

