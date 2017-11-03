clear all
close all

% choose the number of the image (3 last digits)
imNum = input('image id (3 digits) : ', 's'); 

%% read image and ground truth
% read image, normalize values between 0 and 1, resize (for dullRazor)
pathIm = '../data/ISIC-2017_Training_sample/';
imName= strcat('ISIC_0000', imNum, '.jpg');
I = double(imread(strcat(pathIm, imName)))/255;
I = imresize(I,[512 nan], 'bilinear');

% read groundtruth mask, normalize, resize
pathTruth = '../data/ISIC-2017_GroundTruth_sample/';
truthName= strcat('ISIC_0000', imNum, '_segmentation.png');
T = double(imread(strcat(pathTruth, truthName)))/255;
T = imresize(T,[512 nan], 'nearest'); % 'nearest' preserves T as a binary mask


%% dullRazor
% hair removal using the dullRazor algorithm. Ishaved and I are RGB images
Ishaved = dullRazor(I);

%% channel selection
% converts Ishaved to a grayscale image (here : channel X from CIE-XYZ)
channel = 'X';
IpreProc= channelSelect(Ishaved, channel);
% maximize dynamic range
IpreProc=(IpreProc-min(IpreProc(:)))/max(IpreProc(:));

%% otsu
% Threshold the image using Otsu's paper : 'threshold' is the optimal threshold.
% eta is Otsu's separability measure at the optimal threshold. 
% it can be used to evaluate the quality of the thresholding. 
[threshold, eta] = otsu(IpreProc);
I_seuil = double(IpreProc < threshold); 

%% Connected component analysis
% we keep only the largest connected component
CC=bwconncomp(I_seuil);
% Sort the connected component by size
numPixels = cellfun(@numel,CC.PixelIdxList);
[biggest,idx] = max(numPixels);
% we only set to 1 the pixels from that component
Isegt = zeros(size(I_seuil));
Isegt(CC.PixelIdxList{idx}) = 1;


%% evaluation
% compute dice and jaccard index
dice = dice(Isegt, T)
jaccard = jaccard(Isegt,T)

%% display
% display the segmentation and tuth for visual evaluation of the results
displayResult(IpreProc, Isegt, T);
title(sprintf('Otsu Threshold - dice = %g, jaccard = %g',dice,jaccard))


