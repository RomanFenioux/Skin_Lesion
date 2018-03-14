function [ IpreProc, blackM , Ishaved] = preProc( I, channel, hair_removal, blackframe_param)
%PREPROC computes all needed preprocessing on the image I
%   [ IpreProc, blackM ] = preProc( I, channel, [hair_removal, blackframe] )
%   channel contains a string : 
%   'meanRGB' average the channels RGB
%   'r' or 'red' to select the red channel in RGB space
%   'g' or 'green' to select the green channel in RGB space
%   'b' or 'blue' to select the blue channel in RGB space
%   'X' to select the X channel in CIE-XYZ space
%
%   NOTE : this function may require extra parameters in the future
%   Different segmentation methods will need different preprocessing.
%   For now preProc merely removes hair, using Dullrazor method and changes
%   the color channel.
    
%% PARAMS
if exist('hair_removal','var')
    hair = hair_removal;
else
    hair = true;
end
if exist('blackframe_param','var') 
    blackframe = blackframe_param;
else
    blackframe = true;
end

%% dullRazor
% hair removal using the dullRazor algorithm. Ishaved and I are RGB images
Ishaved = I;
if hair
    Ishaved = dullRazor(I);
end
%% channel selection
% converts Ishaved to a grayscale image (here : channel X from CIE-XYZ)
IpreProc= channelSelect(Ishaved, channel);

%% black frame mask
% blackM is a binary mask that equals 1 on the black borders of the image I
blackM = zeros(size(IpreProc));
if blackframe 
    blackM = blackFrame(IpreProc,0.2); 
end
%% maximize dynamic range
% we don't take the black borders into account, so these black area may end
% up negative if their intensity is lower than the computed minimum
IpreProc=IpreProc-min(IpreProc(~logical(blackM)));
IpreProc=IpreProc/max(IpreProc(~logical(blackM)));


end