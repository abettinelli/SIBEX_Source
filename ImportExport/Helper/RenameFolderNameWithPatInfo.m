function PlanDestPath=RenameFolderNameWithPatInfo(PlanDestPath)
PatientFile=[PlanDestPath, '\Patient'];

if ~exist(PatientFile, 'file')
    return;
end

PatInfo=ReadPinnTextFile(PatientFile);

TempIndex=strmatch('LastName', PatInfo);
if ~isempty(TempIndex)    
    eval(PatInfo{TempIndex(1)});
else
    LastName=[];
end

TempIndex=strmatch('FirstName', PatInfo);
if ~isempty(TempIndex)    
    eval(PatInfo{TempIndex(1)});
else
    FirstName=[];
end

TempIndex=strmatch('MedicalRecordNumber ', PatInfo);
if ~isempty(TempIndex)    
    eval(PatInfo{TempIndex(1)});
else
    MedicalRecordNumber=[];
end

try    
    if isequal(PlanDestPath(end), '\')
        PlanDestPath(end)=[];
    end
    
    TempIndex=findstr(PlanDestPath, '\');
    FolderNamePre=PlanDestPath(1:TempIndex(end));
        
    FolderName=[LastName, '_', FirstName, '_', MedicalRecordNumber, '_',datestr(now, 30)];
    NewFolder=[FolderNamePre, '\', FolderName];
   
    dos(['move "', PlanDestPath, '" "', NewFolder, '"']);   
catch
end




