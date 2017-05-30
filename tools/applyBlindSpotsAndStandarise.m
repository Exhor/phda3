function [img] = applyBlindSpotsAndStandarise(imgfull, obscuredFraction)
% Create blind spots to obscure <obscuredFraction> of vision

% Standarise intensity
k1 = numel(imgfull)*128;
k2 = sum(imgfull(:));
imgfull = uint8(double(imgfull)*double(k1)/double(k2));

% Repeatability. Images are always blotched in the same way.
seed = floor(sum(imgfull(:)));
rng(seed)

masker = false(size(imgfull));
blindSpotArea = 0;
A = numel(masker) / size(masker,3);
[cc rr] = meshgrid(1:size(imgfull,2),1:size(imgfull,1));

while abs(blindSpotArea - obscuredFraction * A) > A * 0.01
    col = randi(size(imgfull,2));
    row = randi(size(imgfull,1));
    rsquared = randi(floor(1.2 * (A - blindSpotArea) / pi));
    C = (rr-row).^2+(cc-col).^2 < rsquared;
    if size(masker,3) > 1
        C = repmat(C,[1 1 3]);
    end
    maskernew = masker | C;
    if sum(maskernew(:) / size(masker,3)) < obscuredFraction * A
        masker = maskernew;
        blindSpotArea = sum(masker(:) / size(masker,3));
    end
%     imshow( imgfull .* uint8(~masker) );
end
img = imgfull .* uint8(~masker);


end