clear all
close all

CCA_Enabled = input('enable connected component analysis? (y/n) ', 's'); 
segtMethod = input('segmentation method (otsu or region): ','s');
computeOtsu = strcmp(segtMethod,'otsu');
computeRegion = strcmp(segtMethod,'region');
compare = strcmp(segtMethod,'compare');

% Preprocessing and postprocessing options
hair_removal = true;
compute_blackframe = true;
compute_filling = true;
compute_CCA = strcmp(CCA_Enabled,'y');

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
etaList=zeros(numel(idList),1);
                
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
    
    [I, T] = getImage(idList{i});
    I = imresize(I,[538 720], 'bilinear');
    T = imresize(T,[538 720], 'nearest');
    
    %% dullRazor
    % hair removal using the dullRazor algorithm. Ishaved and I are RGB images
    Ishaved = dullRazor(I);

    %% channel selection
    % converts Ishaved to a grayscale image (here : channel X from CIE-XYZ)
    channel = 'blue';
    IpreProc= channelSelect(Ishaved, channel);

    %% black frame mask
    % blackM is a binary mask that equals 1 on the black borders of the image I
    % will be negative on the black border region, unchanged elsewhere
    blackM = blackFrame(IpreProc,0.2); 

    %% maximize dynamic range
    % we don't take the black borders into account, so these borders may end
    IpreProc=IpreProc-min(IpreProc(~logical(blackM)));
    IpreProc=IpreProc/max(IpreProc(~logical(blackM)));
    
    if computeOtsu
        %% otsu
        % Threshold the image using Otsu's paper : 'threshold' is the optimal threshold.
        % eta is Otsu's separability measure at the optimal threshold. 
        % it can be used to evaluate the quality of the thresholding. 
        [threshold, eta] = otsu(IpreProc((IpreProc-2*blackM>0)));
        I_seuil = double(IpreProc < threshold)-blackM;
        etaList(i)=eta;
    end
    
    if computeRegion
        figure(1);
        imshow(IpreProc)
        [x, y] = ginput(1);
        t=0.2;
        I_seuil=regionGrowing(IpreProc,round(x),round(y),t);
    end
    
    Isegt=postProc(I_seuil,compute_filling, compute_CCA, compute_blackframe);
    
    %% evaluation
    % compute dice and jaccard index 
    diceList(i) = dice(Isegt, T);
    jaccardList(i) =  jaccard(Isegt,T);
    
    segtList=cat(3,segtList,Isegt);
end

diceNevus=diceList(1:numel(idNevus));
jaccardNevus=jaccardList(1:numel(idNevus));
etaNevus=etaList(1:numel(idNevus));

diceMela=diceList(numel(idNevus)+1:end);
jaccardMela=jaccardList(numel(idNevus)+1:end);
etaMela=etaList(numel(idNevus)+1:end);
%% display
% plot the dice and jaccard indices for all images

F=figure;
subplot(1,2,1)
plot(diceNevus,'-s','Color','red')
hold on
plot(get(gca,'xlim'), [mean(diceNevus) mean(diceNevus)],'red'); 
plot(jaccardNevus,'-d','Color', 'blue')
plot(get(gca,'xlim'), [mean(jaccardNevus) mean(jaccardNevus)],'blue'); 
plot(etaNevus,'-o','Color', 'green')
hold off
axis([0 numel(diceNevus)+1 0 1])
title('Dice and jaccard indices : nevus')
legend('dice','average dice','jaccard','average jaccard','eta','Location','SouthWest')
% set(gca,'XTick',(1:20));
% set(gca,'XTickLabel',idNevus);

subplot(1,2,2)
plot(diceMela,'-s','Color','red')
hold on
plot(get(gca,'xlim'), [mean(diceMela) mean(diceMela)],'red'); 
plot(jaccardMela,'-d','Color', 'blue')
plot(get(gca,'xlim'), [mean(jaccardMela) mean(jaccardMela)],'blue'); 
plot(etaMela,'-o','Color', 'green')

hold off
axis([0 numel(diceMela)+1 0 1])
title('Dice and jaccard indices : melanoma')
legend('dice','average dice','jaccard','average jaccard','eta','Location','SouthWest')
% set(gca,'XTick',(1:20));
% set(gca,'XTickLabel',idMelanoma);

set(0, 'units', 'points')
p=get(0,'screensize');
set(F,'Position',[0.25*p(3) 0.25*p(4) 1.3*p(3) p(4)])

