function [ features,featureMetrics ] = extractSIFT( img )
    img = imresize(img, [300 300]);
    if size(img,3) > 1
        img = rgb2gray(img);
    end
    img = single(img);
    [fr,features] = vl_sift(img);
    featureMetrics = ones(size(features,2),1);
    features = single(features');
end

