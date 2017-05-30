function [imgcropped, newCentre, actualRadius] = findCentreCutAndScale(imgraw, maxRadius, previousCentre)
% Finds the sensor circle centre and returns a cropped img with max radius
[imrows, imcols, imrgb] = size(imgraw);
if imrgb > 1
    imgraw = rgb2gray(imgraw);
end
centreGuess = previousCentre;
if previousCentre(1) < 0
    centreGuess(1) = floor(imrows / 2);
    centreGuess(2) = centreGuess(1);
end

% Find 6 corners
img = imgaussfilt(double(edge(imgaussfilt(imgraw,5),'Canny')),10);
i1 = img(1,:); [~,m] = max(i1(1:50)); p(1,:) = [1 m];
i1 = img(1,:); [~,m] = max(i1(floor(imrows/2):floor(imrows/2)+100)); p(2,:) = [1 m+floor(imrows/2)];
i1 = img(imrows,:); [~,m] = max(i1(1:50)); p(3,:) = [imrows m];
i1 = img(imrows,:); [~,m] = max(i1(floor(imrows/2):floor(imrows/2)+100)); p(4,:) = [imrows m+floor(imrows/2)];

% 
% imgsmooth = imgaussfilt(imgraw, 40);
% ilocal = imgsmooth(centreGuess(1) + [-50:50], centreGuess(2) + [-50:50]);
% [m,i] = max(ilocal(:));
% [I_row, I_col] = ind2sub(size(ilocal), i);
% newCentre(1) = I_row - 50 + centreGuess(1);
% newCentre(2) = I_col - 50 + centreGuess(2);

% for ii = 2:length(rn)
%     if norm(p(ii,:) - p(ii-1,:)) > jump*1.2
%         
x0 = centreGuess;
% validP = findValidPts(x0, p);
validP = p;
newCentre = fminsearch(@(x) std(pdist2(x,validP)), x0);
actualRadius = floor(min([maxRadius, newCentre(1), imrows-newCentre(1), newCentre(2), imcols-newCentre(2)])) - 1;



imgcropped = imgraw([-actualRadius:actualRadius] + round(newCentre(1)), [-actualRadius:actualRadius] + round(newCentre(2)));
end

function validPts = findValidPts(x, p)
    d = pdist2(x,p);
    m = median(d);
    validPts = p(abs(d-m) < 5, :); % magic number 5, empirically found
end
