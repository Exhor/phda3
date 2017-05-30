function [ bagsOfWordsFullImage, bagsOfWordsBlindspotted, classLabels, objInstanceId, isOccluded, imlocs ] = pretrain_vision_raw( imgDir, pretImgDir, n_classes, n_imgs_per_class, valid_nwords, valid_ncomps, featureName, blindSpotsArea )
% Extract features from <n_imgs_per_class> images for each class and create
% histograms for all values of <n_words>, using all <valid_brightnesses>
    imgPret = imageSet(pretImgDir);
    imgSets = imageSet(imgDir,'recursive');
%     imgSetNimages = select(imgSets,1:n_imgs_per_class);
    d = 0; 
    imlocs = {};

    for gtClass = 1:n_classes; 
        noccluded = 0;
        nfull = 0;
        while noccluded < n_imgs_per_class/2 || nfull < n_imgs_per_class/2
            i = randi(imgSets(gtClass).Count);
            n = imgSets(gtClass).ImageLocation{i};
            m = strfind(n,'\');
            isocc = strcmp('o',n(m(end)+1)) | strcmp('_',n(m(end)+1)); 
            if (isocc && noccluded<n_imgs_per_class/2) || (~isocc && nfull<n_imgs_per_class/2)
                noccluded = noccluded + isocc;
                nfull = nfull + ~isocc;
                d=d+1; 
                isOccluded(d) = isocc;
                objInstanceId(d) = i; 
                classLabels(d) = gtClass;
                imlocs{d} = n;
            end
        end
    end
    
    bag = {};
    bagBlindSpots = {};
    for nwords = valid_nwords
        needPret = false;
        cachefile = sprintf('data/pretraining/cache_raw_%s_%s_nw_%d_bs_%d.mat',imgDir,featureName,nwords,round(100*blindSpotsArea));
        cachefileLocal = sprintf('C:/Users/tadeo/Documents/backup/database_phd_A1_data/data/pretraining/cache_raw_%s_%s_nw_%d_bs_%d.mat',imgDir,featureName,nwords,round(100*blindSpotsArea));
        if ~exist(cachefile,'file') && exist(cachefileLocal,'file')
            fprintf('Using local cache file: %s \n', cachefileLocal)
            cachefile = cachefileLocal;
        end
        if ~exist(cachefile,'file')
            fprintf('\nPretraining for nwords = %d:\n', nwords);
            if strcmp(featureName, 'SIFT')
                bag{nwords} = bagOfFeatures(imgPret,'Verbose',false,'VocabularySize',nwords,'CustomExtractor',@extractSIFT); 
            else
                bag{nwords} = bagOfFeatures(imgPret,'Verbose',false,'VocabularySize',nwords,'PointSelection','Detector'); 
    %             bag{nwords} = bagOfFeatures(imgPret,'Verbose',false,'VocabularySize',nwords,'CustomExtractor',@extractSURF);
            end
            bagoffeatures = zeros(n_imgs_per_class * n_classes,nwords); 
            bagoffeaturesBS = zeros(n_imgs_per_class * n_classes,nwords); 
            d = 0; 
            fprintf('Pretraining Class:');
            for gtClass = 1:n_classes; 
                for i=1:n_imgs_per_class; 
                    d=d+1; 
                    img = rgb2gray( imread(imlocs{d}) );
                    imgBS = applyBlindSpotsAndStandarise(img,blindSpotsArea);
                    k1 = numel(img)*128;
                    k2 = sum(img(:));
                    imgstd = uint8(double(img)*double(k1)/double(k2));
                    bagoffeatures(d,:) = encode(bag{nwords},imgstd) ; 
                    bagoffeaturesBS(d,:) = encode(bag{nwords},imgBS) ; 
                end; 
                fprintf('%d',gtClass); 
            end
            save(cachefile,'bagoffeatures','bagoffeaturesBS');
        else
            load(cachefile,'bagoffeatures','bagoffeaturesBS');
        end
        bagsOfWordsFullImage{nwords,valid_ncomps(1)} = bagoffeatures;     
        bagsOfWordsBlindspotted{nwords,valid_ncomps(1)} = bagoffeaturesBS;    
    end
end

