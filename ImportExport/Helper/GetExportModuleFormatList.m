function FormatList=GetExportModuleFormatList(CodeDir, PatternStr)
FileList=GetFileList(CodeDir)';

if ~isempty(FileList)
    FileList=FilterFileList(FileList, '.m');
else
    FormatList=[];
    return;
end

if isempty(FileList)
    FormatList=[];
    return;
end

TempIndex=strmatch([PatternStr, 'Method_'], FileList);
if ~isempty(TempIndex)
    TempStr=FileList(TempIndex);
    TempStr=char(TempStr);
    TempStr=strjust(TempStr, 'right');
    TempStr(:, end-1:end)=[];
    
    TempStr=strjust(TempStr, 'left');
    Len=length([PatternStr, 'Method_']);
    TempStr=TempStr(:, Len+1:end);
    
    FormatList=cellstr(TempStr);
else
    FormatList=[];
end