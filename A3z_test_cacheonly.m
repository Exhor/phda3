function [cm, acc_local, v_prob_local, t_prob_local] = A3z_test_cacheonly()
methodVision = 1;
methodTouch = 2;
methodPVPT = 3;
ntouchesMax_te = 20;
nobjects_test = 10;
nlabels = 10;
rawbs = 1;

methods = [methodVision, methodTouch, methodPVPT];
nmethods = length(methods);
cm = zeros(nmethods, ntouchesMax_te, nobjects_test, nlabels);
acc_local = zeros(nmethods, ntouchesMax_te);

cache_filename = sprintf('cache/cache_drywet_wet_%d.mat',trial);
    load(cache_filename, 'vpload', 'clasPred_vision', 'phatload');
    for te_ob_id = 1:length(clasPred_vision)
        cm(methodVision, :, te_ob_id, clasPred_vision(te_ob_id)) = cm(methodVision, :, te_ob_id, clasPred_vision(te_ob_id)) + 1;
    end
    acc_local(methodVision, :) = mean(1:length(clasPred_vision) == clasPred_vision);
    assert(norm(acc_local(methodVision, 3) - trace(cm(methodVision,3,:,:)/sum( cm(methodVision,1,:,:) ) )) < 0.001)
    
     % Touch & PVPT
    
    trTouch = randsample(1:ntouchesMax_te, ntrainT);
    if ttoverlap
        teTouch = randsample(setdiff(1:ntouches_test,trTouch), ntouchesMax_te);    
    else
        teTouch = randsample(1:ntouches_test, ntouchesMax_te);
    end
    trTouchIndex = ismember(dtrain.t_touchids,trTouch) & ismember(dtrain.t_objId, train_object_ids);
    teTouchIndex = ismember(dtest.t_touchids,teTouch) & ismember(dtest.t_objId, test_object_ids);

    phat = phatload;
    phatR = reshape(phat, ntouchesMax_te, nobjects_test, nlabels);
    %l_phat = te_id2label(dtest.t_objId(teTouchIndex));
    %l_phatR = reshape(l_phat, ntouchesMax_te, length(test_object_ids));

    % Test
    tprob = ones(nlabels, ntouchesMax_te) / nlabels; # P(C=c) prior
    for te_ob_id = 1:nobjects_test
        for touchid = 1:ntouchesMax_te
            % P(C=c | T=t) = P(T=t | C=c)P(C=c)/P(T=t)
            tprob(te_ob_id, touchid) = tprob(te_ob_id, touchid) * 
            t_prob_local(touchid, te_ob_id, :) = phatR(touchid, te_ob_id, :);
            tp = squeeze(prod(t_prob_local(1:touchid, te_ob_id, :) + 0.1, 1)); % 0.1 smoothing % TODO: revert to 'prod' from 'sum'
            cht = false;
            [~, clasPred_touch] = max(tp);
            clasPred_pvpt = zeros(1, 2);
            % touch
            cm(raw, methodTouch, touchid, test_object_ids(te_ob_id), clasPred_touch) = cm(raw, methodTouch, touchid, test_object_ids(te_ob_id), clasPred_touch) + 1;
            % pvpt       
            for raw_bs = 1:rawbs
                vp = squeeze(v_prob_local(raw_bs, test_object_ids(te_ob_id), :));
                [~, clasPred_pvpt(raw_bs)] = max(tp .* vp);
                if cht
                    clasPred_pvpt(raw_bs) = test_object_ids(te_ob_id);
                end
                cm(raw_bs, methodPVPT, touchid, test_object_ids(te_ob_id), clasPred_pvpt(raw_bs)) = cm(raw_bs, methodPVPT, touchid, test_object_ids(te_ob_id), clasPred_pvpt(raw_bs)) + 1;
            end
            gt_label = te_id2label(test_object_ids(te_ob_id));        
            for raw_bs = 1:rawbs
                acc_local(raw_bs, methodTouch, touchid) = acc_local(raw_bs, methodTouch, touchid) + (gt_label == clasPred_touch) / length(test_object_ids);
                acc_local(raw_bs, methodPVPT, touchid) = acc_local(raw_bs, methodPVPT, touchid) + (gt_label == clasPred_pvpt(raw_bs)) / length(test_object_ids);
            end
        end
    end    
    
nobjects_train = length(dtrain.objects);
nobjects_test = length(dtest.objects);
nlabels = length(unique(tr_id2label(1:nobjects_train)));
nphotosPerInstance_test = length(dtest.v_objImgs) / length(dtest.objects);
nphotosPerInstance_test = 40; % TODO: make it proper, min(nphot per class)
nphotosPerInstance_train = length(dtrain.v_objImgs) / length(dtrain.objects);

assert(all(unique(dtrain.v_objId) == unique(dtrain.t_objId)));
assert(all(unique(dtest.v_objId) == unique(dtest.t_objId)));

cm = zeros(2, nmethods, ntouchesMax_te, nobjects_test, nlabels);
acc_local = zeros(2, nmethods, ntouchesMax_te);
v_prob_local = zeros(2, nobjects_test, nlabels);
t_prob_local = zeros(ntouchesMax_te, nobjects_test, nlabels);

% vision

whichImgToTest = randi(nphotosPerInstance_test); %TODO: use multiple images at test time?
teImgIndex = (dtest.v_objImgs == whichImgToTest) & ismember(dtest.v_objId, test_object_ids);
whichImgsToTrain = randsample(setdiff(1:nphotosPerInstance_train, whichImgToTest), ntrainV);
trImgIndex = ismember(dtrain.v_objImgs, whichImgsToTrain) & ismember(dtrain.v_objId, train_object_ids);
raw = 1;
bs = 2;
rawbs = 1; # TODO: revert to 2

if load_cache && ~exist(cache_filename, 'file')
    fprintf('Cache file not found: %s\n', cache_filename)
    load_cache = false;
    for te_ob_id = 1:length(test_object_ids)
        cm(raw_bs, methodVision, :, test_object_ids(te_ob_id), clasPred_vision(te_ob_id)) = cm(raw_bs, methodVision, :, test_object_ids(te_ob_id), clasPred_vision(te_ob_id)) + 1;
    end
    acc_local(raw_bs, methodVision, :) = mean(cte == clasPred_vision);
    
   
end