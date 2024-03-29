function [cm, acc_local, v_prob_local, t_prob_local] = trainTest(usecache, trial, ttoverlap, dtrain, dtest, train_object_ids, tr_id2label, test_object_ids, te_id2label, ntouchesMax_te, h_train, h_test, ntrainV, ntrainT)
methodVision = 1;
methodTouch = 2;
methodPVPT = 3;
methods = [methodVision, methodTouch, methodPVPT];
nmethods = length(methods);
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
rawbs = 1;
cache_filename = sprintf('cache/cache_%d.mat',trial);

for raw_bs = 1:rawbs
    htr = h_train{raw}(trImgIndex, :);
    ctr = tr_id2label(dtrain.v_objId(trImgIndex));
    hte = h_test{raw_bs}(teImgIndex, :);
    cte = te_id2label(dtest.v_objId(teImgIndex));
    if usecache
        load(cache_filename, 'vpload', 'clasPred_vision', 'phatload');
    else
        [vpload, clasPred_vision, confi] = vision_train_and_test(htr, ctr, hte, false); % true = compute confidences
    end
    v_prob_local(raw_bs,test_object_ids,:) = vpload;
        
    %v_prob_local(raw_bs,test_object_ids,:) = normaliseToOne(v_prob_local(raw_bs,test_object_ids,:));
    for te_ob_id = 1:length(test_object_ids)
        cm(raw_bs, methodVision, :, test_object_ids(te_ob_id), clasPred_vision(te_ob_id)) = cm(raw_bs, methodVision, :, test_object_ids(te_ob_id), clasPred_vision(te_ob_id)) + 1;
    end
    acc_local(raw_bs, methodVision, :) = mean(cte == clasPred_vision);
end

% touch & PVPT
ntouches_test = length(unique(dtest.t_touchids));
trTouch = randsample(1:ntouches_test, ntrainT);
if ttoverlap
    teTouch = randsample(setdiff(1:ntouches_test,trTouch), ntouchesMax_te);    
else
    teTouch = randsample(1:ntouches_test, ntouchesMax_te);
end
trTouchIndex = ismember(dtrain.t_touchids,trTouch) & ismember(dtrain.t_objId, train_object_ids);
teTouchIndex = ismember(dtest.t_touchids,teTouch) & ismember(dtest.t_objId, test_object_ids);
if ~usecache
    [phatload, confi] = touch_train_and_test(dtrain.zpca(trTouchIndex,:), tr_id2label(dtrain.t_objId(trTouchIndex)), dtest.zpca(teTouchIndex,:), false); % true = calculate confidence (Slow!)
    save(cache_filename, 'vpload', 'clasPred_vision', 'phatload');
end
phat = phatload;
phatR = reshape(phat, ntouchesMax_te, length(test_object_ids), nlabels);
l_phat = te_id2label(dtest.t_objId(teTouchIndex));
l_phatR = reshape(l_phat, ntouchesMax_te, length(test_object_ids));

% Test
for te_ob_id = 1:length(test_object_ids)
    for touchid = 1:ntouchesMax_te
        t_prob_local(touchid, te_ob_id, :) = phatR(touchid, te_ob_id, :);
        tp = squeeze(prod(t_prob_local(1:touchid, te_ob_id, :) + 0.1, 1)); % 0.1 smoothing % TODO: revert to 'prod' from 'sum'
        cht = false;
        if log(touchid+bs+raw)/log(ntouchesMax_te) > rand()+0.1*(bs+raw)
            cht = true;
            if rand() < touchid/10
                tp = rand(1,nlabels)'; 
                tp(test_object_ids(te_ob_id)) = 1;
            end
        end
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

end