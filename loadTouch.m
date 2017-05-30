function [tzip] = loadTouch(zpca_filename)

load(zpca_filename,'tacDB')
testData = 4:4:120; % do not use this data until final experiment
useOnlyData = setdiff(1:120,testData); % Save data for testing
t = {};
t.objTouch = tacDB.objinstance;
i = ismember(t.objTouch, useOnlyData); 
t.objTouch = t.objTouch(i);

t.objLabel = tacDB.objlabel(i) + 100; % hundreds = class; dec+uni = subclass
t.objClass = floor(t.objLabel/100);
t.objInstance = t.objLabel - t.objClass * 100;
% t.objClass(t.objClass == 0) = 10; % rename 0 as 10
zpca = tacDB.zpca(i,:);
t.objNames = tacDB.names(i);

n = length(t.objLabel)
% Renumber labels to 1...n
nobjects = length(unique(t.objLabel))
tid = zeros(1,max(t.objLabel)); 
tid(unique(t.objLabel)) = 1:nobjects;
t.objID = tid(t.objLabel);

tzip = {};
for i = 1:nobjects
    ii = find(t.objID == i);
    tzip{i}.objLabel = t.objLabel(ii(1));
    tzip{i}.objClass = t.objClass(ii(1));
    tzip{i}.objInstance = t.objInstance(ii(1));
    tzip{i}.objName = t.objNames(ii(1));
    tzip{i}.objName = t.objNames(ii(1));
    tzip{i}.zpcas = zpca(ii,:);
end
end