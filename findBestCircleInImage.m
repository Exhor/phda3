function [r,c] = findBestCircleInImage(img)
if size(img,3)>1
    img = rgb2gray(img);
end
img = imgaussfilt(double(edge(imgaussfilt(img,5),'Canny')),3);
initialRowColRad = [size(img,1)/2 size(img,1)/2, size(img,1)/2];
rc = fminsearch(@(rowcolrad) meanOfPixelsInImgCircle(img, rowcolrad(1:2), rowcolrad(3)), initialRowColRad);
r = rc(1);
c = rc(2);
end

function mp = meanOfPixelsInImgCircle(img, ccenter, cradius)

[mx,my] = meshgrid(1:size(img,1),1:size(img,2));
mmasked = img(abs((mx-ccenter(1)).^2 + (my-ccenter(2)).^2 - cradius^2) < 1);
mp = mean(mmasked(:));
end