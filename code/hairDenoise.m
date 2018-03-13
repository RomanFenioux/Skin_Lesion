function [Mdenoised] = hairDenoise(M)
%HAIRDENOISE cleans the hair mask obtained with dullRazor
%   M is the hair mask obtained in the step 1 of dullRazor function
%   Mdenoised is the cleaned hair mask
%
%   We check all pixels from M to see if they are connected to a hair (ie.
%   a line long enough). To achieve that, we start from a pixel and we
%   check 4 direction (horizontal, vertical, both diagonals) and see how
%   far we can go. We keep the pixel when one direction has a length > 50
%   and all others < 10
   
%%%%********* TEMPORARY MORPHOLOGICAL DENOISING ***********%%%%

    SE0  =  [0, 1, 1, 1, 1, 1, 1, 0];
    SE90 =  [0; 1; 1; 1; 1; 1; 1; 0];
    SE45 =  [0 0 0 0 0 0 0 0;
             0 1 0 0 0 0 0 0;
             0 0 1 0 0 0 0 0;
             0 0 0 1 0 0 0 0;
             0 0 0 0 1 0 0 0;
             0 0 0 0 0 1 0 0;
             0 0 0 0 0 0 1 0;
             0 0 0 0 0 0 0 0;];
    SE135=  [0 0 0 0 0 0 0 0;
             0 0 0 0 0 0 1 0;
             0 0 0 0 0 1 0 0;
             0 0 0 0 1 0 0 0;
             0 0 0 1 0 0 0 0;
             0 0 1 0 0 0 0 0;
             0 1 0 0 0 0 0 0;
             0 0 0 0 0 0 0 0;];
     
    Mdenoised=cat(3, imopen(M,SE0),imopen(M,SE90),imopen(M,SE45),imopen(M,SE135));
    Mdenoised=max(Mdenoised,[],3);

%%%%*******************************************************%%%%
      
%     [sizeX, sizeY] = size(M);
%     Mdenoised = M;
%     [row, col]=find(Mdenoised==1);
%     
%     for p=1:size(row,1)
%         
%         % INIT PHASE
%         
%         % i1, i2, j1, j2 are the coordinates of the ends of the differents 
%         % lines (e.g vertical goes from (i1,(j1+j2)/2) to (i2,(j1+j2)/2),
%         % right diag goes from (i2,j1) to (i1,j2), etc...)
%         % These coordinates are initialised to the position of the
%         % currently evaluated pixel.
%         
%         % pmin, pmax are the ends of each lines.
%         % Since we compute all 4 lines in a single while loop, these 
%         % parameters identified with the letters H, V, RD, LD.
%         
%         ip=row(p);
%         jp=col(p);
%         i1=ip;
%         i2=ip;
%         j1=jp;
%         j2=jp;
% 
%         % horizontal line init 
%         p1H=1;
%         p2H=1;
%         
%         % vertical line int
%         p1V=1;
%         p2V=1;
%         
%         % right diagonal line init
%         p1RD=1;
%         p2RD=1;
%         
%         % left diagonal line init
%         p1LD=1;
%         p2LD=1; 
%         
%         % a vector to store the lengths of the 4 lines in the following order
%         % H,V,RD,RL 
%         % (there is a -4 offset to cancel the effect of the first loop. Not
%         % very clean I know...)
%         lengths=zeros(1,4)-4;
%         
%         % computing the lines while there is at least one end still in the
%         % hair mask (while one of the p1 or p2 is 1, we keep extending the
%         % corresponding line)
%         while ((p1H || p2H || p1V || p2V || p1RD || p2RD || p1LD || p2LD) && max(lengths)<50)           
%             % update the values if there are still in the hair mask (if
%             % their value is 1)
%             
%             if p1H 
%                 p1H  =  M( ip, j1);       
%                 lengths(1) = lengths(1) + 1;
%             end
%             if p2H
%                 p2H  =  M( ip, j2);
%                 lengths(1) = lengths(1) + 1;
%             end
%             if p1V
%                 p1V  =  M( i1, jp);
%                 lengths(2) = lengths(2) + 1;
%             end
%             if p2V
%                 p2V  =  M( i2, jp);
%                 lengths(2) = lengths(2) + 1;
%             end
%             if p1RD
%                 p1RD =  M( i2, j1);   
%                 lengths(3) = lengths(3) + 1;
%             end
%             if p2RD                
%                 p2RD =  M( i1, j2);
%                 lengths(3) = lengths(3) + 1;
%             end
%             if p1LD
%                 p1LD =  M( i1, j1);
%                 lengths(4) = lengths(4) + 1;
%             end
%             if p2LD
%                 p2LD =  M( i2, j2);   
%                 lengths(4) = lengths(4) + 1;
%             end
%           
%             % update the positions of the ends of the lines unless we
%             % reached the border of the image
%             if (i1-1 > 0)
%                 i1=i1-1;
%             else
%                 p1V=0;
%                 p1LD=0;
%                 p2RD=0;
%             end
%             if (i2+1 <= sizeX)
%                 i2=i2+1;    
%             else
%                 p1RD=0;
%                 p2V=0;
%                 p2LD=0;
%             end
%             if (j1-1 > 0)
%                 j1=j1-1;
%             else
%                 p1LD=0;
%                 p1H=0;
%                 p1RD=0;
%             end
%             if (j2+1 <= sizeY)
%                 j2=j2+1;
%             else
%                 p2RD=0;
%                 p2H=0;
%                 p2LD=0;
%             end
%             
%         end
%         
%         % longest line
%         maxlength = max(lengths);
%         
%         % second longest line
%         maxlength2 = max(lengths(lengths<max(maxlength)));
%         
%         % verification of the criterium : We only keep pixels when the 
%         % longest line is longer than 50 and all others are shorter than 10 
%         if (maxlength < 30 || maxlength2 > 10)
%             Mdenoised(row(p), col(p))=0;
%         end
%         
%     end
    
end