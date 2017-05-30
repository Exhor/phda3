function [phat, confidence] = touch_train_and_test(xtr, ytr, xte, calcConfidence)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    [nb, confidence] = A1_fitSumOfGaussiansNaiveBayes(xtr, ytr, true, calcConfidence); % true: components are independent
    phat = nb.posterior(xte);
end

