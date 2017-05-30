function A3b_vision2histograms(visdir, pretImgDir, histfilename, nclasses, numberofinstances, valid_nwords, featureDesc)
% Read visual database and turn into feature vectors (histogram of words)
    blindSpotsArea = 0.2;
    % Pretrain
    pretrainagain = false;
    pretvisfile = sprintf('data/pret_vision_%s_20_to_160.mat',featureDesc);
    if exist(pretvisfile) || pretrainagain
        load(pretvisfile, 'knn')
    else
        d = dir(fullfile(pretImgDir,'*.jpg'));
        feats_pret = [];
        for i = 1:length(d)
            sprintf('Pretraining %d of %d',i,length(d))
            img = imread(fullfile(pretImgDir, d(i).name));
            imgstd = applyBlindSpotsAndStandarise(img, 0.0); % no bs
            descriptors = getFeats(imgstd, featureDesc, false);
            feats_pret = [feats_pret; descriptors];
        end
        for nwords = valid_nwords
            % raw imgs
            [idx, centres] = kmeans(feats_pret, nwords);
            knn{nwords} = fitcknn(centres, 1:nwords);
        end 
        save(pretvisfile, 'knn') 
    end
    classdir = dir(fullfile(visdir,'*_*'));
    nclasses_test = length(classdir)
    assert(nclasses_test <= nclasses)
%     maxp = imgsPerInst * numberofinstances * nclasses_test;
    for nwords = valid_nwords 
        v.histograms_raw{nwords} = []; % zeros(maxp, nwords);
        v.histograms_bs{nwords} = []; % zeros(maxp, nwords);
    end
    v.objClass = []; % zeros(1,maxp);
    v.objInstance = []; % zeros(1,maxp);
    v.objImg = []; % zeros(1,maxp);
    v.visNames = {};
    i = 0;
    c = clock;
    p = 0;
    ;
    for classid = 1:nclasses_test
        classLabel = str2num(classdir(classid).name(1:2));
        usco = strfind(classdir(classid).name, '_');
        className = classdir(classid).name(usco(1)+1:end);
        instdir = dir(fullfile(visdir,classdir(classid).name,'0*'));
        for instid = 1:numberofinstances
            imdirPath = fullfile(visdir,classdir(classid).name,instdir(instid).name,'*.jpg');
            imgdir = dir(imdirPath);
            fprintf('\n%d : %s\n', length(imgdir), fullfile(visdir,classdir(classid).name,instdir(instid).name,'*.jpg'))
%             if imgsPerInst > length(imgdir)
%                 fprintf('WARNING! More images in folder than needed: %s \n',imdirPath);
%             end
            for imgid = 1:length(imgdir)
                imgPath = fullfile(visdir,classdir(classid).name,instdir(instid).name,imgdir(imgid).name);
                img = imread(imgPath);
                img = imresize(img, [300 300]);
                img_bs = applyBlindSpotsAndStandarise(img, blindSpotsArea);
                img_raw = applyBlindSpotsAndStandarise(img, 0.0);
                i = i + 1;
                for nwords = valid_nwords
                    descriptors = getFeats(img_raw, featureDesc, true);
                    words = predict(knn{nwords}, descriptors);
                    hists = histcounts(words,[0:nwords]+0.5);
                    v.histograms_raw{nwords} = [v.histograms_raw{nwords}; hists];
                    
                    descriptors = getFeats(img_bs, featureDesc, true);
                    words = predict(knn{nwords}, descriptors);
                    hists = histcounts(words,[0:nwords]+0.5);
                    v.histograms_bs{nwords} = [v.histograms_bs{nwords}; hists];
                    v.imgPath{i} = imgPath;
                    v.imgFile{i} = imgdir(imgid).name;
                    v.objClass(i) = classLabel;
                    v.objInstance(i) = instid;
                    v.objImg(i) = imgid;
                    v.visNames{i} = [className '_' num2str(instid)];
                end
                fprintf('.');
            end
            fprintf('saving;\n');
            save(histfilename, 'v')

%             p = p + 1;
%             eta = etime(clock, c) * (maxp - i) / i;
%             fprintf('ETA: %d ##',eta);
        end
    end
    maxp = size(v.histograms_raw{nwords}, 1);
    assert(i == maxp);
end

function [d] = getFeats(img, fname, doResize)
    if doResize
        img = imresize(img, [300 300]);
    end
    if size(img,3) == 3
        img = rgb2gray(img);
    end
    if strcmp(fname,'sift')
        [~,d] = vl_sift(single(img));
    elseif strcmp(fname,'surf')
        surf = OpenSurf(img);
        d = [surf(:).descriptor];
    elseif strcmp(fname,'phow')
        [~,d] = vl_phow(single(img),'Sizes',[10],'Step',4);
    else
        error(sprintf('Error, feature not available: "%s"',fname));
    end
    d = double(d');
end
    
