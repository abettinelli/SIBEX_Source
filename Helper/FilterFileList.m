function FileList=FilterFileList(FileList, Ext)
if isempty(FileList)
    FileList=[];
    return;
end

TempStr=char(FileList');
TempStr=strjust(TempStr, 'right');

PattLen=length(Ext);
if size(TempStr, 2) >PattLen
    PattStr=TempStr(:, end-PattLen+1:end);
    
    TempIndex=strmatch(Ext, PattStr);
    
    if ~isempty(TempIndex)
        FileList=FileList(TempIndex);
    else
        FileList=[];
    end
else
    FileList=[];
end

