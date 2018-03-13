function [ img, groundTruth ] = getImage( imNum )
%READIMAGE reads an image from the database 
%   [ img, groundTruth ] = getImage( imNum )
%   this functions also crops the image by a 1 pixel because some have an
%   annoying white one-pixel-wide border.

pathIm = '../data/ISIC-2017_Training_sample/';
imName= strcat('ISIC_0000', imNum, '.jpg');
img = double(imread(strcat(pathIm, imName)))/255; % normalization
img = img(2:end-1,2:end-1,:); % crop because of artifacts on some images

pathTruth = '../data/ISIC-2017_GroundTruth_sample/'; 
truthName= strcat('ISIC_0000', imNum, '_segmentation.png');
groundTruth = double(imread(strcat(pathTruth, truthName)))/255; % normalize
groundTruth = groundTruth(2:end-1,2:end-1,:); % crop to match the image

end