function [blackM] = blackFrame(I,threshold)
%REMOVEBLACKFRAME detects the black borders on grayscale image I
%   I is a gray level image
%   blackM is a binary mask : equals 1 where the black border are detected
%   threshold is the level of darkness of the black frame
%   We threshold the image, and keep only the regions that are in contact
%   with the borders of the image.

    % maximize dynamic range
    I=I-min(I(:));
    I=I/max(I(:));
    Iblack = double(I<threshold); 

    CC=bwconncomp(Iblack);
    % Compute the areas and the bounding box of each component
    stats=regionprops('table',CC,'BoundingBox');
    
    % keep only the regions when the bounding box reach the limits of I
    idx=find(stats.BoundingBox(:,1)<1 | stats.BoundingBox(:,2)<1 | ...
        stats.BoundingBox(:,1)+stats.BoundingBox(:,3)>size(Iblack,2) | ...
        stats.BoundingBox(:,2)+stats.BoundingBox(:,4)>size(Iblack,1));
    blackM=double(ismember(labelmatrix(CC),idx));
    
end

