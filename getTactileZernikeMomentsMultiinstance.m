function db = getTactileZernikeMomentsMultiinstance(tactframesdir, zerDim, zerPolys, cropImg)
% Load tactile database and compute zernike moments up to deg 15

db = {};
db.dir = tactframesdir;

d = dir([tactframesdir,'/touch*.jpg']);
db.n_imgs = length(d);
db.objlabel = zeros(1,db.n_imgs); % 1: stapler, 2...
db.zdim = zerDim;
db.Z = zeros(db.n_imgs, db.zdim);
db.imgCentres = zeros(db.n_imgs,2);

% Calibrate centre
baseTactileImage = imread([tactframesdir '/baselineForCalibration.jpg']);
% close all;
% imshow(baseTactileImage);
% fprintf('Click on 6 circle points');
% p = ginput(6);
%baseTactileImage = imresize(baseTactileImage, [
p = [1.7539   41.6912
    1.0016  191.7853
   57.0517  238.8072
  163.8856  239.5596
  178.1803    1.8166
  243.6348  117.6787];
[centre,radius] = fminsearch(@(x) std(pdist2(p,x)), [size(baseTactileImage,1)/2 size(baseTactileImage,1)/2]);
cmin = floor(centre);
actualRadius = min(cmin) - 1;

% Imgs -> zernikes
c = clock;
vectorisedSize = 100;
db.imgVectorised = zeros(db.n_imgs, vectorisedSize^2);
imgid = 0;
for i = 1:db.n_imgs
    timg = imread(fullfile(tactframesdir,d(i).name));
    if size(timg,3) > 1
        timg = rgb2gray(timg);
    end
    timg = imresize(timg, [240 320]);
%         timg = imresize(timg, [imgResize imgResize]);
%     cimg = cropImg(timg);

%     % Auto-determine centre for each image
%     maxRadius = 190;
%     [cimg, cmin, actualRadius] = findCentreCutAndScale(timg, maxRadius, oldcmin);
    mustBeSeen = false;
%     if norm(cmin - oldcmin) > 5
%         mustBeSeen = true;
%     end
%     oldcmin = cmin;

    cimg = timg(cmin(1)+[-actualRadius:actualRadius], cmin(2)+[-actualRadius:actualRadius]);

    cimg = imresize(cimg, [340 340]);
%     imshow(cimg); drawnow;
    cimg = double(cimg);
    cimg = cimg - mean(cimg(:));
    cimg = cimg / std(cimg(:));
    db.imgCentres(i,:) = cmin;
    db.imgVectorised(i,:) = reshape(imresize(cimg, [vectorisedSize vectorisedSize]), 1, vectorisedSize^2);
    
    db.Z(i,:) = bathTipImg2Zernike(cimg,0,zerPolys);
    % TODO: zernike this image, store in massive matrx Z
    uscore = strfind(d(i).name, '_');
    % Filname format is: touch_L_img_I_name_S_at_X_Y_Z.jpg
    db.objlabel(i) = str2num(d(i).name(uscore(1)+1:uscore(2)-1));
    db.objinstance(i) = str2num(d(i).name(uscore(3)+1:uscore(4)-1));
    db.names{i} = d(i).name(uscore(5)+1:uscore(7)-1);
    try
        db.x(i) = str2num(d(i).name(uscore(8)+1:uscore(9)-1));
        db.y(i) = str2num(d(i).name(uscore(9)+1:uscore(10)-1));
        db.z(i) = str2num(d(i).name(uscore(10)+1:end-4));
    catch ME
        if strcmp(ME.identifier, 'MATLAB:badsubscript')
            db.x(i) = -1; db.y(i) = -1; db.z(i) = -1;
        else
            rethrow(MR)
        end
    end

    % Progress test + view img
    if mod(i,50) == 0 || mustBeSeen
        subplot(5,8,mod(imgid,5*8)+1)
        imgid = imgid + 1;
        eta = (db.n_imgs + 1 - i) * etime(clock,c) / (i+1);
        fprintf('%d of %d done. ETA = %d sec.\n', i, db.n_imgs, eta)
        imshow(timg)
        hold on
        viscircles([cmin(2) cmin(1)], [actualRadius]);
        rectangle('Position',[round(cmin(2)-actualRadius) round(cmin(1)-actualRadius) 2*actualRadius 2*actualRadius],'EdgeColor','b');
%         title(sprintf('Name: %s / Label:%d / Instance:%d \n at:%.2f,%.2f,%.2f',strrep(db.names{i},'_','\_'),db.objlabel(i),db.objinstance(i),db.x(i),db.y(i),db.z(i)));
        title(sprintf('Name: %s / Label:%d / Instance:%d',strrep(db.names{i},'_','\_'),db.objlabel(i),db.objinstance(i)));
        drawnow
    end
end

end