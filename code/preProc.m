function [ IpreProc ] = preProc( I, channel )
%PREPROC computes all needed preprocessing on the image I
%   [ IpreProc ] = preProc( I, channel )
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
   
    
    % removing hair with dullRazor
    Ishaved = dullRazor(I);
    
    % selecting channel
    IpreProc = channelSelect(Ishaved, channel);
    
    % maximize dynamic range
    IpreProc=(IpreProc-min(IpreProc(:)))/max(IpreProc(:));

end

