clear all
close all

CCA_Enabled = input('enable connected component analysis? (y/n)', 's'); 

% inputs
pathIm = '../data/ISIC-2017_Training_sample/';
pathTruth = '../data/ISIC-2017_GroundTruth_sample/';
idListNevus = {   '000' '001' '003' '006' '007' '008' '009' '010' '011'...
    '012' '015' '016' '017' '019' '042' '082' '085' '095' '127' '235'};
idListMelanoma = { '002' '004' '013' '022' '026' '030' '031' '035' '036'...
    '040' '043' '049' '054' '056' '074' '077' '078' '139' '160' '174'};
imList = [idListNevus idListMelanoma];
inputNb = numel(imList);

% init outputs
segtList=[];
diceList=zeros(inputNb,1);
jaccardList=zeros(inputNb,1);
                
for i=1:inputNb
    fprintf('processing image number %d, id = %s\n',i, imList{i})
    if i>size(idListNevus,1)
        Melanoma = true;
    end
    
    %% read image and ground truth
    % read image, normalize values between 0 and 1, resize (for dullRazor)
    
    imName= strcat('ISIC_0000', imList{i}, '.jpg');
    I = double(imread(strcat(pathIm, imName)))/255;
    I = imresize(I,[512 680], 'nearest');

    % read groundtruth mask, normalize, resize
    truthName= strcat('ISIC_0000', imList{i}, '_segmentation.png');
    T = double(imread(strcat(pathTruth, truthName)))/255;
    T = imresize(T,[512 680], 'nearest');


    %% dullRazor
    % hair removal using the dullRazor algorithm. Ishaved and I are RGB images
    Ishaved = dullRazor(I);

    %% channel selection
    % converts Ishaved to a grayscale image (here : channel X from CIE-XYZ)
    channel = 'X';
    IpreProc= channelSelect(Ishaved, channel);

    %% otsu
    % Threshold the image using Otsu's paper : 'threshold' is the optimal threshold.
    % eta is Otsu's separability measure at the optimal threshold. 
    % it can be used to evaluate the quality of the thresholding. 
    [threshold, eta] = otsu(IpreProc);
    I_seuil = double(IpreProc < threshold);
         
    %% Image filling
    %fill the holes in the regions
    I_filled=imfill(I_seuil,'holes');
    
    %% Connected component analysis
    if strcmp(CCA_Enabled,'y')
       

        %% Connected component analysis
        % connected component
        CC=bwconncomp(I_filled);
        % Compute the areas and the bounding box of each component
        stats=regionprops('table',CC,'Area','BoundingBox','Centroid');
        % keep only the components with a sufficient area and centered (heuristic, but this is
        % not very sensitive, because lesions are way bigger, and noise is way
        % smaller than 80)
        center=repmat(size(I_seuil)/2,size(stats,1),1);
        distance=sqrt(sum((stats.Centroid-center).^2,2));
        idx=find([stats.Area]>1000 & distance<size(I_seuil,1)/2);

        % To choose among the big areas, we keep those with a small bounding box
        % (this avoids choosing the black margins)
        boundingBoxArea=stats.BoundingBox(:,3).*stats.BoundingBox(:,4);
        [~,argmin]=min(boundingBoxArea(idx));
        Isegt=double(ismember(labelmatrix(CC),idx(argmin)));

    elseif strcmp(CCA_Enabled,'n')
        Isegt=I_seuil;
    end
    %% evaluation
    % compute dice and jaccard index 
    diceList(i) = dice(Isegt, T);
    jaccardList(i) =  jaccard(Isegt,T);
    
    segtList=cat(3,segtList,Isegt);
end

%% display
% plot the dice and jaccard indices for all images

figure;
plot(diceList,'red')
hold on
plot(jaccardList,'blue')
hold off
title('Evaluation of the results on the database')
legend('dice','jaccard','Location','SouthEast')


