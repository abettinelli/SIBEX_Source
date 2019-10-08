%-----------------------Do conversion from  DICOM-->Pinnacle------------
function  DoConvertDICOM2PinnIFOA(handles)
%Status
handles.DCMBatchMode=0;
handles.PinnPath=handles.PatDataPath;
handles.DCM2PinnV9=1;   

BatchFlag=get(handles.CheckboxBatch, 'Value');

Anonymize=handles.ParentHandles.Anonymize;

%Set Status
set(handles.figure1, 'Pointer', 'watch');

StatusHandle=StatusProgressTextCenterIFOA('Import', ['Importing DICOM data ', '...'], handles.figure1);
hText=findobj(StatusHandle, 'Style', 'Text');
drawnow;

%Patient Catogorize accoring to patient Study Intance ID
PatientStr={[]}; PatientMRN={[]}; PatientStudyID={[]}; ImageSetNum=[]; FileDirAll={[]}; PatientSeiresUID={[]};   PatientDCMInfo={[]};    %One Row, One patient. different UID or image DCMInfo

%For display
PatientAllImageInfo={[]};  %One row: one patient; one column: one item info.

%Image conversion first
for i=handles.CurrentIMIndex:handles.CurrentIMIndex
    TempPatientStr={[]};
    
    DCMInfo=handles.CTDICOMInfo{i, 1};
    
    %Check PixelSpacing
    if ~isfield(DCMInfo, 'PixelSpacing')
        MissTags={'Width_Length'; 'Height_Length'};
        NoteOnMissTag='Specify length in cm.';
        MissData=GetMissDCMTag(1, MissTags, NoteOnMissTag);
        
        if isempty(MissData)
            %Delete status
            delete(StatusHandle);
            set(handles.figure1, 'Pointer', 'arrow');

            return;
        else
            try
                Width_Len=str2num(MissData{1, 2});
                Height_Length=str2num(MissData{2, 2});
                
                DCMInfo.PixelSpacing(1)=Width_Len*10/double(DCMInfo.Width);
                DCMInfo.PixelSpacing(2)=Height_Length*10/double(DCMInfo.Height);
            catch
                delete(StatusHandle);
                set(handles.figure1, 'Pointer', 'arrow');
                
                return;
            end
        end
    end
    
    %Update PatientMRNs
    PatientStudyID(1, 1)={DCMInfo.StudyInstanceUID};
    PatientSeiresUID(1, 1)={DCMInfo.SeriesInstanceUID};
    PatientDCMInfo(1,1)={DCMInfo};
    PatientMRN(1,1)={DCMInfo.PatientID};
    
    %---Patient File
    %Basic
    TempPatientStr=WritePatientFileBasic(DCMInfo);
    
    %Image
    NameStr=GetNameStr(DCMInfo);
    TimeStr=GetTimeStr(DCMInfo);
    
    if isfield(DCMInfo, 'SeriesDescription')
        SeriesStr=DCMInfo.SeriesDescription;
        
        NameFromScanner=GetNameStrWitherSeriesStr(NameStr, SeriesStr);
    else
        NameFromScanner=NameStr;
    end
    
    
    ImageNumber=cellfun('isempty', handles.CTDICOMInfo(i, :)');
    ImageNumber=find(ImageNumber == 0);
    ImageNumber=length(ImageNumber);
    
    TTStr={...
        'ImageSetList ={'; ...
        'ImageSet ={'; ...
        'ImageSetID = 0;'; ...
        'PatientID = 11111;'; ...
        'ImageName = "ImageSet_0";'; ...
        ['NameFromScanner = "', NameFromScanner,'";']; ...
        'ExamID = "11111";'; ...
        'StudyID = "11111";'; ...
        ['Modality = "', DCMInfo.Modality, '";']; ...
        ['NumberOfImages = ', num2str(ImageNumber), ';']; ...
        ['ScanTimeFromScanner = "', TimeStr, '";']; ...
        'FileName = "";'; ...
        '};'; ...
        '}'};
    
    TempPatientStr=[TempPatientStr; TTStr];
    
    %--Save for display
    ImageInfoStr=GetDcmPatInfo(DCMInfo, ['ImageSet_0', '.*']);
    ImageInfoStr(end-1)= {['ZDim: ', num2str(ImageNumber), '.']};
    PatientAllImageInfo(1, 1)={ImageInfoStr};
    
    %-Create Patient Folder
    NameStrG=GetNameStrG(DCMInfo);
    FileDir=deblank([handles.PinnPath, '\', NameStrG, '_', DCMInfo.PatientID]);
    
    SeriesStr=GetSeriesStr(DCMInfo, BatchFlag);           
    
    if BatchFlag < 1
        if isfield(DCMInfo, 'SeriesDescription')
            FileDir=[FileDir, '_', SeriesStr];
            
            if isfield(DCMInfo, 'SeriesNumber')
                FileDir=[FileDir, '_', num2str(DCMInfo.SeriesNumber)];
            end
            
            if isfield(DCMInfo, 'StudyID')
                FileDir=[FileDir, '_', num2str(DCMInfo.StudyID)];
            end
            
            FileDir=[FileDir, '_', datestr(now, 30)];
        end
    else                
        if isfield(DCMInfo, 'StudyID')
            FileDir=[FileDir, '_', num2str(DCMInfo.StudyID)];
        end
        
        if isfield(DCMInfo, 'SeriesNumber')
            FileDir=[FileDir, '_', num2str(DCMInfo.SeriesNumber)];
        end
        
         FileDir=[FileDir, '_', SeriesStr];
    end
    
    FileDir=[FileDir, '\'];
    
    SpecialChar={'!'; ':'; char(34); '#'; '\$'; '%'; '&'; '`'; '('; ')'; '\*'; '\+';  '/'; ';'; '<'; '='; '>'; '\?'; '@'; ','; '\.'; '[';  ']'; char(39); '{'; '\|'; '}'; '~'; ' '};
    FileDir=regexprep(FileDir, SpecialChar, '');
    FileDir=[FileDir(1), ':', FileDir(2:end)];
    
    if ~exist(FileDir, 'dir')
        mkdir(FileDir);
    else
        rmdir(FileDir, 's');
        mkdir(FileDir);
    end
    
    %Save
    PatientStr={TempPatientStr};
    ImageSetNum=[0];
    FileDirAll={FileDir};
    
    %-Writing Image related stuff .img, .ImageInfo, .ImageSet, .header
    PatientStr=WritePinnImage('ImageSet_0', handles.CTDICOMInfo(i, :), TTStr, TimeStr, hText, FileDir, handles.CTSetInfo{i, 5}, handles.DCM2PinnV9, PatientStr, DCMInfo);
end %i=1:size(handles.CTDICOMInfo, 1)


%---Plan
PlanID=ones(length(PatientMRN), 1)*-1;  ROITakenFlag=zeros(size(handles.ROIDICOMInfo, 1), 1);
PlanStr=repmat({[]}, length(PatientMRN), 1);

%Display info.
PatientAllPlanInfo={[]};

%Plan matrix is not empty
if ~isequal(handles.POIDICOMInfo, {[]}) && ~isnan(handles.CurrentPlanIndex)
    for i=handles.CurrentPlanIndex:handles.CurrentPlanIndex
        DCMInfo=handles.POIDICOMInfo{i};
        
        TempMRN=DCMInfo.StudyInstanceUID;
        
        %Which patient------------Need to update
        TTIndex=[];
        for kk=1:length(PatientMRN)
            if isfield(DCMInfo, 'ReferencedStructureSetSequence')
                
                TPatientDCMInfo=PatientDCMInfo(kk, :);
                
                for mm=1:size(TPatientDCMInfo, 2)
                    
                    if isempty(TPatientDCMInfo{mm})
                        continue;
                    else
                        TImgInfo=TPatientDCMInfo{mm};
                    end
                    
                    BaseStr1=TImgInfo.SeriesInstanceUID;
                    
                    if ~isequal(handles.ROIDICOMInfo, {[]})
                        for kkk=1:size(handles.ROIDICOMInfo, 1)
                            TROIInfo=handles.ROIDICOMInfo{kkk};
                            if isequal(BaseStr1, TROIInfo.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID) ...  %Series UID
                                    && isequal(DCMInfo.ReferencedStructureSetSequence.Item_1.ReferencedSOPInstanceUID, TROIInfo.SOPInstanceUID)
                                
                                TTIndex=kk;
                                break;
                            end
                        end
                    end
                    
                    if ~isempty(TTIndex)
                        break;
                    end
                    
                end
                
            else
                TPatientStudyID=RemoveEmptyCell(PatientStudyID(kk, :)');
                TTIndex=strmatch(TempMRN, TPatientStudyID, 'exact');
            end
            
            if ~isempty(TTIndex)
                TempIndex=kk;
                break;
            end
        end
        
        if isempty(TTIndex)
            TempIndex=[];
        end
        
        %Yes Plan for study
        if ~isempty(TempIndex)
            PlanID(TempIndex)=PlanID(TempIndex)+1;
            
            TempPlanDir=[FileDirAll{TempIndex}, 'Plan_', num2str(PlanID(TempIndex)), '\'];
            if ~exist(TempPlanDir, 'dir')
                mkdir(TempPlanDir);
                
            else
                delete([TempPlanDir, '*.*']);
            end
            
            IsocenterM=GetPlanIsocenter(DCMInfo);   %Isocenter is in DICOM coordinates.
            BeamNumMU=GetPlanBeamNumMU(DCMInfo);
            
            %--ROI
            try
                BaseStr=DCMInfo.ReferencedStructureSetSequence.Item_1.ReferencedSOPInstanceUID;
            catch
                BaseStr='';
            end
            
            BaseStrPlanSOPUID=DCMInfo.SOPInstanceUID;
            
            ROIExistFlag=0;
            %ROI is not empty
            if ~isequal(handles.ROIDICOMInfo, {[]})
                for j=1:size(handles.ROIDICOMInfo, 1)
                    %ROI for current study and current plan
                    TempIndex2=strmatch(BaseStr, handles.ROIDICOMInfo{j}.SOPInstanceUID, 'exact');
                    
                    if ~isempty(TempIndex2)   %ROI exist for plan
                        ROITakenFlag(j)=1;
                        
                        TempSeriesUID=handles.ROIDICOMInfo{j}.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID;
                        TempIndex3=strmatch(TempSeriesUID, RemoveEmptyCell(PatientSeiresUID(TempIndex, :)'), 'exact');
                        
                        if ~isempty(TempIndex3)
                            PrimaryImageSetID=TempIndex3-1;
                            
                            ImageDCMInfo=PatientDCMInfo{TempIndex, TempIndex3};
                            
                            TempSpacing=ImageDCMInfo.PixelSpacing;
                            
                            XPixDim=TempSpacing(1)/10;
                            YPixDim=TempSpacing(2)/10;
                            TempPos=ImageDCMInfo.ImagePositionPatient(1:2)/10;
                            
                            ROIExistFlag=1; PatientAllPlanInfo(TempIndex, PlanID(TempIndex)+1)={[]};
                            
                            %Save display info
                            PatientAllPlanInfo{TempIndex, PlanID(TempIndex)+1}=[PatientAllPlanInfo{TempIndex, PlanID(TempIndex)+1}; ...
                                {['PrimaryImageSetID: ', num2str(PrimaryImageSetID), '.']}];
                            
                            %Transform Isocenter
                            if ~isempty(IsocenterM)
                                %Before 09/19/2009
                                %IsocenterM(:, 1)=IsocenterM(:, 1)+XPixDim/2;
                                %IsocenterM(:, 2)=2*TempPos(2)-IsocenterM(:, 2);
                                %IsocenterM(:, 3)=-IsocenterM(:, 3);
                                
                                %Changed on 03/25/2010
                                if handles.DCM2PinnV9 < 1
                                    %IsocenterM(:, 1)=IsocenterM(:, 1)+XPixDim/2;
                                    %IsocenterM(:, 2)=2*TempPos(2)-IsocenterM(:, 2)-YPixDim/2;
                                    IsocenterM(:, 1)=IsocenterM(:, 1);
                                    IsocenterM(:, 2)=2*TempPos(2)-IsocenterM(:, 2)-YPixDim;
                                    IsocenterM(:, 3)=-IsocenterM(:, 3);
                                else
                                    IsocenterM(:, 1)=IsocenterM(:, 1);
                                    IsocenterM(:, 2)=-IsocenterM(:, 2);
                                    IsocenterM(:, 3)=-IsocenterM(:, 3);
                                end
                                
                                %Write plan.Points
                                TimeStr=GetTimeStr(DCMInfo);
                                WritePinPlanPoints(TempPlanDir, IsocenterM, hText, PlanID(TempIndex), TimeStr);
                                
                                %Save display info
                                PatientAllPlanInfo{TempIndex, PlanID(TempIndex)+1}=[PatientAllPlanInfo{TempIndex, PlanID(TempIndex)+1}; ...
                                    {['IsocenterNum: ', num2str(size(IsocenterM, 1)), '.']}; {' '}];
                            else
                                %Save display info
                                PatientAllPlanInfo{TempIndex, PlanID(TempIndex)+1}=[PatientAllPlanInfo{TempIndex, PlanID(TempIndex)+1}; ...
                                    {['IsocenterNum: ', num2str(0), '.']}; {' '}];
                            end
                            
                            %Write plan.roi----------------------TO DO: Load ROI script LoadROI.script------------------
                            TempROIName=WritePinPlanROI(TempPlanDir, handles.ROIDICOMInfo{j}, ImageDCMInfo, hText, PlanID(TempIndex), handles.DCM2PinnV9);
                            
                                                        
                            %Save display info
                            PatientAllPlanInfo{TempIndex, PlanID(TempIndex)+1}=[PatientAllPlanInfo{TempIndex, PlanID(TempIndex)+1}; ...
                                {'ROI: '}; TempROIName];
                            
                            %Save plan string
                            TempPlanStr=GeneratePlanStr(PlanID(TempIndex), PrimaryImageSetID, DCMInfo);
                            PlanStr{TempIndex}=[PlanStr{TempIndex}; TempPlanStr];
                        else
                            %Don't write ROI
                        end
                        
                    end  %ROI exist for plan
                end  %Loop ROI
                
            end %ROI is not empty
            
            %-Write plan.Points directly
            if (isequal(handles.ROIDICOMInfo, {[]}) || ROIExistFlag == 0)
                %Set to first image set
                PrimaryImageSetID=0;
                
                ImageDCMInfo=PatientDCMInfo{TempIndex, 1};
                
                TempSpacing=ImageDCMInfo.PixelSpacing;
                XPixDim=TempSpacing(1)/10;
                YPixDim=TempSpacing(2)/10;
                TempPos=ImageDCMInfo.ImagePositionPatient(1:2)/10;
                
                %Save for display
                PatientAllPlanInfo(TempIndex, PlanID(TempIndex)+1)={[]};
                
                PatientAllPlanInfo{TempIndex, PlanID(TempIndex)+1}=[PatientAllPlanInfo{TempIndex, PlanID(TempIndex)+1}; ...
                    {['PrimaryImageSetID: ', num2str(PrimaryImageSetID), '.']}];
                
                %Transform Isocenter
                if  ~isempty(IsocenterM)
                    %Before 09/19/2009
                    %IsocenterM(:, 1)=IsocenterM(:, 1)+XPixDim/2;
                    %IsocenterM(:, 2)=2*TempPos(2)-IsocenterM(:, 2);
                    %IsocenterM(:, 3)=-IsocenterM(:, 3);
                    
                    %Changed on 03/25/2009
                    if handles.DCM2PinnV9 < 1
                        %IsocenterM(:, 1)=IsocenterM(:, 1)+XPixDim/2;
                        %IsocenterM(:, 2)=2*TempPos(2)-IsocenterM(:, 2)-YPixDim/2;
                        IsocenterM(:, 1)=IsocenterM(:, 1);
                        IsocenterM(:, 2)=2*TempPos(2)-IsocenterM(:, 2)-YPixDim;
                        IsocenterM(:, 3)=-IsocenterM(:, 3);
                    else
                        IsocenterM(:, 1)=IsocenterM(:, 1);
                        IsocenterM(:, 2)=-IsocenterM(:, 2);
                        IsocenterM(:, 3)=-IsocenterM(:, 3);
                    end
                    
                    %Write plan.Points
                    TimeStr=GetTimeStr(DCMInfo);
                    WritePinPlanPoints(TempPlanDir, IsocenterM, hText, PlanID(TempIndex), TimeStr);
                    
                    %Save display info
                    PatientAllPlanInfo{TempIndex, PlanID(TempIndex)+1}=[PatientAllPlanInfo{TempIndex, PlanID(TempIndex)+1}; ...
                        {['IsocenterNum: ', num2str(size(IsocenterM, 1)), '.']}; {'No ROI.'}];
                else
                    %Save display info
                    PatientAllPlanInfo{TempIndex, PlanID(TempIndex)+1}=[PatientAllPlanInfo{TempIndex, PlanID(TempIndex)+1}; ...
                        {['IsocenterNum: ', num2str(0), '.']}; {'No ROI.'}];
                end
                
                %Save plan string
                TempPlanStr=GeneratePlanStr(PlanID(TempIndex), PrimaryImageSetID, DCMInfo);
                PlanStr{TempIndex}=[PlanStr{TempIndex}; TempPlanStr];
                
            end  %NO ROI  for plan, onay plan.roi
            
        end %Yes Plan for study
    end %Loop Plan
end  %Plan Matrix is not empty

%

%--ROI
if isnan(handles.CurrentPlanIndex) && ~isnan(handles.CurrentRSIndex)
    if ~isequal(handles.ROIDICOMInfo, {[]})
        for i=handles.CurrentRSIndex:handles.CurrentRSIndex
            %ROI is not taken
            if ROITakenFlag(i) == 1
                continue;
            end
            
            DCMInfo=handles.ROIDICOMInfo{i};
            
            %Pinnacle POI
            if isfield(DCMInfo, 'SeriesDescription') && isequal(DCMInfo.SeriesDescription, 'Pinnacle POI')
                continue;
            end
            
            if isfield(DCMInfo, 'StructureSetName') && isequal(DCMInfo.StructureSetName, 'POI')
                continue;
            end
            
            
            TempMRN=DCMInfo.StudyInstanceUID;
            %                 TempIndex=strmatch(TempMRN, PatientStudyID, 'exact');
            
            %Which patient
            TTIndex=[];
            for kk=1:length(PatientMRN)
                TPatientStudyID=RemoveEmptyCell(PatientStudyID(kk, :)');
                TTIndex=strmatch(TempMRN, TPatientStudyID, 'exact');
                
                if ~isempty(TTIndex)
                    TempIndex=kk;
                    break;
                end
            end
            
            if isempty(TTIndex)
                TempIndex=[];
            end
            
            %Not for any study
            if isempty(TempIndex)
                continue;
            end
            
            %ROI for current studies and one image set
            BaseStr=DCMInfo.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID;
            
            TempIndex3=strmatch(BaseStr, RemoveEmptyCell(PatientSeiresUID(TempIndex, :)'), 'exact');
            
            %no primary image set
            if isempty(TempIndex3)
                continue;
            end
            
            %Make new dir
            PlanID(TempIndex)=PlanID(TempIndex)+1;
            
            TempPlanDir=[FileDirAll{TempIndex}, 'Plan_', num2str(PlanID(TempIndex)), '\'];
            if ~exist(TempPlanDir, 'dir')
                mkdir(TempPlanDir);
                
            else
                delete([TempPlanDir, '*.*']);
            end
            
            %Primary Image Set and Information
            PrimaryImageSetID=TempIndex3-1;
            
            ImageDCMInfo=PatientDCMInfo{TempIndex, TempIndex3};
            
            %Save for display
            PatientAllPlanInfo(TempIndex, PlanID(TempIndex)+1)={[]};
            
            PatientAllPlanInfo{TempIndex, PlanID(TempIndex)+1}=[PatientAllPlanInfo{TempIndex, PlanID(TempIndex)+1}; ...
                {['PrimaryImageSetID: ', num2str(PrimaryImageSetID), '.']}; {['IsocenterNum: ', num2str(0), '.']}; {' '}];
            
            %Write plan.roi
            TempROIName=WritePinPlanROIMRI(TempPlanDir, DCMInfo, ImageDCMInfo, hText, PlanID(TempIndex), handles.DCM2PinnV9, handles.CTDICOMInfo(handles.CurrentIMIndex, :));            
            %TempROIName=WritePinPlanROI(TempPlanDir, DCMInfo, ImageDCMInfo, hText, PlanID(TempIndex), handles.DCM2PinnV9);
            
            %Save display info
            PatientAllPlanInfo{TempIndex, PlanID(TempIndex)+1}=[PatientAllPlanInfo{TempIndex, PlanID(TempIndex)+1}; ...
                {'ROI: '}; TempROIName];
            
            %Save plan string
            TempPlanStr=GenerateFakePlanStr(PlanID(TempIndex), PrimaryImageSetID);
            PlanStr{TempIndex}=[PlanStr{TempIndex}; TempPlanStr];
            
        end %Loop ROI
    end  %ROI is not empty
end
 
%Update patient string, Update next unique ImageSet ID and PlanID
for i=1:length(PatientMRN)
    TempPatientStr=PatientStr{i};
    
    TempIndex=strmatch('NextUniquePlanID', TempPatientStr);
    TempPatientStr(TempIndex)={['NextUniquePlanID = ', num2str(PlanID(i)+1), ';']};
    
    TempIndex=strmatch('NextUniqueImageSetID', TempPatientStr);
    TempPatientStr(TempIndex)={['NextUniqueImageSetID = ', num2str(ImageSetNum(i)+1), ';']};
    
    EndStr={'ObjectVersion ={'; ...
        'WriteVersion = "Launch Pad: 3.4b";'; ...
        'CreateVersion = "Launch Pad: 3.4b";'; ...
        'LoginName = "p3rtp";'; ...
        ['CreateTimeStamp = "', datestr(now, 31),  '";'];...
        ['WriteTimeStamp = "', datestr(now, 31), '";'];...
        'LastModifiedTimeStamp = "";';
        '};'};
    
    if ~isequal(PlanStr(i), {[]})
        TempPlanStr=PlanStr{i};
        PatientStr{i}=[TempPatientStr; {'PlanList ={'}; TempPlanStr; {'};'}; EndStr];
    else
        PatientStr{i}=[TempPatientStr; EndStr];
    end
    
    %--write patient file
    WritePatientFile(PatientStr{i}, FileDirAll{i}, hText);
    WritePatPlanTrial(FileDirAll{i}, hText);
    
    %Anonymize
    if Anonymize > 0
        AnonymizePatient(FileDirAll{i});
    end
end

%--Update Pinn display
ListboxStr=[]; ConvertPinnDetail=[]; TempNum=1;
for i=1:length(PatientMRN)
    %Patient Info
    ListboxStr=[ListboxStr; {['MRN: ', PatientMRN{i}]}];
    ConvertPinnDetail{TempNum}=[{['ImageSetNum: ', num2str(ImageSetNum(i)+1)]}; {['PlanNum: ', num2str(PlanID(i)+1)]}];
    TempNum=TempNum+1;
    
    %ImageSet
    for j=1:ImageSetNum(i)+1
        ListboxStr=[ListboxStr; {['--ImageSet_', num2str(j-1)]}];
        ConvertPinnDetail{TempNum}=PatientAllImageInfo{i, j};
        TempNum=TempNum+1;
    end
    
    %Plan
    for j=1:PlanID(i)+1
        ListboxStr=[ListboxStr; {['--Plan_', num2str(j-1)]}];
        ConvertPinnDetail{TempNum}=PatientAllPlanInfo{i, j};
        TempNum=TempNum+1;
    end
    
    ListboxStr=[ListboxStr; {' '}];
    ConvertPinnDetail{TempNum}=' ';
    TempNum=TempNum+1;
end

%Delete status
delete(StatusHandle);
set(handles.figure1, 'Pointer', 'arrow');


%-------------Remove Empty Cell
function ColCell=RemoveEmptyCell(ColCell)
TTIndex=cellfun('isempty', ColCell);
TTIndex=~TTIndex;

ColCell=ColCell(TTIndex);


%-------------Get patient basic information string
function TempPatientStr=WritePatientFileBasic(DCMInfo)

TempPatientStr{1}='PatientID = 11111;';

if isfield(DCMInfo.PatientName, 'FamilyName')
    TempPatientStr=[TempPatientStr; {['LastName = "', DCMInfo.PatientName.FamilyName, '";']}];
else
    TempPatientStr=[TempPatientStr; {['LastName = "', '";']}];
end

if isfield(DCMInfo.PatientName, 'GivenName')
    TempPatientStr=[TempPatientStr; {['FirstName = "', DCMInfo.PatientName.GivenName, '";']}];
else
    TempPatientStr=[TempPatientStr; {['FirstName = "', '";']}];
end

if isfield(DCMInfo.PatientName, 'MiddleName')
    TempPatientStr=[TempPatientStr; {['MiddleName = "', DCMInfo.PatientName.MiddleName, '";']}];
else
    TempPatientStr=[TempPatientStr; {['MiddleName = "', '";']}];
end

if isfield(DCMInfo, 'PatientID')
    TempPatientStr=[TempPatientStr; {['MedicalRecordNumber = "', DCMInfo.PatientID, '";']}];
else
    TempPatientStr=[TempPatientStr; {['MedicalRecordNumber = "', '";']}];
end

TTStr={'EncounterNumber = "";'; ...
'PrimaryPhysician = "";'; ...
'AttendingPhysician = "";'; ...
'ReferringPhysician = "";'; ...
'RadiationOncologist = "";'; ...
'Oncologist = "";'; ...
'Radiologist = "";'; ...
'Prescription = "";'; ...
'Disease = "";'; ...
'Diagnosis = "";'; ...
'Comment = "";'; ...
'NextUniquePlanID = 2;'; ...
'NextUniqueImageSetID = 1;'; ...
'Gender = "Male";'; ...
'DateOfBirth = "";'};

TempPatientStr=[TempPatientStr; TTStr];

%----------Get dciom name string from dicom information--------
function NameStr=GetNameStr(DCMInfo)

NameStr=[];
if isfield(DCMInfo.PatientName, 'FamilyName')
    NameStr=[NameStr, DCMInfo.PatientName.FamilyName, '^'];
else
    NameStr=[NameStr,  ' ^'];
end

if isfield(DCMInfo.PatientName, 'GivenName')
    NameStr=[NameStr, DCMInfo.PatientName.GivenName, '^^^'];
else
    NameStr=[NameStr, ' ^^^'];
end


%----------Get general name string from dicom information--------
function NameStr=GetNameStrG(DCMInfo)

NameStr=[];
if isfield(DCMInfo.PatientName, 'FamilyName')
    NameStr=[NameStr, DCMInfo.PatientName.FamilyName, '_'];
else
    NameStr=[NameStr,  'NA_'];
end

if isfield(DCMInfo.PatientName, 'GivenName')
    NameStr=[NameStr, DCMInfo.PatientName.GivenName];
else
    NameStr=[NameStr, ''];
end
       


%----------Get time string from dicom information--------
function TimeStr=GetTimeStr(DCMInfo)

TimeStr=[];
if isfield(DCMInfo, 'StudyDate') && isfield(DCMInfo, 'StudyTime')
    TempStr1=DCMInfo.StudyDate;
    TempStr2=DCMInfo.StudyTime;
    
    if isempty(TempStr1)
        if isfield(DCMInfo, 'InstanceCreationDate') && isfield(DCMInfo, 'InstanceCreationTime')
            TempStr1=DCMInfo.InstanceCreationDate;
            TempStr2=DCMInfo.InstanceCreationTime;
        end
    end

    if ~isempty(TempStr1) && ~isempty(TempStr2)
        TimeStr=[TempStr1, ' ', TempStr2];        
    else
        TimeStr=' ';
    end   
    
else
    if isfield(CTInfo, 'InstanceCreationDate') && isfield(CTInfo, 'InstanceCreationTime')
        TempStr1=CTInfo.InstanceCreationDate;
        TempStr2=CTInfo.InstanceCreationTime;

        if ~isempty(TempStr1) && ~isempty(TempStr2)
            TimeStr=[TempStr1, ' ', TempStr2];
        else
            TimeStr=' ';
        end
        
    else
        TimeStr=' ';
    end
end

function PatientStr=UpdatePatientStr(PatientStr, CurrentGroup, SubGroupSliceNum)
PatientStr=PatientStr{1};

StartIndex=strmatch('ImageSetID', PatientStr)-1;
EndIndex=strmatch('FileName', PatientStr)+1;

PatientStrHead=PatientStr(1:StartIndex(1)-1);
PatientStrEnd=PatientStr(EndIndex(end)+1:end);

TemplateStr=PatientStr(StartIndex(1):EndIndex(1));

if CurrentGroup < 2
    ImageSetStr=[];
else
    ImageSetStr=PatientStr(StartIndex(1):EndIndex(end));        
end

%Update ImageSetID, ImageName, NumberOfImages
TempIndex=strmatch('ImageSetID', TemplateStr);
TemplateStr(TempIndex)={['ImageSetID = ', num2str(CurrentGroup-1), ';']};

TempIndex=strmatch('ImageName', TemplateStr);
TemplateStr(TempIndex)={['ImageName = ', '"ImageSet_', num2str(CurrentGroup-1), '";']};

TempIndex=strmatch('NumberOfImages', TemplateStr);
TemplateStr(TempIndex)={['NumberOfImages = ', num2str(SubGroupSliceNum), ';']};

PatientStr=[PatientStrHead; ImageSetStr; TemplateStr; PatientStrEnd];

PatientStr={PatientStr};

function [GroupMethod, InstanceNum, SortIndex]=DecideGroupMethod(InstanceNum)
SortIndex=1:length(InstanceNum);

if length(InstanceNum) > 1
    GroupMethod=2;
    [InstanceNumT, SortIndex]=sort(InstanceNum);
    if abs(InstanceNumT(1)-InstanceNumT(2)) < 1             
        H=[1, -1];
        Diff=conv(InstanceNumT, H);
        Diff(1)=[];
        Diff(end)=[];        
        TempIndex=find(abs(Diff) < 1);
        
        while ~isempty(TempIndex)
            MaxV=max(InstanceNumT);
            InstanceNumT(TempIndex+1)=InstanceNumT(TempIndex+1)+MaxV;
            
            H=[1, -1];
            Diff=conv(InstanceNumT, H);
            Diff(1)=[];
            Diff(end)=[];
            TempIndex=find(abs(Diff) < 1);
        end       
        
        InstanceNum=InstanceNumT;  
    else
        SortIndex=1:length(InstanceNum);
    end
else
    GroupMethod=1;
end


%----------Write .img, .header, .ImageSet, and .ImageInfo---------
function PatientStr=WritePinnImage(ImageSetName, DCMFileList, ImageInfoStr, TimeStr, hText, FileDir, MaxRescaleSlope, DCM2PinnV9, PatientStr, DCMInfoFirst)

%Transpose
DCMFileList=DCMFileList';

%Delete empty item
TIndex=cellfun('isempty', DCMFileList);
TIndex=~TIndex;
DCMFileList=DCMFileList(TIndex);

%----Read image
ZDim=length(DCMFileList);
InstanceUID={[]}; DailyTablePos=[]; AxialImage=[];
ScaleFactor=[]; InstanceNum=[];

ColorLUTScale=1;

%Write DICOMInfo XML and copy DICOM file
DICOMInfoPath=[FileDir, '\DICOMInfo'];
if ~exist(DICOMInfoPath, 'dir')
    mkdir(DICOMInfoPath);
end

[MFilePath, MFileName]=fileparts(mfilename('fullpath'));
TempIndex=strfind(MFilePath, '\');

ExePath=[MFilePath(1:TempIndex(end-2)), 'Utils\dcm2xml'];
ExeStr=[ExePath, ' "', DCMFileList{1}.Filename, '" "',  DICOMInfoPath, '\', ImageSetName, DCMFileList{1}.Modality, '.xml', '"'];
copyfile(DCMFileList{1}.Filename, [DICOMInfoPath, '\', ImageSetName, DCMFileList{1}.Modality, '.dcm'], 'f');

[DosStatus, DosResult] = dos(ExeStr);


for i=1:ZDim
    %Show Status
    set(hText, 'String', ['Reading DICOM  images... (', num2str(i), ' of ', num2str(ZDim), ')']);
    drawnow;

    %UID and others
    InstanceUID=[InstanceUID; cellstr(DCMFileList{i}.SOPInstanceUID)];

    if isfield(DCMFileList{i}, 'RescaleSlope')
        RescaleSlope=DCMFileList{i}.RescaleSlope;        
    else
        RescaleSlope=1;       
    end
    
    if isfield(DCMFileList{i}, 'RescaleIntercept')
        RescaleIntercept=DCMFileList{i}.RescaleIntercept;
    else
         RescaleIntercept=0;
    end
    
    %CBCT
    if ~isfield(DCMFileList{i}, 'SliceLocation') || isequal(DCMFileList{i}.Modality, 'CT')
        DailyTablePos=[DailyTablePos; DCMFileList{i}.ImagePositionPatient(3)];
    else
        DailyTablePos=[DailyTablePos; DCMFileList{i}.SliceLocation];
    end    
   
            
    %image data    
    TempImageData=dicomread(DCMFileList{i});   
    
    if isequal(DCMFileList{i}.Modality, 'CT')
        TempImageData=uint16(double(TempImageData)*RescaleSlope+RescaleIntercept+1000);
        InstanceNum=[InstanceNum; DCMFileList{i}.InstanceNumber];
    end
    
    if isequal(DCMFileList{i}.Modality, 'MR')
        TempImageData=uint16(TempImageData);
        InstanceNum=[InstanceNum; DCMFileList{i}.InstanceNumber];
    end
    
    if isequal(DCMFileList{i}.Modality, 'PT')                 
        %Method2: Use real SUV value
        TScaleFactor=GetSUVScaleFactor(DCMFileList{i});
        ScaleFactor=[ScaleFactor; TScaleFactor];
        InstanceNum=[InstanceNum; DCMFileList{i}.InstanceNumber];
        
        TempImageData=double(TempImageData)*RescaleSlope+RescaleIntercept;
        TempImageData=single(TempImageData);    
    end    
    
    AxialImage=cat(3, AxialImage, TempImageData);
end

clear('TempImageData');        

%Method 2: Real SUV value
if isequal(DCMFileList{1}.Modality, 'PT')    
    
    %NEED TO CHECK%
    ScaleFactor=ScaleFactor(1);
    
%     AxialImage=AxialImage/ScaleFactor(1);
    
    MaxV=max(AxialImage(:));
    ColorLUTScale=MaxV/4095;
    
    AxialImage=AxialImage/single(ColorLUTScale);
end
      
%how many group in one series
[GroupMethod, InstanceNum, SortIndex]=DecideGroupMethod(InstanceNum);
DailyTablePos=DailyTablePos(SortIndex);
InstanceUID(1)=[];
InstanceUID=InstanceUID(SortIndex);
AxialImage=AxialImage(:,:,SortIndex);

switch GroupMethod
    case 1  %Every group has the same  number of slices, instance number can be same
        
        %Sort according to DailyTable Position
        DailyTablePosOri=DailyTablePos;
        [DailyTablePosT, TempIndex]=sort(DailyTablePosOri, 'descend');
        InstanceNumSort=InstanceNum(TempIndex);
        
        if length(InstanceNumSort) > 1 && abs(InstanceNumSort(1)-InstanceNumSort(2))> 1
            %MR--One series, multiple temporal sets
            SubGroupSliceNum=abs(InstanceNumSort(1)-InstanceNumSort(2));
            GroupNum=length(DailyTablePos)/SubGroupSliceNum;
        else
            SubGroupSliceNum=length(InstanceNumSort);
            GroupNum=1;
        end
        
        [InstanceNum, InstanceIndex]=sort(InstanceNum);
        DailyTablePosT=DailyTablePosOri(InstanceIndex);
        AxialImageT=AxialImage(:,:,InstanceIndex);      
        InstanceUIDT=InstanceUID(InstanceIndex);
        
    case 2 %Group may have the different  number of slices, instance number has to be unique
        DailyTablePosOri=DailyTablePos;
        [InstanceNum, InstanceIndex]=sort(InstanceNum);
        DailyTablePosT=DailyTablePosOri(InstanceIndex);
        AxialImageT=AxialImage(:,:,InstanceIndex);
        InstanceUIDT=InstanceUID(InstanceIndex);
        
        TSliceSpacing=abs(DailyTablePosT(end)-DailyTablePosT(end-1));
        
        DiffTablePos=abs(conv(DailyTablePosT, [1, -1]));
        DiffTablePos(1)=[];
        DiffTablePos(end)=[];
        
        %TempIndex=find(DiffTablePos > 3*TSliceSpacing);        
        TempIndex=find(abs(DiffTablePos -TSliceSpacing) >0.1);
        
        if isempty(TempIndex)
            SubGroupSliceNum=length(InstanceNum);
            GroupNum=1;
            
            StartIndexT=1;
            EndIndexT=length(DailyTablePos);
        else
            StartIndexT=[1; TempIndex+1];
            EndIndexT=[TempIndex; length(DailyTablePos)];
            
            GroupNum=length(StartIndexT);
        end
        
end

ImageSetNameT=ImageSetName;

for CurrentGroup=1:GroupNum    
    
    switch GroupMethod
        case 1
            StartIndex=(CurrentGroup-1)*SubGroupSliceNum+1;
            EndIndex=CurrentGroup*SubGroupSliceNum;
        case 2
            StartIndex=StartIndexT(CurrentGroup);
            EndIndex=EndIndexT(CurrentGroup);
            
            SubGroupSliceNum=EndIndex-StartIndex+1;
    end
    
    DailyTablePos=DailyTablePosT(StartIndex:EndIndex);
    AxialImage=AxialImageT(:, :, StartIndex:EndIndex);
    InstanceUID=InstanceUIDT(StartIndex:EndIndex);
    
    [DailyTablePos, TempIndex]=sort(DailyTablePos, 'descend');

    AxialImage=AxialImage(:,:,TempIndex);   
    InstanceUID=InstanceUID(TempIndex);
    
    %Update ImageSet information in the Patient file
    if GroupNum < 2
        SeriesDesAppend=0;        
    else
        SeriesDesAppend=1;
    end
    PatientStr=UpdatePatientStr(PatientStr, CurrentGroup, SubGroupSliceNum);
    
    %change the sign of Table pos to make table pos direction conforms to pinnalce
    if length(DailyTablePos) > 1
        if DailyTablePos(1) > DailyTablePos(2)
            DailyTablePos=-(DailyTablePos/10);
        else
            DailyTablePos=DailyTablePos/10;
        end
    else
        DailyTablePos=-DailyTablePos/10;
    end
    
    %-----Img
    TTIndex=strfind(ImageSetNameT, '_');
    TempStr=num2str(str2num(ImageSetNameT(TTIndex(end)+1:end))+CurrentGroup-1);
    ImageSetName=['ImageSet_', TempStr];
    
    set(hText, 'String', ['Writing ', ImageSetName, '.img ...']);
    drawnow;
    
    AxialImage=permute(AxialImage, [2,1,3]);
    
    %Write new img file
    if isequal(DCMFileList{1}.Modality, 'CT')  || isequal(DCMFileList{1}.Modality, 'MR')
        TempFid=fopen([FileDir, ImageSetName, '.img'], 'w');
        fwrite(TempFid, AxialImage, 'uint16');
        fclose(TempFid);
    end
    
    if isequal(DCMFileList{1}.Modality, 'PT')
        TempFid=fopen([FileDir, ImageSetName, '.img'], 'w');
        fwrite(TempFid, AxialImage, 'float32');
        fclose(TempFid);
    end
    
    clear('AxialImage');
    
    
    %----.ImageSet
    %Set Status
    set(hText, 'String', ['Writing ', ImageSetName, '.ImageSet ...']);
    drawnow;
    
    Fid=fopen([FileDir, ImageSetName, '.ImageSet'], 'w');
    for i=1:length(ImageInfoStr)-4
        fprintf(Fid, '%s\n', ImageInfoStr{2+i});
    end
    fclose(Fid);
    
    %----.Header
    TempSpacing=DCMInfoFirst.PixelSpacing;
    XPixDim=TempSpacing(1)/10;
    YPixDim=TempSpacing(2)/10;
    
    TempPos=DCMFileList{1}.ImagePositionPatient(1:2)/10;
    
    HalfPixOffset=1;
    
    if DCM2PinnV9 < 1
        if HalfPixOffset > 0
            XDailyOriginStart=TempPos(1)+XPixDim/2;
            YDailyOriginStart=TempPos(2)+YPixDim/2-double(DCMFileList{1}.Height)*YPixDim;
        else
            XDailyOriginStart=TempPos(1);
            YDailyOriginStart=TempPos(2)-double(DCMFileList{1}.Height-1)*YPixDim;
        end
    else
        XDailyOriginStart=TempPos(1);
        YDailyOriginStart=TempPos(2)-double(DCMFileList{1}.Height-1)*YPixDim;
        
        XDailyOriginStartV9=TempPos(1);
        YDailyOriginStartV9=-(TempPos(2)+double(DCMFileList{1}.Height-1)*YPixDim);
    end
    
    NameStr=GetNameStr(DCMFileList{1});
    
    if  isfield(DCMFileList{1}, 'SeriesDescription')
        
        SeriesStr=DCMFileList{1}.SeriesDescription;
        
        NameStr=GetNameStrWitherSeriesStr(NameStr, SeriesStr);
    end
    
    
    if isfield(DCMFileList{1}, 'PatientID')
        MRNStr=DCMFileList{1}.PatientID;
    else
        MRNStr='';
    end
    
    if length(DailyTablePos) == 1
        ZPixDimTemp=0.3;
    else
        ZPixDimTemp=abs(DailyTablePos(1)-DailyTablePos(2));
    end
    
    if isequal(DCMFileList{1}.Modality, 'CT') || isequal(DCMFileList{1}.Modality, 'MR')
        bitpix=16;
        bytes_pix=2;
    end
    
    if isequal(DCMFileList{1}.Modality, 'PT')
        bitpix=32;
        bytes_pix=4;
    end
    
    if isfield(DCMFileList{1}, 'TableHeight')
        CouchHeight=DCMFileList{1}.TableHeight/10;
    else
        CouchHeight=18.4;
    end
    
    if isfield(DCMFileList{1}, 'Manufacturer')
        Manufacturer=DCMFileList{1}.Manufacturer;
    else
        Manufacturer='NA';
    end
    
    if isfield(DCMFileList{1}, 'ManufacturerModelName')
        ManufacturerModelName=DCMFileList{1}.ManufacturerModelName;
    else
        ManufacturerModelName='NA';
    end
    
    if isfield(DCMFileList{1}, 'PatientPosition')
        PatientPosition=DCMFileList{1}.PatientPosition;
    else
        PatientPosition='NA';
    end      
  
    
    TempStr={
        'byte_order = 0;'; ...
        'read_conversion = "";'; ...
        'write_conversion = "";'; ...
        't_dim = 0;';...
        ['x_dim = ', num2str(DCMFileList{1}.Width), ';']; ...
        ['y_dim = ', num2str(DCMFileList{1}.Height), ';']; ...
        ['z_dim = ', num2str(SubGroupSliceNum), ';']; ...
        'datatype = 1;' ;...
        ['bitpix = ', num2str(bitpix), ';'] ;...
        ['bytes_pix = ', num2str(bytes_pix), ';'] ;...
        'vol_max = 0.000000;';...
        'vol_min = 0.000000;';...
        't_pixdim = 0.000000;';...
        ['x_pixdim = ', num2str(XPixDim, 10), ';']; ...
        ['y_pixdim = ', num2str(YPixDim, 10), ';']; ...
        ['z_pixdim = ', num2str(ZPixDimTemp, 10), ';']; ...
        't_start = 0.000000;';...
        ['x_start =',  num2str(XDailyOriginStart, 10), ';']; ...
        ['y_start =',  num2str(YDailyOriginStart, 10), ';']; ...
        ['z_start =',  num2str(DailyTablePos(1), 10), ';']; ...
        'z_time = 0.000000;';...
        'dim_units : ';...
        'voxel_type : ';...
        'id = 0;'; ...
        'vis_only = 0;'; ...
        'data_type : '; ...
        'vol_type : '; ...
        ['db_name : ', NameStr]; ...
        'medical_record : '; ...
        'originator : '; ...
        ['date : ', TimeStr]; ...
        'scanner_id : ';...
        ['patient_position : ', PatientPosition]; ...
        'orientation = 0;';...
        'scan_acquisition = 0;';...
        'comment : ';...
        'fname_format : '; ...
        'fname_index_start = 0;';...
        'fname_index_delta = 0;';...
        'binary_header_size = 0;';...
        ['manufacturer : ', Manufacturer];...
        ['model : ', ManufacturerModelName];...
        'couch_pos = 0.000000;';...
        ['couch_height = ', num2str(CouchHeight, 10), ';'];...
        'X_offset = -0.000000;';...
        'Y_offset = 0.000000;';...
        'dataset_modified = 0;';...
        'study_id : 11111';...
        'exam_id : 11111';...
        ['patient_id : ', MRNStr]; ...
        ['modality : ', DCMFileList{1}.Modality]};
    
    if isfield(DCMFileList{1}, 'SeriesDescription')
        if SeriesDesAppend > 0
            SeriesDescription=[DCMFileList{1}.SeriesDescription, '_',  num2str(CurrentGroup)];
        else
            SeriesDescription=[DCMFileList{1}.SeriesDescription];
        end
    else
        SeriesDescription='';
    end
    
    if isfield(DCMFileList{1}, 'ScanOptions')
        ScanOptions=DCMFileList{1}.ScanOptions;
    else
        ScanOptions='';
    end
    
    if isfield(DCMFileList{1}, 'StationName')
        StationName=DCMFileList{1}.StationName;
    else
        StationName='';
    end
    
    if isfield(DCMFileList{1}, 'KVP')
        KVP=DCMFileList{1}.KVP;
    else
        KVP='';
    end
    
    if isfield(DCMFileList{1}, 'AcquisitionTime') && isfield(DCMFileList{1}, 'ContentDate')
        SeriesDateTime=[DCMFileList{1}.ContentDate, ' ', DCMFileList{1}.AcquisitionTime];
    else
        SeriesDateTime='';
    end

    if DCM2PinnV9 > 0
        TempStr=[TempStr;...
            {'gating_type :'};...
            {'gating_UID :'};...
            {['Series_Description : ', SeriesDescription]};...
            {['Scan_Options : ', ScanOptions]};...
            {'Low_Sag : '};...
            {'Negative_Voxel : Yes'};...
            {['Station_Name : ', StationName]};...
            {['KVP : ', num2str(KVP)]};...
            {['SeriesDateTime : ', SeriesDateTime]};...
            {'Version : 9.0'};...
            {['x_start_dicom = ', num2str(XDailyOriginStartV9,10), ';']};...
            {['y_start_dicom = ', num2str(YDailyOriginStartV9,10), ';']}]; % bettinelli
    end
    
    
    %Set Status
    set(hText, 'String', ['Writing ', ImageSetName, '.header ...']);
    drawnow;
    
    Fid=fopen([FileDir, ImageSetName, '.header'], 'w');
    for i=1:length(TempStr)
        fprintf(Fid, '%s\n', TempStr{i});
    end
    fclose(Fid);
    
    
    %------.ImageInfo
    TempStr={[]};
    
    %For PET modality, change ColorLUTScale and SUV
    if isequal(DCMFileList{1}.Modality, 'PT')
        %     ColorLUTScale=ColorLUTScale*100;
        %     SUVScale=0.01;
        
        SUVScale=1/ScaleFactor(1);
    else
        ColorLUTScale=1;
        SUVScale=1;
    end
    
    for i=1:length(DailyTablePos)
        
        if ~isfield(DCMFileList{1}, 'FrameOfReferenceUID')            
            DCMFileList{1}.FrameOfReferenceUID=' ';
        end
        
        TempStr=[TempStr; ...
            {'ImageInfo ={'}; ...
            {['TablePosition = ', num2str(DailyTablePos(i), 10), ';']};...
            {['CouchPos = ', num2str(-DailyTablePos(i), 10), ';']};...
            {['SliceNumber = ', num2str(i), ';']};...
            {['SeriesUID = "', DCMFileList{1}.SeriesInstanceUID, '";']};...
            {['StudyInstanceUID = "', DCMFileList{1}.StudyInstanceUID, '";']};...
            {['FrameUID = "', DCMFileList{1}.FrameOfReferenceUID, '";']};...
            {['ClassUID = "', DCMFileList{1}.SOPClassUID, '";']};...
            {['InstanceUID = "', InstanceUID{i}, '";']};...
            {['SUVScale = ', num2str(SUVScale), ';']};...
            {['ColorLUTScale = ', num2str(ColorLUTScale), ';']};...
            {'};'}...
            ];
    end
    
    %Set Status
    set(hText, 'String', ['Writing ', ImageSetName, '.ImageInfo ...']);
    drawnow;
    
    Fid=fopen([FileDir, ImageSetName, '.ImageInfo'], 'w');
    for i=2:length(TempStr)
        fprintf(Fid, '%s\n', TempStr{i});
    end
    fclose(Fid);
end


%---------Get PinnPET scale facctor
function ScaleFactor=GetSUVScaleFactor(info)

try
    p_Weight = info.PatientWeight;    
    p_StartTime = info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime;
    p_TotalDose = info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose;
    p_HalfLife  = info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife;
    p_RefTime   = info.FrameReferenceTime/1000.0;
    p_Number    = info.InstanceNumber;
    p_Decay     = info.DecayCorrection;
catch
    ScaleFactor=1;
    
    return;
    %%Example how to manually set admin. dose information
%         if ~isempty(findstr(info.PatientName.FamilyName,'SNM'))
%             p_Weight = 10.9; %kg
%             p_StartTime = '120000.00';%145500.00
%             p_TotalDose = 168000000;%428338976
%             p_HalfLife  = 23414400; %6588
%             p_RefTime   = info.FrameReferenceTime/1000.0; %366
%             p_Number    = info.InstanceNumber; %100
%             p_Decay     = info.DecayCorrection; %'START'
%         end
end

if (strcmp(p_Decay, 'START'))
    p_Time = info.AcquisitionTime;
else
    p_Time = info.SeriesTime;
end;


ka = length(p_StartTime);
t1 = str2num(p_StartTime(1:2))*3600 + str2num(p_StartTime(3:4))*60.0 + str2num(p_StartTime(5:ka));

ka = length(p_Time);
t2 = str2num(p_Time(1:2))*3600 + str2num(p_Time(3:4))*60.0 + str2num(p_Time(5:ka));

if (strcmp(p_Decay, 'NONE'))
    diff_time = t2 - t1 + p_RefTime;
    ScaleFactor = p_TotalDose * 0.5^(diff_time/p_HalfLife)/(p_Weight * 1000);
else
    if (strcmp(p_Decay, 'ADMIN'))
        diff_time = 0.0;
    else
        diff_time = t2 - t1;
    end;

    ScaleFactor = p_TotalDose * 0.5^(diff_time/p_HalfLife)/(p_Weight * 1000);
end


%----------Get plan isocenter--------
function IsocenterM=GetPlanIsocenter(CTInfo)

IsocenterM=[];

if isfield(CTInfo, 'BeamSequence')    %Photon, Neutron
    for i=1:length(fieldnames(CTInfo.BeamSequence))
        FieldName=['Item_', num2str(i)];
       
        try
            if isfield(CTInfo.BeamSequence.(FieldName).ControlPointSequence.Item_1, 'IsocenterPosition')
                TempP=CTInfo.BeamSequence.(FieldName).ControlPointSequence.Item_1.IsocenterPosition';
                
                if isempty(IsocenterM)
                    IsocenterM=[IsocenterM; TempP];
                else                    
                    A1=TempP(:,1)-IsocenterM(:,1); A2=TempP(:,2)-IsocenterM(:,2); A3=TempP(:,3)-IsocenterM(:,3);
                    TT=A1.*A1+A2.*A2+A3.*A3;
                    if find(TT <= 1E-04)
                        continue;
                    else
                        IsocenterM=[IsocenterM; TempP];
                    end
                end
            end
            
        catch            
        end       
            
    end
    
end

if isfield(CTInfo, 'IonBeamSequence')    %Photon, Neutron
    for i=1:length(fieldnames(CTInfo.IonBeamSequence))
        FieldName=['Item_', num2str(i)];
       
        try
            if isfield(CTInfo.IonBeamSequence.(FieldName).IonControlPointSequence.Item_1, 'IsocenterPosition')
                TempP=CTInfo.IonBeamSequence.(FieldName).IonControlPointSequence.Item_1.IsocenterPosition';
                
                if isempty(IsocenterM)
                    IsocenterM=[IsocenterM; TempP];
                else                    
                    A1=TempP(:,1)-IsocenterM(:,1); A2=TempP(:,2)-IsocenterM(:,2); A3=TempP(:,3)-IsocenterM(:,3);
                    TT=A1.*A1+A2.*A2+A3.*A3;
                    if find(TT <= 1E-04)
                        continue;
                    else
                        IsocenterM=[IsocenterM; TempP];
                    end
                end
            end
            
        catch            
        end       
            
    end
    
end


if ~isempty(IsocenterM)
    IsocenterM=IsocenterM/10;
end


%----------Get reference number and MU of each beam from plan DCM file--------
function BeamNumMU=GetPlanBeamNumMU(DCMInfo)

BeamMU=[]; BeamFractionRefNum=[];

ValidFlag=1;
if isfield(DCMInfo, 'FractionGroupSequence')
    FractionInfo=DCMInfo.FractionGroupSequence;
    
    for i=1:length(fieldnames(FractionInfo))
        FieldName=['Item_', num2str(i)];
        
        if isfield(FractionInfo.(FieldName), 'ReferencedBeamSequence')
            BeamInfo=FractionInfo.(FieldName).ReferencedBeamSequence;
            
            for j=1:length(fieldnames(BeamInfo))
                subFieldName=['Item_', num2str(j)];
                
                if isfield(BeamInfo.(subFieldName), 'BeamMeterset')
                    BeamMU=[BeamMU; BeamInfo.(subFieldName).BeamMeterset];
                    BeamFractionRefNum=[BeamFractionRefNum; BeamInfo.(subFieldName).ReferencedBeamNumber];
                else
                    ValidFlag=0;
                    break;
                end
                
            end
            
            if ValidFlag == 0
                break;
            end
            
        else
            ValidFlag=0;
            break;
        end                
                
    end    
    
else
    ValidFlag=0;
end

if ValidFlag == 0
    BeamNumMU=[];
    return;
end

ValidFlag=1;

PhotonBeam=0;    
ProtonBeam=0;    

if isfield(DCMInfo, 'BeamSequence')
    PhotonBeam=1;    
else
    if isfield(DCMInfo, 'IonBeamSequence')
        ProtonBeam=1;   
    end
end

if (PhotonBeam==0) && (ProtonBeam==0)
    BeamNumMU=[];
    return;
end

if PhotonBeam == 1
    if isfield(DCMInfo, 'BeamSequence')
        BeamInfo=DCMInfo.BeamSequence;
        
        for i=1:length(fieldnames(BeamInfo))
            FieldName=['Item_', num2str(i)];            
            
            DosiUnit=BeamInfo.(FieldName).PrimaryDosimeterUnit;
            
            if ~isequal(DosiUnit, 'MU')
                ValidFlag=0;
                break;
            end
        end
        
    end
end

if ProtonBeam == 1
    if isfield(DCMInfo, 'IonBeamSequence')
        BeamInfo=DCMInfo.IonBeamSequence;
        
        for i=1:length(fieldnames(BeamInfo))
            FieldName=['Item_', num2str(i)];            
            
            DosiUnit=BeamInfo.(FieldName).PrimaryDosimeterUnit;
            
            if ~isequal(DosiUnit, 'MU')
                ValidFlag=0;
                break;
            end
        end
        
    end
end


if ValidFlag == 0
    BeamNumMU=[];
    return;
end

BeamNumMU=[BeamFractionRefNum, BeamMU];


%------------Write plan.Points from DICOM------------------
function WritePinPlanPoints(TempPlanDir, IsocenterM, hText, PlanID,TimeStr)
TempStr={[]};
for i=1:size(IsocenterM, 1)
    TempStr={TempStr; ...
        'Poi ={'; ...
        ['Name = "Iso_', num2str(i), '";'];...
        ['XCoord = ', num2str(IsocenterM(i, 1), 6), ';']; ...
        ['YCoord = ', num2str(IsocenterM(i, 2), 6), ';']; ...
        ['ZCoord = ', num2str(IsocenterM(i, 3), 6), ';']; ...
        'XRotation = 0;';...
        'YRotation = 0;';...
        'ZRotation = 0;';...
        'Radius = 0.5;';...
        'Color = "red";';...
        'CoordSys = "CT";';...
        'CoordinateFormat = "%6.2f";';...
        'Display2d = "On";';...
        'Display3d = "Off";';...
        'ObjectVersion ={';...
        'WriteVersion = "Pinnacle v7.6c";';...
        'CreateVersion = "Pinnacle v7.6c";';...
        'LoginName = "p3rtp";';...
        ['CreateTimeStamp = "', TimeStr, '";'];...
        ['WriteTimeStamp = "', TimeStr, '";'];...
        'LastModifiedTimeStamp = "";';...
        '};';...
        '};';...
        };
end

%Set Status
set(hText, 'String', ['Writing plan.Points for Plan_', num2str(PlanID), ' ...']);
drawnow;

Fid=fopen([TempPlanDir, 'plan.Points'], 'w');
for i=2:length(TempStr)
    fprintf(Fid, '%s\n', TempStr{i});
end
fclose(Fid);

%Set Status
set(hText, 'String', ['Writing LoadPOI script for Plan_', num2str(PlanID), ' ...']);
drawnow;

TempStr={[]};
for i=1:size(IsocenterM, 1)
    TempStr={TempStr; ...
        ['CreateNewPOI = ', char(34), 'Add Point Of Interest',char(34) ';']; ...
        ['PoiList .Current .Name = ', char(34), 'Iso_', num2str(i), char(34) ';']; ...
        ['PoiList .Current .DisplayXCoord = ', char(34), num2str(IsocenterM(i, 1), 6), char(34) ';']; ...
        ['PoiList .Current .DisplayYCoord = ', char(34), num2str(IsocenterM(i, 2), 6), char(34) ';']; ...
        ['PoiList .Current .DisplayZCoord = ', char(34), num2str(IsocenterM(i, 3), 6), char(34) ';']; ...
        ' '};
end

Fid=fopen([TempPlanDir, 'LoadPOI.Script'], 'w');
for i=2:length(TempStr)
    fprintf(Fid, '%s\n', TempStr{i});
end
fclose(Fid);

%LoadAll.Script
if exist([TempPlanDir, 'LoadAll.Script'])
    LoadAllCell=textread([TempPlanDir, 'LoadAll.Script'], '%s', 'delimiter', '\n');
    
else
    LoadAllCell={'Store.At.ScriptPath=SimpleString{};'; ...
        'Store.At.ScriptPath.AppendString=Script .ScriptList .Directory;'; ...
        ''};    
end

LoadAllCell=[LoadAllCell; ...
    {'Store.At.POIPath=SimpleString{};'}; ...
    {'Store.At.POIPath.AppendString=Script .ScriptList .Directory;'};...
    {['Store.At.POIPath.AppendString=', char(34), char(47), 'LoadPOI.Script', char(34), ';']}; ...
    {'Script.ExecuteNow =Store.StringAt.POIPath;'}; ...
    {['Store.FreeAt.POIPath= ', char(34), char(34), ';']}; ...
    {''}];

Fid=fopen([TempPlanDir, 'LoadAll.Script'], 'w');
for i=1:length(LoadAllCell)
    fprintf(Fid, '%s\n', LoadAllCell{i});
end
fclose(Fid);


%------------------------Write plan.roi from DICOM MRI----------------------------
function ROIName=WritePinPlanROIMRI(TempPlanDir, ROIDICOMInfo, ImageDCMInfo, hText, PlanID, DCM2PinnV9, CTDICOMInfo)

ImgSOPUID=[];
for i=1:length(CTDICOMInfo)
    ImgSOPUID=[ImgSOPUID; {CTDICOMInfo{i}.SOPInstanceUID}];
end

%Transform
TempSpacing=ImageDCMInfo.PixelSpacing;

% if isfield(ImageDCMInfo, 'PixelSpacing')
%     TempSpacing=ImageDCMInfo.PixelSpacing;
% else   
%      if isfield(ImageDCMInfo, 'ReconstructionDiameter')         
%          TempSpacing(1)=ImageDCMInfo.ReconstructionDiameter/ImageDCMInfo.Width;
%          TempSpacing(2)=ImageDCMInfo.ReconstructionDiameter/ImageDCMInfo.Height;         
%      end
% end

XPixDim=TempSpacing(1)/10;
YPixDim=TempSpacing(2)/10;
TempPos=ImageDCMInfo.ImagePositionPatient(1:2)/10;


%NameStr
NameStr=GetNameStr(ImageDCMInfo);

if  isfield(ImageDCMInfo, 'SeriesDescription')
    SeriesStr=ImageDCMInfo.SeriesDescription;
    NameStr=GetNameStrWitherSeriesStr(NameStr, SeriesStr);
end

%ROIName 
ROIName=[]; 
if isfield(ROIDICOMInfo, 'StructureSetROISequence')
    for i=1:length(fieldnames(ROIDICOMInfo.StructureSetROISequence))
        FieldName=['Item_', num2str(i)];       
        ROIName=[ROIName; {ROIDICOMInfo.StructureSetROISequence.(FieldName).ROIName}];        
    end
end

%No ROI
if isempty(ROIName)
    return;
end

%Write DICOMInfo XML
TempIndex=strfind(TempPlanDir, '\');
DICOMInfoPath=[TempPlanDir(1:TempIndex(end-1)), 'DICOMInfo'];
if ~exist(DICOMInfoPath, 'dir')
    mkdir(DICOMInfoPath);
end

[MFilePath, MFileName]=fileparts(mfilename('fullpath'));
TempIndex=strfind(MFilePath, '\');

ExePath=[MFilePath(1:TempIndex(end-2)), 'Utils\dcm2xml'];
ExeStr=[ExePath, ' "', ROIDICOMInfo.Filename, '" "',  DICOMInfoPath, '\Plan_', num2str(PlanID) , 'RS.xml', '"'];
copyfile(ROIDICOMInfo.Filename, [DICOMInfoPath, '\Plan_', num2str(PlanID) , 'RS.dcm'], 'f');

[DosStatus, DosResult] = dos(ExeStr);

%Start writing
set(hText, 'String', ['Creating plan.roi for Plan_', num2str(PlanID), ' ...']);
drawnow;

FinalFileHead={
    '// Region of Interest file';  ...
    ['// Data set: ', NameStr]; ...
    ['// File created: ', datestr(now, 0)];  ...
    ' ';  ...
    '//';...
    '// Pinnacle Treatment Planning System Version 7.6c'; ...
    '// 7.6c '; ...
    '//'};


%Template ROI head
ModelROIStart={
    '//-----------------------------------------------------';...
    '//  Beginning of ROI: RT Parotid';...
    '//-----------------------------------------------------';...
    ' ';...
    'roi={';...
    'name: RT Parotid';...
    ['volume_name: ', NameStr];...
    ['stats_volume_name: ', NameStr];...
    'flags =          131088;';...
    'color:           forest';...
    'box_size =       5;';...
    'line_2d_width =  1;';...
    'line_3d_width =  1;';...
    'paint_brush_radius =  0.4;';...
    'paint_allow_curve_closing = 1;';...
    'lower =          800;';...
    'upper =          4096;';...
    'radius =         0;';...
    'density =        1;';...
    'density_units:   g/cm^3';...
    'override_data =  0;';...
    'invert_density_loading =  0;';...
    'volume =         0;';...
    'pixel_min =      0;';...
    'pixel_max =      0;';...
    'pixel_mean =     0;';...
    'pixel_std =      0;';...
    'num_curve = 18;'...
    };

ModelROIEnd={'}; // End of ROI RT Parotid'};

ModelCurveStart={
    '//----------------------------------------------------';...
    '//  ROI: GTV primary 0';...
    '//  Curve 1 of 16';...
    '//----------------------------------------------------';...
    'curve={';...
    'flags =       16908308;';...
    'block_size =  64;';...
    'num_points =  77;';...
    'points={';...
    };

ModelCurveEnd={
    '};  // End of points for curve 1';...
    '}; // End of curve 1';...
    };

ColorList={'lightorange'; 'red'; 'green'; 'blue'; 'yellow'; 'purple'; 'skyblue'; 'maroon'; 'orange'; 'forest'; 'slateblue'; 'lightblue'; 'yellowgreen'};

PinColor={'red'; 'green'; 'blue'; 'yellow'; 'purple'; 'skyblue'; 'lavender'; 'orange'; 'forest'; 'slateblue';  'lightblue'; 'yellowgreen'; 'lightorange'; ...
    'grey'; 'khaki'; 'aquamarine'; 'teal'; 'steelblue'; 'brown';  'olive'; 'tomato'; 'seashell'; 'maroon'; 'greyscale'; 'Thermal'; 'skin'; ...
    'Smart'; 'Fusion_Red'; 'Thermal'; 'SUV2'; 'SUV3'; 'CEqual'; 'rainbow1'; 'rainbow2'; 'GEM'; 'spectrum'};

WindowColor=[255,0,0; 0,255,0; 0,0, 255; 255,255,0; 255,0,255; 0,255,255; 200,180,255; 255,149,0; 34,139,34; 128,0,255; 0,128,255; 192,255,0; 255,192,0; ...
    192,192,192; 240,230,140; 128,255,212; 0,160,160; 70,130,180; 165,80,55; 165,161,55; 255,83,76; 255,228,196; 180,30,30; 255,255,255; 0,0,0; 255,200,150; ...
    255,255,255; 255,0,0; 0,0,0; 255,255,255; 255,255,255; 0,0,0; 136,0, 121; 64,0,128; 0,32,64; 0,0,0]/255;

%Write curve cooridate for each organ
ROIFileMiddle=[];
RowNum=length(ROIName);

XStartFirst=CTDICOMInfo{1}.ImagePositionPatient(1);
YStartFirst=CTDICOMInfo{1}.ImagePositionPatient(2);

for i=1:RowNum
    %Set Status
    set(hText, 'String', ['Generating ', ROIName{i}, ' in plan.roi for Plan_', num2str(PlanID), ' ...']);
    drawnow;
    
    %ROI Start&End template
    TempROIStart=ModelROIStart;
    TempROIStart{2}=['//  Beginning of ROI: ', ROIName{i}];
    TempROIStart{6}=['name: ',  ROIName{i}];
    
    FieldName=['Item_', num2str(i)];    
    
    try
        if isfield(ROIDICOMInfo.ROIContourSequence.(FieldName), 'ROIDisplayColor')
            ROIColor=ROIDICOMInfo.ROIContourSequence.(FieldName).ROIDisplayColor'/255;
            
            TempV=sum(ROIColor.^2);
            if TempV < 1E-04
                ROIColor=[0, 1,1 ];
            end
        else
            ROIColor=[1, 0, 0];
        end
    catch
        ROIColor=[1, 0, 0];
    end
    
    TempColor=repmat(ROIColor, [length(WindowColor), 1])-WindowColor;
    TempColor=sum(TempColor.*TempColor, 2);
    [TempMin, TempIndex]=min(TempColor);

    TempROIStart{10}=['color:           ', PinColor{TempIndex}];      
    
    try
        if isfield(ROIDICOMInfo.ROIContourSequence.(FieldName), 'ContourSequence')
            ROICurveNum=length(fieldnames(ROIDICOMInfo.ROIContourSequence.(FieldName).ContourSequence));
        else
            continue;
        end
    catch
        continue;
    end
    TempROIStart{end}=['num_curve = ', num2str(ROICurveNum), ';'];    
    
    TempROIEnd=ModelROIEnd;
    TempROIEnd{1}=['}; // End of ROI ', ROIName{i}];

    %Curve Start&End template
    TempCurveStart=ModelCurveStart;
    TempCurveStart{2}=['//  ROI: ', ROIName{i}];
    
    TempCurveEnd=[{'};  // End of points for curve 1'}; {'}; // End of curve 1'}];

    %Write Curve points
    TempROISection=[];
    for jj=1:ROICurveNum
        SubFieldName=['Item_', num2str(jj)]; 
        
        TempCurveStart(3)=cellstr(['//  Curve ', num2str(jj), ' of ', num2str(ROICurveNum)]);
        
        %CurvePoints        
        TempData=ROIDICOMInfo.ROIContourSequence.(FieldName).ContourSequence.(SubFieldName).ContourData;
        TempImgSOPUID=ROIDICOMInfo.ROIContourSequence.(FieldName).ContourSequence.(SubFieldName).ContourImageSequence.Item_1.ReferencedSOPInstanceUID;
        
        ImageIndex=strmatch(TempImgSOPUID, ImgSOPUID, 'exact');
        ImageDCMInfoC=CTDICOMInfo{ImageIndex};
        
        %Bettinelli
        ImageDCMInfoC.ImagePositionPatient;
        
        SX=ImageDCMInfoC.ImagePositionPatient(1);
        SY=ImageDCMInfoC.ImagePositionPatient(2);
        SZ=ImageDCMInfoC.ImagePositionPatient(3);
        
        DeltaI=ImageDCMInfoC.PixelSpacing(1);
        DeltaJ=ImageDCMInfoC.PixelSpacing(2);
        
        Xx=ImageDCMInfoC.ImageOrientationPatient(1);
        Xy=ImageDCMInfoC.ImageOrientationPatient(2);
        Xz=ImageDCMInfoC.ImageOrientationPatient(3);
        
        Yx=ImageDCMInfoC.ImageOrientationPatient(4);
        Yy=ImageDCMInfoC.ImageOrientationPatient(5);
        Yz=ImageDCMInfoC.ImageOrientationPatient(6);
        
        A1=Xx*DeltaI;
        A2=Xy*DeltaI;
        B1=Yx*DeltaJ;
        B2=Yy*DeltaJ;
        
        %OrientMatrix=[Xx, Xy, Xz, 0; DeltaI, DeltaI, DeltaI, 0; Yx, Yy, Yz, 0; DeltaJ, DeltaJ, DeltaJ, 0; 0,0,0,0; SX, SY, SZ, 1]';
        OrientMatrix=[Xx*DeltaI, Xy*DeltaI, Xz*DeltaI, 0;Yx*DeltaJ, Yy*DeltaJ, Yz*DeltaJ, 0; 0,0,0,0; SX, SY, SZ, 1]';
        
        
        if ~isnumeric(TempData)
            TempData=[];
            
            try
                if isstruct(TempData)
                    FieldNames=fieldnames(TempData);
                    if length(FieldNames) == 1
                        TempData=str2num(char({TempData.(FieldNames{1})}'));
                    end
                end
            catch
                  TempData=[];            
            end
        end
                     
               
        TempData=reshape(TempData, 3, [])';
        
        PX=TempData(:, 1);
        PY=TempData(:, 2);
        
        II=(B2*(PX-SX)-B1*(PY-SY))/(B2*A1-B1*A2);
        JJ=(A2*(PX-SX)-A1*(PY-SY))/(A2*B1-A1*B2);
    
        %          CX=SX+(II-1)*DeltaJ;
        %         CY=SY+(JJ-1)*DeltaI;
        
        CX=SX+II*DeltaJ+(ImageDCMInfoC.ImagePositionPatient(1)-XStartFirst);
        CY=SY+JJ*DeltaI-(ImageDCMInfoC.ImagePositionPatient(2)-YStartFirst);        
        
        CZ=ImageDCMInfoC.SliceLocation*ones(length(II), 1);
        
        TempData=[CX, CY, CZ]/10;
        
        TempPoint=ROIDICOMInfo.ROIContourSequence.(FieldName).ContourSequence.(SubFieldName).NumberOfContourPoints;
        TempCurveStart(8)=cellstr(['num_points = ', num2str(TempPoint), ';']);                  

        TempCurveEnd(1)={['};  // End of points for curve ', num2str(jj)]};
        TempCurveEnd(2)={['}; // End of curve ', num2str(jj)]};

        TempZLocation=TempData(:, 3);       

        %Before 09/19/2009
%         TempData(:,1)=TempData(:,1)+XPixDim/2;
%         TempData(:,2)=2*TempPos(2)-TempData(:,2);
%         TempData(:, 3)=-TempData(:, 3);       
       
        %Changed on 03/25/2010
        HalfPixelOffset=1;        
        
        if DCM2PinnV9 < 1
            if HalfPixelOffset > 0
                %TempData(:,1)=TempData(:,1)+XPixDim/2;
                %TempData(:,2)=2*TempPos(2)-TempData(:,2)-YPixDim/2;
                TempData(:,1)=TempData(:,1);
                TempData(:,2)=2*TempPos(2)-TempData(:,2)-YPixDim;                
                TempData(:, 3)=-TempData(:, 3);
            else
                TempData(:,1)=TempData(:,1);
                TempData(:,2)=2*TempPos(2)-TempData(:,2);
                TempData(:, 3)=-TempData(:, 3);
            end
        else
            TempData(:,1)=TempData(:,1);
            TempData(:,2)=-TempData(:,2);
            TempData(:, 3)=-TempData(:, 3);
        end

        TempCurvePoint=cellstr(num2str(TempData, 10)); %Bettinelli '%.10f'

        TempROISection=[TempROISection; TempCurveStart; TempCurvePoint; TempCurveEnd];
    end

    %Store
    ROIFileMiddle=[ROIFileMiddle; TempROIStart; TempROISection; TempROIEnd];
end

FinalFile=[FinalFileHead; ROIFileMiddle];


%Update status
set(hText, 'String', ['Writing plan.roi for Plan_', num2str(PlanID), ' ....']);
drawnow;

Fid=fopen([TempPlanDir, 'plan.roi'], 'w');
for i=1:length(FinalFile)
    fprintf(Fid, '%s\n', FinalFile{i});
end
fclose(Fid);

%Generate the script
set(hText, 'String', ['Writing LoadROI script for Plan_', num2str(PlanID), ' ....']);
drawnow;

LoadROI={['Store.At.ScriptPath=SimpleString{};']; ...
    ['Store.At.ScriptPath.AppendString=Script .ScriptList .Directory;']; ...
    [' '];
    ['RoiImportFileList.Directory = Store.StringAt.ScriptPath;']; ...
    ['RoiImportFileList.File = ', char(34), 'plan.roi', char(34) ';'];...
    ['ImportRoi = ', char(34), 'OK', char(34), ';'];...
    [' '];    
    ['Store.FreeAt.ScriptPath= ', char(34), char(34), ';']};

Fid=fopen([TempPlanDir, 'LoadROI.Script'], 'w');
for i=1:length(LoadROI)
    fprintf(Fid, '%s\n', LoadROI{i});
end
fclose(Fid);

%LoadAll.Script
if exist([TempPlanDir, 'LoadAll.Script'])
    LoadAllCell=textread([TempPlanDir, 'LoadAll.Script'], '%s', 'delimiter', '\n');
    
else
    LoadAllCell={'Store.At.ScriptPath=SimpleString{};'; ...
        'Store.At.ScriptPath.AppendString=Script .ScriptList .Directory;'; ...
        ''};    
end

LoadAllCell=[LoadAllCell; ...
    {'Store.At.ROIPath=SimpleString{};'}; ...
    {'Store.At.ROIPath.AppendString=Script .ScriptList .Directory;'};...
    {['Store.At.ROIPath.AppendString=', char(34), char(47), 'LoadROI.Script', char(34), ';']}; ...
    {'Script.ExecuteNow =Store.StringAt.ROIPath;'}; ...
    {['Store.FreeAt.ROIPath= ', char(34), char(34), ';']}; ...
    {''}];

Fid=fopen([TempPlanDir, 'LoadAll.Script'], 'w');
for i=1:length(LoadAllCell)
    fprintf(Fid, '%s\n', LoadAllCell{i});
end
fclose(Fid);


%------------------------Write plan.roi from DICOM----------------------------
function ROIName=WritePinPlanROI(TempPlanDir, ROIDICOMInfo, ImageDCMInfo, hText, PlanID, DCM2PinnV9)
%Transform
TempSpacing=ImageDCMInfo.PixelSpacing;

% if isfield(ImageDCMInfo, 'PixelSpacing')
%     TempSpacing=ImageDCMInfo.PixelSpacing;
% else   
%      if isfield(ImageDCMInfo, 'ReconstructionDiameter')         
%          TempSpacing(1)=ImageDCMInfo.ReconstructionDiameter/ImageDCMInfo.Width;
%          TempSpacing(2)=ImageDCMInfo.ReconstructionDiameter/ImageDCMInfo.Height;         
%      end
% end

XPixDim=TempSpacing(1)/10;
YPixDim=TempSpacing(2)/10;
TempPos=ImageDCMInfo.ImagePositionPatient(1:2)/10;


%NameStr
NameStr=GetNameStr(ImageDCMInfo);

if  isfield(ImageDCMInfo, 'SeriesDescription')
    SeriesStr=ImageDCMInfo.SeriesDescription;
    NameStr=GetNameStrWitherSeriesStr(NameStr, SeriesStr);
end

%ROIName 
ROIName=[]; 
if isfield(ROIDICOMInfo, 'StructureSetROISequence')
    for i=1:length(fieldnames(ROIDICOMInfo.StructureSetROISequence))
        FieldName=['Item_', num2str(i)];       
        ROIName=[ROIName; {ROIDICOMInfo.StructureSetROISequence.(FieldName).ROIName}];        
    end
end

%No ROI
if isempty(ROIName)
    return;
end

%Write DICOMInfo XML
TempIndex=strfind(TempPlanDir, '\');
DICOMInfoPath=[TempPlanDir(1:TempIndex(end-1)), 'DICOMInfo'];
if ~exist(DICOMInfoPath, 'dir')
    mkdir(DICOMInfoPath);
end

[MFilePath, MFileName]=fileparts(mfilename('fullpath'));
TempIndex=strfind(MFilePath, '\');

ExePath=[MFilePath(1:TempIndex(end-2)), 'Utils\dcm2xml'];
ExeStr=[ExePath, ' "', ROIDICOMInfo.Filename, '" "',  DICOMInfoPath, '\Plan_', num2str(PlanID) , 'RS.xml', '"'];
copyfile(ROIDICOMInfo.Filename, [DICOMInfoPath, '\Plan_', num2str(PlanID) , 'RS.dcm'], 'f');

[DosStatus, DosResult] = dos(ExeStr);

%Start writing
set(hText, 'String', ['Creating plan.roi for Plan_', num2str(PlanID), ' ...']);
drawnow;

FinalFileHead={
    '// Region of Interest file';  ...
    ['// Data set: ', NameStr]; ...
    ['// File created: ', datestr(now, 0)];  ...
    ' ';  ...
    '//';...
    '// Pinnacle Treatment Planning System Version 7.6c'; ...
    '// 7.6c '; ...
    '//'};


%Template ROI head
ModelROIStart={
    '//-----------------------------------------------------';...
    '//  Beginning of ROI: RT Parotid';...
    '//-----------------------------------------------------';...
    ' ';...
    'roi={';...
    'name: RT Parotid';...
    ['volume_name: ', NameStr];...
    ['stats_volume_name: ', NameStr];...
    'flags =          131088;';...
    'color:           forest';...
    'box_size =       5;';...
    'line_2d_width =  1;';...
    'line_3d_width =  1;';...
    'paint_brush_radius =  0.4;';...
    'paint_allow_curve_closing = 1;';...
    'lower =          800;';...
    'upper =          4096;';...
    'radius =         0;';...
    'density =        1;';...
    'density_units:   g/cm^3';...
    'override_data =  0;';...
    'invert_density_loading =  0;';...
    'volume =         0;';...
    'pixel_min =      0;';...
    'pixel_max =      0;';...
    'pixel_mean =     0;';...
    'pixel_std =      0;';...
    'num_curve = 18;'...
    };

ModelROIEnd={'}; // End of ROI RT Parotid'};

ModelCurveStart={
    '//----------------------------------------------------';...
    '//  ROI: GTV primary 0';...
    '//  Curve 1 of 16';...
    '//----------------------------------------------------';...
    'curve={';...
    'flags =       16908308;';...
    'block_size =  64;';...
    'num_points =  77;';...
    'points={';...
    };

ModelCurveEnd={
    '};  // End of points for curve 1';...
    '}; // End of curve 1';...
    };

ColorList={'lightorange'; 'red'; 'green'; 'blue'; 'yellow'; 'purple'; 'skyblue'; 'maroon'; 'orange'; 'forest'; 'slateblue'; 'lightblue'; 'yellowgreen'};

PinColor={'red'; 'green'; 'blue'; 'yellow'; 'purple'; 'skyblue'; 'lavender'; 'orange'; 'forest'; 'slateblue';  'lightblue'; 'yellowgreen'; 'lightorange'; ...
    'grey'; 'khaki'; 'aquamarine'; 'teal'; 'steelblue'; 'brown';  'olive'; 'tomato'; 'seashell'; 'maroon'; 'greyscale'; 'Thermal'; 'skin'; ...
    'Smart'; 'Fusion_Red'; 'Thermal'; 'SUV2'; 'SUV3'; 'CEqual'; 'rainbow1'; 'rainbow2'; 'GEM'; 'spectrum'};

WindowColor=[255,0,0; 0,255,0; 0,0, 255; 255,255,0; 255,0,255; 0,255,255; 200,180,255; 255,149,0; 34,139,34; 128,0,255; 0,128,255; 192,255,0; 255,192,0; ...
    192,192,192; 240,230,140; 128,255,212; 0,160,160; 70,130,180; 165,80,55; 165,161,55; 255,83,76; 255,228,196; 180,30,30; 255,255,255; 0,0,0; 255,200,150; ...
    255,255,255; 255,0,0; 0,0,0; 255,255,255; 255,255,255; 0,0,0; 136,0, 121; 64,0,128; 0,32,64; 0,0,0]/255;

%Write curve cooridate for each organ
ROIFileMiddle=[];
RowNum=length(ROIName);

for i=1:RowNum
    %Set Status
    set(hText, 'String', ['Generating ', ROIName{i}, ' in plan.roi for Plan_', num2str(PlanID), ' ...']);
    drawnow;
    
    %ROI Start&End template
    TempROIStart=ModelROIStart;
    TempROIStart{2}=['//  Beginning of ROI: ', ROIName{i}];
    TempROIStart{6}=['name: ',  ROIName{i}];
    
    FieldName=['Item_', num2str(i)];    

    try
        if isfield(ROIDICOMInfo.ROIContourSequence.(FieldName), 'ROIDisplayColor')
            ROIColor=ROIDICOMInfo.ROIContourSequence.(FieldName).ROIDisplayColor'/255;
            
            TempV=sum(ROIColor.^2);
            if TempV < 1E-04
                ROIColor=[0, 1,1 ];
            end
        else
            ROIColor=[1, 0, 0];
        end
    catch
        ROIColor=[1, 0, 0];
    end
    
    TempColor=repmat(ROIColor, [length(WindowColor), 1])-WindowColor;
    TempColor=sum(TempColor.*TempColor, 2);
    [TempMin, TempIndex]=min(TempColor);

    TempROIStart{10}=['color:           ', PinColor{TempIndex}];      
    
    try
        if isfield(ROIDICOMInfo.ROIContourSequence.(FieldName), 'ContourSequence')
            ROICurveNum=length(fieldnames(ROIDICOMInfo.ROIContourSequence.(FieldName).ContourSequence));
        else
            continue;
        end
    catch
        continue;
    end
    TempROIStart{end}=['num_curve = ', num2str(ROICurveNum), ';'];    
    
    TempROIEnd=ModelROIEnd;
    TempROIEnd{1}=['}; // End of ROI ', ROIName{i}];

    %Curve Start&End template
    TempCurveStart=ModelCurveStart;
    TempCurveStart{2}=['//  ROI: ', ROIName{i}];
    
    TempCurveEnd=[{'};  // End of points for curve 1'}; {'}; // End of curve 1'}];

    %Write Curve points
    TempROISection=[];
    for jj=1:ROICurveNum
        SubFieldName=['Item_', num2str(jj)]; 
        
        TempCurveStart(3)=cellstr(['//  Curve ', num2str(jj), ' of ', num2str(ROICurveNum)]);
        
        %CurvePoints        
        TempData=ROIDICOMInfo.ROIContourSequence.(FieldName).ContourSequence.(SubFieldName).ContourData;
        
        if ~isnumeric(TempData)
            TempData=[];
            
            try
                if isstruct(TempData)
                    FieldNames=fieldnames(TempData);
                    if length(FieldNames) == 1
                        TempData=str2num(char({TempData.(FieldNames{1})}'));
                    end
                end
            catch
                  TempData=[];            
            end
        end
        
        TempData=reshape(TempData, 3, [])'/10;
        
        TempPoint=ROIDICOMInfo.ROIContourSequence.(FieldName).ContourSequence.(SubFieldName).NumberOfContourPoints;
        TempCurveStart(8)=cellstr(['num_points = ', num2str(TempPoint), ';']);
        
%         %Close Curve or not
%         if isequal(ROIDICOMInfo.ROIContourSequence.(FieldName).ContourSequence.(SubFieldName).ContourGeometricType, 'CLOSED_PLANAR')
%             TTBB=TempData(1, :)-TempData(end, :);
%             TTBB=abs(TTBB(1).*TTBB(1)+TTBB(2).*TTBB(2)+TTBB(3).*TTBB(3))
%             
%             if TTBB <= 1E-04
%                 TempPoint=ROIDICOMInfo.ROIContourSequence.(FieldName).ContourSequence.(SubFieldName).NumberOfContourPoints;                
%             else
%                 TempData(end+1, :)=TempData(1, :);
%                 TempPoint=ROIDICOMInfo.ROIContourSequence.(FieldName).ContourSequence.(SubFieldName).NumberOfContourPoints+1;
%             end
%             
%             TempCurveStart(8)=cellstr(['num_points = ', num2str(TempPoint), ';']);
%         else
%             TempPoint=ROIDICOMInfo.ROIContourSequence.(FieldName).ContourSequence.(SubFieldName).NumberOfContourPoints;
%             TempCurveStart(8)=cellstr(['num_points = ', num2str(TempPoint), ';']);
%         end              

        TempCurveEnd(1)={['};  // End of points for curve ', num2str(jj)]};
        TempCurveEnd(2)={['}; // End of curve ', num2str(jj)]};

        TempZLocation=TempData(:, 3);       

        %Before 09/19/2009
%         TempData(:,1)=TempData(:,1)+XPixDim/2;
%         TempData(:,2)=2*TempPos(2)-TempData(:,2);
%         TempData(:, 3)=-TempData(:, 3);       
       
        %Changed on 03/25/2010
        HalfPixelOffset=1;        
        
        if DCM2PinnV9 < 1
            if HalfPixelOffset > 0
                %TempData(:,1)=TempData(:,1)+XPixDim/2;
                %TempData(:,2)=2*TempPos(2)-TempData(:,2)-YPixDim/2;
                TempData(:,1)=TempData(:,1);
                TempData(:,2)=2*TempPos(2)-TempData(:,2)-YPixDim;                
                TempData(:, 3)=-TempData(:, 3);
            else
                TempData(:,1)=TempData(:,1);
                TempData(:,2)=2*TempPos(2)-TempData(:,2);
                TempData(:, 3)=-TempData(:, 3);
            end
        else
            TempData(:,1)=TempData(:,1);
            TempData(:,2)=-TempData(:,2);
            TempData(:, 3)=-TempData(:, 3);
        end

        TempCurvePoint=cellstr(num2str(TempData), 10); %Bettinelli '%.10f'

        TempROISection=[TempROISection; TempCurveStart; TempCurvePoint; TempCurveEnd];
    end

    %Store
    ROIFileMiddle=[ROIFileMiddle; TempROIStart; TempROISection; TempROIEnd];
end

FinalFile=[FinalFileHead; ROIFileMiddle];


%Update status
set(hText, 'String', ['Writing plan.roi for Plan_', num2str(PlanID), ' ....']);
drawnow;

Fid=fopen([TempPlanDir, 'plan.roi'], 'w');
for i=1:length(FinalFile)
    fprintf(Fid, '%s\n', FinalFile{i});
end
fclose(Fid);

%Generate the script
set(hText, 'String', ['Writing LoadROI script for Plan_', num2str(PlanID), ' ....']);
drawnow;

LoadROI={['Store.At.ScriptPath=SimpleString{};']; ...
    ['Store.At.ScriptPath.AppendString=Script .ScriptList .Directory;']; ...
    [' '];
    ['RoiImportFileList.Directory = Store.StringAt.ScriptPath;']; ...
    ['RoiImportFileList.File = ', char(34), 'plan.roi', char(34) ';'];...
    ['ImportRoi = ', char(34), 'OK', char(34), ';'];...
    [' '];    
    ['Store.FreeAt.ScriptPath= ', char(34), char(34), ';']};

Fid=fopen([TempPlanDir, 'LoadROI.Script'], 'w');
for i=1:length(LoadROI)
    fprintf(Fid, '%s\n', LoadROI{i});
end
fclose(Fid);

%LoadAll.Script
if exist([TempPlanDir, 'LoadAll.Script'])
    LoadAllCell=textread([TempPlanDir, 'LoadAll.Script'], '%s', 'delimiter', '\n');
    
else
    LoadAllCell={'Store.At.ScriptPath=SimpleString{};'; ...
        'Store.At.ScriptPath.AppendString=Script .ScriptList .Directory;'; ...
        ''};    
end

LoadAllCell=[LoadAllCell; ...
    {'Store.At.ROIPath=SimpleString{};'}; ...
    {'Store.At.ROIPath.AppendString=Script .ScriptList .Directory;'};...
    {['Store.At.ROIPath.AppendString=', char(34), char(47), 'LoadROI.Script', char(34), ';']}; ...
    {'Script.ExecuteNow =Store.StringAt.ROIPath;'}; ...
    {['Store.FreeAt.ROIPath= ', char(34), char(34), ';']}; ...
    {''}];

Fid=fopen([TempPlanDir, 'LoadAll.Script'], 'w');
for i=1:length(LoadAllCell)
    fprintf(Fid, '%s\n', LoadAllCell{i});
end
fclose(Fid);

%----------------------Generate plan string------------------------------
function PlanStr=GeneratePlanStr(PlanID, PrimaryImageSetID, DCMPlanInfo)
PlanName='';
if isfield(DCMPlanInfo, 'RTPlanLabel')
    PlanName=DCMPlanInfo.RTPlanLabel;
end

if isequal(PlanName, '')
    PlanName=['Plan_', num2str(PlanID)];
end

TempStr1=[]; TempStr2=[];
if isfield(DCMPlanInfo, 'InstanceCreationDate') && isfield(DCMPlanInfo, 'InstanceCreationTime')
    TempStr1=DCMPlanInfo.InstanceCreationDate;
    TempStr2=DCMPlanInfo.InstanceCreationTime;
    
    if isempty(TempStr1)
        if isfield(DCMPlanInfo, 'RTPlanDate') && isfield(DCMPlanInfo, 'RTPlanTime')
            TempStr1=DCMPlanInfo.RTPlanDate;
            TempStr2=DCMPlanInfo.RTPlanTime;
        end
    end

    if ~isempty(TempStr1) && ~isempty(TempStr2)
        TimeStr=[TempStr1, ' ', TempStr2];        
    else
        TimeStr=' ';
    end   
    
else
    if isfield(CTInfo, 'RTPlanDate') && isfield(CTInfo, 'RTPlanTime')
        TempStr1=CTInfo.RTPlanDate;
        TempStr2=CTInfo.RTPlanTime;    

        if ~isempty(TempStr1) && ~isempty(TempStr2)
            TimeStr=[TempStr1, ' ', TempStr2];
        else
            TimeStr=' ';
        end
    else
        TimeStr=' ';
    end
end

PlanStr={...
    'Plan ={'; ...
    ['PlanID = ', num2str(PlanID), ';']; ...
    'ToolType = "Pinnacle^3";'; ...
    ['PlanName = "', PlanName, '";']; ...
    'Physicist = "";'; ...
    'Comment = "";'; ...
    'Dosimetrist = "";'; ...
    ['PrimaryCTImageSetID = ', num2str(PrimaryImageSetID), ';'];...
    'FusionIDArray ={'; ...
    '};'; ...
    'PrimaryImageType = "Images";'; ...
    'PinnacleVersionDescription = "Pinnacle 7.6c";'; ...
    'IsNewPlanPrefix = 1;';...
    'PlanIsLocked = 1;';...
    'OKForSyntegraInLaunchpad = 0;';...
    'ObjectVersion ={';...
    'WriteVersion = "Launch Pad: 3.4b";';...
    'CreateVersion = "Launch Pad: 3.4b";';...
    'LoginName = "p3rtp";';...
    ['CreateTimeStamp = "', TimeStr, '";'];...
    ['WriteTimeStamp = "', TimeStr, '";'];...
    'LastModifiedTimeStamp = "";'; ...
    '};';...
    '};'};

%-----------------------Generate Fake plan string-------------------------
function PlanStr=GenerateFakePlanStr(PlanID, PrimaryImageSetID)
PlanStr={
    'Plan ={'; ...
    ['PlanID = ', num2str(PlanID), ';']; ...
    'ToolType = "Pinnacle^3";'; ...
    ['PlanName = "', 'FakePlan', '";']; ...
    'Physicist = "";'; ...
    'Comment = "";'; ...
    'Dosimetrist = "";'; ...
    ['PrimaryCTImageSetID = ', num2str(PrimaryImageSetID), ';'];...
    'FusionIDArray ={'; ...
    '};'; ...
    'PrimaryImageType = "Images";'; ...
    'PinnacleVersionDescription = "Pinnacle 7.6c";'; ...
    'IsNewPlanPrefix = 1;';...
    'PlanIsLocked = 1;';...
    'OKForSyntegraInLaunchpad = 0;';...
    'ObjectVersion ={';...
    'WriteVersion = "Launch Pad: 3.4b";';...
    'CreateVersion = "Launch Pad: 3.4b";';...
    'LoginName = "p3rtp";';...
    ['CreateTimeStamp = "', datestr(now, 31), '";'];...
    ['WriteTimeStamp = "', datestr(now, 31), '";'];...
    'LastModifiedTimeStamp = "";'; ...
    '};';...
    '};'};



%-------------------------------Generate patient file-----------------------------------
function WritePatPlanTrial(FileDir, hText)
%Templdate
TemplatePlanTrial='TemplatePlan.Trial';
TrailInfo=textread(TemplatePlanTrial, '%s', 'delimiter', '\n');

%Plan Directory
DirList=GetDirList(FileDir);
PlanIndex=strmatch('Plan', DirList);

for i=1:length(PlanIndex)
    CurrentPlanDir=[FileDir, '\', DirList{PlanIndex(i)}, '\'];
    
    DoseScriptFile=[CurrentPlanDir, '\LoadDoseTotal_0.Script'];
    
    if exist(DoseScriptFile, 'file')
        set(hText, 'String', ['Writing Plan.Trial file for ', DirList{PlanIndex(i)}, ' ...']);
        
        PlanTrialCell=TrailInfo;
        
        ScriptInfo=textread(DoseScriptFile, '%s', 'delimiter', '\n');
        
        TempIndex=strmatch('TrialList .Current .DoseGrid .VoxelSize .X ', ScriptInfo);
        eval(ScriptInfo{TempIndex});
        TempIndex=strmatch('TrialList .Current .DoseGrid .VoxelSize .Y ', ScriptInfo);
        eval(ScriptInfo{TempIndex});
        TempIndex=strmatch('TrialList .Current .DoseGrid .VoxelSize .Z ', ScriptInfo);
        eval(ScriptInfo{TempIndex});
        
        TempIndex=strmatch('TrialList .Current .DoseGrid .Dimension .X ', ScriptInfo);
        eval(ScriptInfo{TempIndex});
        TempIndex=strmatch('TrialList .Current .DoseGrid .Dimension .Y ', ScriptInfo);
        eval(ScriptInfo{TempIndex});
        TempIndex=strmatch('TrialList .Current .DoseGrid .Dimension .Z ', ScriptInfo);
        eval(ScriptInfo{TempIndex});
        
        TempIndex=strmatch('TrialList .Current .DoseGrid .Origin .X ', ScriptInfo);
        eval(ScriptInfo{TempIndex});
        TempIndex=strmatch('TrialList .Current .DoseGrid .Origin .Y ', ScriptInfo);
        eval(ScriptInfo{TempIndex});
        TempIndex=strmatch('TrialList .Current .DoseGrid .Origin .Z ', ScriptInfo);
        eval(ScriptInfo{TempIndex});               
        
        
       TempIndex=strmatch('DoseGrid .VoxelSize .X ', PlanTrialCell);
       PlanTrialCell{TempIndex}=['DoseGrid .VoxelSize .X = ', num2str(TrialList.Current.DoseGrid.VoxelSize.X), ';'];
       TempIndex=strmatch('DoseGrid .VoxelSize .Y ', PlanTrialCell);
       PlanTrialCell{TempIndex}=['DoseGrid .VoxelSize .Y = ', num2str(TrialList.Current.DoseGrid.VoxelSize.Y), ';'];       
       TempIndex=strmatch('DoseGrid .VoxelSize .Z ', PlanTrialCell);
       PlanTrialCell{TempIndex}=['DoseGrid .VoxelSize .Z = ', num2str(TrialList.Current.DoseGrid.VoxelSize.Z), ';'];
       TempIndex=strmatch('DoseGrid .Dimension .X ', PlanTrialCell);
       PlanTrialCell{TempIndex}=['DoseGrid .Dimension .X = ', num2str(TrialList.Current.DoseGrid.Dimension.X), ';'];
       TempIndex=strmatch('DoseGrid .Dimension .Y ', PlanTrialCell);
       PlanTrialCell{TempIndex}=['DoseGrid .Dimension .Y = ', num2str(TrialList.Current.DoseGrid.Dimension.Y), ';'];       
       TempIndex=strmatch('DoseGrid .Dimension .Z ', PlanTrialCell);
       PlanTrialCell{TempIndex}=['DoseGrid .Dimension .Z = ', num2str(TrialList.Current.DoseGrid.Dimension.Z), ';'];
       TempIndex=strmatch('DoseGrid .Origin .X ', PlanTrialCell);
       PlanTrialCell{TempIndex}=['DoseGrid .Origin .X = ', num2str(TrialList.Current.DoseGrid.Origin.X), ';'];
       TempIndex=strmatch('DoseGrid .Origin .Y ', PlanTrialCell);
       PlanTrialCell{TempIndex}=['DoseGrid .Origin .Y = ', num2str(TrialList.Current.DoseGrid.Origin.Y), ';'];       
       TempIndex=strmatch('DoseGrid .Origin .Z ', PlanTrialCell);
       PlanTrialCell{TempIndex}=['DoseGrid .Origin .Z = ', num2str(TrialList.Current.DoseGrid.Origin.Z), ';'];
       
       PlanTrialFile=[CurrentPlanDir, '\plan.Trial'];
       FID=fopen(PlanTrialFile, 'w');
       for j=1:length(PlanTrialCell)
           fprintf(FID, '%s\n', PlanTrialCell{j});
       end
       fclose(FID);
       
       copyfile([CurrentPlanDir, '\LoadDoseTotal_0.Script.binary.000'], [CurrentPlanDir, '\plan.Trial.binary.003']);        
    end
end

%Update status
set(hText, 'String', ['Writing Plan.Trial file...']);
drawnow;

function NameFromScanner=GetNameStrWitherSeriesStr(NameStr, SeriesStr)
try
    if ~isempty(strmatch('T=', SeriesStr))
        PercentIndex=strfind(SeriesStr, '%');  %4DCT case
        SeriesStr=SeriesStr(1:PercentIndex(1)-1);
        SeriesStr=SeriesStr(3:end);
        NameFromScanner=[NameStr(1:end-1), 'T=', SeriesStr];
    else
        [TFlag, SeriesStr]=Get4DPhase(SeriesStr);
        if TFlag > 0
            NameFromScanner=[NameStr(1:end-1), 'T=', SeriesStr];
        else
            if length(SeriesStr)> 4
                SeriesStr=SeriesStr(1:4);
            end
            NameFromScanner=[NameStr(1:end-1), SeriesStr];
        end
    end

catch
    if length(SeriesStr)> 4
        SeriesStr=SeriesStr(1:4);
    end
    NameFromScanner=[NameStr(1:end-1), SeriesStr];
end


function InfoList=GetDcmPatInfo(CTInfo, FileName)
    
%Get info on chosen item
if isequal(CTInfo.Modality, 'CT')
    InfoList={'[Basic]'; 'Modality: CT.'};
end

if isequal(CTInfo.Modality, 'MR')
    InfoList={'[Basic]'; 'Modality: MR.'};
end

if isequal(CTInfo.Modality, 'PT')
    InfoList={'[Basic]'; 'Modality: PT.'};
end

if ~isequal(CTInfo.Modality, 'CT') && ~isequal(CTInfo.Modality, 'MR') && ~isequal(CTInfo.Modality, 'PT')
    InfoList={'[Basic]'; 'Modality:  .'};
end


if isfield(CTInfo, 'PatientID')
    TempStr1=CTInfo.PatientID;
    InfoList=[InfoList; {['MRN: ', TempStr1, '.']}];
else
    InfoList=[InfoList; {['MRN: ', ' .']}];
end

if isfield(CTInfo, 'PatientName')
    TempName=[];
    Name=struct2cell(CTInfo.PatientName);
    for i=1:length(Name)
        TempName=[TempName, Name{i}, ' '];
    end
    InfoList=[InfoList; {['Name: ', TempName, '.']}];   
else
    InfoList=[InfoList; {['Name: ', ' .']}];    
end

TempStr1=[]; TempStr2=[];
if isfield(CTInfo, 'StudyDate') && isfield(CTInfo, 'StudyTime')
    TempStr1=CTInfo.StudyDate;
    TempStr2=CTInfo.StudyTime;
    
    if isempty(TempStr1)
        if isfield(CTInfo, 'InstanceCreationDate') && isfield(CTInfo, 'InstanceCreationTime')
            TempStr1=CTInfo.InstanceCreationDate;
            TempStr2=CTInfo.InstanceCreationTime;
        end
    end

    if ~isempty(TempStr1) && ~isempty(TempStr2)
        InfoList=[InfoList; {['Time: ', TempStr1, ' ', TempStr2, '.']}];        
    else
        InfoList=[InfoList; {['Time: ', ' .']}];
    end   
    
else
    if isfield(CTInfo, 'InstanceCreationDate') && isfield(CTInfo, 'InstanceCreationTime')
        TempStr1=CTInfo.InstanceCreationDate;
        TempStr2=CTInfo.InstanceCreationTime;

        if ~isempty(TempStr1) && ~isempty(TempStr2)
            InfoList=[InfoList; {['Time: ', TempStr1, ' ', TempStr2, '.']}];            
        else
            InfoList=[InfoList; {['Time: ', ' .']}];
        end       
        
    else
        InfoList=[InfoList; {['Time: ', ' .']}];
    end
end

InfoList=[InfoList; {['File: ', FileName, '.']}];

InfoList=[InfoList; {['    ']}; {'[Format]'}];
if isfield(CTInfo, 'PixelSpacing')
    TempStr=num2str(round(CTInfo.PixelSpacing(1)*double(CTInfo.Width)*100/10)/100);
    InfoList=[InfoList; {['XFOV: ', TempStr, 'cm.']}];
    
    TempStr=num2str(round(CTInfo.PixelSpacing(2)*double(CTInfo.Height)*100/10)/100);
    InfoList=[InfoList; {['YFOV: ', TempStr, 'cm.']}];
else
    InfoList=[InfoList; {['Pixel Size: ', ' cm.']}];
end

if isfield(CTInfo, 'Width')
    TempStr=num2str(CTInfo.Width);
    InfoList=[InfoList; {['XDim: ', TempStr, '.']}];
else
    InfoList=[InfoList; {['XDim: ', ' .']}];
end

if isfield(CTInfo, 'Height')
    TempStr=num2str(CTInfo.Height);
    InfoList=[InfoList; {['YDim: ', TempStr, '.']}];
else
    InfoList=[InfoList; {['YDim: ', ' .']}];
end    

InfoList=[InfoList; {['ZDim: ', ' .']}];

if isfield(CTInfo, 'SliceThickness')
    TempStr=num2str(CTInfo.SliceThickness,10);
    InfoList=[InfoList; {['Slice Thickness: ', TempStr, 'mm.']}];
else
    InfoList=[InfoList; {['Slice Thickness: ', ' mm.']}];
end


function InfoList=GetDcmPatInfoRS(CTInfo, FileName)
    
%Get info on chosen item
InfoList={'[Basic]'; 'Modality: RS.'};
if isfield(CTInfo, 'PatientID')
    TempStr1=CTInfo.PatientID;
    InfoList=[InfoList; {['MRN: ', TempStr1, '.']}];
else
    InfoList=[InfoList; {['MRN: ', ' .']}];
end

if isfield(CTInfo, 'PatientName')
    TempName=[];
    Name=struct2cell(CTInfo.PatientName);
    for i=1:length(Name)
        TempName=[TempName, Name{i}, ' '];
    end
    InfoList=[InfoList; {['Name: ', TempName, '.']}];   
else
    InfoList=[InfoList; {['Name: ', ' .']}];    
end

TempStr1=[]; TempStr2=[];
if isfield(CTInfo, 'InstanceCreationDate') && isfield(CTInfo, 'InstanceCreationTime')
    TempStr1=CTInfo.InstanceCreationDate;
    TempStr2=CTInfo.InstanceCreationTime;
    
    if isempty(TempStr1)
        if isfield(CTInfo, 'StructureSetDate') && isfield(CTInfo, 'StructureSetTime')
            TempStr1=CTInfo.StructureSetDate;
            TempStr2=CTInfo.StructureSetTime;
        end
    end

    if ~isempty(TempStr1) && ~isempty(TempStr2)
        InfoList=[InfoList; {['Time: ', TempStr1, ' ', TempStr2, '.']}];        
    else
        InfoList=[InfoList; {['Time: ', ' .']}];
    end   
    
else
    if isfield(CTInfo, 'StructureSetDate') && isfield(CTInfo, 'StructureSetTime')
        TempStr1=CTInfo.StructureSetDate;
        TempStr2=CTInfo.StructureSetTime;

        if ~isempty(TempStr1) && ~isempty(TempStr2)
            InfoList=[InfoList; {['Time: ', TempStr1, ' ', TempStr2, '.']}];            
        else
            InfoList=[InfoList; {['Time: ', ' .']}];
        end       
        
    else
        InfoList=[InfoList; {['Time: ', ' .']}];
    end
end

InfoList=[InfoList; {['File: ', FileName, '.']}];

InfoList=[InfoList; {['    ']}; {'[ROI]'}];

if isfield(CTInfo, 'StructureSetROISequence')
    TempStr={' '};
    for i=1:length(fieldnames(CTInfo.StructureSetROISequence))
        FieldName=['Item_', num2str(i)];
        if  i==1        
            TempStr={CTInfo.StructureSetROISequence.(FieldName).ROIName};
        else
            TempStr=[TempStr; {CTInfo.StructureSetROISequence.(FieldName).ROIName}];
        end
    end
    
    InfoList=[InfoList; TempStr];
else
    InfoList=[InfoList; {'    '}];
end

function InfoList=GetDcmPatInfoPlan(CTInfo, FileName)
    
%Get info on chosen item
InfoList={'[Basic]'; 'Modality: PLAN.'};
if isfield(CTInfo, 'PatientID')
    TempStr1=CTInfo.PatientID;
    InfoList=[InfoList; {['MRN: ', TempStr1, '.']}];
else
    InfoList=[InfoList; {['MRN: ', ' .']}];
end

if isfield(CTInfo, 'PatientName')
    TempName=[];
    Name=struct2cell(CTInfo.PatientName);
    for i=1:length(Name)
        TempName=[TempName, Name{i}, ' '];
    end
    InfoList=[InfoList; {['Name: ', TempName, '.']}];   
else
    InfoList=[InfoList; {['Name: ', ' .']}];    
end

TempStr1=[]; TempStr2=[];
if isfield(CTInfo, 'InstanceCreationDate') && isfield(CTInfo, 'InstanceCreationTime')
    TempStr1=CTInfo.InstanceCreationDate;
    TempStr2=CTInfo.InstanceCreationTime;
    
    if isempty(TempStr1)
        if isfield(CTInfo, 'RTPlanDate') && isfield(CTInfo, 'RTPlanTime')
            TempStr1=CTInfo.RTPlanDate;
            TempStr2=CTInfo.RTPlanTime;
        end
    end

    if ~isempty(TempStr1) && ~isempty(TempStr2)
        InfoList=[InfoList; {['Time: ', TempStr1, ' ', TempStr2, '.']}];        
    else
        InfoList=[InfoList; {['Time: ', ' .']}];
    end   
    
else
    if isfield(CTInfo, 'RTPlanDate') && isfield(CTInfo, 'RTPlanTime')
        TempStr1=CTInfo.RTPlanDate;
        TempStr2=CTInfo.RTPlanTime;

        if ~isempty(TempStr1) && ~isempty(TempStr2)
            InfoList=[InfoList; {['Time: ', TempStr1, ' ', TempStr2, '.']}];            
        else
            InfoList=[InfoList; {['Time: ', ' .']}];
        end       
        
    else
        InfoList=[InfoList; {['Time: ', ' .']}];
    end
end

InfoList=[InfoList; {['File: ', FileName, '.']}];

InfoList=[InfoList; {['    ']}; {'[Plan]'}];

if isfield(CTInfo, 'RTPlanLabel')
   InfoList=[InfoList; {['PlanName: ',  CTInfo.RTPlanLabel, '.']}];
else
    InfoList=[InfoList; {['    ']}];
end

if isfield(CTInfo, 'BeamSequence')    %Photon, Neutron
    InfoList=[InfoList; {['BeamNumber: ',  num2str(length(fieldnames(CTInfo.BeamSequence))) '.']}];
    
    for i=1:length(fieldnames(CTInfo.BeamSequence))
        FieldName=['Item_', num2str(i)];

        SubStr=[];
        if isfield(CTInfo.BeamSequence.(FieldName), 'BeamNumber')
            SubStr=[num2str(CTInfo.BeamSequence.(FieldName).BeamNumber), '. '];
        else
            SubStr=[' . ']
        end

        if isfield(CTInfo.BeamSequence.(FieldName), 'BeamName')
            SubStr=[SubStr, CTInfo.BeamSequence.(FieldName).BeamName, ', '];
        else
            SubStr=[' , ']
        end

        if isfield(CTInfo.BeamSequence.(FieldName), 'RadiationType')
            SubStr=[SubStr, CTInfo.BeamSequence.(FieldName).RadiationType, ', '];
        else
            SubStr=[' , ']
        end

        if isfield(CTInfo.BeamSequence.(FieldName), 'BeamType')
            SubStr=[SubStr, CTInfo.BeamSequence.(FieldName).BeamType, '.'];
        else
            SubStr=[' .']
        end

        InfoList=[InfoList; SubStr];
    end
else
    if isfield(CTInfo, 'IonBeamSequence')    %%Proton, Electron
        InfoList=[InfoList; {['BeamNumber: ',  num2str(length(fieldnames(CTInfo.IonBeamSequence))) '.']}];

        for i=1:length(fieldnames(CTInfo.IonBeamSequence))
            FieldName=['Item_', num2str(i)];

            SubStr=[];
            if isfield(CTInfo.IonBeamSequence.(FieldName), 'BeamNumber')
                SubStr=[num2str(CTInfo.IonBeamSequence.(FieldName).BeamNumber), '. '];
            else
                SubStr=[' . ']
            end

            if isfield(CTInfo.IonBeamSequence.(FieldName), 'BeamName')
                SubStr=[SubStr, CTInfo.IonBeamSequence.(FieldName).BeamName, ', '];
            else
                SubStr=[' , ']
            end

            if isfield(CTInfo.IonBeamSequence.(FieldName), 'RadiationType')
                SubStr=[SubStr, CTInfo.IonBeamSequence.(FieldName).RadiationType, ', '];
            else
                SubStr=[' , ']
            end

            if isfield(CTInfo.IonBeamSequence.(FieldName), 'BeamType')
                SubStr=[SubStr, CTInfo.IonBeamSequence.(FieldName).BeamType, '.'];
            else
                SubStr=[' .']
            end

            InfoList=[InfoList; SubStr];
        end
    else
        InfoList=[InfoList; {['BeamNumber: ', ' .']}];
    end
end

function InfoList=GetDcmPatInfoDose(CTInfo, FileName)
    
%Get info on chosen item
InfoList={'[Basic]'; 'Modality: DOSE.'};
if isfield(CTInfo, 'PatientID')
    TempStr1=CTInfo.PatientID;
    InfoList=[InfoList; {['MRN: ', TempStr1, '.']}];
else
    InfoList=[InfoList; {['MRN: ', ' .']}];
end

if isfield(CTInfo, 'PatientName')
    TempName=[];
    Name=struct2cell(CTInfo.PatientName);
    for i=1:length(Name)
        TempName=[TempName, Name{i}, ' '];
    end
    InfoList=[InfoList; {['Name: ', TempName, '.']}];   
else
    InfoList=[InfoList; {['Name: ', ' .']}];    
end

TempStr1=[]; TempStr2=[];
if isfield(CTInfo, 'InstanceCreationDate') && isfield(CTInfo, 'InstanceCreationTime')
    TempStr1=CTInfo.InstanceCreationDate;
    TempStr2=CTInfo.InstanceCreationTime;       

    if ~isempty(TempStr1) && ~isempty(TempStr2)
        InfoList=[InfoList; {['Time: ', TempStr1, ' ', TempStr2, '.']}];        
    else
        InfoList=[InfoList; {['Time: ', ' .']}];
    end   
    
else    
    InfoList=[InfoList; {['Time: ', ' .']}];
end

InfoList=[InfoList; {['File: ', FileName, '.']}];

if isfield(CTInfo, 'StudyID')
   InfoList=[InfoList; {['StudyID: ',  CTInfo.StudyID, '.']}];
else
    InfoList=[InfoList; {['    ']}];
end

InfoList=[InfoList; {['    ']}; {'[Format]'}];

if isfield(CTInfo, 'DoseUnits')    
    InfoList=[InfoList; {['Units: ', CTInfo.DoseUnits, '.']}];
else
    InfoList=[InfoList; {['Units: ', ' .']}];
end

if isfield(CTInfo, 'DoseType')    
    InfoList=[InfoList; {['Type: ', CTInfo.DoseType, '.']}];
else
    InfoList=[InfoList; {['Type: ', ' .']}];
end

if isfield(CTInfo, 'DoseSummationType')    
    InfoList=[InfoList; {['Summation: ', CTInfo.DoseSummationType, '.']}];
else
    InfoList=[InfoList; {['Summation: ', ' .']}];
end

InfoList=[InfoList; {['    ']}];

if isfield(CTInfo, 'Width')
    TempStr=num2str(CTInfo.Width);
    InfoList=[InfoList; {['XDim: ', TempStr, '.']}];
else
    InfoList=[InfoList; {['XDim: ', ' .']}];
end

if isfield(CTInfo, 'Height')
    TempStr=num2str(CTInfo.Height);
    InfoList=[InfoList; {['YDim: ', TempStr, '.']}];
else
    InfoList=[InfoList; {['YDim: ', ' .']}];
end    

if isfield(CTInfo, 'NumberOfFrames')
    TempStr=num2str(CTInfo.NumberOfFrames);
    InfoList=[InfoList; {['ZDim: ', TempStr, '.']}];
else
    InfoList=[InfoList; {['ZDim: ', ' .']}];
end    


if isfield(CTInfo, 'PixelSpacing')
    TempStr=num2str(round(CTInfo.PixelSpacing(1)*10000/10)/10000);
    InfoList=[InfoList; {['XGrid: ', TempStr, 'cm.']}];
    
    TempStr=num2str(round(CTInfo.PixelSpacing(2)*10000/10)/10000);
    InfoList=[InfoList; {['YGrid: ', TempStr, 'cm.']}];
else
   InfoList=[InfoList; {['XGrid: ', ' .']}];
   InfoList=[InfoList; {['YGrid: ', ' .']}];
end

if isfield(CTInfo, 'GridFrameOffsetVector')
    ZGrid=abs(CTInfo.GridFrameOffsetVector(2)-CTInfo.GridFrameOffsetVector(1));
    ZGrid=round(ZGrid*1000/10)/1000;
    
    TempStr=num2str(ZGrid);
    InfoList=[InfoList; {['ZGrid: ', TempStr, 'cm.']}];
else
    InfoList=[InfoList; {['ZGrid: ', ' .']}];
end

function WritePatientFile(PatientStr, FileDir, hText)
%Update status
set(hText, 'String', ['Writing Patient file...']);
drawnow;

Fid=fopen([FileDir, 'Patient'], 'w');
for i=1:length(PatientStr)
    fprintf(Fid, '%s\n', PatientStr{i});
end
fclose(Fid);


function SeriesStr=GetSeriesStr(DCMInfo, BatchFlag)
try
    SeriesStr=DCMInfo.SeriesDescription;
catch
    SeriesStr='';
end

if BatchFlag > 0
    TruncPos=17;
else
    TruncPos=4;
end

try
    if ~isempty(strmatch('T=', SeriesStr))
        PercentIndex=strfind(SeriesStr, '%');  %4DCT case
        SeriesStr=SeriesStr(1:PercentIndex(1)-1);
        SeriesStr=SeriesStr(3:end);
        SeriesStr=['T', SeriesStr];
    else
        [TFlag, SeriesStr]=Get4DPhase(SeriesStr);
        if TFlag > 0
            SeriesStr=['T', SeriesStr];
        else
            if length(SeriesStr)> TruncPos
                SeriesStr=SeriesStr(1:TruncPos);
            end
        end
    end
    
catch
    if length(SeriesStr)> TruncPos
        SeriesStr=SeriesStr(1:TruncPos);
    end
end
