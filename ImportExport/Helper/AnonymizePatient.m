function PatInfo=AnonymizePatient(PlanDestPath, IndexStr)

%Patient Index
if isequal(PlanDestPath(end), '\')
    PlanDestPath(end)=[];
end

TempIndex=strfind(PlanDestPath, '\');
SitePath=PlanDestPath(1:TempIndex(end));

if exist([PlanDestPath, '\Plan'], 'dir')
    PlanDestPath=[PlanDestPath, '\Plan'];
end

if nargin < 2
    try
        DirList=GetDirList(SitePath);
        
        TempIndex=strmatch('1Feature', DirList);
        PadStr=num2str(length(DirList)-length(TempIndex)+1);
    catch
        PadStr=[];
    end
else
    PadStr=IndexStr;
end

%Patient Info.
LastName=['Pat', PadStr];
FirstName=' ';
MiddleName=' ';
MRN='111111';

%Update Patient File
PatientFile=[PlanDestPath, '\Patient'];
UpdatePatientFile(PatientFile, LastName, FirstName, MiddleName, MRN);

%Update Header File
UpdateHeaderFiles(PlanDestPath, LastName, FirstName, MiddleName, MRN);

%Update ImageSet File
% UpdateImageSetFiles(PlanDestPath, LastName, FirstName, MiddleName, MRN);

%Update plan.roi file
UpdatePlanFile(PlanDestPath, LastName, FirstName, MiddleName, MRN);

%Patient information
PatInfo.LastName=LastName;
PatInfo.FirstName=FirstName;
PatInfo.MiddleName=MiddleName;
PatInfo.MRN=MRN;

%Folder
if exist('SitePath', 'var')
    FolderName=[LastName, '_', datestr(now, 30)];
    NewFolder=[SitePath, '\', FolderName];
    mkdir(NewFolder);
    
    movefile([PlanDestPath, '\*'], NewFolder, 'f');
    rmdir(PlanDestPath, 's');
    
    PatInfo.Directory=FolderName;
end



function UpdatePlanFile(PlanDestPath, LastName, FirstName, MiddleName, MRN)
DirList=GetDirList(PlanDestPath);
for i=1:length(DirList)
    CurrentDir=[PlanDestPath, '\', DirList{i}];
    
    ROIFile=[CurrentDir, '\', 'plan.roi'];
    if exist(ROIFile, 'file')
        UpdatePlanROIFile(ROIFile, LastName, FirstName, MiddleName, MRN);
    end
    
    POIFile=[CurrentDir, '\', 'plan.Points'];
    if exist(POIFile, 'file')
        UpdatePlanPOIFile(POIFile, LastName, FirstName, MiddleName, MRN);
    end    
end

function UpdatePlanROIFile(ROIFile, LastName, FirstName, MiddleName, MRN)
PatInfo=ReadPinnTextFileOri(ROIFile);

TempIndex=strmatch('// Data set: ', PatInfo);
if ~isempty(TempIndex)    
    PatInfo(TempIndex)={['// Data set: ', LastName, '^', FirstName]};
end

TempIndex=strmatch('volume_name: ', PatInfo);
if ~isempty(TempIndex)    
    PatInfo(TempIndex)={['volume_name: ', LastName, '^', FirstName]};
end

TempIndex=strmatch('stats_volume_name: ', PatInfo);
if ~isempty(TempIndex)    
    PatInfo(TempIndex)={['stats_volume_name: ', LastName, '^', FirstName]};
end

Fid=fopen(ROIFile, 'w');
for i=1:length(PatInfo)
    fprintf(Fid, '%s\n', PatInfo{i});
end
fclose(Fid);

function UpdatePlanPOIFile(POIFile, LastName, FirstName, MiddleName, MRN)
PatInfo=ReadPinnTextFileOri(POIFile);

TempIndex=strmatch('VolumeName = : ', PatInfo);
if ~isempty(TempIndex)    
    PatInfo(TempIndex)={['VolumeName = "', LastName, '^', FirstName, '";']};
end

Fid=fopen(POIFile, 'w');
for i=1:length(PatInfo)
    fprintf(Fid, '%s\n', PatInfo{i});
end
fclose(Fid);


function UpdateImageSetFiles(PlanDestPath, LastName, FirstName, MiddleName, MRN)
FileList=GetFileList(PlanDestPath);

TempIndex=regexp(FileList, ['ImageSet_', '\w*', '.ImageSet']);
for i=1:length(TempIndex)
    if ~isempty(TempIndex{i})
        HeaderFile=[PlanDestPath, '\', FileList{i}];
        UpdateImageSetFile(HeaderFile, LastName, FirstName, MiddleName, MRN);
    end
end

function UpdateImageSetFile(HeaderFile, LastName, FirstName, MiddleName, MRN)
PatInfo=ReadPinnTextFileOri(HeaderFile);

TempIndex=strmatch('NameFromScanner =', PatInfo);
if ~isempty(TempIndex)    
    PatInfo(TempIndex)={['NameFromScanner = "', LastName, '^', FirstName, '";']};
end

TempIndex=strmatch('PatientID ', PatInfo);
if ~isempty(TempIndex)    
    PatInfo(TempIndex)={['PatientID = ', MRN]};
end

Fid=fopen(HeaderFile, 'w');
for i=1:length(PatInfo)
    fprintf(Fid, '%s\n', PatInfo{i});
end
fclose(Fid);

function UpdateHeaderFiles(PlanDestPath, LastName, FirstName, MiddleName, MRN)
FileList=GetFileList(PlanDestPath);

TempIndex=regexp(FileList, ['ImageSet_', '\w*', '.header']);
for i=1:length(TempIndex)
    if ~isempty(TempIndex{i})
        HeaderFile=[PlanDestPath, '\', FileList{i}];
        UpdateHeaderFile(HeaderFile, LastName, FirstName, MiddleName, MRN);
    end
end

function UpdateHeaderFile(HeaderFile, LastName, FirstName, MiddleName, MRN)
PatInfo=ReadPinnTextFileOri(HeaderFile);

TempIndex=strmatch('db_name', PatInfo);
if ~isempty(TempIndex)    
    PatInfo(TempIndex)={['db_name : ', LastName, '^', FirstName]};
end

TempIndex=strmatch('patient_id', PatInfo);
if ~isempty(TempIndex)    
    PatInfo(TempIndex)={['patient_id : ', MRN]};
end

Fid=fopen(HeaderFile, 'w');
for i=1:length(PatInfo)
    fprintf(Fid, '%s\n', PatInfo{i});
end
fclose(Fid);


function UpdatePatientFile(PatientFile, LastName, FirstName, MiddleName, MRN)
if ~exist(PatientFile, 'file')
    return;
end

PatInfo=ReadPinnTextFileOri(PatientFile);

TempIndex=strmatch('LastName', PatInfo);
if ~isempty(TempIndex)    
    PatInfo(TempIndex)={['LastName = "', LastName, '";']};
end

TempIndex=strmatch('FirstName', PatInfo);
if ~isempty(TempIndex)    
    PatInfo(TempIndex)={['FirstName  = "', FirstName, '";']};
end

TempIndex=strmatch('MiddleName', PatInfo);
if ~isempty(TempIndex)    
    PatInfo(TempIndex)={['MiddleName  = "', MiddleName, '";']};
end

TempIndex=strmatch('MedicalRecordNumber ', PatInfo);
if ~isempty(TempIndex)    
    PatInfo(TempIndex)={['MedicalRecordNumber  = "', MRN, '";']};
end

TempIndex=strmatch('NameFromScanner ', PatInfo);
if ~isempty(TempIndex)    
    PatInfo(TempIndex)={['NameFromScanner  = "', LastName, '^', FirstName, '";']};
end

TempIndex=strmatch('MRN ', PatInfo);
if ~isempty(TempIndex)    
    PatInfo(TempIndex)={['MRN  = "', MRN, '";']};
end

Fid=fopen(PatientFile, 'w');
for i=1:length(PatInfo)
    fprintf(Fid, '%s\n', PatInfo{i});
end
fclose(Fid);












































