%% Process bathtip images from A3 and write to disk the ZPCA moments
function A3a_bathtip2zpca(tac_dir, zpca_filename)

% TODO: replace with newly captured random touchesvideo
videoFile = 'C:\Users\tadeo\Google Drive\phd\2014\February\TACTIP\tactileShapeVideos\Random Touches.mp4'; 
tmpZfile = 'tmp_delete_zernikeMoments.mat';
tt = tt_setup(15, 340); % prepare zerinke stuff, incl.: tt.zerDim, tt.img2feature
% A3a_pretrain_touch(videoFile,20,tt,tmpZfile);
d = load(tmpZfile);
cropImgFn = @(img) imresize(img(1:470,1:470), [340 340]);
tacDB = getTactileZernikeMomentsMultiinstance(tac_dir,tt.zerDim,tt.zerPolys,cropImgFn);
zpca = (tacDB.Z - repmat(d.tac_mean_pret,[size(tacDB.Z,1),1])) * d.tac_coeff_pret;
zpca = normalise(zpca,true); % all values between 0 and 1
tacDB.Z = [];
tacDB.zpca = zpca;
save(zpca_filename,'tacDB')
end