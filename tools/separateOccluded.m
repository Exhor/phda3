imgDir = 'C:\Users\tadeo\Google Drive\phd\A1 Direct vision and touch\objAllFrames';
imgSets = imageSet(imgDir,'recursive');
error('STOP! This fucks things up!')
ims2 = {};
hm = zeros(1,10);
for c = imgSets
    d = c.Description;
    cn = str2num(d(1:2));
    hm(cn) = hm(cn) + c.Count;
    if length(d) == 3
        for i = 1:c.Count
            oldloc = c.ImageLocation{i};
            t = strfind(oldloc,'\');
            newloc = [oldloc(1:t(end-1)) '_' oldloc(t(end)+1:end)];
            imwrite(imread(oldloc),newloc);
        end
    end
end
nimgsperclass = min(hm);
