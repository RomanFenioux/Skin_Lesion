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
    
    % selecting blue channel
    elseif strcmp(channel, 'b') || strcmp(channel, 'blue')
        I = I(:,:,3);
    
    % selecting X channel from CIE-XYZ
    elseif strcmp(channel,'X')
        cR = 0.4125;
        cG = 0.3576;
        cB = 0.1804;
        I = cR*I(:,:,1) + cG*I(:,:,2) + cB*I(:,:,3);
    
    else 
        warning('non existent or invalid channel argument : assumed meanRGB')
        I = sum(I,3)/3;
    end
    
    
    Ipreproc= dullRazor(I);    

end

