function [nb, confidence] = A1_fitSumOfGaussiansNaiveBayes(x_train, labels, areCompsIndependent, calculateConfidence)
% Fit a sum of gaussians naive bayes model for given labelled data
% x and label must have the same number of rows
% label is assumed to be categorical or integer
% Gaussians standard deviation is set to the sample deviation of x_train
sigma = cov(x_train); 
if areCompsIndependent
    sigma = diag(sigma)'; % Diagonal only, since components are indep.
end
nb.posterior = @(x_test) sog(sigma, x_train, labels, x_test);
confidence = zeros(1,max(labels));
counts = zeros(1,max(labels));
if calculateConfidence
	% Reflective Learning: confidence = accuracy over training using leave-one-out
	for i = 1:size(x_train,1)
		all_but_i = (1:size(x_train) ~= i);
		s = sog(sigma, x_train(all_but_i,:), labels(all_but_i), x_train(i,:));
		[a,b] = max(s);
        counts(labels(i)) = counts(labels(i)) + 1;
		if b == labels(i)
			confidence(labels(i)) = confidence(labels(i)) + 1;
		end
    end
    counts(counts == 0) = 0.000001; % avoid div by zero, wont alter sum == 1
    confidence = confidence ./ counts;
else
    confidence = ones(1,max(labels));
end
end

function nbPosterior = sog(sigma, x_train, labels, x_test)
    ulabels = unique(labels);
    nlabels = length(ulabels);
    ntrain = size(x_train,1);
    ntest = size(x_test,1);
    nbPosterior = zeros(ntest, nlabels);
    for i = 1:ntrain
        x = mvnpdf(x_test,x_train(i,:),sigma);
        nbPosterior(:,labels(i)) = nbPosterior(:,labels(i)) + x;  
    end
    s = sum(nbPosterior,2);
    for j = 1:ntest
        nbPosterior(j, :) = nbPosterior(j, :) / s(j);
    end
end