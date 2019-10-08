function Flag=FTPPlanDataIFOA(CurrentHostName, SourcePath, PlanDestPath, hText, ParentGcf, FTPUser, FTPPassword, Anonymize)

Flag=0;

%download
try
    f = ftp(CurrentHostName, FTPUser, FTPPassword);
catch
    Flag=1;
    return;
end


%Get directory
try
    cd(f, SourcePath);
catch
    Flag=2;
    close(f);    
    return;
end

%Get Patient file
set(hText, 'String', 'Transferring patient file...');
drawnow;

OldPath=pwd;
cd(PlanDestPath);

try
    mget(f, 'Patient');
catch
    Flag=3;
    
    close(f);
    cd(OldPath);
    
    return;
end

%Get Image Header file
set(hText, 'String', 'Transferring image header files...');
drawnow;

try
    mget(f, '*.header');
catch
    Flag=6;
    
    close(f);
    cd(OldPath);
    
    return;
end


%Read Patient file
PatFileName=[PlanDestPath, '\Patient'];
PatientInfo=ReadPinnTextFile(PatFileName);

%Get Plan Info
PlanInfo=GetPlanInfo(PatientInfo);

%Get HeaderInfo
HeaderInfo=GetHeaderInfo(PlanDestPath, 0);

%Select Image sets to be transferred
[GoFlag, ImageSetSelected]=SelectEntryFromTable(1, HeaderInfo, 'Select image sets to be tranferred:', [{80}, {60}, {100}, {180}, {180}, {80}, {250}], ParentGcf);
    
if GoFlag < 1
    Flag =7;
    
    close(f);
    cd(OldPath);
    
    return;    
end

ImageSetIDIndex=[];
for i=1:length(HeaderInfo)
    if ImageSetSelected(i)
        ImageSetIDIndex=[ImageSetIDIndex, {HeaderInfo(i).ID}];
    end
end

if isempty(ImageSetIDIndex)
    Flag =8;
    
    close(f);
    cd(OldPath);
    
    return;    
end

delete([PlanDestPath, '\*.header']);

%-------Get Image files
drawnow;
pause(0.05);

set(hText, 'String', ['Transferring image data', '...']);
drawnow;

for i=1:length(ImageSetIDIndex)
    PrimaryID=ImageSetIDIndex{i};
        
    set(hText, 'String', ['Transferring ImageSet_', PrimaryID,  '...']);
    drawnow;

    try
        mget(f,  ['ImageSet_', PrimaryID, '.ImageInfo']);
    catch
        Flag=5;
        
        close(f);
        cd(OldPath);
        
        return;
    end
    
    try
        mget(f,  ['ImageSet_', PrimaryID, '.header']);
    catch
        Flag=5;
        
        close(f);
        cd(OldPath);
        
        return;
    end
    
    try
        mget(f,  ['ImageSet_', PrimaryID, '.img']);
    catch
        Flag=5;
        
        close(f);
        cd(OldPath);
        
        return;
    end
    
    try
        mget(f,  ['ImageSet_', PrimaryID, '.ImageSet']);
    catch
        Flag=5;
        
        close(f);
        cd(OldPath);
        
        return;
    end
end

%--Get plan.roi and plan.points
PlanIDList=PlanInfo.PlanIDList;

for i=1:length(PlanIDList)
    set(hText, 'String', ['Transferring Plan_', num2str(PlanIDList(i)), '...']);
    drawnow;

    %Ftp Path
    if i >1
        cd(f, '..');
    end    
    
    try
        cd(f, ['Plan_', num2str(PlanIDList(i))]);
    catch
        continue;
    end
    
    %Local Path
    if i >1
        cd('..');
    end
    mkdir(['Plan_', num2str(PlanIDList(i))]);
    cd(['Plan_', num2str(PlanIDList(i))]);
    
    try 
        mget(f,  'plan.roi');
    catch
    end
    
    try 
        mget(f,  'plan.Points');
    catch
    end
    
    try 
        mget(f,  'plan.PlanRev');
    catch
    end
    
     try 
        mget(f,  'plan.Pinnacle');
    catch
    end
        
    try
        mget(f,  'plan.VolumeInfo');       
    catch
    end  
        
end

%Close
close(f);
cd(OldPath);

%Rename Folder name with Patient information
PlanDestPath=RenameFolderNameWithPatInfo(PlanDestPath);


%Anonymize
if Anonymize > 0
    AnonymizePatient(PlanDestPath);
end













