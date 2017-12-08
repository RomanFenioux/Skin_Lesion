clear all
%close all

% choose the number of the image (3 last digits)
imNum = input('image id (3 digits) : ', 's'); 
segtMethod = input('segmentation method (otsu or region): ','s');
computeOtsu = strcmp(segtMethod,'otsu');
computeRegion = strcmp(segtMethod,'region');
compare = strcmp(segtMethod,'compare');

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

if computeOtsu | compare
    %% otsu
    % Threshold the image using Otsu's paper : 'threshold' is the optimal
    % threshold. eta is Otsu's separability measure at the optimal threshold.
    % it can be used to evaluate the quality of the thresholding.
    
    % -2*blackM : negative on the black border region, unchanged elsewhere
    [threshold, eta] = otsu(IpreProc((IpreProc-2*blackM)>0));
    Iotsu = double(IpreProc < threshold)-blackM;
    
    %% post processing : 
    % image filling, connected component analysis (see the function for more
    % details.
    IsegtOtsu=postProc(Iotsu);
    
        %% evaluation
    % compute dice and jaccard index
    dotsu = dice(IsegtOtsu, T);
    jotsu = jaccard(IsegtOtsu,T);
end
    
if computeRegion || compare
    %% Region Growing
    % start from a seed and add neighbor pixels to the region as long as
    % their intensity is close (threshold) to the mean intensity of the region
    figure(1);
    imshow(IpreProc)
    [x, y] = ginput(1);
  
    t=input('enter seed and threshold for region growing (default 0.2)  : ');
    if numel(t)==0
        t=0.2;
    end
    Iregion=regionGrowing(IpreProc,round(x),round(y),t);
    
    %% post processing : 
    % image filling, connected component analysis (see the function for more
    % details.
    IsegtRegion=postProc(Iregion);    
    
    %% evaluation
    % compute dice and jaccard index
    dregion = dice(IsegtRegion, T);
    jregion = jaccard(IsegtRegion,T);
end


%% display
% display the segmentation and tuth for visual evaluation of the results
if compare
    displayResult(IpreProc, T, IsegtOtsu, IsegtRegion)
    title(sprintf('comparison between the segmentation methods'))
elseif computeOtsu
    displayResult(IpreProc, T, IsegtOtsu);
    title(sprintf('Otsu Threshold on image %s : dice = %g, jaccard = %g',imNum,dotsu,jotsu))
elseif computeRegion
    displayResult(IpreProc, T, IsegtRegion);
    title(sprintf('Region Growing on image %s : dice = %g, jaccard = %g',imNum,dregion,jregion))
end


