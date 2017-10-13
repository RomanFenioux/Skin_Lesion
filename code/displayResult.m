function [] = displayResult(Iorig,Isegt, Itruth)
%DISPLAYRESULT a quick and simple way to evalute the segmentation visually
%on a given image.
%   Iorig is the original image before segmentation
%   Isegt is the segmentation mask obtained with the method
%   Itruth is the ground truth segmentation mask

figure
imshow(Iorig)
hold on
[c,h] = contour(double(Isegt));
h.LineColor='red';
hold on
[c,h]=contour(Itruth);
h.LineColor='green';
legend('Otsu result','ground truth')

end

