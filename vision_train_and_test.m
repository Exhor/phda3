function [v_prob, clasPred_vision, confidences] =  vision_train_and_test(xtr, ytr, xte, compConfidence)
    vision_svm = fitcecoc(xtr,ytr,'Coding','onevsall','Learners',templateSVM('KernelFunction','gaussian'),'fitposterior',1);
    confidences = ones(1, length(unique(ytr)));
    if compConfidence
        confidences = zeros(1, length(unique(ytr)));
        cvmdl = crossval(vision_svm);
        confi = cvmdl.kfoldMargin;
        for y = unique(ytr)
            confidences(y) = mean(confi(ytr == y));
        end
    end
    [~,~,~,v_prob] = vision_svm.predict(xte);
    [~, clasPred_vision] = max(v_prob');
end

