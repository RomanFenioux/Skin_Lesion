%  This Matlab code demonstrates an edge-based active contour model as an application of 
%  the Distance Regularized Level Set Evolution (DRLSE) formulation in the following paper:
%
%  C. Li, C. Xu, C. Gui, M. D. Fox, "Distance Regularized Level Set Evolution and Its Application to Image Segmentation", 
%     IEEE Trans. Image Processing, vol. 19 (12), pp. 3243-3254, 2010.
%
% Author: Chunming Li, all rights reserved
% E-mail: lchunming@gmail.com   
%         li_chunming@hotmail.com 
% URL:  http://www.imagecomputing.org/~cmli//

clear all;
close all;

imNum = input('image id (3 digits) : ', 's'); 

%[I,T] = getImage(imNum);

pathIm = '../data/ISIC-2017_Training_sample/';
imName= strcat('ISIC_0000', imNum, '.jpg');
I = double(imread(strcat(pathIm, imName))); % normalization
% Img=preProc(I,'X');
Img = I(:,:,3);
%% parameter setting
timestep=1;  % time step
mu=0.2/timestep;  % coefficient of the distance regularization term R(phi)
iter_inner=5;
epoch=50;
lambda=1; % coefficient of the weighted length term L(phi)
alpha=2;  % coefficient of the weighted area term A(phi)
epsilon=1.5; % parameter that specifies the width of the DiracDelta function



% initialize LSF as binary step function
c0=2;
initialLSF = c0*ones(size(Img));

%% initial LSF from user input
figure(1);
imshow(Img,[])
input=round(ginput()); 

%%%%%%% RECTANGLES %%%%%%%
% points from input are used to define rectangles
% for i = 1:size(input,1)/2
%     initialLSF(input(2*i-1,2):input(2*i,2),input(2*i-1,1):input(2*i,1))=-c0; % initial contour 
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% POLYGONS %%%%%%%%%
% points from input generate R0 as a polygonal mask
row=input(:,2);
col=input(:,1);
mask = roipoly(Img,col,row);
initialLSF(mask)=-c0;
%%%%%%%%%%%%%%%%%%%%%%%%%%

imin=min(row);
imax=max(row);
jmin=min(col);
jmax=max(col);
Img_temp = Img(imin:imax,jmin:jmax);

phi=initialLSF(imin:imax,jmin:jmax);

sigma=.8;    % scale parameter in Gaussian kernel
G=fspecial('gaussian',15,sigma); % Caussian kernel
Img_smooth=conv2(Img_temp,G,'same');  % smooth image by Gaussian convolution
[Ix,Iy]=gradient(Img_smooth);
f=Ix.^2+Iy.^2;
g=1./(1+f);  % edge indicator function.

figure(1);
mesh(-phi);   % for a better view, the LSF is displayed upside down
hold on;  contour(phi, [0,0], 'r','LineWidth',2);
title('Initial level set function');
view([-80 35]);

figure(2);
imshow(Img_temp,[]); hold on;  contour(phi, [0,0], 'r');
title('Initial zero level contour');
pause(0.5);

potential=2;  
if potential ==1
potentialFunction = 'single-well';  % use single well potential p1(s)=0.5*(s-1)^2, which is good for region-based model 
elseif potential == 2
potentialFunction = 'double-well';  % use double-well potential in Eq. (16), which is good for both edge and region based models
else
potentialFunction = 'double-well';  % default choice of potential function
end  

% start level set evolution
for n=1:epoch
    phi = level_set(phi, g, lambda, mu, alpha, epsilon, timestep, iter_inner, potentialFunction); 
    fprintf('iteration = %d / %d\n',n*iter_inner,epoch*iter_inner)
    % parameter can evolve in each epoch
end

% refine the zero level contour by further level set evolution with alpha=0
alpha=0;
iter_refine = 50;
phi = level_set(phi, g, lambda, mu, alpha, epsilon, timestep, iter_refine, potentialFunction);

Isegt=zeros(size(Img(:,:,1)));
Isegt(imin:imax,jmin:jmax)=double(phi<0);

figure(3);
imshow(Img,[]); hold on;  contour(Isegt, 'r');
str=['Final zero level contour, ', num2str(epoch*iter_inner+iter_refine), ' iterations'];
title(str);

figure;
mesh(-phi);   % for a better view, the LSF is displayed upside down
hold on;  contour(phi, [0,0], 'r','LineWidth',2);
title('final level set function');
view([-80 35]);
