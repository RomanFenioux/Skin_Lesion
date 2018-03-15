function [ Ishaved ] = dullRazor( I )
%DULLRAZOR Hair removal
%   [ Ishaved ] = dullRazor( I )
%   I is the RGB image
%   Ishaved is the RGB image without the hair
%

    Ishaved=I;
    [sizeX, sizeY]=size(I(:,:,1));

    

    %% 1st step : locating dark hair (=computing the hair mask)
    
    %   maskThreshold is a threshold used to get the hair mask from the morphological
    %   closing image. It is a heuristic value.
    maskThreshold = 0.1;    

    % we separate the 3 RGB components of I. Each channel will be processed
    % separately, then the 3 hair masks will be merged
    Ir = I(:,:,1);
    Ig = I(:,:,2);
    Ib = I(:,:,3);
    
    % 3 structure elements (vertical, horizontal, 45 degree)
    SE0  =  [0, 1, 1, 1, 1, 1, 1, 1, 1, 0];
    SE90 =  [0; 1; 1; 1; 1; 1; 1; 1; 1; 0];
    SE45 =  [0 0 0 0 0 0 0 0 0 0;
             0 1 0 0 0 0 0 0 0 0;
             0 0 1 0 0 0 0 0 0 0;
             0 0 0 1 0 0 0 0 0 0;
             0 0 0 0 1 0 0 0 0 0;
             0 0 0 0 0 1 0 0 0 0;
             0 0 0 0 0 0 1 0 0 0;
             0 0 0 0 0 0 0 1 0 0;
             0 0 0 0 0 0 0 0 1 0;
             0 0 0 0 0 0 0 0 0 0;];
    SE135=  [0 0 0 0 0 0 0 0 0 0;
             0 0 0 0 0 0 0 0 1 0;
             0 0 0 0 0 0 0 1 0 0;
             0 0 0 0 0 0 1 0 0 0;
             0 0 0 0 0 1 0 0 0 0;
             0 0 0 0 1 0 0 0 0 0;
             0 0 0 1 0 0 0 0 0 0;
             0 0 1 0 0 0 0 0 0 0;
             0 1 0 0 0 0 0 0 0 0;
             0 0 0 0 0 0 0 0 0 0;];
    
    % compute the morphological closing on each channel with the 3 SE
    Irclose = cat(3, imclose(Ir,SE0),imclose(Ir,SE45), imclose(Ir,SE90), imclose(Ir,SE135));
    Igclose = cat(3, imclose(Ig,SE0),imclose(Ig,SE45), imclose(Ig,SE90), imclose(Ig,SE135));
    Ibclose = cat(3, imclose(Ib,SE0),imclose(Ib,SE45), imclose(Ib,SE90), imclose(Ib,SE135));
    
    
    % compute the closing masks on each channel with a heuristic threshold
    Gr = abs(Ir-max(Irclose,[],3));
    Gg = abs(Ig-max(Igclose,[],3));
    Gb = abs(Ib-max(Ibclose,[],3));
   
    Mr = double(Gr>maskThreshold);
    Mg = double(Gg>maskThreshold);
    Mb = double(Gb>maskThreshold);
    
    % the final mask M is the union of the 3 masks obtained on each channel
    M=max(cat(3,Mr,Mg,Mb), [], 3);
    
    %% 2d step : denoising and interpolation of the removed hair
    
    % we check all hair pixels in M to remove the outliers with the function
    % hairDenoise : if a pixels is not connected to a line (=a hair) then
    % this pixel is removed from M. See hairDenoise for further details
    
    %Md=hairDenoise(M);
    Md=hairDenoise(M);
    
    % linear interpolation. To avoid using hair pixel for the
    % interpolation we give ourselves 4 chances for finding pixels outside 
    % of the hair. We check the mask in the 4 direction (vertical,
    % horizontal, both diagonals) for pairs of non-hair pixels.
    
    d=20;
    [row, col]=find(Md==1);
    for p=1:size(row,1)
        
        i=row(p);
        j=col(p);
        
        imin=max(i-d,1);
        imax=min(i+d,sizeX);
        jmin=max(j-d,1);
        jmax=min(j+d,sizeY);
        Hborder=false;
        Vborder=false;
        % border check
        if (imin~=i-d || imax~=i+d)
            firstbestneighbor=2; % top or bottom border forces horizontal 
            Hborder=true;
        end
        if (jmin~=j-d || jmax~=j+d)
            firstbestneighbor=1; % right or left border forces vertical
            Vborder=true;
        end    
        if (Hborder && Vborder)
            firstbestneighbor=5; % both border (corner): leave I(i,j) as it is
        end
        
        if (~Hborder && ~Vborder) % no border, clear to go            
            neighbors=[Md(imin,j), Md(i,jmin), Md(imax,jmin), Md(imin,jmax), 0;
                       Md(imax,j), Md(i,jmax), Md(imin,jmax), Md(imax,jmin), 0];

            % neighbors are valid only if both are outside of the hair : their
            % positions in the mask should both have a value of 1 (-> we multiply the 2 row)
            validneighbors=1-neighbors(1,:).*neighbors(2,:);
            [~, firstbestneighbor]=max(validneighbors);
        end
        
        switch firstbestneighbor
            case 1 % vertical neighbors
                Ishaved(i,j,:)=(I(imin,j,:)+I(imax,j,:))/2;
            case 2 % horizontal neighbors
                Ishaved(i,j,:)=(I(i,jmin,:)+I(i,jmax,:))/2;
            case 3 % left diagonal neighbors
                Ishaved(i,j,:)=(I(imin,jmin,:)+I(imax,jmax,:))/2;
            case 4 % right diagonal neighbors
                Ishaved(i,j,:)=(I(imin,jmax,:)+I(imax,jmin,:))/2;
            case 5 % border problem or no good neighbor, no interpolation
                Ishaved(i,j,:)=I(i,j,:);
        end
        
    end
    
    %% 3d step : remove artifacts
    
    % binary dilatation of the hair mask
    SEdilat = [0 0 0 0 0 0 0 0 0;
               0 1 1 1 1 1 1 1 0;
               0 1 1 1 1 1 1 1 0;
               0 1 1 1 1 1 1 1 0;
               0 1 1 1 1 1 1 1 0;
               0 1 1 1 1 1 1 1 0;
               0 1 1 1 1 1 1 1 0;
               0 1 1 1 1 1 1 1 0;
               0 0 0 0 0 0 0 0 0;];
    Mdilat= imdilate(Md, SEdilat);
    
    % adaptative median filter : we only apply it on the pixel of the
    % dilated hair mask (to remove remaining hair lines artifacts)
    
    % computing the median filtered shaved image
    ImedianR = medfilt2(Ishaved(:,:,1),[5, 5]);
    ImedianG = medfilt2(Ishaved(:,:,2),[5, 5]); 
    ImedianB = medfilt2(Ishaved(:,:,3),[5, 5]);
    
    % replacing the pixels located in the dilated hair mask by the filtered pixels 
    indexes=find(Mdilat==1);
    IshavedR = Ishaved(:,:,1);
    IshavedG = Ishaved(:,:,2);
    IshavedB = Ishaved(:,:,3);
    
    IshavedR(indexes) = ImedianR(indexes);
    IshavedG(indexes) = ImedianG(indexes);
    IshavedB(indexes) = ImedianB(indexes);
    
    Ishaved = cat(3, IshavedR, IshavedG, IshavedB);

    
end