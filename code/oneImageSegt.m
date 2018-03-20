clear all
close all

% choose the number of the image (3 last digits)
imNum = input('image id (3 digits) : ', 's'); 
segtMethod = input('segmentation method (otsu, srm, region, levelset): ','s');

computeOtsu = strcmp(segtMethod,'otsu');
computeSrm = strcmp(segtMethod,'srm');
computeRegion = strcmp(segtMethod,'region');
computeLevelSet = strcmp(segtMethod,'levelset');
compare = strcmp(segtMethod,'compare');

% Preprocessing and postprocessing options
%pre
channel='blue'; % color channel
hair_removal = true; % dullrazor shaving
compute_blackframe = true; % removing blackframe in preproc
%post
compute_filling = true; % morphological filling of the holes in the ROI
compute_CCA = true; % denoising of small "islands" (keeping regions with area > 1000)
clear_border = false; % if true, removes regions that touches the border of the image

%% read image and ground truth
% custom function that reads an image and the ground truth mask
% I is normalized
path = '../data/norestriction/';
[I,T] = getData(path,imNum);

% resize for dullRazor (optional but important for hairy images)
I = imresize(I,[538 720], 'bilinear');
T = imresize(T,[538 720], 'nearest'); % 'nearest' preserves T as a binary mask

%%%%%%%% PREPROCESSING STAGE %%%%%%%%%%
[IpreProc, blackM, Ishaved]=preProc(I,channel, hair_removal, compute_blackframe);

%%%%%%%%%%% SEGMENTATION STAGE %%%%%%%%%%%%%%
if computeOtsu || compare
    %% otsu
    % Threshold the image using Otsu's paper : 'threshold' is the optimal
    % threshold. eta is Otsu's separability measure at the optimal
    % threshold. it can be used to evaluate the quality of the
    % thresholding.
    
    % -2*blackM : negative on the black border region, unchanged elsewhere
    [threshold, eta,sigList] = otsu(IpreProc((IpreProc-2*blackM)>0));
    Iotsu = double(IpreProc < threshold)-blackM;
    Iotsu = double(Iotsu>0);

    %% post processing : 
    % image filling, connected component analysis (see the function for
    % more details.
    IsegtOtsu=postProc(Iotsu,compute_filling, compute_CCA, clear_border);
    
    %% evaluation
    % compute dice and jaccard index
    dotsu = dice(IsegtOtsu, T);
    jotsu = jaccard(IsegtOtsu,T);
end

if computeSrm || compare
    %% Segmentation parameter Q; Q small few segments, Q large many segments
    Qlevel=250;
    
    %% Performing SRM
    Isrm=srm(IpreProc*255,Qlevel);
    Isrm=Isrm/255;
    
    % displays
%     figure(1)
%     imshow(IpreProc)
    figure(2)
    imshow(Isrm)

    %% post proc : selectionner les bonnes regions
    figure(3);
    imshow(I,[])
    input=round(ginput(2));  % selectionner patch de peau
    skinpatch=IpreProc(input(1,2):input(2,2),input(1,1):input(2,1));
    skinvalue=mean(skinpatch(:));
    skinmatrix=ones(size(IpreProc))*skinvalue;
    ISegt=double(abs(skinmatrix-Isrm)>60/255);
    
    if compute_blackframe
        ISegt=double((ISegt - blackM)>0);
    end
    ISrmSegt = postProc(ISegt,compute_filling, compute_CCA, clear_border);
    
    %% evaluation
    % compute dice and jaccard index
    dsrm = dice(ISrmSegt, T);
    jsrm = jaccard(ISrmSegt,T);
end
    
if computeRegion 
    %% Region Growing
    % start from a seed and add neighbor pixels to the region as long as
    % their intensity is close (threshold) to the mean intensity of the
    % region
    figure;
    imshow(IpreProc)
    [x, y] = ginput(1);
  
    t=input('enter seed and threshold for region growing (default 0.2)  : ');
    if numel(t)==0
        t=0.2;
    end
    Iregion=regionGrowing(IpreProc,round(x),round(y),t);
    
    %% post processing : 
    % image filling, connected component analysis (see the function for
    % more details.
    IsegtRegion=postProc(Iregion);    
    
    %% evaluation
    % compute dice and jaccard index
    dregion = dice(IsegtRegion, T);
    jregion = jaccard(IsegtRegion,T);
end

if computeLevelSet
    
    IpreProc=IpreProc*255; 
    
    %% initialize LSF as binary step function
    c0=2;
    initialLSF = c0*ones(size(IpreProc));
    %% initial LSF from user input
    figure(1);
    imshow(I)
    input=round(ginput()); 

    %%%%%%% MULTI RECTANGLE INPUT %%%%%%%
%     % points from input are used to define rectangles 
%     for i = 1:size(input,1)/2
%         initialLSF(input(2*i-1,2):input(2*i,2),input(2*i-1,1):input(2*i,1))=-c0;
%         % initial contour
%     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%% POLYGON INPUT %%%%%%%%%%%
    % points from input generate R0 as a polygonal mask
    row=input(:,2);
    col=input(:,1);
    mask = roipoly(IpreProc,col,row);
    initialLSF(mask)=-c0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % we reduce the size of the image using the bounding box of the user
    % input points to speed up the computing. Important : this works
    % because the alpha parameter is positive (that forces the contour to
    % shrink)
    imin=min(row); imax=max(row); jmin=min(col); jmax=max(col);
    I_small = IpreProc(imin:imax,jmin:jmax);
    phi=initialLSF(imin:imax,jmin:jmax);
 
    
    % display initial zero level contour
    figure(1);
    imshow(I_small/255);
    hold on; contour(phi, [0,0], 'r'); hold off;
    title('Initial zero level contour');
    pause(0.2)
  

    %% parameter setting
    timestep=1;  % time step
    mu=0.2/timestep;  % coefficient of the distance regularization term R(phi)
    iter_inner=5; % number of iteration of the evolution of the LSF in each epoch
    epoch=20;
    lambda=1; % coefficient of the weighted length term L(phi)
    alpha=5;  % coefficient of the weighted area term A(phi): negative to expand, positive to shrink the contour
    epsilon=1.5; % paramater that specifies the width of the DiracDelta function (usually 1.5)

    sigma=.5;    % scale parameter in Gaussian kernel
    G=fspecial('gaussian',15,sigma); % Caussian kernel
    I_smooth=conv2(I_small,G,'same');  % smooth image by Gaussian convolution
    [Ix,Iy]=gradient(I_smooth);
    f=Ix.^2+Iy.^2;
    g=1./(1+f);  % edge indicator function.

    potential=2;  
    if potential ==1
    potentialFunction = 'single-well';  % use single well potential p1(s)=0.5*(s-1)^2, which is good for region-based model 
    elseif potential == 2
    potentialFunction = 'double-well';  % use double-well potential in Eq. (16), which is good for both edge and region based models
    else
    potentialFunction = 'double-well';  % default choice of potential function
    end  

    %% start level set evolution
    for n=1:epoch
        phi = level_set(phi, g, lambda, mu, alpha, epsilon, timestep, iter_inner, potentialFunction); 
        fprintf('iteration = %d / %d\n',n*iter_inner,epoch*iter_inner)
    end

    %% refine the contour 
    % further level set evolution with alpha=0 (no influence of the area to
    % help the contour grow anymore)
    alpha=0;
    iter_refine = 20;
    phi = level_set(phi, g, lambda, mu, alpha, epsilon, timestep, iter_refine, potentialFunction);
    
    % back to full size
    IsegtLevelSet=zeros(size(I(:,:,1)));
    IsegtLevelSet(imin:imax,jmin:jmax) = double(-phi>0);
    IsegtLevelSet = postProc(IsegtLevelSet);
    
    %% evaluation
    % compute dice and jaccard index
    dLevelSet = dice(IsegtLevelSet, T);
    jLevelSet = jaccard(IsegtLevelSet,T);
    
    IpreProc=IpreProc/255;
end

%% display
% display the segmentation and tuth for visual evaluation of the results
if compare
    displayResult(IpreProc, T, IsegtOtsu, ISRMSegt)
    title(sprintf('comparison between the segmentation methods'))
elseif computeSrm
    displayResult(IpreProc, T, ISrmSegt);
    title(sprintf('SRM on image %s : dice = %g, jaccard = %g',imNum,dsrm,jsrm))
elseif computeOtsu
    displayResult(I, T, IsegtOtsu);
    title(sprintf('Otsu Threshold on image %s : dice = %g, jaccard = %g',imNum,dotsu,jotsu))
elseif computeRegion
    displayResult(IpreProc, T, IsegtRegion);
    title(sprintf('Region Growing on image %s : dice = %g, jaccard = %g',imNum,dregion,jregion))
elseif computeLevelSet
    displayResult(I, T, IsegtLevelSet);
    title(sprintf('Level Set on image %s : dice = %g, jaccard = %g',imNum,dLevelSet,jLevelSet))
end