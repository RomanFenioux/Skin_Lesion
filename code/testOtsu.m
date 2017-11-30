clear all
%close all

% choose the number of the image (3 last digits)
imNum = input('image id (3 digits) : ', 's'); 

%% read image and ground truth
% read image, normalize values between 0 and 1, resize (for dullRazor)
pathIm = '../data/ISIC-2017_Training_sample/';
imName= strcat('ISIC_0000', imNum, '.jpg');
I = double(imread(strcat(pathIm, imName)))/255;
I = I(2:end-1,2:end-1,:);
I = imresize(I,[512 nan], 'bilinear');

% read groundtruth mask, normalize, resize
pathTruth = '../data/ISIC-2017_GroundTruth_sample/';
truthName= strcat('ISIC_0000', imNum, '_segmentation.png');
T = double(imread(strcat(pathTruth, truthName)))/255;
T = T(2:end-1,2:end-1,:);
% 'nearest' preserves T as a binary mask
T = imresize(T,[512 nan], 'nearest'); 


%% dullRazor
% hair removal using the dullRazor algorithm. Ishaved and I are RGB images
Ishaved = dullRazor(I);

%% channel selection
% converts Ishaved to a grayscale image (here : channel X from CIE-XYZ)
channel = 'X';
IpreProc= channelSelect(Ishaved, channel);

%% black frame mask
% blackM is a binary mask that equals 1 on the black borders of the image I
% will be negative on the black border region, unchanged elsewhere
blackM = blackFrame(IpreProc,0.2); 

%% maximize dynamic range
% we don't take the black borders into account, so these borders may end
IpreProc=IpreProc-min(IpreProc(~logical(blackM)));
IpreProc=IpreProc/max(IpreProc(~logical(blackM)));

%% otsu
% Threshold the image using Otsu's paper : 'threshold' is the optimal
% threshold. eta is Otsu's separability measure at the optimal threshold.
% it can be used to evaluate the quality of the thresholding.

% -2*blackM : negative on the black border region, unchanged elsewhere
[threshold, eta] = otsu(IpreProc((IpreProc-2*blackM)>0));
I_seuil = double(IpreProc < threshold)-blackM; 

%% Image filling
%fill the holes in the regions
I_filled=imfill(I_seuil,'holes');

%% Connected component analysis
% connected component
CC=bwconncomp(I_filled);
% Compute the areas and the bounding box of each component
stats=regionprops('table',CC,'Area','BoundingBox','Centroid');
% keep only the components with a sufficient area and centered (heuristic,
% but this is not very sensitive, because lesions are way bigger, and noise
% is way smaller than 80)
center=repmat(size(I_seuil)/2,size(stats,1),1);
distance=sqrt(sum((stats.Centroid-center).^2,2));
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
Isegt=double(ismember(labelmatrix(CC),idx));


%% evaluation
% compute dice and jaccard index
d = dice(Isegt, T);
j = jaccard(Isegt,T);

%% display
% display the segmentation and tuth for visual evaluation of the results
displayResult(IpreProc, Isegt, T);
title(sprintf('Otsu Threshold on image %s : dice = %g, jaccard = %g',imNum,d,j))



