function AddExportFilterPath
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

TempIndex=strfind(MFilePath, '\');
ProgramPath=MFilePath(1:TempIndex(end)-1);

DataDir=[ProgramPath, '\ImportExport\ExportModule'];

ImportDir=GetExportModuleList(DataDir);

if isempty(ImportDir)
    return;
end

for i=1:length(ImportDir)
    addpath([ProgramPath, '\ImportExport\ExportModule\', ImportDir{i}]);
    
     if exist([ProgramPath, '\ImportExport\ExportModule\', ImportDir{i}, '\helper'], 'dir')
        addpath([ProgramPath, '\ImportExport\ExportModule\', ImportDir{i}, '\helper']);
    end
end