%Read Dcm information
function ReadDcmPathInfoIFOA(handles, TempPath)

%----------------Read DICOM RT information-------------
%Set Status
set(handles.figure1, 'Pointer', 'watch');

hStatus=StatusProgressTextCenterIFOA('Searching', ['Searching DICOM data ', '...'], handles.figure1);
hText=findobj(hStatus, 'Style', 'Text');
drawnow;

%Get File Names
Temp=dir(TempPath);

FileList = struct();
for i = 1:length(Temp)
    FileList(i).name = Temp(i).name;
    FileList(i).date = Temp(i).date;
    FileList(i).bytes = Temp(i).bytes;
    FileList(i).isdir = Temp(i).isdir;
    FileList(i).datenum = Temp(i).datenum;
end

cellFileList=struct2cell(FileList);
charFileName=char(cellFileList(1,:)');

DirFlag=cell2mat(cellFileList(4,:)');
TempIndex=find(DirFlag);
if ~isempty(TempIndex)
    charFileName(TempIndex,:)=[];
end

cellFileName=cellstr(charFileName);

%Read DICOM
CTSetInfo={[]}; CTDICOMInfo={[]};   %SetInfo: for display, DicomInfo: Header file
ROISetInfo={[]}; ROIDICOMInfo={[]};
POISetInfo={[]}; POIDICOMInfo={[]};


for i=1:length(cellFileName)
    set(hText, 'String', ['Searching DICOM data (', num2str(i), '/', num2str(length(cellFileName)),  ') ...']);
    drawnow;

    try
        DCMInfo=dicominfo([TempPath, '\', cellFileName{i}], 'dictionary', 'DicomDict_Plan.txt');

        %CT
        if isfield(DCMInfo, 'Modality') && (isequal(DCMInfo.Modality, 'CT') || isequal(DCMInfo.Modality, 'MR') || isequal(DCMInfo.Modality, 'PT'))
            if isequal(CTSetInfo, {[]})
                CTSetInfo(1, 1)={DCMInfo.SeriesInstanceUID};
                CTSetInfo(1, 2)={1}; %ZDim

                InfoList=GetDcmPatInfo(DCMInfo, cellFileName{i});
                InfoList(length(InfoList)-1)={['ZDim: ', num2str(1), '.']};
                CTSetInfo(1, 3)={InfoList};

                CTSetInfo(1, 4)={DCMInfo.StudyInstanceUID};

                if isfield(DCMInfo, 'RescaleSlope')
                    CTSetInfo(1, 5)={DCMInfo.RescaleSlope};
                else
                    CTSetInfo(1, 5)={1};
                end

                CTDICOMInfo(1, 1)={DCMInfo};       %Row----Set, Column: different file
            else
                SeriesID=CTSetInfo(:,1);
                TempIndex=strmatch(DCMInfo.SeriesInstanceUID, SeriesID, 'exact');

                if ~isempty(TempIndex)
                    CTSetInfo(TempIndex, 2)= {cell2mat(CTSetInfo(TempIndex, 2))+1};

                    InfoList=CTSetInfo{TempIndex, 3};
                    InfoList(length(InfoList)-1)={['ZDim: ', num2str(CTSetInfo{TempIndex, 2}), '.']};
                    CTSetInfo(TempIndex, 3)={InfoList};

                    if isfield(DCMInfo, 'RescaleSlope') && CTSetInfo{TempIndex, 5} < DCMInfo.RescaleSlope
                        CTSetInfo(TempIndex, 5)={DCMInfo.RescaleSlope};
                    end

                    CTDICOMInfo(TempIndex, CTSetInfo{TempIndex, 2})={DCMInfo};
                else
                    CurrentRow=size(CTSetInfo, 1);
                    CTSetInfo(CurrentRow+1, 1)={DCMInfo.SeriesInstanceUID};
                    CTSetInfo(CurrentRow+1, 2)={1}; %ZDim

                    InfoList=GetDcmPatInfo(DCMInfo, cellFileName{i});
                    InfoList(length(InfoList)-1)={['ZDim: ', num2str(1), '.']};
                    CTSetInfo(CurrentRow+1, 3)={InfoList};

                    CTSetInfo(CurrentRow+1, 4)={DCMInfo.StudyInstanceUID};

                    if isfield(DCMInfo, 'RescaleSlope')
                        CTSetInfo(CurrentRow+1, 5)={DCMInfo.RescaleSlope};
                    else
                        CTSetInfo(CurrentRow+1, 5)={1};
                    end

                    CTDICOMInfo(CurrentRow+1, 1)={DCMInfo};
                end
            end
        end

        %RT Structure--ROI
        if isfield(DCMInfo, 'Modality') && isequal(DCMInfo.Modality, 'RTSTRUCT')

            if isequal(ROISetInfo, {[]})
                ROISetInfo(1, 1)={DCMInfo.StudyInstanceUID};
                ROISetInfo(1, 2)={DCMInfo.SOPInstanceUID};

                InfoList=GetDcmPatInfoRS(DCMInfo, cellFileName{i});
                ROISetInfo(1, 3)={InfoList};

                try
                    ROISetInfo(1, 4)={DCMInfo.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID};
                catch
                    ROISetInfo(1, 4)={''};
                end

                ROIDICOMInfo(1, 1)={DCMInfo};
            else
                CurrentRow=size(ROISetInfo, 1)+1;
                ROISetInfo(CurrentRow, 1)={DCMInfo.StudyInstanceUID};
                ROISetInfo(CurrentRow, 2)={DCMInfo.SOPInstanceUID};

                InfoList=GetDcmPatInfoRS(DCMInfo, cellFileName{i});
                ROISetInfo(CurrentRow, 3)={InfoList};

                try
                    ROISetInfo(CurrentRow, 4)={DCMInfo.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID};
                catch
                    ROISetInfo(CurrentRow, 4)={''};
                end

                ROIDICOMInfo(CurrentRow, 1)={DCMInfo};
            end

        end

        %RT Proton Plan--POI
        if isfield(DCMInfo, 'Modality') && isequal(DCMInfo.Modality, 'RTPLAN') 
            
            if isequal(POISetInfo, {[]})
                POISetInfo(1, 1)={DCMInfo.StudyInstanceUID};

                %RS
                try
                    POISetInfo(1, 2)={DCMInfo.ReferencedStructureSetSequence.Item_1.ReferencedSOPInstanceUID};
                catch
                    POISetInfo(1, 2)={''};
                end

                InfoList=GetDcmPatInfoPlan(DCMInfo, cellFileName{i});
                POISetInfo(1, 3)={InfoList};

                POISetInfo(1, 4)={DCMInfo.SOPInstanceUID};

                POIDICOMInfo(1, 1)={DCMInfo};
            else
                CurrentRow=size(POISetInfo, 1)+1;
                POISetInfo(CurrentRow, 1)={DCMInfo.StudyInstanceUID};

                %RS
                try
                    POISetInfo(CurrentRow, 2)={DCMInfo.ReferencedStructureSetSequence.Item_1.ReferencedSOPInstanceUID};
                catch
                    POISetInfo(CurrentRow, 2)={''};
                end

                InfoList=GetDcmPatInfoPlan(DCMInfo, cellFileName{i});
                POISetInfo(CurrentRow, 3)={InfoList};

                POISetInfo(CurrentRow, 4)={DCMInfo.SOPInstanceUID};

                POIDICOMInfo(CurrentRow, 1)={DCMInfo};
            end

        end
        
    catch
        %disp(lasterr);
        continue;  %Ignore non-dicom file
    end

end


%Relation
%---Plan
if ~isequal(POISetInfo, {[]})
    for i=1:size(POISetInfo)
        POISetInfo{i, 3}=[POISetInfo{i, 3}; {' '}];
        POISetInfo{i, 3}=[POISetInfo{i, 3}; {'[Relation]'}];

        %CT
        BaseStr=POISetInfo{i, 1}; TPlanInfo=POIDICOMInfo{i};
        if ~isequal(CTSetInfo, {[]})
            for j=1:size(CTSetInfo, 1)

                if isfield(TPlanInfo, 'ReferencedStructureSetSequence')
                    BaseStr1=CTSetInfo{j, 1};

                    if ~isequal(ROISetInfo, {[]})
                        for k=1:size(ROISetInfo, 1)
                            if isequal(BaseStr1, ROISetInfo{k, 4}) ...  %Series UID
                                    && isequal(TPlanInfo.ReferencedStructureSetSequence.Item_1.ReferencedSOPInstanceUID, ROISetInfo{k, 2})
                                POISetInfo{i, 3}=[POISetInfo{i, 3}; {['IM Set_', num2str(j-1)]}];
                            end
                        end
                    end

                else
                    if isequal(BaseStr, CTSetInfo{j, 4} )
                        POISetInfo{i, 3}=[POISetInfo{i, 3}; {['IM Set_', num2str(j-1)]}];
                    end
                end

            end
        end

        %RS
        BaseStr=POISetInfo{i, 2};
        if ~isequal(ROISetInfo, {[]})
            for j=1:size(ROISetInfo, 1)
                if isequal(BaseStr, ROISetInfo{j, 2} )
                    POISetInfo{i, 3}=[POISetInfo{i, 3}; {['RS Set ', num2str(j-1)]}];
                end
            end
        end

       
    end

end


%---RS
if ~isequal(ROISetInfo, {[]})
    for i=1:size(ROISetInfo)
        ROISetInfo{i, 3}=[ROISetInfo{i, 3}; {' '}];
        ROISetInfo{i, 3}=[ROISetInfo{i, 3}; {'[Relation]'}];

        %CT
        BaseStr=ROISetInfo{i, 4};
        if ~isequal(CTSetInfo, {[]})
            for j=1:size(CTSetInfo, 1)
                if isequal(BaseStr, CTSetInfo{j, 1} )
                    ROISetInfo{i, 3}=[ROISetInfo{i, 3}; {['IM Set_', num2str(j-1)]}];
                end
            end
        end

        %Plan
        BaseStr=ROISetInfo{i, 2};
        if ~isequal(POISetInfo, {[]})
            for j=1:size(POISetInfo, 1)
                if isequal(BaseStr, POISetInfo{j, 2} )
                    ROISetInfo{i, 3}=[ROISetInfo{i, 3}; {['Plan ', num2str(j-1)]}];
                end
            end
        end
    end

end


%Display & Save Path
if ~isequal(CTSetInfo, {[]}) || ~isequal(ROISetInfo, {[]}) || ~isequal(POISetInfo, {[]})

    %Display
    %CT
    CTTotalInfo={[]}; CTDetailInfo={[]};
    if ~isequal(CTSetInfo, {[]})

        for i=1:size(CTSetInfo, 1)
            if i == 1
                CTTotalInfo={['IM Set_', num2str(0)]};
                CTDetailInfo=[CTSetInfo(1, 3)];
            else
                CTTotalInfo=[CTTotalInfo; {['IM Set_', num2str(i-1)]}];
                CTDetailInfo=[CTDetailInfo; CTSetInfo(i, 3)];
            end
        end
    else
        CTTotalInfo={'CT N/A'};  CTDetailInfo={' '};
    end

    %RS
    ROITotalInfo={[]}; ROIDetailInfo={[]};
    if ~isequal(ROISetInfo, {[]})

        for i=1:size(ROISetInfo, 1)
            if i == 1
                ROITotalInfo={['RS Set_', num2str(0)]};
                ROIDetailInfo=[ROISetInfo(1, 3)];
            else
                ROITotalInfo=[ROITotalInfo; {['RS Set_', num2str(i-1)]}];
                ROIDetailInfo=[ROIDetailInfo; ROISetInfo(i, 3)];
            end
        end
    else
        ROITotalInfo={'RS N/A'};  ROIDetailInfo={' '};
    end

    %Plan
    POITotalInfo={[]}; POIDetailInfo={[]};
    if ~isequal(POISetInfo, {[]})

        for i=1:size(POISetInfo, 1)
            if i == 1
                POITotalInfo={['Plan ', num2str(0)]};
                POIDetailInfo=[POISetInfo(1, 3)];
            else
                POITotalInfo=[POITotalInfo; {['Plan ', num2str(i-1)]}];
                POIDetailInfo=[POIDetailInfo; POISetInfo(i, 3)];
            end
        end
    else
        POITotalInfo={'Plan N/A'};  POIDetailInfo={' '};
    end

    
    %Display

    %Save
    handles.CTDICOMInfo=CTDICOMInfo; %Row----Set, Column: different file
    handles.CTDetailInfo=CTDetailInfo;          %Row----Set
    handles.CTSetInfo=CTSetInfo;

    handles.ROIDICOMInfo=ROIDICOMInfo;
    handles.ROIDetailInfo=ROIDetailInfo;
    handles.ROISetInfo=ROISetInfo;

    handles.POIDICOMInfo=POIDICOMInfo;
    handles.POIDetailInfo=POIDetailInfo;
    handles.POISetInfo=POISetInfo;
    
    handles.InfoDCMPath=TempPath;  
 else
    %Save
    handles.CTDICOMInfo=CTDICOMInfo; %Row----Set, Column: different file    
    handles.CTDetailInfo=[];  
    handles.CTSetInfo=CTSetInfo;

    handles.ROIDICOMInfo=ROIDICOMInfo;
    handles.ROIDetailInfo=[];
    handles.ROISetInfo=ROISetInfo;

    handles.POIDICOMInfo=POIDICOMInfo;
    handles.POIDetailInfo=[];
    handles.POISetInfo=POISetInfo;    
    
    handles.InfoDCMPath=TempPath;
end

%Set Status
set(handles.figure1, 'Pointer', 'arrow');
delete(hStatus);

guidata(handles.figure1, handles);


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

if isfield(CTInfo, 'SeriesDescription')
    InfoList=[InfoList; {['Series: ', CTInfo.SeriesDescription, ' .']}];
else
    InfoList=[InfoList; {['Series: ', ' .']}];
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
                SubStr=[' . '];
            end

            if isfield(CTInfo.IonBeamSequence.(FieldName), 'BeamName')
                SubStr=[SubStr, CTInfo.IonBeamSequence.(FieldName).BeamName, ', '];
            else
                SubStr=[' , '];
            end
            
            if isfield(CTInfo.IonBeamSequence.(FieldName).IonControlPointSequence.Item_1, 'GantryAngle')
                SubStr=[SubStr, 'Angle ', num2str(CTInfo.IonBeamSequence.(FieldName).IonControlPointSequence.Item_1.GantryAngle), ', '];
            else
                SubStr=[' , '];
            end

            if isfield(CTInfo.IonBeamSequence.(FieldName), 'RadiationType')
                SubStr=[SubStr, CTInfo.IonBeamSequence.(FieldName).RadiationType, ', '];
            else
                SubStr=[' , '];
            end

            if isfield(CTInfo.IonBeamSequence.(FieldName), 'BeamType')
                SubStr=[SubStr, CTInfo.IonBeamSequence.(FieldName).BeamType, '.'];
            else
                SubStr=[' .'];
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
    ZGrid=CTInfo.GridFrameOffsetVector(2)-CTInfo.GridFrameOffsetVector(1);
    ZGrid=round(ZGrid*1000/10)/1000;
    
    TempStr=num2str(ZGrid);
    InfoList=[InfoList; {['ZGrid: ', TempStr, 'cm.']}];
else
    InfoList=[InfoList; {['ZGrid: ', ' .']}];
end
