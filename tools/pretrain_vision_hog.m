% Read 'randomImagesForPreTraining' dir and compute sift for all images
% Apply pca and kmeans, and save resulting knn classifier
function pretrain_vision_hog(c)
% Pretrains vision using a random set of images, saves result to c.pcaVisPretrainingFile

dd = dir('C:\Users\tadeo\Google Drive\phd\A1 Direct vision and touch\randomImagesForPreTraining');
siftOfRandomImages = [];
desc = @(im) reshape(vl_lbp(im2single(im),30), 100,58)';
for i=1:length(dd)
    i
    if strfind(dd(i).name,'jpg') | strfind(dd(i).name,'png')
%     [fe,de] = vl_sift(single(rgb2gray(imread(['randomImagesForPreTraining/' dd(i).name]))));
        de = desc(imresize(rgb2gray(imread(['randomImagesForPreTraining/' dd(i).name])),[300 300]));
        siftOfRandomImages = [siftOfRandomImages; de'];
    end
    size(siftOfRandomImages)
end
vis_mean_pret = mean(siftOfRandomImages);
save(c.pcaVisPretrainingFile, 'siftOfRandomImages', 'vis_mean_pret');

end