
function ms = calcModelSizes(c, touch_nb_kde, touch_nb_sog, meanZER, COEFFT, visionClassifier)
    ms.tacKDEmodelsize = 0;
    ms.tacSOGmodelsize = 0;
    ms.visModelSize = 0;
    s = whos('touch_nb_kde'); ms.tacKDEmodelsize = ms.tacKDEmodelsize + s.bytes/s.size(2);
    s = whos('meanZER'); ms.tacKDEmodelsize = ms.tacKDEmodelsize + s.bytes/s.size(2);
    s = whos('COEFFT'); ms.tacKDEmodelsize = ms.tacKDEmodelsize + s.bytes/s.size(2);

    s = whos('touch_nb_sog'); ms.tacSOGmodelsize = ms.tacSOGmodelsize + s.bytes/s.size(2);
    s = whos('meanZER'); ms.tacSOGmodelsize = ms.tacSOGmodelsize + s.bytes/s.size(2);
    s = whos('COEFFT'); ms.tacSOGmodelsize = ms.tacSOGmodelsize + s.bytes/s.size(2);

    s = whos('visionClassifier'); ms.visModelSize = ms.visModelSize + s.bytes;
%     s = whos('visHistTR'); ms.visModelSize = ms.visModelSize + s.bytes / (c.ntrials * c.nclasses);
end