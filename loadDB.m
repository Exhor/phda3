function [d] = loadDB(visdb,tacdb)
%% Touch
load(tacdb,'tacDB')
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

nobjects = length(unique(t.objLabel));
tid = zeros(1,max(t.objLabel)); 
tid(unique(t.objLabel)) = 1:nobjects;
t.objID = tid(t.objLabel);

%% Vision
load(visdb,'v');

%% V + T
d.histograms_raw = v.histograms_raw;
d.histograms_bs = v.histograms_bs;
d.v_imgPath = v.imgPath;
assert(nobjects == length(unique(v.visNames))); % Same # in v and t
nclasses = length(unique(t.objClass));
assert(nclasses == length(unique(v.objClass)));
ninstancesperclass = length(unique(t.objInstance));
assert(ninstancesperclass == length(unique(v.objInstance)));
nt = zeros(nclasses, ninstancesperclass);
for c = 1:nclasses
    for i = 1:ninstancesperclass
        nt(c,i) = length(unique(t.objTouch(t.objClass == c & t.objInstance == i)));
    end
end
ntouchesperinstance = min(nt(:));

for objClass = 1:nclasses
for objInstance = 1:ninstancesperclass
    objId = ninstancesperclass * (objClass - 1) + objInstance;
    
    ti = find(objInstance == t.objInstance & t.objClass == objClass);
    assert(length(ti) >= ntouchesperinstance);
    objName = t.objNames{ti(1)};
    for i = 1:ntouchesperinstance
        newindex = i + ntouchesperinstance * (objId-1);
        d.t_objId(newindex) = objId;
%     d.t_objLabel(ti) = t.objLabel(ti(1));
        d.t_objClass(newindex) = objClass;
        d.t_objInstance(newindex) = objInstance;
        d.t_objName{newindex} = objName;
        d.t_touchids(newindex) = i;
        d.zpca(newindex,:) = zpca(ti(i), :);
    end
        
    vi = find(objInstance == v.objInstance & v.objClass == objClass);
    d.v_objId(vi) = objId;
    d.v_objClass(vi) = objClass;
    d.v_objInstance(vi) = objInstance;
    d.v_objImgs(vi) = 1:length(vi);
    for jjj = vi 
        d.v_objName{jjj} = objName;
    end
%     fprintf('Matched:   %s <===> %s\n',t.objNames{ti(1)},v.visNames{vi(1)});
    
    d.objects(objId).zpcaindices = ti;
    d.objects(objId).visindices = vi;  
    d.id2class(objId) = objClass;
    d.id2instance(objId) = objInstance;
end
end