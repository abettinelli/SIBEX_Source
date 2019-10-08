function DirList=GetImportModuleList(DataDir)
DirList=GetDirList(DataDir);

DirList=FilterDirList(DirList, DataDir);


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
    
    TempStr=[DirName, 'ImportMain'];
    TempIndex=strmatch(TempStr, FileList);
    
    if ~isempty(TempIndex)
        FinalDirList=[FinalDirList; {DirName}];
    end
end