function [blackM] = blackFrame(I,threshold)
%REMOVEBLACKFRAME Summary of this function goes here
%   I is a gray level image
%   blackM

    Iblack = double(I<threshold); %removeBlackFrame(IpreProc);

    CC=bwconncomp(Iblack);
    % Compute the areas and the bounding box of each component
    stats=regionprops('table',CC,'BoundingBox');
    idx=find(stats.BoundingBox(:,1)<1 | stats.BoundingBox(:,2)<1 | ...
        stats.BoundingBox(:,1)+stats.BoundingBox(:,3)>size(Iblack,2) | ...
        stats.BoundingBox(:,2)+stats.BoundingBox(:,4)>size(Iblack,1));
    blackM=double(ismember(labelmatrix(CC),idx));
    
end

