function [ features,featureMetrics ] = extractSURF( img )
    if size(img,3) > 1
        img = rgb2gray(img);
    end
%     img = imresize(img, [300 300]);
%     img = single(img);
    points = detectSURFFeatures(img);
    if length(points) < 1
        error('too few surfs')
    end
    [features,validpoints] = extractFeatures(img, points);
%     [fr,features] = (img);
    featureMetrics = ones(size(features,1),1);
    features = single(features);
end

