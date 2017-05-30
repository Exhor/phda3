function [w, projected_sv] = f2wordFN(sv, meanf, dimRedMat, knnModel)
    % Converts a vector sv into a word, by subtracting the mean vector
    % meanf, and then multiplying by the matrix reduction dimRedMat;
    % finally the resulting low-dimensionality vector is classified by a
    % nearest neighbour model knnModel.
    centered_sv = sv - repmat(meanf, [size(sv,1) 1] );
    projected_sv = centered_sv * dimRedMat;
    if nargin > 3
        w = knnModel.predict(single(projected_sv));
    else
        w = [];
    end
end