function DirList=GetDirList(JobScanDir)
try
    structFilesList = dir(JobScanDir);
    structFilesList(1:2) = [];    %delete the default system directory name
    
    %Convert struct FilesList to char array
    cellFilesList=struct2cell(structFilesList);
    cellFilesName=cellFilesList(1,:);
    
    %Delete folder name
    DirNum=GetDirectoryNum(structFilesList);
    TempDirFlag=cellFilesList(DirNum,:);
    TempDirFlag=cell2mat(TempDirFlag);
    
    DirList=cellFilesName(TempDirFlag);
catch
    DirList=[];
end