% Read 'randomImagesForPreTraining' dir and compute sift for all images
% Apply pca and kmeans, and save resulting knn classifier
function pretrain_vision(c)
% Pretrains vision using a random set of images, saves result to c.pcaVisPretrainingFile

dd = dir('C:\Users\tadeo\Google Drive\phd\A1 Direct vision and touch\randomImagesForPreTraining');
siftOfRandomImages = [];
for i=1:length(dd)
    i
    if strfind(dd(i).name,'jpg') | strfind(dd(i).name,'png')
    [fe,de] = vl_sift(single(rgb2gray(imread(['randomImagesForPreTraining/' dd(i).name]))));
    siftOfRandomImages = [siftOfRandomImages; de'];
    end
    size(siftOfRandomImages)
end
vis_mean_pret = mean(siftOfRandomImages);
save(c.pcaVisPretrainingFile, 'siftOfRandomImages', 'vis_mean_pret');

end