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
while blindSpotArea < obscuredFraction * A
    rsquared = 1.1 * ((obscuredFraction * A - blindSpotArea) / pi);
    col = randi(size(imgfull,2));
    row = randi(size(imgfull,1));
    if ~masker(row,col)
        % Draw circle for blindspot
        C = (rr-row).^2+(cc-col).^2 < rsquared;
        if size(masker,3) > 1
            C = repmat(C,[1 1 3]);
        end
        masker = masker | C;
        blindSpotArea = sum(masker(:));
    end
end
img = imgfull .* uint8(~masker);


end