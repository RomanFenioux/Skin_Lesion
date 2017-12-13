close all
I = double(imread('../data/ISIC-2017_Training_sample/ISIC_0000001.jpg'))/255;
image=preProc(I,'blue');

% preproc : black frame removal (done)
% median smoothing of size

fprintf('preprocessing completed')
% Choose different scales
% Segmentation parameter Q; Q small few segments, Q large may segments
Qlevel=250;
% This creates the following list of Qs [256 128 64 32 16 8 4 2 1]
% Creates 9 segmentations

Isrm=srm(I*255,Qlevel);
figure(1)
imshow(image)
% hold on
% contour(Isrm(:,:,1));
% hold off
figure(2)
imshow(Isrm/255)

% post proc : selectionner les bonnes regions

