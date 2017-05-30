function [ newr ] = concatSims_visOpt( r1, r2 )
    newr = r1; 
    clear r1;
    newr.visualProbs_svm = [newr.visualProbs_svm; r2.visualProbs_svm];
    newr.visualProbs_nbg = [newr.visualProbs_nbg; r2.visualProbs_nbg];
    nruns1 = length(newr.confs);
    for i = 1:length(r2.confs)
        newr.confs{nruns1 + i} = r2.confs{i};
    end
    newr.conf_setup = [newr.conf_setup ' (+) ' r2.conf_setup];
    c = newr.c;
    newr.c = {};
    newr.c{1} = c;
    newr.c{2} = r2.c;
end

