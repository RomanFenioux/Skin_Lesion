function [ img, groundTruth ] = getData(path, imNum,type_param )
%READIMAGE reads an image from the database 
%   [ img, groundTruth ] = getImage(path, imNum, type )
%   this functions also crops the image by a 1 pixel because some have an
%   annoying white one-pixel-wide border.

if exist('type_param','var')
    type=type_param;
else
    nevusList = dir([path 'training/nevus/*.jpg']); % file list (nevus)
    idNevus = cell(1,numel(nevusList));
    for i=1:numel(nevusList)
        idNevus{i}=nevusList(i).name(end-6:end-4); % to get the 3 last digits without extension.jpg
    end
    melaList = dir([path 'training/melanoma/*.jpg']); % file list (melanoma)
    idMelanoma = cell(1,numel(melaList));
    for i=1:numel(melaList)
        idMelanoma{i}=melaList(i).name(end-6:end-4); % to get the 3 last digits without extension.jpg
    end
    
    % check if the imNum is a nevus or melanoma
    if find(strcmp(imNum,idNevus))
        type='nevus';
    else if find(strcmp(imNum,idMelanoma))
            type='melanoma';
        else
            fprintf('Wrong id number or path for data')
         end
    end            
end

% retrieving image and groundtruth
pathIm = [path 'training/' type '/'];
imName= strcat('ISIC_0000', imNum, '.jpg');
img = double(imread(strcat(pathIm, imName)))/255; % normalization
img = img(2:end-1,2:end-1,:); % crop because of artifacts on some images

pathTruth = [path 'truth/' type '/']; 
truthName= strcat('ISIC_0000', imNum, '_segmentation.png');
groundTruth = double(imread(strcat(pathTruth, truthName)))/255; % normalize
groundTruth = groundTruth(2:end-1,2:end-1,:); % crop to match the image

end