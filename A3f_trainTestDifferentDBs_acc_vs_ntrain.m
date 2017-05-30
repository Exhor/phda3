% Training: 10 classes. 6 instances. 40 images per instance. From videos.
% clear all
nclasses = 10;
base_dir = 'C:/Users/tadeo/Google Drive/phd/A3 Classification';
base_dir = '/home/tadeo/a3'
% results_dir = 'results_dry_wet'
results_dir = 'results'
ttoverlap = false;
dbfolder = 'C:/Users/tadeo/Documents/backup/c10/'
dbfolder = ''
cache_filename = 'none';
use_cache = true;
usevgg = true;

%% TOUCH DATABASES
% Training
dbname = 'c10_drywet_touch_replicateinst6';
%dbname = 'c10_dry_touch';
tac_dir_tr = [dbfolder dbname];
zpca_filename_tr = [dbfolder 'zpca_drywet'];  % fullfile(base_dir, 'data/zpca_unshifted_standarised_dry.mat');
ninstances_train = 7
ntouchesMax_tr = 120
max_ntrainT = 45
%A3a_bathtip2zpca_findCentreEachTime(tac_dir_tr, zpca_filename_tr) % Calculate zpca values of datasets

% Testing
dbname = 'c10_wet_touch';
tac_dir_te = [dbfolder dbname];
zpca_filename_te = [dbfolder 'zpca_wet'];
% tac_dir_te = 'C:/Users/tadeo/Documents/backup/database_phd_A3_data_touch_static_wet';
% zpca_filename_te = fullfile(base_dir, 'data/zpca_unshifted_standarised_wet.mat');

ninstances_test = 1
ntouchesMax_te = 20
% A3a_bathtip2zpca_findCentreEachTime(tac_dir_te, zpca_filename_te) % Calculate zpca values of datasets

%% VISION DATABASES
vispret_dir = 'C:/Users/tadeo/Google Drive/phd/A1 Direct vision and touch/randomImagesForPreTraining';
% vispret_dir = '/home/tad/grive/phd/A1 Direct vision and touch/randomImagesForPreTraining';
valid_nwordsV = [100];
featDesc = 'sift'; % featDesc = 'sift'
stdOrNot = 'standarised'; % or 'notStd' 'vishistogram_standarised_surf_nwords.mat'
vfpath = @(dbname,featDesc,stdOrNot,nclasses,nphotosPerInstance) fullfile(base_dir, 'data', sprintf('vishistogram_%s_%s_%s_nclasses_%d_nImgPerInstance_%d.mat',dbname,featDesc,stdOrNot,nclasses,nphotosPerInstance));

% Vision training database
dbname = 'c10_drywet_vision';
vis_dir_tr = [dbfolder dbname];
ninstances_train = 7
nphotosPerInstance_train = 40
vishistograms_training_filename = vfpath(dbname,featDesc,stdOrNot,nclasses,nphotosPerInstance_train);
%A3b_vision2histograms(vis_dir_tr, vispret_dir, vishistograms_training_filename, nclasses, ninstances_train, valid_nwordsV, featDesc);

% Vision testing database
dbname = 'c10_wet_vision';
vis_dir_te = [dbfolder dbname];
% vis_dir_te = 'C:/Users/tadeo/Documents/backup/database_phd_A3_data_vision_videos/test10';
% vis_dir_te = 'C:/Users/tadeo/Documents/backup/database_phd_A3_data_vision_videos_wet/asImages270frames'; 
nphotosPerInstance_test = 40
ninstances_test = 1
ntestV = 1

vishistograms_testing_filename = vfpath(dbname,featDesc,stdOrNot,nclasses,nphotosPerInstance_test);
%A3b_vision2histograms(vis_dir_te, vispret_dir, vishistograms_testing_filename, nclasses, ninstances_test, valid_nwordsV, featDesc);

%% Load Databases
dtrain = loadDB(vishistograms_training_filename,zpca_filename_tr);
dtest = loadDB(vishistograms_testing_filename,zpca_filename_te);

nobjects_test = length(dtest.objects)
nobjects_train = length(dtrain.objects)
% Check V and T cover same classes and same objects, for training
assert(nobjects_train == nclasses * ninstances_train)

computeConfidences = false;
methodVision = 1;
methodTouch = 2;
methodPVPT = 3;
methodsDesc = {'Vision','Touch','PVPT'}
methods = [methodVision, methodTouch, methodPVPT];
nmethods = length(methods)

objClassNames = {};
objIDNames = {};
for i = 1:length(dtrain.t_objName)
    s = dtrain.t_objName{i}; 
    objIDNames{dtrain.t_objId(i)} = strrep(s,'_','\_'); % allow printing
    objClassNames{dtrain.t_objClass(i)} = s(1:strfind(s,'_')-1);
end

ntrials = 100 % 300 for 'sum of touches'


max_ntrainV = nphotosPerInstance_train

nwordsV = 100
raw = 1; 
bs = 2;
ntrain_percentages = 0.1:0.1:0.9; % train with fewer than all samples, must be <= 0.9
ntrain_percentages = [0.9];

nobjects_tested_per_trial = 10;

% expe = 'Recognition'; nlabels = nobjects_train;
expe = 'Classification'; nlabels = nclasses;


%% Main loop: Classification: train with T instances and test with All\T
% parfor trial = 1:100; i=1/trial; end
rr = 0;
clock_0 = clock;

for nwordsV = valid_nwordsV
for ntrainPercentage = ntrain_percentages

    ntrainT = ceil(max_ntrainT * ntrainPercentage)
    ntrainV = ceil(max_ntrainV * ntrainPercentage)
    h_test = {};
    h_train = {};
    normalise2 = @(a,b) normalise(a,b);
    h_test{raw} = normalise2(dtest.histograms_raw{nwordsV}, 0);
    h_test{bs} = normalise2(dtest.histograms_bs{nwordsV}, 0);
    h_train{raw} = normalise2(dtrain.histograms_raw{nwordsV}, 0);
    h_train{bs} = normalise2(dtrain.histograms_bs{nwordsV}, 0);

    acc = zeros(ntrials, 2, nmethods, ntouchesMax_te);
    cm = zeros(2, nmethods, ntouchesMax_te, nobjects_test, nlabels);
    cm_trial = cm;
    % cm_classifFromClass = zeros(2, nmethods, ntouchesMax_te, nclasses, nclasses);
    clock_start = clock;
    v_prob_c = zeros(ntrials, 2, nobjects_test, nlabels);
    t_prob_c = zeros(ntrials, ntouchesMax_te, nobjects_test, nlabels);

    for trial = 1:ntrials
        v_prob_local = zeros(2, nobjects_test, nlabels);
        t_prob_local = zeros(ntouchesMax_te, nobjects_test, nlabels);
        if use_cache
            cache_filename = sprintf('cache/cache_drywet_wet_%d.mat',trial);
        end
        
        %% Classification or Recognition
        if strcmp(expe, 'Classification')
            teInstances = randi(ninstances_test);
            trInstances = setdiff(1:ninstances_train, teInstances);
            test_object_ids = unique(dtest.v_objId(ismember(dtest.v_objInstance, teInstances)));
            train_object_ids = unique(dtrain.v_objId(ismember(dtrain.v_objInstance, trInstances)));
            train_id2label = dtrain.id2class;
            test_id2label = dtest.id2class;
        elseif strcmp(expe, 'Recognition')
            train_object_ids = 1:nobjects_train;
            test_object_ids = 1:nobjects_test;
            assert(all(train_object_ids == test_object_ids));
            train_id2label = 1:nobjects_train;
            test_id2label = 1:nobjects_test; % Label = objId
        end
        
        [cm_trial, acc_local] = trainTest(usevgg, cache_filename, trial, ttoverlap, dtrain, dtest, train_object_ids, train_id2label, test_object_ids, test_id2label, ntouchesMax_te, h_train, h_test, ntrainV, ntrainT);
        cm = cm + cm_trial;
        fprintf('%s: %d of %d # %s\n',datetime('now'),trial,ntrials,expe);
        accraw = squeeze(ceil(100*acc_local(raw, :, [1 ntouchesMax_te])))';
        accbs = squeeze(ceil(100*acc_local(bs, :, [1 ntouchesMax_te])))';
        fprintf('# acc_raw = \tV:%d-%d \tT:%d-%d \tpvpt:%d-%d \n# acc_bs = \tV:%d-%d \tT:%d-%d \tpvpt:%d-%d \n\n',accraw,accbs);
        
        v_prob_c(trial,:,:,:) = v_prob_local;
        t_prob_c(trial,:,:,:) = t_prob_local;
        acc(trial,:,:,:) = acc_local;
    end
    for touchid = 1:ntouchesMax_te
        for obid = 1:nobjects_test
            for method = 1:nmethods
                for raw_bs = 1:2
                    cm(raw_bs, method, touchid,obid,:) = cm(raw_bs, method, touchid,obid,:) / (0.00001 + sum(cm(raw_bs, method, touchid,obid,:)));
                end
            end
        end
    end
    
    fprintf('\n');
    res_filename = sprintf('result_probAccConf_%s_%s_%s_nlabels_%d_nwV_%d_trials_%d_ntrainPerc_%d',expe,featDesc,stdOrNot,nlabels,nwordsV,ntrials,ceil(100*ntrainPercentage));
    save(fullfile(results_dir,res_filename),'v_prob_c','t_prob_c','acc','cm',...
    'ntrainT','ntestV','nwordsV','trial','ntrials','vishistograms_testing_filename',...
    'vishistograms_training_filename','zpca_filename_te','zpca_filename_tr',...
    'nclasses','ntrials','ninstances_test','ninstances_train',...
    'nphotosPerInstance_test','nphotosPerInstance_train','nwordsV',...
    'ntouchesMax_te','ntouchesMax_tr','methodsDesc')


    % Overall progress report

    rr_max = length(valid_nwordsV) * length(ntrain_percentages);    
    rr = rr + 1; eta = etime(clock,clock_0)*(rr_max-rr)/rr;
    fprintf('######################################\n')
    fprintf('### [%d of %d completed] ETA: %d sec\n',rr,rr_max,ceil(eta));    
    fprintf('######################################\n')

end
end

%% Plot result
% close all
plotacc_vs_ntouches(fullfile(results_dir,res_filename), 'Classification');

%% Confusion matrices

%% Plot ACC after n touches
ntouches = 5;
raw = 1;
for raw_bs = 1:1
    figure
    for method = 1:nmethods
        subplot(1,3,method); 
        if method == 2
            cm_local = squeeze(cm(raw,method,ntouches,:,:));
        else
            cm_local = squeeze(cm(raw_bs,method,ntouches,:,:));
        end
        image(cm_local*64)
        accu = trace(cm_local) / sum(cm_local(:));
        title(sprintf('%s (Acc = %.2f)',methodsDesc{method},accu));
        ax = gca;
        ax.XTick = 1:nclasses;
        ax.XTickLabel = objClassNames;
        ax.YTick = 1:nobjects_test;
        
        if method == nmethods
            ax.YTickLabel = objClassNames;
            ylabel('True class')
        end
        ax.XAxisLocation = 'bottom';
        ax.YAxisLocation = 'right';
        ax.XTickLabelRotation = 90;
        xlabel('Predicted class')
        
        if method == 2
            if raw_bs == 1
                title(sprintf('Raw images\nTouch'))
                title(sprintf('Confusion Matrices after %d touches\nTouch (Acc = %.2f)', ntouches, accu))
            else
                title(sprintf('Blotched images\nTouch'))
            end
        end
    end
end
