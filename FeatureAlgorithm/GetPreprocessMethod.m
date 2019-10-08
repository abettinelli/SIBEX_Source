function PreprocessMethod=GetPreprocessMethod(ProprocessFolder)
[MFilePath, MFileName, FileType]=fileparts(mfilename('fullpath'));

FileList=GetFileList(ProprocessFolder);

if isempty(FileList)
    PreprocessMethod=[];
    return;
end

TFileList=strjust(char(FileList), 'right');
if size(TFileList, 2) > 2
    TT=TFileList(:, end-1:end);
    
    TTIndex=strmatch('.m', TT);
    
    if isempty(TTIndex)
        TTIndex=strmatch('.p', TT);
    end
    
    if ~isempty(TTIndex)
        TT=TFileList(TTIndex, :);
        TT=TT(:, 1:end-2);
        TT=strjust(TT, 'left');
        
        PreprocessMethod=cellstr(TT);
    else
        PreprocessMethod=[];
        return;
    end
else
    PreprocessMethod=[];
    return;
end










