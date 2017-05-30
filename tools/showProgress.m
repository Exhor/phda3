function showProgress(trainingConfig, tmpDir, stime, nruns)
f = fopen(fullfile(tmpDir, [num2str(trainingConfig) '.mat']),'w');
fwrite(f,[1 1],'double');
fclose(f);
et = etime(clock(),stime);
progress = length(dir(fullfile(tmpDir, '/*.mat')));
etas = et*(nruns-progress)/progress;
etah = etas / 3600;
% fprintf('#%d/%d: T: %.1f. ETA: %.1f (hours: %.1f) vtr=%d ttr=%d tva=%d\n#Acc_sog: pvpt=%.2f tv=%.2f t=%.2f v=%.2f\n',progress,nruns,et,etas,etah,c.ntrainV,c.ntrainT,c.nvalidT,acc_pvpt_tmp,acc_alpha_tmp(c.alphas == 0.5),acc_alpha_tmp(c.alphas == 0),acc_alpha_tmp(c.alphas == 1));
fprintf('\n #%d/%d: T: %.1f. ETA: %.1f (hours: %.1f) ',progress,nruns,et,etas,etah);
end