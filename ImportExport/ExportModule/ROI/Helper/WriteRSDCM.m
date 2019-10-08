function Flag=WriteRSDCM(structAxialROI, FileName, PatInfo, ImgUIDInfo, hText)


%Update status
set(hText, 'String', 'Creating DICOM RS file ...(1/2)');
drawnow;

%--Load template
load('ExportRSTemplate.mat');

%PatientName
RSInfo.PatientName.FamilyName=PatInfo.LastName;
RSInfo.PatientName.GivenName=PatInfo.FirstName;


%Patient ID
RSInfo.PatientID=PatInfo.MRN;

%StudyInstanceUID
RSInfo.StudyInstanceUID=ImgUIDInfo.StudyInstanceUID;

%SeriesInstanceUID
RSInfo.SeriesInstanceUID=dicomuid;

%StudyID
RSInfo.StudyID=PatInfo.MRN;

TempUID=['1.2.246.352.71.4.231.1579.',  datestr(now, 30)];
TempUID(findstr(TempUID, 'T'))=[];

RSInfo.MediaStorageSOPInstanceUID=TempUID;
RSInfo.SOPInstanceUID=TempUID;

RSInfo.StructureSetLabel='IBEX_ROI';


%RS Part
RSInfo.ReferencedFrameOfReferenceSequence.Item_1.FrameOfReferenceUID=ImgUIDInfo.FrameUID;
RSInfo.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.ReferencedSOPInstanceUID=ImgUIDInfo.StudyInstanceUID;
RSInfo.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID=...
    ImgUIDInfo.SeriesUID;

for i=1:length(ImgUIDInfo.InstanceUID)
    FieldName=['Item_', num2str(i)];
    RSInfo.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.(FieldName).ReferencedSOPClassUID=ImgUIDInfo.ClassUID;    
    RSInfo.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.(FieldName).ReferencedSOPInstanceUID=...
        ImgUIDInfo.InstanceUID{length(ImgUIDInfo.InstanceUID)-i+1};
end

%Update StructureSetROISequence
ROIName={structAxialROI.name}';
for i=1:length(ROIName)
    FieldName=['Item_', num2str(i)];
    RSInfo.StructureSetROISequence.(FieldName).ROINumber=i;
    RSInfo.StructureSetROISequence.(FieldName).ReferencedFrameOfReferenceUID=ImgUIDInfo.FrameUID;
    RSInfo.StructureSetROISequence.(FieldName).ROIName=deblank(ROIName{i});
    RSInfo.StructureSetROISequence.(FieldName).ROIGenerationAlgorithm= 'MANUAL';
    Type='OVERLAPPING ';
    RSInfo.StructureSetROISequence.(FieldName).Private_3263_1000= Type';
end

%Update ROIContourSequence
PinColor={'red'; 'green'; 'blue'; 'yellow'; 'purple'; 'skyblue'; 'lavender'; 'orange'; 'forest'; 'slateblue';  'lightblue'; 'yellowgreen'; 'lightorange'; ...
    'grey'; 'khaki'; 'aquamarine'; 'teal'; 'steelblue'; 'brown';  'olive'; 'tomato'; 'seashell'; 'maroon'; 'greyscale'; 'Thermal'; 'skin'; ...
    'Smart'; 'Fusion_Red'; 'Thermal'; 'SUV2'; 'SUV3'; 'CEqual'; 'rainbow1'; 'rainbow2'; 'GEM'; 'spectrum'};

ColorList=[255,0,0; 0,255,0; 0,0, 255; 255,255,0; 255,0,255; 0,255,255; 200,180,255; 255,149,0; 34,139,34; 128,0,255; 0,128,255; 192,255,0; 255,192,0; ...
    192,192,192; 240,230,140; 128,255,212; 0,160,160; 70,130,180; 165,80,55; 165,161,55; 255,83,76; 255,228,196; 180,30,30; 255,255,255; 0,0,0; 255,200,150; ...
    255,255,255; 255,0,0; 0,0,0; 255,255,255; 255,255,255; 0,0,0; 136,0, 121; 64,0,128; 0,32,64; 0,0,0];

for i=1:length(ROIName)
    FieldName=['Item_', num2str(i)];
    
    TIndex=strmatch(structAxialROI(i).Color, PinColor, 'exact');
    if isempty(TIndex)
        TIndex=1;
    end
    
    RSInfo.ROIContourSequence.(FieldName).ROIDisplayColor=ColorList(TIndex(1), :)';
    
    RSInfo.ROIContourSequence.(FieldName).ReferencedROINumber=i;               
    
    %Loop through each curve    
    TempCurveNum=0;
    ZLocation=structAxialROI(i).ZLocation;
    for j=1:length(ZLocation)
                
        TempZLocation=structAxialROI(i).ZLocation(j);
        TempData=structAxialROI(i).CurvesCor{j};
        
        if (TempZLocation < min(ImgUIDInfo.TablePos)) || (TempZLocation > max(ImgUIDInfo.TablePos))    %Within volume
            continue;
        else
            [MinD, TempIndex]=min(abs(TempZLocation-ImgUIDInfo.TablePos));
            TempZLocation=ImgUIDInfo.TablePos(TempIndex);
         end
        
         TempCurveNum=TempCurveNum+1;
        
        subFieldName=['Item_', num2str(j)];
        RSInfo.ROIContourSequence.(FieldName).ContourSequence.(subFieldName).NumberOfContourPoints=...
            size(structAxialROI(i).CurvesCor{j}, 1);  
       
        %Only good for same FOV
        if PatInfo.StartV9 < 1
            ShiftValue=PatInfo.YPixDim/2;
            
            TempData(:,1)=(TempData(:,1)-ShiftValue)*10;
            TempData(:,2)=(TempData(:,2)-PatInfo.YStart)+ (PatInfo.YStart+PatInfo.YDim*PatInfo.YPixDim-ShiftValue)-ShiftValue;
            TempData(:,2)=-TempData(:,2)*10;
        end
        
        if PatInfo.StartV9 > 0
            TempData(:,1)=TempData(:,1)*10;            
            TempData(:,2)=-TempData(:,2)*10;
        end
                
        TempZBack=TempZLocation;        
        TempZLocation=-TempZLocation*10;        
        
        TempData=[TempData(:,1)'; TempData(:,2)'; ones(1, length(TempData(:,1)))*TempZLocation];
        
        %Close curve
        if size(TempData, 2) >=2 && isempty(find(TempData(:,1)-TempData(:,end))) 
            TempData(:,end)=[];
            RSInfo.ROIContourSequence.(FieldName).ContourSequence.(subFieldName).NumberOfContourPoints=...
            size(structAxialROI(i).CurvesCor{j}, 1)-1;
        end
        
        TempData=reshape(TempData, size(TempData, 1)*size(TempData,2), 1);               
        
        %Debug
        if ~isempty(find(RSInfo.ROIContourSequence.(FieldName).ContourSequence.(subFieldName).NumberOfContourPoints-length(TempData)/3))
            disp('not matched data');
        end
                                
        RSInfo.ROIContourSequence.(FieldName).ContourSequence.(subFieldName).ContourImageSequence.Item_1.ReferencedSOPClassUID=ImgUIDInfo.ClassUID;
        
        [MinD, TempIndex]=min(abs(TempZBack-ImgUIDInfo.TablePos));
        RSInfo.ROIContourSequence.(FieldName).ContourSequence.(subFieldName).ContourImageSequence.Item_1.ReferencedSOPInstanceUID=...
            ImgUIDInfo.InstanceUID{TempIndex(1)};
        
        RSInfo.ROIContourSequence.(FieldName).ContourSequence.(subFieldName).ContourGeometricType='CLOSED_PLANAR';
        
        RSInfo.ROIContourSequence.(FieldName).ContourSequence.(subFieldName).NumberOfContourPoints=uint16(length(TempData)/3);
        
        RSInfo.ROIContourSequence.(FieldName).ContourSequence.(subFieldName).ContourData=TempData;
        
    end    
    
end


%Update RTROIObservationsSequence
RSInfo=rmfield(RSInfo, 'RTROIObservationsSequence');

for i=1:length(ROIName)
    FieldName=['Item_', num2str(i)];
    RSInfo.RTROIObservationsSequence.(FieldName).ObservationNumber=i;
    
    RSInfo.RTROIObservationsSequence.(FieldName).ReferencedROINumber=i;
   
        
    RSInfo.RTROIObservationsSequence.(FieldName).ROIObservationLabel=deblank(ROIName{i});
    RSInfo.RTROIObservationsSequence.(FieldName).RTROIInterpretedType='PTV';
    RSInfo.RTROIObservationsSequence.(FieldName).ROIInterpreter.FamilyName='';
    RSInfo.RTROIObservationsSequence.(FieldName).ROIInterpreter.GivenName='';
    RSInfo.RTROIObservationsSequence.(FieldName).ROIInterpreter.MiddleName='';
    RSInfo.RTROIObservationsSequence.(FieldName).ROIInterpreter.NamePrefix='';
    RSInfo.RTROIObservationsSequence.(FieldName).ROIInterpreter.NameSuffix='';
end

%--Write RS DICOM file
%Update status
set(hText, 'String', 'Writing DICOM RS file ...(2/2)');
drawnow;

%Save to locak disk
CurrentPath=pwd;

TempTime=datestr(now, 30);
RSInfo.InstanceCreationDate=TempTime(1:8);
RSInfo.InstanceCreationTime=TempTime(10:end);

warning off;
My_dicomwrite(1, FileName, RSInfo, 'CreateMode', 'copy');
%dicomwrite(1, FileName, RSInfo, 'CreateMode', 'copy');

%Covert to standard DICOM file
[~, maxArraySize]=computer;
Flag64bit=maxArraySize > 2^31;

if Flag64bit < 1
    DcmTKConvert(FileName);
    delete([FileName, '.bak']);
end

cd(CurrentPath);
drawnow;

%Return Flag
Flag=1;
