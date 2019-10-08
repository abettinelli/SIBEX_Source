function Category=GetFeatureCategoryFolder

[MFilePath, MFileName, FileType]=fileparts(mfilename('fullpath'));

Category=[];

CategoryPath=[MFilePath, '\Category'];

DirList=GetDirList(CategoryPath);

DirList=FilterDirList(DirList, CategoryPath);

Category=DirList;


function FinalDirList=FilterDirList(DirList, DataDir)
FinalDirList=[];

if isempty(DirList)
    return;
end

for i=1:length(DirList)
    DirName=DirList{i};
    
    CurrentDir=[DataDir, '\', DirName];
    
    FileList=GetFileList(CurrentDir);
    if isempty(FileList)
        continue;
    end
    
    TempStr=[DirName, '_Category.m'];
    TempIndex=strmatch(TempStr, FileList);
    
    if isempty(TempIndex)
        TempStr=[DirName, '_Category.p'];
        TempIndex=strmatch(TempStr, FileList);
    end
    
    TempStr=[DirName, '_Feature.m'];
    TempIndex1=strmatch(TempStr, FileList);
    
    if isempty(TempIndex)
        TempStr=[DirName, '_Feature.p'];
        TempIndex1=strmatch(TempStr, FileList);
    end
            
    if ~isempty(TempIndex) && ~isempty(TempIndex1)
        FinalDirList=[FinalDirList; {DirName}];
    end
end








