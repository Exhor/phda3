function z = bathTipImg2Zernike(img, imgResizeTo, zerPolys)
% Turns bathtip acquired image/s into zernike moment/s
if imgResizeTo > 0
    img = imresize(img, [imgResizeTo imgResizeTo]);
end
if size(img,3) == 3
    img = rgb2gray(img);
end
img = reshape(double(img),size(img,1)*size(img,2),1)';
z = abs(img * zerPolys);

% #TODO: is this necessary? why are there 0 images? why is 321 zero?
if sum(z) == 0
    z(z == 0) = 1;
end
z = z / sum(z);
end