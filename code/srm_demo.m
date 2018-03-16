close all
clear all

imNum = input('image id (3 digits) : ', 's'); 
%% read image and ground truth
% custom function that reads an image and the ground truth mask
% I is normalized
path = '../data/easysample/';
[I,T] = getData(path,imNum);

% resize for dullRazor (optional but important for hairy images)
I = imresize(I,[538 720], 'bilinear');
T = imresize(T,[538 720], 'nearest'); % 'nearest' preserves T as a binary mask

%% Preprocessing and postprocessing options
%pre
channel='b'; % color channel : stay in color !
hair_removal = true; % dullrazor shaving
compute_blackframe = true; % removing blackframe in preproc

%post
compute_filling = false; % morphological filling of the holes in the ROI
compute_CCA = false; % denoising of small "islands" (keeping regions with area > 1000)
clear_border = true; % if true, removes regions that touches the border of the image
% preproc : black frame removal (done)
% median smoothing of size

%% PREPROCESSING STAGE
%%%%%%%% PREPROCESSING STAGE %%%%%%%%%%
[IpreProc, blackM, Ishaved]=preProc(I,channel, hair_removal, compute_blackframe);

fprintf('preprocessing completed')
% Choose different scales
% Segmentation parameter Q; Q small few segments, Q large may segments
Qlevel=250;
% This creates the following list of Qs [256 128 64 32 16 8 4 2 1]
% Creates 9 segmentations

Isrm=srm(IpreProc*255,Qlevel);
Isrm=Isrm/255;
figure(1)
imshow(IpreProc)
figure(2)
imshow(Isrm)


%% post proc : selectionner les bonnes regions
figure(3);
imshow(I,[])
input=round(ginput(2));  % selectionner patch de peau
skinpatch=IpreProc(input(1,2):input(2,2),input(1,1):input(2,1));
skinvalue=mean(skinpatch(:));
skinmatrix=ones(size(IpreProc))*skinvalue;
SrmSegt=double(abs(skinmatrix-Isrm)>60/255);

SrmSegt=postProc(SrmSegt);

displayResult(IpreProc,T,SrmSegt)





