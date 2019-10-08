
function CDataSetInfo=UpdateDateSetSrcPath(DataSetFile, CDataSetInfo)
TempIndexCurrent=strfind(DataSetFile, '\');
TempIndexSave=strfind(CDataSetInfo.SrcPath, '\');

if length(CDataSetInfo.SrcPath) > 4 && isequal(lower(CDataSetInfo.SrcPath(end-3:end)), 'plan')
    CDataSetInfo.SrcPath=[DataSetFile(1:TempIndexCurrent(end-1)), CDataSetInfo.SrcPath(TempIndexSave(end-1)+1:end)];
else
    CDataSetInfo.SrcPath=[DataSetFile(1:TempIndexCurrent(end-1)), CDataSetInfo.SrcPath(TempIndexSave(end)+1:end)];
end