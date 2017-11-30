clear all
close all

CCA_Enabled = input('enable connected component analysis? (y/n)', 's'); 

% inputs
pathIm = '../data/ISIC-2017_Training_sample/';
pathTruth = '../data/ISIC-2017_GroundTruth_sample/';
idNevus = {   '000' '001' '003' '006' '007' '008' '009' '010' '011'...
    '012' '015' '016' '017' '019' '042' '082' '085' '095' '127' '235'};
idMelanoma = { '002' '004' '013' '022' '026' '030' '031' '035' '036'...
    '040' '043' '049' '054' '056' '074' '077' '078' '139' '160' '174'};
idList = [idNevus idMelanoma];

% init outputs
segtList=[];
diceList=zeros(numel(idList),1);
jaccardList=zeros(numel(idList),1);

                
for i=1:numel(idList)
    
    if i>numel(idNevus)
        Melanoma = true;
        type = 'melanoma';
    else
        Melanoma = false;
        type = 'nevus';
    end
    fprintf('processing image number %d, id = %s, type = %s\n',i, idList{i},type)
    
    %% read image and ground truth
    % read image, normalize values between 0 and 1, resize (for dullRazor)
    
    imName= strcat('ISIC_0000', idList{i}, '.jpg');
    I = double(imread(strcat(pathIm, imName)))/255;
    I = I(2:end-1,2:end-1,:);
    I = imresize(I,[512 680], 'bilinear');

    % read groundtruth mask, normalize, resize
    truthName= strcat('ISIC_0000', idList{i}, '_segmentation.png');
    T = double(imread(strcat(pathTruth, truthName)))/255;
    T = T(2:end-1,2:end-1,:);
    T = imresize(T,[512 680], 'nearest');
    
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
    % Threshold the image using Otsu's paper : 'threshold' is the optimal threshold.
    % eta is Otsu's separability measure at the optimal threshold. 
    % it can be used to evaluate the quality of the thresholding. 
    [threshold, eta] = otsu(IpreProc((IpreProc-2*blackM>0)));
    I_seuil = double(IpreProc < threshold)-blackM;
         
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
        %idx=find([stats.Area]>1000& distance<0.7*size(I_seuil,1));
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

    elseif strcmp(CCA_Enabled,'n')
        Isegt=I_seuil;
    end
    %% evaluation
    % compute dice and jaccard index 
    diceList(i) = dice(Isegt, T);
    jaccardList(i) =  jaccard(Isegt,T);
    
    segtList=cat(3,segtList,Isegt);
end

diceNevus=diceList(1:numel(idNevus));
jaccardNevus=jaccardList(1:numel(idNevus));

diceMela=diceList(numel(idNevus)+1:end);
jaccardMela=jaccardList(numel(idNevus)+1:end);
%% display
% plot the dice and jaccard indices for all images

F=figure;
subplot(1,2,1)
plot(diceNevus,'s','Color','red')
hold on
plot(get(gca,'xlim'), [mean(diceNevus) mean(diceNevus)],'red'); 
plot(jaccardNevus,'d','Color', 'blue')
plot(get(gca,'xlim'), [mean(jaccardNevus) mean(jaccardNevus)],'blue'); 
hold off
title('Dice and jaccard indices : nevus')
legend('dice','average dice','jaccard','average jaccard','Location','SouthWest')
% set(gca,'XTick',(1:20));
% set(gca,'XTickLabel',idNevus);

subplot(1,2,2)
plot(diceMela,'s','Color','red')
hold on
plot(get(gca,'xlim'), [mean(diceMela) mean(diceMela)],'red'); 
plot(jaccardMela,'d','Color', 'blue')
plot(get(gca,'xlim'), [mean(jaccardMela) mean(jaccardMela)],'blue'); 
hold off
title('Dice and jaccard indices : melanoma')
legend('dice','average dice','jaccard','average jaccard','Location','SouthWest')
% set(gca,'XTick',(1:20));
% set(gca,'XTickLabel',idMelanoma);

set(0, 'units', 'points')
p=get(0,'screensize');
set(F,'Position',[0.25*p(3) 0.25*p(4) 1.3*p(3) p(4)])


