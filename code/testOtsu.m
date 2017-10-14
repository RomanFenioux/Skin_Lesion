clear all
close all

% choose the number of the image (3 last digits)
imNum = input('image id (3 digits) : ', 's'); 

% choose the paths of the training images and ground truth segmentation masks
pathTraining = '../data/ISIC-2017_Training_sample/';
pathTruth = '../data/ISIC-2017_GroundTruth_sample/';

imName= strcat('ISIC_0000', imNum, '.jpg');
truthName= strcat('ISIC_0000', imNum, '_segmentation.png');

%% Segmentation of an image

I = double(imread(strcat(pathTraining, imName)))/255;

% pre-processing the image to change color space and remove hair
channel='X';
I = preProc(I,channel);

% compute the threshold using Otsu's paper : threshold is the optimal threshold.
% eta is the separability measure used by Otsu to choose the threshold (see otsu.m), it 
% can be used to evaluate the quality of the thresholding 
[threshold, eta] = otsu(I); 

I_seuil = double(I < threshold);

%% Evaluation by displaying the results and the corresponding ground truth mask

T = double(imread(strcat(pathTruth, truthName)))/255;

displayResult(I, I_seuil, T);


