function [ bagsOfSURF, classLabels, objInstanceId ] = pretrain_vision_surf( imgDir, pretImgDir, n_classes, n_imgs_per_class, n_words, valid_brightnesses )
% Extract SURF from <n_imgs_per_class> images for each class and create
% histograms for all values of <n_words>, using all <valid_brightnesses>
    imgPret = imageSet(pretImgDir);
    imgSets = imageSet(imgDir,'recursive');
    imgSetNimages = select(imgSets,1:n_imgs_per_class);
    for nw = n_words
        fprintf('Pretraining for nwords = %d:', nw);
        bag{nw} = bagOfFeatures(imgPret,'Verbose',false,'VocabularySize',nw,'PointSelection','Detector'); 
        for brightnessID = 1:length(valid_brightnesses)
            brightness = valid_brightnesses(brightnessID);
            bagofsurf = zeros(n_imgs_per_class * n_classes,nw); 
            classLabel = zeros(n_imgs_per_class * n_classes,1); 
            d = 0; 
            fprintf('Pretraining Class:');
            for gtClass = 1:n_classes; 
                for i=1:n_imgs_per_class; 
                    d=d+1; 
                    objInstanceId(d) = i; 
                    img = rgb2gray( imread(imgSetNimages(gtClass).ImageLocation{i}) );
                    k1 = prod(size(img))*128;
                    k2 = sum(img(:));
                    imgstd = uint8(double(img)*double(k1)/double(k2));
                    bagofsurf(d,:) = encode(bag{nw},imgstd) ; 
                    classLabel(d) = gtClass;
                end; 
                fprintf('%d',gtClass); 
            end
            bagsOfSURF{nw,brightnessID} = bagofsurf; 
            classLabels{nw,brightnessID} = classLabel;
        end
    end

end

