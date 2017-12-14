close all
I = double(imread('../data/ISIC-2017_Training_sample/ISIC_0000095.jpg'))/255;
I = I(2:end-1,2:end-1,:);
I = imresize(I,[512 nan], 'bilinear');
IpreProc=preProc(I,'X');

% preproc : black frame removal (done)
% median smoothing of size

fprintf('preprocessing completed')
% Choose different scales
% Segmentation parameter Q; Q small few segments, Q large may segments
Qlevel=250;
% This creates the following list of Qs [256 128 64 32 16 8 4 2 1]
% Creates 9 segmentations

Isrm=srm(IpreProc*255,Qlevel);
figure(1)
imshow(IpreProc)
% hold on
% contour(Isrm(:,:,1));
% hold off
figure(2)
imshow(Isrm/255)

% post proc : selectionner les bonnes regions

