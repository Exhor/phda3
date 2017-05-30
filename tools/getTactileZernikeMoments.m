function tctdb = getTactileZernikeMoments(tactframesdir, recalculateZ, zerDim, zerPolys, imgResize)
% Load tactile database and compute zernike moments up to deg 15
tctdb = {};
tctdb.dir = tactframesdir;
if recalculateZ
    d = dir([tactframesdir,'/*.png']);
    tctdb.n_imgs = length(d);
    tctdb.objlabel = zeros(1,tctdb.n_imgs); % 1: stapler, 2...
    tctdb.zdim = zerDim;
    tctdb.Z = zeros(tctdb.n_imgs, tctdb.zdim);
    % Imgs -> zernikes
    for i = 1:tctdb.n_imgs
        if mod(i,100) == 0
            [i tctdb.n_imgs]
        end
        timg = imread(fullfile(tactframesdir,d(i).name));
        timg = imresize(timg, [imgResize imgResize]);
        tctdb.Z(i,:) = bathTipImg2Zernike(timg,imgResize,zerPolys);
        % TODO: zernike this image, store in massive matrx Z
        tctdb.objlabel(i) = str2num(d(i).name(5)); % 5th char of filename is obj id
        if str2num(d(i).name(6)) >= 0
            tctdb.objlabel(i) = str2num(d(i).name(5:6)); % or 5th and 6th
        end
%         tctdb.objname(i) = d(i).name;
    end
    save('data/tactileZernikeData','tctdb');
else
    load('data/tactileZernikeData');
end
end