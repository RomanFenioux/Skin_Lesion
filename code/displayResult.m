function [] = displayResult(Iorig, Itruth, Isegt, Isegt2)
%DISPLAYRESULT a quick and simple way to evalute the segmentation visually
%on a given image.
%   Iorig is the original image before segmentation
%   Isegt is the segmentation mask obtained with the method
%   Itruth is the ground truth segmentation mask

compare=exist('Isegt2','var');
figure
imshow(Iorig)
hold on
[c,h] = contour(double(Isegt));
h.LineColor='red';
if compare
    [c,h] = contour(double(Isegt2));
    h.LineColor='blue';
end
[c,h]=contour(Itruth);
h.LineColor='green';
% if compare
%     legend('Otsu', 'Region','Truth')
% else
    legend('segmentation','Truth')
% end
end