d.skipFrames = 1; % Skips these many frames per capture
videosDir = 'C:\Users\tadeo\Downloads\objectVideos';
videosDir = 'C:\Users\tadeo\Videos\Debut';
outputDir = 'C:\Users\tadeo\Videos\Debut\frames';
d = struct();
d.filepaths = {};
d.labels = {};
d.instance = [];
d.class = [];

d.zernikes = [];
d.deltaZernikes = [];
dirfiles = dir(fullfile(videosDir,'*.avi'))
d.sensitivity = 0;
oldimg = 1;

d.imgwidth = 340;
c1guess = 200;
c2guess = 200; % Close to sensors actual centre in image
tt = tt_setup(15,d.imgwidth);

for i = 1:length(dirfiles)
    
    tic;
    framesDir = fullfile(outputDir, dirfiles(i).name(1:end-4));
    mkdir(framesDir);
    tacVideo = VideoReader(fullfile(videosDir, dirfiles(i).name));
    ii = 1;
    frameCounter = 0;
    iscalibrated = false;
    while hasFrame(tacVideo)
        fprintf('.');
        imgraw = readFrame(tacVideo);
        frameCounter = frameCounter + 1;
        if size(oldimg,1) ~= size(imgraw,1)
            oldimg = uint8(rand(size(imgraw))*255);
        end
        dimgraw = double(rgb2gray(imgraw)) - double(rgb2gray(oldimg));
        delta = norm(dimgraw);
        if delta > d.sensitivity
            if ~iscalibrated
                if frameCounter > 10
                    cropImg = calibrateTT(imgraw,d.imgwidth,c1guess,c2guess);
                    iscalibrated = true;
                end
            else
                img = cropImg(imgraw);
                dimg = cropImg(dimgraw);
                filename = [dirfiles(i).name(1:end-4) '_' num2str(ii) '.jpg'];
                fullname = fullfile(framesDir,filename);
                imwrite(img,fullname)    % Write out to a JPEG file (img1.jpg, img2.jpg, etc.)
%                 d.delta = [d.delta; dimg(:)];
%                 d.raw = [d.raw; img(:)];
                d.zernikes = [d.zernikes; bathTipImg2Zernike(img,d.imgwidth,tt.zerPolys)];
                d.deltaZernikes = [d.deltaZernikes; bathTipImg2Zernike(dimg,d.imgwidth,tt.zerPolys)];
                d.filepaths{ii} = fullname;
                d.labels{ii} = [dirfiles(i).name(1:end-4) '_' num2str(ii)];
                d.class = [d.class; str2num(dirfiles(i).name(1:2))];
                d.instance = [d.instance; str2num(dirfiles(i).name(4:5))];
                ii = ii+1;
    %             subplot(2,4,mod(ii,4)+1);
    %             imshow(rgb2gray(img));
    %             subplot(2,4,mod(ii,4)+1 + 4);
    %             imshow(uint8((dimg-min(dimg(:)))/range(dimg(:))*255))
    %             drawnow
                oldimg = img;
            end
        end
        
    end
    fprintf('\n%s = %d frames\n',dirfiles(i).name,ii)
    toc
end
d.count = ii;
d.desc = 'Zernike moments of tactile inputs and its delta (1 step jump).'
save('tmp.mat','d')
