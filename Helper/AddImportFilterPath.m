function AddImportFilterPath
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

TempIndex=strfind(MFilePath, '\');
ProgramPath=MFilePath(1:TempIndex(end)-1);

DataDir=[ProgramPath, '\ImportExport\ImportModule'];

ImportDir=GetImportModuleList(DataDir);

if isempty(ImportDir)
    return;
end

for i=1:length(ImportDir)
    addpath([ProgramPath, '\ImportExport\ImportModule\', ImportDir{i}]);
    
    if exist([ProgramPath, '\ImportExport\ImportModule\', ImportDir{i}, '\helper'], 'dir')
        addpath([ProgramPath, '\ImportExport\ImportModule\', ImportDir{i}, '\helper']);
    end
end