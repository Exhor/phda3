function plotacc_vs_ntouches(res_filename, titletext)
load(res_filename,'acc_classification','cm_classifFromId','ntrainT','ntestV','nwordsV','ntrials');
nmethods = 3;
methodTouch = 2;
methodVision = 1;
methodPVPT = 3;
raw = 1;
ntouches = 20;
nclasses = 10;
ntrainV = 9;
nobjects = 60;

figure
clf
ii = 1:20;
for raw_bs = 1:2
    subplot(2,2,raw_bs); 
    hold all
    for method = 1:nmethods
        if method == methodTouch
            m = squeeze(mean(acc_classification(:, raw, method, :)));
            s = squeeze(std(acc_classification(:, raw, method, :)));
        else
            m = squeeze(mean(acc_classification(:, raw_bs, method, :)));
            s = squeeze(std(acc_classification(:, raw_bs, method, :)));
        end
        errorbar(ii+method/10,m(ii),s(ii)/2)
    end
    plot(1:ntouches, ones(1,ntouches) * 1/nclasses, '--');
%     legend('Vision','Touch','PVPT','baseline (random)')
    xlabel('Number of touches at test time');
    ylabel(sprintf('Mean accuracy (%d trials)', ntrials));
    if raw_bs == raw
        title(sprintf('Classification \nTrain: %d touch, %d photo (unlatered)', ntrainT, ntrainV));
    else
        title(sprintf('Classification \nTrain: %d touch, %d photo (blotched)', ntrainT, ntrainV));
    end
    axis([0 20.8 0 1.0])
    grid minor
end
l=legend('Vision','Touch','Vision & Touch','baseline (random)');
% l.Orientation='horizontal';
for raw_bs = 1:2
    subplot(2,2,2+raw_bs); 
    hold all
    for method = 1:nmethods
        if method == methodTouch
            m = squeeze(mean(acc_classification(:, raw, method, :)));
            s = squeeze(std(acc_classification(:, raw, method, :)));
        else
            m = squeeze(mean(acc_classification(:, raw_bs, method, :)));
            s = squeeze(std(acc_classification(:, raw_bs, method, :)));
        end
        errorbar(ii,m(ii),s(ii)/2)
    end
    plot(1:ntouches, ones(1,ntouches) * 1/nobjects, '--');
%     legend('Vision','Touch','Vision & Touch','baseline (random)')
    xlabel('Number of touches at test time');
    ylabel(sprintf('Mean accuracy (%d trials)', ntrials));
    if raw_bs == raw
        title(sprintf('Instance Recognition. \nTrain: %d touch, %d photo (unaltered)', ntrainT, ntrainV));
    else
        title(sprintf('Instance Recognition. \nTrain: %d touch, %d photo (blotched)', ntrainT, ntrainV));
    end
    axis([0 20.8 0 1.0])
    grid minor
end
l=legend('Vision','Touch','Vision & Touch','baseline (random)');
% l.Orientation='horizontal';
end