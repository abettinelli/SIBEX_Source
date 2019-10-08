function varargout = DICOMImportMain(varargin)
% DICOMIMPORTMAIN MATLAB code for DICOMImportMain.fig
%      DICOMIMPORTMAIN, by itself, creates a new DICOMIMPORTMAIN or raises the existing
%      singleton*.
%
%      H = DICOMIMPORTMAIN returns the handle to a new DICOMIMPORTMAIN or the handle to
%      the existing singleton*.
%
%      DICOMIMPORTMAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DICOMIMPORTMAIN.M with the given input arguments.
%
%      DICOMIMPORTMAIN('Property','Value',...) creates a new DICOMIMPORTMAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DICOMImportMain_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DICOMImportMain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DICOMImportMain

% Last Modified by GUIDE v2.5 08-Dec-2014 15:32:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DICOMImportMain_OpeningFcn, ...
                   'gui_OutputFcn',  @DICOMImportMain_OutputFcn, ...
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


% --- Executes just before DICOMImportMain is made visible.
function DICOMImportMain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DICOMImportMain (see VARARGIN)

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
if isfield(ConfigStruct, 'DICOMInDir') 
    if ~exist(ConfigStruct.DICOMInDir, 'dir')
        DirFlag=mkdir(ConfigStruct.DICOMInDir);                
    else
        DirFlag=1;
    end
end

if DirFlag < 1
    ConfigStruct.DICOMInDir='C:';
end

handles.ConfigStruct=ConfigStruct;

%Pat Path
handles.PatDataPath=[handles.ParentHandles.INIConfigInfo.DataDir, '\', handles.ParentHandles.CurrentUser, '\', handles.ParentHandles.CurrentSite];


%Initialize UI
set(handles.EditDCMPath, 'String', ConfigStruct.DICOMInDir);

set(handles.ListboxPat, 'String', 'NA', 'Value', 1, 'Enable', 'inactive');
set(handles.ListboxPatInfo, 'String', 'NA', 'Value', 1, 'Enable', 'inactive');

set(handles.PushbuttonOK, 'Enable', 'off');
set(handles.PushbuttonImportAll, 'Enable', 'off');


%Set Position
SetPositionRight(ParentHandles.figure1, handles.figure1);

% Update handles structure
guidata(hObject, handles);

%Set figure units to normalized for resize
set(handles.figure1, 'Units', 'normalized');
hChild=get(handles.figure1, 'Children');
set(hChild, 'Units', 'normalized');

% Choose default command line output for DICOMImportMain
handles.output = 1;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DICOMImportMain wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DICOMImportMain_OutputFcn(hObject, eventdata, handles) 
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
if ~isempty(handles.PatientStr)
    CurrentValue=get(hObject,'Value');
    CurrentPatInfo=handles.PatientInfoStr{CurrentValue};
    
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
if isempty(eventdata) || isobject(eventdata)
    CurrentValue=get(handles.ListboxPat, 'Value');
else
    CurrentValue=eventdata;
end

AllPlanInfo=get(handles.ListboxPat, 'String');

handles.CurrentPlanInfo=AllPlanInfo{CurrentValue};
handles.CurrentROIInfo=handles.ROIInfoStr{CurrentValue};
handles.CurrentPlanIndex=handles.PatientPlanIndex(CurrentValue);
handles.CurrentRSIndex=handles.RSSetIndex(CurrentValue);
handles.CurrentIMIndex=handles.IMSetIndex(CurrentValue);

%Conversion
DoConvertDICOM2PinnIFOA(handles);

if isempty(eventdata) ||  isequal(class(eventdata), 'matlab.ui.eventdata.ActionData')
    MsgboxGuiIFOA('Data import is done.', 'Confirm', 'help', 'modal', handles.ProgramPath);
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
    
    PushbuttonOK_Callback(handles.PushbuttonOK, i, handles);
    pause(1);
end

BatchFlag=get(handles.CheckboxBatch, 'Value');

if BatchFlag < 1
    MsgboxGuiIFOA('Data import is done.', 'Confirm', 'help', 'modal', handles.ProgramPath);
end


% --- Executes on button press in PushbuttonCancel.
function PushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);


% --- Executes on button press in PushbuttonRefresh.
function PushbuttonRefresh_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonRefresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Reset
set(handles.ListboxPat, 'String', 'NA', 'Value', 1, 'Enable', 'inactive');
set(handles.ListboxPatInfo, 'String', 'NA', 'Value', 1, 'Enable', 'inactive');
    
%Read new 
ReadDcmPathInfoIFOA(handles, handles.ConfigStruct.DICOMInDir);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

%Display new
DisplayInfo(handles);




function EditDCMPath_Callback(hObject, eventdata, handles)
% hObject    handle to EditDCMPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditDCMPath as text
%        str2double(get(hObject,'String')) returns contents of EditDCMPath as a double

CurrentStr=get(handles.EditDCMPath, 'String');

if exist(CurrentStr, 'dir')
    handles.ConfigStruct.DICOMInDir=CurrentStr;
    guidata(handles.figure1, handles);
    
    PushbuttonRefresh_Callback(hObject, eventdata, handles);
else
    set(handles.EditDCMPath, 'String', handles.ConfigStruct.DICOMInDir);    
end





% --- Executes during object creation, after setting all properties.
function EditDCMPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditDCMPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushbuttonDCMDir.
function PushbuttonDCMDir_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonDCMDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

TempPath=uigetdir(handles.ConfigStruct.DICOMInDir, 'Select DCM directory:');

if TempPath ~= 0        
    handles.ConfigStruct.DICOMInDir=TempPath;
    guidata(handles.figure1, handles);
    
    BatchFlag=get(handles.CheckboxBatch, 'Value');
    
    if BatchFlag < 1
        set(handles.EditDCMPath, 'String', TempPath);
        EditDCMPath_Callback(handles.EditDCMPath, [], handles);
    else
        DirList=GetDirList(TempPath);
        for i=1:length(DirList)
            TempPathSub=[TempPath, '\', DirList{i}];
            set(handles.EditDCMPath, 'String', TempPathSub);
            
            EditDCMPath_Callback(handles.EditDCMPath, [], handles);            
            handles=guidata(handles.figure1);
            guidata(handles.figure1, handles);
            
            PushbuttonImportAll_Callback(handles.PushbuttonImportAll, 1, handles);
        end
    end
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
PushbuttonCancel_Callback(handles.PushbuttonCancel, [], handles);


%-------------------------------Utilities Functions--------------------------------------%
function DisplayInfo(handles)
PatientStr=[]; PatientInfoStr=[]; PatientPlanIndex=[]; RSSetIndex=[]; IMSetIndex=[]; ROIInfoStr=[];
for i=1:length(handles.POIDetailInfo)    
    if ValidPlanRSCT(handles.POIDetailInfo{i})
        CurrentPatStr=GetPatStr(handles.POIDetailInfo{i});
        PatientStr=[PatientStr; {CurrentPatStr}];

        [CurrentPatInfoStr, CurrentROIStr, RSSetNum, IMSetNum]=GetPatInfoStr(handles.POIDetailInfo{i}, handles.ROIDetailInfo, handles.CTDetailInfo);
        PatientInfoStr=[PatientInfoStr; {CurrentPatInfoStr}];
        ROIInfoStr=[ROIInfoStr; {CurrentROIStr}];
        RSSetIndex=[RSSetIndex; RSSetNum];
        IMSetIndex=[IMSetIndex; IMSetNum];
        
        PatientPlanIndex=[PatientPlanIndex; i];
    end
end

for i=1:length(handles.ROIDetailInfo)    
    TempIndex=find(RSSetIndex == i);
    
    if isempty(TempIndex)
        if ValidRSCT(handles.ROIDetailInfo{i})
            CurrentPatStr=GetPatStrRS(handles.ROIDetailInfo{i});
            PatientStr=[PatientStr; {CurrentPatStr}];

            [CurrentPatInfoStr, CurrentROIStr, IMSetNum]=GetPatInfoStrRS(handles.ROIDetailInfo{i}, handles.CTDetailInfo);
            PatientInfoStr=[PatientInfoStr; {CurrentPatInfoStr}];
            ROIInfoStr=[ROIInfoStr; {CurrentROIStr}];
            RSSetIndex=[RSSetIndex; i];
            IMSetIndex=[IMSetIndex; IMSetNum];

            PatientPlanIndex=[PatientPlanIndex; NaN];
        end
    end    
end

for i=1:length(handles.CTDetailInfo)    
    TempIndex=find(IMSetIndex == i);
    
    if isempty(TempIndex)
        CurrentPatStr=GetPatStrCT(handles.CTDetailInfo{i});
        PatientStr=[PatientStr; {CurrentPatStr}];
        
        CurrentPatInfoStr=GetPatInfoStrCT(handles.CTDetailInfo{i});
        PatientInfoStr=[PatientInfoStr; {CurrentPatInfoStr}];
        ROIInfoStr=[ROIInfoStr; {' '}];
        RSSetIndex=[RSSetIndex; NaN];
        IMSetIndex=[IMSetIndex; i];
        
        PatientPlanIndex=[PatientPlanIndex; NaN];        
    end
end


if ~isempty(PatientStr)
    
    %DEBUG
%     for i=1:2
%         TempStr=PatientStr{i};
%         
%         TempIndex=strfind(TempStr, ',');
%         TStr=['TestPat' num2str(i), num2str(i), num2str(i)];
%         
%         TempStr=[TStr, TempStr(TempIndex(2):end)];
%         PatientStr{i}=TempStr;
%         
%         TempStr=PatientInfoStr{i};
%         TempStr{2}=['MRN: ', num2str(i), num2str(i), num2str(i), '.'];
%         TempStr{3}=['Name: ', TStr, '.'];
%         PatientInfoStr{i}=TempStr;
%     end    
    %DEBUG
    
    set(handles.ListboxPat, 'String', PatientStr, 'Value', 1, 'Enable', 'On');
    set(handles.ListboxPatInfo, 'String', PatientInfoStr{1}, 'Value', 1, 'Enable', 'On');
    
    set(handles.PushbuttonOK, 'Enable', 'on');
    set(handles.PushbuttonImportAll, 'Enable', 'on');
else
    set(handles.ListboxPat, 'String', 'NA', 'Value', 1, 'Enable', 'inactive');
    set(handles.ListboxPatInfo, 'String', 'NA', 'Value', 1, 'Enable', 'inactive');
    
    set(handles.PushbuttonOK, 'Enable', 'off');
    set(handles.PushbuttonImportAll, 'Enable', 'off');
end

handles.PatientStr=PatientStr;
handles.PatientInfoStr=PatientInfoStr;

handles.PatientPlanIndex=PatientPlanIndex;
handles.RSSetIndex=RSSetIndex;
handles.IMSetIndex=IMSetIndex;
handles.ROIInfoStr=ROIInfoStr;

guidata(handles.figure1, handles);


function ValidFlag=ValidPlanRSCT(POIDetailInfo)
TempIndex=strmatch('[Relation]', POIDetailInfo);
PlanRelationStr=POIDetailInfo(TempIndex:end);

TempIndex1=strmatch('IM Set', PlanRelationStr);
TempIndex2=strmatch('RS Set', PlanRelationStr);
if ~isempty(TempIndex1) && ~isempty(TempIndex2)
    ValidFlag=1;
else
    ValidFlag=0;
end

function ValidFlag=ValidRSCT(ROIDetailInfo)
TempIndex=strmatch('[Relation]', ROIDetailInfo);
PlanRelationStr=ROIDetailInfo(TempIndex:end);

TempIndex1=strmatch('IM Set', PlanRelationStr);
if ~isempty(TempIndex1)
    ValidFlag=1;
else
    ValidFlag=0;
end

function PatStr=GetPatStr(InfoStr)
PatStr=[];

TempIndex=strmatch('Name:', InfoStr);
TempStr=InfoStr{TempIndex(1)};
PatStr=[PatStr, TempStr(7:end-2), ', '];

TempIndex=strmatch('MRN:', InfoStr);
TempStr=InfoStr{TempIndex(1)};
PatStr=[PatStr, TempStr(6:end-1), ', '];

TempIndex=strmatch('PlanName:', InfoStr);
TempStr=InfoStr{TempIndex(1)};
PatStr=[PatStr, 'Plan: ', TempStr(11:end-1), '.'];

function PatStr=GetPatStrRS(InfoStr)
PatStr=[];

TempIndex=strmatch('Name:', InfoStr);
TempStr=InfoStr{TempIndex(1)};
PatStr=[PatStr, TempStr(7:end-2), ', '];

TempIndex=strmatch('MRN:', InfoStr);
TempStr=InfoStr{TempIndex(1)};
PatStr=[PatStr, TempStr(6:end-1), ', '];

% TempIndex=strmatch('PlanName:', InfoStr);
% TempStr=InfoStr{TempIndex(1)};
PatStr=[PatStr, 'RS', '.'];

function PatStr=GetPatStrCT(InfoStr)
PatStr=[];

TempIndex=strmatch('Name:', InfoStr);
TempStr=InfoStr{TempIndex(1)};
PatStr=[PatStr, TempStr(7:end-2), ', '];

TempIndex=strmatch('MRN:', InfoStr);
TempStr=InfoStr{TempIndex(1)};
PatStr=[PatStr, TempStr(6:end-1), ', '];

% TempIndex=strmatch('PlanName:', InfoStr);
% TempStr=InfoStr{TempIndex(1)};
PatStr=[PatStr, 'Image', '.'];



function [CurrentPatInfoStr, CurrentROIStr, RSSetNum, IMSetNum]=GetPatInfoStr(POIDetailInfo, ROIDetailInfo, CTDetailInfo)
%Plan Info
TempIndex=strmatch('[Relation]', POIDetailInfo);
PlanRelationStr=POIDetailInfo(TempIndex:end);

%Get IM and ROI set num
TempIndex=strmatch('IM Set', PlanRelationStr);
IMStr=PlanRelationStr{TempIndex};
IMSetNum=str2num(IMStr(end))+1;

TempIndex=strmatch('RS Set', PlanRelationStr);
RSStr=PlanRelationStr{TempIndex};
RSSetNum=str2num(RSStr(end))+1;

%Add plan Info
CurrentPatInfoStr=POIDetailInfo;
CurrentPatInfoStr(6)=[];
CurrentPatInfoStr(5)=[];
CurrentPatInfoStr(2)=[];

TempIndex=strmatch('[Relation]', CurrentPatInfoStr);
CurrentPatInfoStr(TempIndex:end)=[];

%Add ROI Info
CurrentROIInfo=ROIDetailInfo{RSSetNum};
TempIndex=strmatch('[ROI]', CurrentROIInfo);
CurrentROIInfo(1:TempIndex-1)=[];

TempIndex=strmatch('[Relation]', CurrentROIInfo);
CurrentROIInfo(TempIndex:end)=[];

if isequal(CurrentROIInfo(end), {' '})
    CurrentROIStr=CurrentROIInfo(2:end-1);
else
    CurrentROIStr=CurrentROIInfo(2:end);
end

if isequal(CurrentPatInfoStr(end), {' '})    
    CurrentPatInfoStr=[CurrentPatInfoStr; CurrentROIInfo];
else
    CurrentPatInfoStr=[CurrentPatInfoStr; {' '}; CurrentROIInfo];
end

%Add CT Info
CurrentCTInfo=CTDetailInfo{IMSetNum};
TempIndex=strmatch('[Format]', CurrentCTInfo);
CurrentCTInfo(TempIndex)={'[Image]'};
CurrentCTInfo(1:TempIndex-1)=[];

TempIndex=strmatch('[Relation]', CurrentCTInfo);
CurrentCTInfo(TempIndex:end)=[];

if isequal(CurrentPatInfoStr(end), {' '})
    CurrentPatInfoStr=[CurrentPatInfoStr; CurrentCTInfo];
else
    CurrentPatInfoStr=[CurrentPatInfoStr; {' '}; CurrentCTInfo];
end

function [CurrentPatInfoStr, CurrentROIStr, IMSetNum]=GetPatInfoStrRS(ROIDetailInfo, CTDetailInfo)
%Plan Info
TempIndex=strmatch('[Relation]', ROIDetailInfo);
PlanRelationStr=ROIDetailInfo(TempIndex:end);

%Get IM and ROI set num
TempIndex=strmatch('IM Set', PlanRelationStr);
IMStr=PlanRelationStr{TempIndex};

TempIndex=strfind(IMStr, '_');
IMSetNum=str2num(IMStr(TempIndex(end)+1:end))+1;

%Add plan Info
CurrentPatInfoStr=ROIDetailInfo;
CurrentPatInfoStr(6)=[];
CurrentPatInfoStr(5)=[];
CurrentPatInfoStr(2)=[];

TempIndex=strmatch('[Relation]', CurrentPatInfoStr);
CurrentPatInfoStr(TempIndex:end)=[];

TempIndex=strmatch('[ROI]', CurrentPatInfoStr);

if isequal(CurrentPatInfoStr(end), {' '})
    CurrentROIStr=CurrentPatInfoStr(TempIndex+1:end-1);
else
    CurrentROIStr=CurrentPatInfoStr(TempIndex+1:end);
end


%Add CT Info
CurrentCTInfo=CTDetailInfo{IMSetNum};
TempIndex=strmatch('[Format]', CurrentCTInfo);
CurrentCTInfo(TempIndex)={'[Image]'};
CurrentCTInfo(1:TempIndex-1)=[];

TempIndex=strmatch('[Relation]', CurrentCTInfo);
CurrentCTInfo(TempIndex:end)=[];

if isequal(CurrentPatInfoStr(end), {' '})
    CurrentPatInfoStr=[CurrentPatInfoStr; CurrentCTInfo];
else
    CurrentPatInfoStr=[CurrentPatInfoStr; {' '}; CurrentCTInfo];
end

function CurrentPatInfoStr=GetPatInfoStrCT(CTDetailInfo)

%Add plan Info
CurrentPatInfoStr=CTDetailInfo;
CurrentPatInfoStr(7)=[];


% --- Executes on button press in CheckboxBatch.
function CheckboxBatch_Callback(hObject, eventdata, handles)
% hObject    handle to CheckboxBatch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CheckboxBatch
