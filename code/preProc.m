function [ Ipreproc ] = preProc( I, channel )
%PREPROC computes all needed preprocessing on the image I
%   [ Ipreproc ] = preProc( I, channel )
%   channel contains a string : 
%   'meanRGB' average the channels RGB
%   'b' or 'blue' to select the blue channel in RGB space
%   'X' ***** TO BE IMPLEMENTED **** the X channel in CIE-XYZ space
%
%
%
%   NOTE :this function may dispapear or require extra parameters in the future
%   Different segmentation methods will need different preprocessing.
%   For now preProc merely removes hair, using Dullrazor method and changes
%   the color channel.
    
    % averaging the channels R, G, B
    if strcmp(channel,'meanRGB')
        I = sum(I,3)/3;
    end
    
    % selecting blue channel
    if strcmp(channel, 'b') || strcmp(channel, 'blue')
        I = I(:,:,3);
    end
    
    
    
    Ipreproc= dullRazor(I);    

end

