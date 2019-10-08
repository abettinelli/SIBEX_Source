
function FileList=GetFileList(JobScanDir)
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
    
    FileList=cellFilesName(~TempDirFlag);
catch
    FileList=[];
end