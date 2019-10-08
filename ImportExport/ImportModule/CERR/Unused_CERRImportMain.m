function varargout = CERRImportMain(varargin)
% CERRIMPORTMAIN MATLAB code for CERRImportMain.fig
%      CERRIMPORTMAIN, by itself, creates a new CERRIMPORTMAIN or raises the existing
%      singleton*.
%
%      H = CERRIMPORTMAIN returns the handle to a new CERRIMPORTMAIN or the handle to
%      the existing singleton*.
%
%      CERRIMPORTMAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CERRIMPORTMAIN.M with the given input arguments.
%
%      CERRIMPORTMAIN('Property','Value',...) creates a new CERRIMPORTMAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CERRImportMain_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CERRImportMain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CERRImportMain

% Last Modified by GUIDE v2.5 08-Jun-2015 16:34:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CERRImportMain_OpeningFcn, ...
                   'gui_OutputFcn',  @CERRImportMain_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before CERRImportMain is made visible.
function CERRImportMain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CERRImportMain (see VARARGIN)

ParentHandles=varargin{1};

handles.ParentHandles=ParentHandles;
handles.ProgramPath=handles.ParentHandles.ProgramPath;

%INI Configuration
[CProgramPath, CFileName]=fileparts(mfilename('fullpath'));

ConfigFile=[CProgramPath, '\', CFileName, '.INI'];
if exist(ConfigFile, 'file')
   ConfigStruct=GetParamFromINI(ConfigFile);
end

DirFlag=0;
if isfield(ConfigStruct, 'FileInDir') 
    if ~exist(ConfigStruct.FileInDir, 'dir')
        DirFlag=mkdir(ConfigStruct.FileInDir);                
    else
        DirFlag=1;
    end
end

if DirFlag < 1
    ConfigStruct.FileInDir='C:';
end

handles.ConfigStruct=ConfigStruct;

%Pat Path
handles.PatDataPath=[handles.ParentHandles.INIConfigInfo.DataDir, '\', handles.ParentHandles.CurrentUser, '\', handles.ParentHandles.CurrentSite];


%Initialize UI
UIInitialize(handles);

%Set Position
SetPositionRight(ParentHandles.figure1, handles.figure1);

% Update handles structure
guidata(hObject, handles);

%Set figure units to normalized for resize
set(handles.figure1, 'Units', 'normalized');
hChild=get(handles.figure1, 'Children');
set(hChild, 'Units', 'normalized');

% Choose default command line output for DICOMImportMain
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% Choose default command line output for CERRImportMain
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CERRImportMain wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function UIInitialize(handles)
set(handles.EditFile, 'String', '');

set(handles.ListboxPat, 'String', 'NA', 'Value', 1, 'Enable', 'inactive');
set(handles.ListboxPatInfo, 'String', 'NA', 'Value', 1, 'Enable', 'inactive');

set(handles.PushbuttonOK, 'Enable', 'off');
set(handles.PushbuttonImportAll, 'Enable', 'off');


% --- Outputs from this function are returned to the command line.
function varargout = CERRImportMain_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in ListboxPat.
function ListboxPat_Callback(hObject, eventdata, handles)
% hObject    handle to ListboxPat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListboxPat contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListboxPat

if isequal(get(handles.PushbuttonOK, 'Enable'), 'On') || isequal(get(handles.PushbuttonOK, 'Enable'), 'on')
    CurrentValue=get(hObject,'Value');
    CurrentPatInfo=handles.PatDetailInfo{CurrentValue};
    
    set(handles.ListboxPatInfo, 'String', CurrentPatInfo, 'Value', 1, 'ListboxTop', 1);
end


% --- Executes during object creation, after setting all properties.
function ListboxPat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListboxPat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ListboxPatInfo.
function ListboxPatInfo_Callback(hObject, eventdata, handles)
% hObject    handle to ListboxPatInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListboxPatInfo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListboxPatInfo


% --- Executes during object creation, after setting all properties.
function ListboxPatInfo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListboxPatInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushbuttonOK.
function PushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Current Information
CurrentValue=get(handles.ListboxPat, 'Value');

if CurrentValue <=length(handles.RSSetImageIndex)
    handles.CRSIndex=CurrentValue;
     handles.CImageIndex=handles.RSSetImageIndex(CurrentValue);
else
    handles.CRSIndex=[];
    handles.CImageIndex=handles.ImageIndex(CurrentValue-length(handles.RSSetImageIndex));
end

guidata(handles.figure1, handles);    

%Conversion
DoConvertCERR2Pinn(handles);

if isempty(eventdata)
    MsgboxGuiIFOA('Data import is done.', 'Confirm', 'help', 'modal', handles.ProgramPath);
end

% --- Executes on button press in PushbuttonCancel.
function PushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);



function EditFile_Callback(hObject, eventdata, handles)
% hObject    handle to EditFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditFile as text
%        str2double(get(hObject,'String')) returns contents of EditFile as a double

FileName=get(handles.EditFile, 'String');

CurrentStr=fileparts(FileName);

if exist(CurrentStr, 'dir')
    handles.ConfigStruct.FileInDir=CurrentStr;
    guidata(handles.figure1, handles);
    
    %Status
    set(handles.figure1, 'Pointer', 'watch');
    
    hStatus=StatusProgressTextCenterIFOA('Searching', 'Searching CERR data...', handles.figure1);
    hText=findobj(hStatus, 'Style', 'Text');
    drawnow;
    
    clear('planC');
    load(FileName);
    
    if exist('planC', 'var')
        CERRMat=planC;
        
        ValidFlag=UpdateInfo(CERRMat, handles);
        if ValidFlag > 0
            handles=guidata(handles.figure1);            
            guidata(handles.figure1, handles);
                                 
            set(handles.ListboxPat, 'String', handles.PatInfo, 'Value', 1, 'Enable', 'on', 'ListboxTop', 1);
            set(handles.ListboxPatInfo, 'String', handles.PatDetailInfo{1}, 'Value', 1, 'Enable', 'on', 'ListboxTop', 1);
            
            set(handles.PushbuttonOK, 'Enable', 'on');        
            set(handles.PushbuttonImportAll, 'Enable', 'on');
        else
            UIInitialize(handles);
        end
        
        clear('CERRMat');
    end
    
    set(handles.figure1, 'Pointer', 'arrow');
    delete(hStatus);

else
    UIInitialize(handles);
end


function ValidFlag=UpdateInfo(CERRMat, handles)
ValidFlag=0;

ImageInfo=CERRMat{3};
RSInfo=CERRMat{4};

ImageNum=size(ImageInfo, 2);
RSNum=size(RSInfo, 2);

if ImageNum < 1
    return;    
end

if RSNum < 1
    RSInfo=[];
end

if ImageNum <1 
    UIInitialize(handles);
else
    ImageUID={ImageInfo.scanUID}';
    ImageTakenFlag=zeros(length(ImageUID), 1);
        
    %Check RS first
    if RSNum > 0
        
        RSImageUID={RSInfo.assocScanUID}';        
        UniqueRSImageUID=unique(RSImageUID);
        
        RSSetNum=length(UniqueRSImageUID);
        RSSetSliceIndex=[{''}]; RSSetImageIndex=zeros(length(ImageNum), 1);
        for i=1:RSSetNum
            TRSSliceIndex=strmatch(UniqueRSImageUID{i}, RSImageUID, 'exact');
            RSSetSliceIndex=[RSSetSliceIndex; {TRSSliceIndex}];
            
            TempIndex=strmatch(UniqueRSImageUID{i}, ImageUID, 'exact');
            if ~isempty(TempIndex)
                ImageTakenFlag(TempIndex(1))=1;                
                RSSetImageIndex(i)=TempIndex(1);
            end
        end
        RSSetSliceIndex(1)=[];
        
        %Remove invalid RS
        TempIndex=find(RSSetImageIndex < 1);
        RSSetSliceIndex(TempIndex)=[];
        RSSetImageIndex(TempIndex)=[];
    else        
        RSSetSliceIndex=[];
        RSSetImageIndex=[];
    end
    
    ImageIndex=find(ImageTakenFlag <1);
    
    [PatInfo, PatDetailInfo]=GetCERRPatInfo(RSSetSliceIndex, RSSetImageIndex, ImageInfo, RSInfo, ImageIndex);    
    
    ValidFlag =1;
    
    handles.PatInfo=PatInfo;
    handles.PatDetailInfo=PatDetailInfo;
    
    handles.RSSetSliceIndex=RSSetSliceIndex;
    handles.RSSetImageIndex=RSSetImageIndex;
    handles.ImageIndex=ImageIndex;
    
    handles.ImageInfo=ImageInfo;
    handles.RSInfo=RSInfo;
    
    guidata(handles.figure1, handles);  
end

function [PatInfo, PatDetailInfo]=GetCERRPatInfo(RSSetSliceIndex, RSSetImageIndex, ImageInfo, RSInfo, ImageIndex)
PatInfo={''};
PatDetailInfo={''};

%RS+Image
if ~isempty(RSSetSliceIndex)
    for i=1:length(RSSetSliceIndex)
        CRSSetSliceIndex=RSSetSliceIndex{i};
        
        %Get Basic Info
        [InfoList, CPatInfo]=GetPatInfoRS(RSInfo(CRSSetSliceIndex(1)));
        
        %Get Structure Name
        CRSInfo=RSInfo(CRSSetSliceIndex);
        RSName={CRSInfo.structureName}';       
                
        InfoList=[InfoList; {' '}; {'[ROI]'}; RSName];
        
        %Get Image Info
        CImageInfo=ImageInfo(RSSetImageIndex(i)); 
        InfoListImage=GetImageInfo(CImageInfo);
        
        InfoList=[InfoList; {' '}; InfoListImage];
        
        PatInfo=[PatInfo; {CPatInfo}];
        PatDetailInfo=[PatDetailInfo; {InfoList}];
    end
end


%Image
if ~isempty(ImageIndex)
    for i=1:length(ImageIndex)
        [InfoList, CPatInfo]=GetImageInfoCT(ImageInfo(ImageIndex(i)));
        
        PatInfo=[PatInfo; {CPatInfo}];
        PatDetailInfo=[PatDetailInfo; {InfoList}];
    end    
end

PatInfo(1)=[];
PatDetailInfo(1)=[];


function [InfoList, PatStr]=GetImageInfoCT(CTInfoT)
 CTInfo=CTInfoT.scanInfo(1); 

 InfoList={'[Basic]'; ['Modality: ', CTInfo.imageType]};


if isfield(CTInfo, 'DICOMHeaders') && isfield(CTInfo.DICOMHeaders, 'PatientID')
    TempStr1=CTInfo.DICOMHeaders.PatientID;
    InfoList=[InfoList; {['MRN: ', TempStr1, '.']}];
else
    TempStr1='';
    InfoList=[InfoList; {['MRN: ', ' .']}];
end

if isfield(CTInfo, 'patientName')
    InfoList=[InfoList; {['Name: ', CTInfo.patientName, '.']}];   
    PatStr=[CTInfo.patientName, ','];
else
    InfoList=[InfoList; {['Name: ', ' .']}];    
    PatStr=[','];
end

TempStr1=[]; TempStr2=[];
if isfield(CTInfo.DICOMHeaders, 'StudyDate') && isfield(CTInfo.DICOMHeaders, 'StudyTime')
    TempStr1=CTInfo.DICOMHeaders.StudyDate;
    TempStr2=CTInfo.DICOMHeaders.StudyTime;
    
    if isempty(TempStr1)
        if isfield(CTInfo.DICOMHeaders, 'InstanceCreationDate') && isfield(CTInfo.DICOMHeaders, 'InstanceCreationTime')
            TempStr1=CTInfo.DICOMHeaders.InstanceCreationDate;
            TempStr2=CTInfo.DICOMHeaders.InstanceCreationTime;
        end
    end

    if ~isempty(TempStr1) && ~isempty(TempStr2)
        InfoList=[InfoList; {['Time: ', TempStr1, ' ', TempStr2, '.']}];        
    else
        InfoList=[InfoList; {['Time: ', ' .']}];
    end   
    
else
    if isfield(CTInfo.DICOMHeaders, 'InstanceCreationDate') && isfield(CTInfo.DICOMHeaders, 'InstanceCreationTime')
        TempStr1=CTInfo.DICOMHeaders.InstanceCreationDate;
        TempStr2=CTInfo.DICOMHeaders.InstanceCreationTime;

        if ~isempty(TempStr1) && ~isempty(TempStr2)
            InfoList=[InfoList; {['Time: ', TempStr1, ' ', TempStr2, '.']}];            
        else
            InfoList=[InfoList; {['Time: ', ' .']}];
        end       
        
    else
        InfoList=[InfoList; {['Time: ', ' .']}];
    end
end

InfoList=[InfoList; {' '}; GetImageInfo(CTInfoT)];

PatStr=[PatStr, ' ', TempStr1, ' Image.'];

function InfoList=GetImageInfo(CTInfo)
    
InfoList={'[Format]'};

ScanInfo=CTInfo.scanInfo(1);

TempStr=num2str(round(ScanInfo.grid1Units*double(ScanInfo.sizeOfDimension1)*100)/100);
InfoList=[InfoList; {['XFOV: ', TempStr, 'cm.']}];

TempStr=num2str(round(ScanInfo.grid2Units*double(ScanInfo.sizeOfDimension2)*100)/100);
InfoList=[InfoList; {['YFOV: ', TempStr, 'cm.']}];

SizeInfo=size(CTInfo.scanArray);
InfoList=[InfoList; {['XDim: ', num2str(SizeInfo(2)), '.']}];
InfoList=[InfoList; {['YDim: ', num2str(SizeInfo(1)), '.']}];
InfoList=[InfoList; {['ZDim: ', num2str(SizeInfo(3)), '.']}];

if isfield(ScanInfo, 'DICOMHeaders') && isfield(ScanInfo.DICOMHeaders, 'SliceThickness')
    InfoList=[InfoList; {['Slice Thickness: ', num2str(ScanInfo.DICOMHeaders.SliceThickness), 'mm.']}];
else
    InfoList=[InfoList; {['Slice Thickness: ', '3', 'mm.']}];
end


function [InfoList, PatStr]=GetPatInfoRS(CTInfo)
    
%Get info on chosen item
InfoList={'[Basic]'};
if isfield(CTInfo, 'DICOMHeaders') && isfield(CTInfo.DICOMHeaders, 'PatientID')
    TempStr1=CTInfo.DICOMHeaders.PatientID;
    InfoList=[InfoList; {['MRN: ', TempStr1, '.']}];
else
    TempStr1='';
    InfoList=[InfoList; {['MRN: ', ' .']}];
end

if isfield(CTInfo, 'patientName')
    InfoList=[InfoList; {['Name: ', CTInfo.patientName, '.']}];   
    PatStr=[CTInfo.patientName, ','];
else
    InfoList=[InfoList; {['Name: ', ' .']}];    
    PatStr=[','];
end


PatStr=[PatStr, ' ', TempStr1, ' RS.'];



% --- Executes during object creation, after setting all properties.
function EditFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushbuttonFile.
function PushbuttonFile_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CurrentDir=pwd;
cd(handles.ConfigStruct.FileInDir);

[FileName, TempPath]=uigetfile('*.mat','Select CERR file:');

cd(CurrentDir);

if TempPath ~= 0        
    handles.ConfigStruct.FileInDir=TempPath;
    guidata(handles.figure1, handles);
    
    set(handles.EditFile, 'String', [TempPath, FileName]);
    EditFile_Callback(handles.EditFile, [], handles);   
end


% --- Executes on button press in PushbuttonImportAll.
function PushbuttonImportAll_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonImportAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Content=get(handles.ListboxPat, 'String');

for i=1:size(Content, 1)   
    set(handles.ListboxPat, 'Value', i, 'ListboxTop', 1);
    ListboxPat_Callback(handles.ListboxPat, [], handles);
    
    PushbuttonOK_Callback(handles.PushbuttonOK, 'Batch', handles);
    pause(1);
end

MsgboxGuiIFOA('Data import is done.', 'Confirm', 'help', 'modal', handles.ProgramPath);
