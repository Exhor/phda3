%% Test if few classes and few instances can be recognised by touch only
base_dir = '/home/tad/grive/phd/A3 Classification/data';
tac_dir = fullfile(base_dir, 'touch');


tac_dir = '/home/tad/Documents/backup/database_phd_A3_data_touch_static'; % TODO: remove



zpca_filename = fullfile(base_dir, 'zpca_unshifted_standarised.mat');

% ONLY ONCE!: calc zpca values of dataset
% A3a_bathtip2zpca_findCentreEachTime(tac_dir, zpca_filename) 

% TODO: find the tt centre and crop function for each image/batch independ.

load(zpca_filename,'tacDB')
testData = 4:4:120; % do not use this data until final experiment
useOnlyData = setdiff(1:120,testData); % Save data for testing
objTouch = tacDB.objinstance;
i = ismember(objTouch, useOnlyData); 
objTouch = objTouch(i);

objLabel = tacDB.objlabel(i); % hundreds = class; dec+uni = subclass
objClass = floor(objLabel/100);
objInstance = objLabel - objClass * 100;
objClass(objClass == 0) = 10; % rename 0 as 10
objLabel(objLabel < 100) = objLabel(objLabel < 100) + 1000;
zpca = tacDB.zpca(i,:);

objNames = tacDB.names(i);
n = length(objLabel)
% Renumber labels to 1...n
nobjects = length(unique(objLabel));
t = zeros(1,max(objLabel)); 
t(unique(objLabel)) = 1:nobjects;
objID = t(objLabel);

objClassNames = {};
objIDNames = {};
for i = 1:n
    s = objNames{i};
    objIDNames{objID(i)} = strrep(s,'_','\_'); % allow printing
    objClassNames{objClass(i)} = s(1:strfind(s,'_')-1);
end

nclasses = length(unique(objClass))
ninstances = 6
ntouchesMax = 120



%% Classification: train with T instances and test with All\T
ntrials = 100
ntrain = 60
ntouches = 20
% cm = zeros(ntrials, ntouches, nclasses, nclasses);
acc_classification = zeros(ntrials, ntouches);
cm_classif2id = zeros(ntouches, nobjects, nclasses);
cm_classif2class = zeros(ntouches, nclasses, nclasses);
for trial = 1:ntrials
    testInstance = randi(ninstances);
    trAll = (objInstance ~= testInstance);
    teAll = ~trAll;
    tr = [];
    te = [];
    ntouchid = [];
    for c = 1:nclasses
        tr = [tr; randsample(find(objClass == c & trAll), ntrain)'];
        te = [te; randsample(find(objClass == c & teAll), ntouches)'];
        ntouchid = [ntouchid; [1:ntouches]'];
    end
    
    [nb, confidence] = A1_fitSumOfGaussiansNaiveBayes(zpca(tr,:), objClass(tr), true, false); % true: components are independent
    p = ones(nclasses, nclasses);
    phat = nb.posterior(zpca(te,:));
    for touch = 1:ntouches
        p = p .* (phat(ntouchid == touch, :) + 0.0001);
        p = normalise(p, false);
        [~, clasPred] = max(p');
        for i = 1:nclasses
            obids = unique(objID(te));
            cm_classif2id(touch, obids(i), clasPred(i)) = cm_classif2id(touch, obids(i), clasPred(i)) + 1;
%             cm_divisor(obids(i)) = cm_divisor(obids(i)) + 1;
            cm_classif2class(touch, i, clasPred(i)) = cm_classif2class(touch, i, clasPred(i)) + 1/ntrials;
        end
        acc_classification(trial, touch) = mean(1:nclasses == clasPred);
    end
    fprintf('.');
end
for touch = 1:ntouches
    for obid = 1:nobjects
        cm_classif2id(touch,obid,:) = cm_classif2id(touch,obid,:) / sum(cm_classif2id(touch,obid,:));
    end
end
fprintf('\n');
mean(acc_classification)

%% Fine Recognition: recognise individual objects
ntrials = 100;

% obid = objInstance + ninstances*(objLabel-1);
% cm = zeros(ntrials, ntouches, nclasses, nclasses);
acc_fineRec = zeros(ntrials, ntouches);
cm_fineRec = zeros(ntouches, nobjects, nobjects);
for trial = 1:ntrials
    tr = [];
    te = [];
    ntouchid = [];
    for id = 1:nobjects
        isc = find(objID == id)';
        r = length(isc)/(ntrain+ntouches);
        ntr = floor(ntrain * r);
        nte = floor(ntouches * r);
        tr = [tr; randsample(isc(1:ntr), ntrain)];
        te = [te; randsample(isc(ntr+1:end), ntouches)];
        ntouchid = [ntouchid; [1:ntouches]'];
    end
    [nb, confidence] = A1_fitSumOfGaussiansNaiveBayes(zpca(tr,:), objID(tr)', true, false); % true: components are independent
    p = ones(nobjects, nobjects);
    phat = nb.posterior(zpca(te,:));
    for touch = 1:ntouches
        p = p .* (phat(ntouchid == touch, :) + 0.0001);
        p = normalise(p, false);
        
%         % Deciding class first and then instance
%         objIDPredAll = zeros(1,nobjects);
%         for k = 1:nobjects
%             [~, classPred] = max([sum(p(k,1:6)) sum(p(k,7:12)) sum(p(k,13:18)) sum(p(k,19:24)) sum(p(k,25:30)) sum(p(k,31:36)) sum(p(k,37:42))]);
%             [~, instancePred] = max(p(k,(classPred-1)*6+1:classPred*6));
%             objIDPredAll(k) = (classPred-1)*6 + instancePred;
%         end
%         objIDPred = objIDPredAll;
        
        % Deciding id directly
        [~, objIDPred] = max(p');
        
        for i = 1:nobjects
            cm_fineRec(touch, i, objIDPred(i)) = cm_fineRec(touch, i, objIDPred(i)) + 1/ntrials;
        end
        acc_fineRec(trial, touch) = mean(1:nobjects == objIDPred);
    end
    fprintf('.');
end
fprintf('\n');
% mean(acc_fineRec)

%% Plot result
% close all
figure
clf
hold on
plot(mean(acc_classification),'r');
plot(1:ntouches, ones(1,ntouches) * 1/nclasses, 'r--');
plot(mean(acc_fineRec),'b');
plot(1:ntouches, ones(1,ntouches) * 1/nobjects, 'b--');

xlabel('Number of touches at test time');
ylabel(sprintf('Average accuracy over %d trials', ntrials));
title(sprintf('Touch only S.O.G.. Training on %d touches. ZPCA components = %d', ntrain, size(zpca,2)));
legend('Classification','Classification baseline (random)','Recognition', 'Recognition baseline (random)')

% Confusion matrices
%% Classification after n touches
ntouches = 10;
figure
cm = squeeze(cm_classif2id(ntouches,:,:));
imagesc(cm)
ax = gca;
ax.XTick = 1:nclasses;
ax.XTickLabel = objClassNames;
ax.YTick = 1:nobjects;
ax.YTickLabel = objIDNames;
ax.XAxisLocation = 'top';
ax.YAxisLocation = 'right';
ax.XTickLabelRotation = 90;
% imagesc(squeeze(cm_classif2class(ntouches,:,:)))
colorbar
title(sprintf('Classification (tactile-only)\nAfter %d touches. %d trials.',ntouches,ntrials))
xlabel('Predicted class')
ylabel('True class')
%% Fine-Grained Recognition after n touches
figure
cm = squeeze(cm_fineRec(ntouches,:,:));
imagesc(cm)
xlabel('Predicted label')
ylabel('True label')
acc = trace(cm) / sum(cm(:));
title(sprintf('Fine-grained recognition (tactile-only)\nAfter %d touches. %d trials. Acc = %.3f',ntouches,ntrials,acc))
hold on
for i = 1:nclasses
    rectangle('Position',[(i-1)*ninstances+0.5 (i-1)*ninstances+0.5 ninstances ninstances],'EdgeColor','r')
end
ax = gca;
ax.XTick = 1:nobjects;
ax.XTickLabel = objIDNames;
ax.XTickLabelRotation = 90;
ax.YTick = 1:nobjects;
ax.YTickLabel = objIDNames;
ax.XAxisLocation = 'top';
ax.YAxisLocation = 'right';