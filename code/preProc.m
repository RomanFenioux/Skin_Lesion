function [ Ipreproc ] = preProc( I, channel )
%PREPROC computes all needed preprocessing on the image I
%   [ Ipreproc ] = preProc( I, channel )
%   channel contains a string : 
%   'meanRGB' average the channels RGB
%   'b' or 'blue' to select the blue channel in RGB space
%   'X' to select the X channel in CIE-XYZ space
%
%   NOTE : this function may require extra parameters in the future
%   Different segmentation methods will need different preprocessing.
%   For now preProc merely removes hair, using Dullrazor method and changes
%   the color channel.
    
    % removing hair with dullRazor
    Ishaved = dullRazor(I);
    
    % selecting meanRGB : averaging the channels R, G, B
    if strcmp(channel,'meanRGB')
        Ipreproc = sum(Ishaved,3)/3;
    
    % selecting blue channel
    elseif strcmp(channel, 'b') || strcmp(channel, 'blue')
        Ipreproc = Ishaved(:,:,3);
    
    % selecting X channel from CIE-XYZ
    elseif strcmp(channel,'X')
        cR = 0.4125;
        cG = 0.3576;
        cB = 0.1804;
        Ipreproc = cR*Ishaved(:,:,1) + cG*Ishaved(:,:,2) + cB*Ishaved(:,:,3);
    
    % selecting meanRGB by default
    else 
        warning('non existent or invalid channel argument : assumed meanRGB')
        Ipreproc = sum(Ishaved,3)/3;
    end

end

