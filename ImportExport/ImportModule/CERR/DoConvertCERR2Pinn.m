%-----------------------Do conversion from  DICOM-->Pinnacle------------
function  DoConvertCERR2Pinn(handles)
%Anonymization Flag
Anonymize=handles.ParentHandles.Anonymize;

%Set Status
set(handles.figure1, 'Pointer', 'watch');

StatusHandle=StatusProgressTextCenterIFOA('Import', ['Importing CERR data ', '...'], handles.figure1);
hText=findobj(StatusHandle, 'Style', 'Text');
drawnow;


ImageInfo=handles.ImageInfo(handles.CImageIndex);
ScanInfo=ImageInfo.scanInfo(1);

%--------Step1: Image Conversion--------%
%Patient File
%Basic
[TempPatientStr, MRNStr]=WritePatientFileBasic(ScanInfo);

%Image
NameStr=GetNameStr(ScanInfo);
TimeStr=GetTimeStr(ScanInfo);
Modality=GetModality(ScanInfo);

NameFromScanner=NameStr;
ImageNumber=length(ImageInfo.scanInfo);

TTStr={...
    'ImageSetList ={'; ...
    'ImageSet ={'; ...
    'ImageSetID = 0;'; ...
    'PatientID = 11111;'; ...
    'ImageName = "ImageSet_0";'; ...
    ['NameFromScanner = "', NameFromScanner,'";']; ...
    'ExamID = "11111";'; ...
    'StudyID = "11111";'; ...
    ['Modality = "', Modality, '";']; ...
    ['NumberOfImages = ', num2str(ImageNumber), ';']; ...
    ['ScanTimeFromScanner = "', TimeStr, '";']; ...
    'FileName = "";'; ...
    '};'; ...
    '}'};

TempPatientStr=[TempPatientStr; TTStr];

%-Create Patient Folder
FilePart=[NameStr, '_', MRNStr];
SpecialChar={'!'; ':'; char(34); '#'; '\$'; '%'; '&'; '`'; '('; ')'; '\*'; '\+';  '/'; ';'; '<'; '='; '>'; '\?'; '@'; ','; '\.'; '[';  ']'; char(39); '{'; '\|'; '}'; '~'; ' '};
FilePart=regexprep(FilePart, SpecialChar, '');

FileDir=deblank([handles.PatDataPath, '\', FilePart, datestr(now, 30)]);

FileDir=[FileDir, '\'];

if ~exist(FileDir, 'dir')
    mkdir(FileDir);
else
    rmdir(FileDir, 's');
    mkdir(FileDir);
end

%Save
PatientStr=TempPatientStr;

%-Writing Image related stuff .img, .ImageInfo, .ImageSet, .header
CImageInfo=handles.ImageInfo(handles.CImageIndex);
WritePinnImage(CImageInfo, 'ImageSet_0', TTStr, TimeStr, hText, FileDir, PatientStr,NameStr);

%--------Step2: structure conversion--------%
%Update patient string
EndStr={'ObjectVersion ={'; ...
    'WriteVersion = "Launch Pad: 3.4b";'; ...
    'CreateVersion = "Launch Pad: 3.4b";'; ...
    'LoginName = "p3rtp";'; ...
    ['CreateTimeStamp = "', datestr(now, 31),  '";'];...
    ['WriteTimeStamp = "', datestr(now, 31), '";'];...
    'LastModifiedTimeStamp = "";';
    '};'};
    
    
if ~isempty(handles.CRSIndex)
    TempPlanDir=[FileDir, '\Plan_0\'];
    if ~exist(TempPlanDir, 'dir')
        mkdir(TempPlanDir);        
    else
        delete([TempPlanDir, '*.*']);
    end
    
    CRSInfo=handles.RsInfo(handles.CRSIndex);
    WritePinPlanROI(CRSInfo, TempPlanDir, hText, 0);
    
    %Save plan string
    PlanStr=GenerateFakePlanStr;        
    
    PatientStr=[PatientStr; {'PlanList ={'}; PlanStr; {'};'}; EndStr];
else
    PatientStr=[PatientStr; EndStr];
end


%--write patient file
WritePatientFile(PatientStr, FileDir, hText);
%Anonymize
if Anonymize > 0
    AnonymizePatient(FileDir);
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
function [TempPatientStr, MRNStr]=WritePatientFileBasic(ScanInfo)

PatientName=ScanInfo.patientName;
FamilyName=' ';
GivenName=' ';
MiddleName=' ';

TempIndex=strfind(PatientName, '^');
if length(TempIndex) > 0
    FamilyName=PatientName(1:TempIndex(1)-1);
    
    if length(TempIndex) < 2
        GivenName=PatientName(TempIndex(1)+1:end);
    end
    
    if length(TempIndex) > 1
        GivenName=PatientName(TempIndex(1)+1:TempIndex(2)-1);
        MiddleName=PatientName(TempIndex(2)+1:end);
    end
end
 
TempPatientStr{1}='PatientID = 11111;';
TempPatientStr=[TempPatientStr; {['LastName = "', FamilyName, '";']}];
TempPatientStr=[TempPatientStr; {['FirstName = "', GivenName, '";']}];
TempPatientStr=[TempPatientStr; {['MiddleName = "', MiddleName, '";']}];

if isfield(ScanInfo, 'DICOMHeaders') && isfield(ScanInfo.DICOMHeaders, 'PatientID')
    MRNStr=ScanInfo.DICOMHeaders.PatientID;
    TempPatientStr=[TempPatientStr; {['MedicalRecordNumber = "', MRNStr, '";']}];
else
    MRNStr='';
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
function NameStr=GetNameStr(ScanInfo)
NameStr=ScanInfo.patientName;


%----------Get time string from dicom information--------
function TimeStr=GetTimeStr(ScanInfo)
TimeStr=ScanInfo.scanDate;


function Modality=GetModality(ScanInfo)
DCMInfo=ScanInfo.DICOMHeaders;
Modality=DCMInfo.Modality;

%----------Write .img, .header, .ImageSet, and .ImageInfo---------
function PatientStr=WritePinnImage(ImageInfo, ImageSetName, ImageInfoStr, TimeStr, hText, FileDir, PatientStr, NameStr)

DCMInfo=ImageInfo.uniformScanInfo.DICOMHeaders;

AxialImage=ImageInfo.scanArray;

XDim=size(AxialImage, 2);
YDim=size(AxialImage, 1);
ZDim=size(AxialImage, 3);

XPixDim=ImageInfo.uniformScanInfo.grid1Units;
YPixDim=ImageInfo.uniformScanInfo.grid2Units;
ZPixDim=ImageInfo.uniformScanInfo.sliceThickness;

DailyTablePos=ImageInfo.uniformScanInfo.firstZValue+(1:ZDim-1)*ZPixDim;


set(hText, 'String', ['Writing ', ImageSetName, '.img ...']);
drawnow;

AxialImage=permute(AxialImage, [2,1,3]);

%Write new img file
if isequal(DCMInfo.Modality, 'CT')  || isequal(DCMInfo.Modality, 'MR')
    TempFid=fopen([FileDir, ImageSetName, '.img'], 'w');
    fwrite(TempFid, AxialImage, 'uint16');
    fclose(TempFid);
end

if isequal(DCMInfo.Modality, 'PT')
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
TempPos=ImageInfo.uniformScanInfo.DICOMHeaders.ImagePositionPatient(1:2)/10;

XDailyOriginStart=TempPos(1);
YDailyOriginStart=TempPos(2)-double(YDim-1)*YPixDim;

XDailyOriginStartV9=TempPos(1);
YDailyOriginStartV9=-(TempPos(2)+double(YDim-1)*YPixDim);

if  isfield(DCMInfo, 'SeriesDescription')    
    SeriesStr=DCMInfo.SeriesDescription;    
    NameStr=GetNameStrWitherSeriesStr(NameStr, SeriesStr);
end

if isfield(DCMInfo, 'PatientID')
    MRNStr=DCMInfo.PatientID;
else
    MRNStr='';
end

if length(DailyTablePos) == 1
    ZPixDimTemp=0.3;
else
    ZPixDimTemp=abs(DailyTablePos(1)-DailyTablePos(2));
end

if isequal(DCMInfo.Modality, 'CT') || isequal(DCMInfo.Modality, 'MR')
    bitpix=16;
    bytes_pix=2;
end

if isequal(DCMInfo.Modality, 'PT')
    bitpix=32;
    bytes_pix=4;
end

if isfield(DCMInfo, 'TableHeight')
    CouchHeight=DCMInfo.TableHeight/10;
else
    CouchHeight=18.4;
end

TempStr={
    'byte_order = 0;'; ...
    'read_conversion = "";'; ...
    'write_conversion = "";'; ...
    't_dim = 0;';...
    ['x_dim = ', num2str(YDim), ';']; ...
    ['y_dim = ', num2str(XDim), ';']; ...
    ['z_dim = ', num2str(ZDim), ';']; ...
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
    'patient_position : HFS'; ...
    'orientation = 0;';...
    'scan_acquisition = 0;';...
    'comment : ';...
    'fname_format : '; ...
    'fname_index_start = 0;';...
    'fname_index_delta = 0;';...
    'binary_header_size = 0;';...
    'manufacturer : Philips';...
    'model : Mx8000 IDT';...
    'couch_pos = 0.000000;';...
    ['couch_height = ', num2str(CouchHeight, 10), ';'];...
    'X_offset = -0.000000;';...
    'Y_offset = 0.000000;';...
    'dataset_modified = 0;';...
    'study_id : 11111';...
    'exam_id : 11111';...
    ['patient_id : ', MRNStr]; ...
    ['modality : ', DCMInfo.Modality]};

if isfield(DCMInfo, 'SeriesDescription')
    SeriesDescription=[DCMInfo.SeriesDescription];
else
    SeriesDescription='';
end

if isfield(DCMInfo, 'ScanOptions')
    ScanOptions=DCMInfo.ScanOptions;
else
    ScanOptions='';
end

if isfield(DCMInfo, 'StationName')
    StationName=DCMInfo.StationName;
else
    StationName='';
end

if isfield(DCMInfo, 'KVP')
    KVP=DCMInfo.KVP;
else
    KVP='';
end

if isfield(DCMInfo, 'AcquisitionTime') && isfield(DCMInfo, 'ContentDate')
    SeriesDateTime=[DCMInfo.ContentDate, ' ', DCMInfo.AcquisitionTime];
else
    SeriesDateTime='';
end

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
    {['x_start_dicom = ', num2str(XDailyOriginStartV9), ';']};...
    {['y_start_dicom = ', num2str(YDailyOriginStartV9), ';']}];

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

for i=1:length(DailyTablePos)
    
    if ~isfield(DCMInfo, 'FrameOfReferenceUID')
        DCMInfo.FrameOfReferenceUID=' ';
    end
    
    TempStr=[TempStr; ...
        {'ImageInfo ={'}; ...
        {['TablePosition = ', num2str(DailyTablePos(i), 10), ';']};...
        {['CouchPos = ', num2str(-DailyTablePos(i), 10), ';']};...
        {['SliceNumber = ', num2str(i), ';']};...
        {['SeriesUID = "', DCMInfo.SeriesInstanceUID, '";']};...
        {['StudyInstanceUID = "', DCMInfo.StudyInstanceUID, '";']};...
        {['FrameUID = "', DCMInfo.FrameOfReferenceUID, '";']};...
        {['ClassUID = "', DCMInfo.SOPClassUID, '";']};...
        {['InstanceUID = "', dicomuid '";']};...
        {['SUVScale = ', num2str(1), ';']};...
        {['ColorLUTScale = ', num2str(1), ';']};...
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



%------------------------Write plan.roi from DICOM----------------------------
function ROIName=WritePinPlanROI(CRSInfo, TempPlanDir, hText)
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
    'block_size =  32;';...
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

    if isfield(ROIDICOMInfo.ROIContourSequence.(FieldName), 'ROIDisplayColor')
        ROIColor=ROIDICOMInfo.ROIContourSequence.(FieldName).ROIDisplayColor'/255;
        
        TempV=sum(ROIColor.^2);
        if TempV < 1E-04
            ROIColor=[0, 1,1 ];
        end        
    else
        ROIColor=[1, 0, 0];
    end
    
    TempColor=repmat(ROIColor, [length(WindowColor), 1])-WindowColor;
    TempColor=sum(TempColor.*TempColor, 2);
    [TempMin, TempIndex]=min(TempColor);

    TempROIStart{10}=['color:           ', PinColor{TempIndex}];      
    
    if isfield(ROIDICOMInfo.ROIContourSequence.(FieldName), 'ContourSequence')
        ROICurveNum=length(fieldnames(ROIDICOMInfo.ROIContourSequence.(FieldName).ContourSequence));
    else
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

        TempCurvePoint=cellstr(num2str(TempData));

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
function PlanStr=GenerateFakePlanStr
PlanStr={
    'Plan ={'; ...
    ['PlanID = ', num2str(0), ';']; ...
    'ToolType = "Pinnacle^3";'; ...
    ['PlanName = "', 'FakePlan', '";']; ...
    'Physicist = "";'; ...
    'Comment = "";'; ...
    'Dosimetrist = "";'; ...
    ['PrimaryCTImageSetID = ', num2str(0), ';'];...
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
