clear all
close all

% choose the number of the image (2 last digits), the paths of the training
% set and ground truth data, etc...

imNum = '13'; 
pathTraining = '../data/ISIC-2017_Training_sample/';
pathTruth = '../data/ISIC-2017_GroundTruth_sample/';

imName= strcat('ISIC_00000', imNum, '.jpg');
truthName= strcat('ISIC_00000', imNum, '_segmentation.png');

I = double(imread(strcat(pathTraining, imName)));
I = sum(I,3)/3;

T = double(imread(strcat(pathTruth, truthName)));

[threshold eta] = otsu(I); % we compute the threshold using otsu's paper

I_seuil = double(I < threshold);

imshow(uint8(I))
hold on
[c,h] = contour(double(I_seuil));
h.LineColor='red';
hold on
[c,h]=contour(T);
h.LineColor='green';
legend('Otsu result','ground truth')





