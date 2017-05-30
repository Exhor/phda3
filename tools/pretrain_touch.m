
function pretrain_touch(nComponentsToKeep, tt, filename)
% Learn tactile features from a video of random touches

%% Read a file containing random touches
videoFile = ['C:\Users\tadeo\Google Drive\phd\2014\February\TACTIP\tactileShapeVideos\Random Touches.mp4']; 
vid = VideoReader(videoFile);
nFrames = vid.NumberOfFrames

%% Assume frame 50-60 is base 'nothing', with smoothing
% Get a sample of "nothingness"
calibImg = double(rgb2gray(read(vid,45)))/255;
[cx,cy,tt.cropImg] = findNewTTcentre(calibImg, tt.imgSize);

distFromNothing = @(img) norm(imresize(img,0.1)-imresize(tt.maskImg(tt.cropImg(calibImg)),0.1)); % Detect touch

%% Analise video of touches
imgs = [];
a=0;
ih = imshow(zeros(tt.imgSize,tt.imgSize));
zernikeOfRandomTouches = []; % Feature vector
for i = 1:nFrames
    img = double(rgb2gray(read(vid,i)))/255;
    img = tt.maskImg(tt.cropImg(img));
    hold off;
    imshow(img)
    % set(ih, 'CData', img);
    d = distFromNothing(img);
    if d > 1
        title([num2str(i/nFrames), num2str(d), ' -> Touching'])
        a=a+1;
        zmom = bathTipImg2Zernike(img,tt.imgSize,tt.zerPolys);
        zernikeOfRandomTouches = [zernikeOfRandomTouches; zmom];
    else
        title([num2str(i/nFrames), num2str(d), ' -> Nothing!'])
    end
    drawnow; 
end

[tac_coeff_pret,tac_score_pret,latent,tsq,pca_explained] = pca(zernikeOfRandomTouches, 'NumComponents', nComponentsToKeep);
tac_mean_pret = mean(zernikeOfRandomTouches);

save(filename,'tt','tac_mean_pret','tac_score_pret','tac_coeff_pret','pca_explained');
end