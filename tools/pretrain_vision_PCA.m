
function [imgBOWs,imgLabels,objInstanceId] = pretrain_vision_PCA( imgDir, pretImgDir, n_classes, n_imgs_per_class, n_words, valid_ncompsV, featureName )
% Pretrains vision using a random set of images in <pretImgDir>
% Computes histograms of BoWs for images in <imgDir>
cacheFile = sprintf('data/pretraining/pret_%s_PCA.mat',featureName);
preload = true;
imgBOWs = {};
meanFeat = [];
pretFiles = dir(pretImgDir);
imgSets = imageSet(imgDir,'recursive');
imgSetNimages = select(imgSets,1:n_imgs_per_class);
d=0;
for gtClass = 1:n_classes; 
    for i=1:n_imgs_per_class; 
            d=d+1; 
            objInstanceId(d) = i;
            imgLabels(d) = gtClass;
    end
end

if preload && exist(cacheFile)
    load(cacheFile,'meanFeat','score','coeff','featDescriptors')
else
    featuresOfRandomImages = [];
    fprintf(['Obtaining ' featureName ' of random images for feature selection']);
    for i=1:length(pretFiles)
        if strfind(pretFiles(i).name,'jpg') | strfind(pretFiles(i).name,'png')
            img = rgb2gray(imread(['randomImagesForPreTraining/' pretFiles(i).name]));
            %[fe,features] = vl_sift(standariseImg(img));
% 			stimg = standariseImg(img);
			features = getFeats(img,featureName,0);
            featuresOfRandomImages = [featuresOfRandomImages; features];
            fprintf('.');
        end
    end
    featuresOfRandomImages = single(featuresOfRandomImages);
    [coeff,score] = pca(featuresOfRandomImages);
    meanFeat = mean(featuresOfRandomImages);

    % Compute features for db images
    featDescriptors = {};
    fprintf('\nComputing %s for class:',featureName);
    for gtClass = 1:n_classes; 
        for i=1:n_imgs_per_class; 
            img = rgb2gray( imread(imgSetNimages(gtClass).ImageLocation{i}) );
            %[fe,de] = vl_sift(standariseImg(img));
% 			stimg = standariseImg(img);
            featDescriptors{gtClass, i} = getFeats(img,featureName,meanFeat);
        end; 
        fprintf('%d',gtClass); 
    end
    save(cacheFile,'meanFeat','score','coeff','featDescriptors')
end
% Compute histogram BOWs

for nw = n_words
    fprintf('\n%d of %d:',find(nw==n_words),length(n_words));
    for ncompsV = valid_ncompsV
        cached = sprintf('data/pretraining/pret_%s_%s_words_%d_comps_%d.mat',imgDir,featureName,nw,ncompsV);
        if exist(cached) && preload
            ff = load(cached);
            imgBOWs{nw,ncompsV} = ff.bagOfWords;
            fprintf('Cached!');
        else
            [centres,~] = vl_kmeans(single(score(:,1:ncompsV))', nw);
            knn = fitcknn(centres', 1:nw);
            bagOfWords = zeros(n_imgs_per_class * n_classes,nw); 
            classLabel = zeros(n_imgs_per_class * n_classes,1); 
            fprintf('\nPretraining Class:');
            d=0;
            for gtClass = 1:n_classes; 
                for i=1:n_imgs_per_class; 
                    de = featDescriptors{gtClass,i};
                    dePCA = coeff(:,1:ncompsV)' * single(de)';
                    vwords = knn.predict(single(dePCA)');
                    hh = histcounts(vwords, 1:(nw+1));
                    d=d+1;
                    if sum(hh) > 0
                        hh = hh / sum(hh);
                    end
                    bagOfWords(d,:) = hh;
                    classLabel(d) = gtClass;
                end; 
                fprintf('%d',gtClass); 
            end
            imgBOWs{nw,ncompsV} = bagOfWords; 
            assert(~any(isnan(bagOfWords(:))));
            save(cached,'bagOfWords');
        end
    end        
end
end
function [imgstd] = standariseImg(img)
    img = single(img);
    k1 = prod(size(img))*128;
    k2 = sum(img(:));
    imgstd = img*k1/k2;
end
function [features] = getFeats(img,featureName,meanToSubtract)
    if strcmp(featureName, 'SURF')
        points = detectSURFFeatures(img);
        [features,~] = extractFeatures(img,points,'Method','SURF','SURFSize',128);
        features = single(features);
    else
        [fe,features] = vl_sift(standariseImg(img));
        if meanToSubtract
            features = single(features') - repmat(meanToSubtract, [size(features,2) 1]);
        else
            features = features';
        end
    end
end