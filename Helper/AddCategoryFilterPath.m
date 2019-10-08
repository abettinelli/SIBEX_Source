function AddCategoryFilterPath(DirList)
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

TempIndex=strfind(MFilePath, '\');
MFilePath=MFilePath(1:TempIndex(end)-1);

for i=1:length(DirList)
    addpath([MFilePath, '\FeatureAlgorithm\Category\', DirList{i}]);
    
    HelperPath=[MFilePath, '\FeatureAlgorithm\Category\', DirList{i}, '\Helper'];
    if exist(HelperPath, 'dir')
        addpath(HelperPath);
    end
end