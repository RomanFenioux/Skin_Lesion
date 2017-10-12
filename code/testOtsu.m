clear all
close all

% choose the number of the image (3 last digits)
imNum = '002'; 

% choose the paths of the training images and ground truth segmentation masks
pathTraining = '../data/ISIC-2017_Training_sample/';
pathTruth = '../data/ISIC-2017_GroundTruth_sample/';

imName= strcat('ISIC_0000', imNum, '.jpg');
truthName= strcat('ISIC_0000', imNum, '_segmentation.png');

%% Segmentation of an image

I = double(imread(strcat(pathTraining, imName)));

% pre-processing the image to change color space and remove hair
channel='blue';
I = preProc(I,channel);

% compute the threshold using Otsu's paper : threshold is the optimal threshold.
% eta is the separability measure used by Otsu to choose the threshold (see otsu.m), it 
% can be used to evaluate the quality of the thresholding 
[threshold, eta] = otsu(I); 

I_seuil = double(I < threshold);

%% Evaluation by displaying the results and the corresponding ground truth mask

T = double(imread(strcat(pathTruth, truthName)));

figure
imshow(uint8(I))
hold on
[c,h] = contour(double(I_seuil));
h.LineColor='red';
hold on
[c,h]=contour(T);
h.LineColor='green';
legend('Otsu result','ground truth')
title(strcat('otsu, image :',imNum,', channel : ',channel));





