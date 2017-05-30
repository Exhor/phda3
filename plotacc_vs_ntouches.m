function plotacc_vs_ntouches(res_filename, titletext)
load(res_filename,'acc','cm','ntrainT','ntestV','nwordsV','ntrials','expe');
nmethods = 3;
methodTouch = 2;
methodVision = 1;
methodPVPT = 3;
raw = 1;
ntouches = 20;
nclasses = 10;
ntrainV = 9;
nobjects = 60;
baseline = 1 / size(cm,5); % number of labels

figure
clf
ii = 1:10;
for raw_bs = 1:1
    subplot(1,1,raw_bs); 
    hold all
    for method = 1:nmethods
        if method == methodTouch
            m = squeeze(mean(acc(:, raw, method, :)));
            s = squeeze(std(acc(:, raw, method, :)));
        else
            m = squeeze(mean(acc(:, raw_bs, method, :)));
            s = squeeze(std(acc(:, raw_bs, method, :)));
        end
        errorbar(ii+method/10,m(ii),s(ii)/2)
    end
    plot(1:ntouches, ones(1,ntouches) * baseline, '--');
%     legend('Vision','Touch','PVPT','baseline (random)')
    xlabel('Number of touches at test time');
    ylabel(sprintf('Mean accuracy (%d trials)', ntrials));
    if raw_bs == raw
        title(sprintf('%s \nTrain: %d touch, %d photo (unlatered)', titletext, ntrainT, ntrainV));
    else
        title(sprintf('%s \nTrain: %d touch, %d photo (blotched)', titletext, ntrainT, ntrainV));
    end
    axis([0 10.8 0 0.8])
    grid minor
end
l=legend('Vision','Touch','Vision & Touch','baseline (random)');
