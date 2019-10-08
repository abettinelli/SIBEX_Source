function varargout = ROIImportMain(varargin)
%%%Doc Starts%%%
%-Purpose: 
%ROIs are imported into workspace through filters under \*\ImportExport\ImportModule\ROI\ROIImportMethod_*.

%-Format Description:
%1.  Filters are defined in \*\ImportExport\ImportModule\ROI\ROIImportMethod_*.
%2.  For the pinnacle format, pinnacle version(8 or 9) can be selected.
%3.  GUI goes through every filter to import the given file. 

%-Revision:
%2014-09-28: The method is implemented.

%-Author:
%Joy Zhang, lifzhang@mdanderson.org
%%%Doc Ends%%%


% ROIIMPORTMAIN MATLAB code for ROIImportMain.fig
%      ROIIMPORTMAIN, by itself, creates a new ROIIMPORTMAIN or raises the existing
%      singleton*.
%
%      H = ROIIMPORTMAIN returns the handle to a new ROIIMPORTMAIN or the handle to
%      the existing singleton*.
%
%      ROIIMPORTMAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROIIMPORTMAIN.M with the given input arguments.
%
%      ROIIMPORTMAIN('Property','Value',...) creates a new ROIIMPORTMAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROIImportMain_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROIImportMain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ROIImportMain

% Last Modified by GUIDE v2.5 30-Sep-2014 15:20:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ROIImportMain_OpeningFcn, ...
                   'gui_OutputFcn',  @ROIImportMain_OutputFcn, ...
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


% --- Executes just before ROIImportMain is made visible.
function ROIImportMain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ROIImportMain (see VARARGIN)

%Input parameters
ImageDataInfo=varargin{1};
PFig=varargin{2};
PatPath=varargin{3};

%Importers
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));
FormatList=GetExportModuleFormatList(MFilePath, MFileName(1:end-4));

%Set UI
set(handles.EditFile, 'String', '');
set(handles.ListboxFormat, 'String', FormatList);

[ImageData, CMap]=imread('Question.jpg');
set(handles.PushbuttonHelp, 'CData', ImageData);

if isempty(FormatList)
    set(handles.PushbuttonHelp, 'Enable', 'Off');
    set(handles.EditFile, 'Enable', 'Off');
    set(handles.PushbuttonFile, 'Enable', 'Off');
else
    set(handles.PushbuttonHelp, 'Enable', 'On');
    set(handles.EditFile, 'Enable', 'On');
    set(handles.PushbuttonFile, 'Enable', 'On');
end

SetImportButtonStatus(handles);

set(handles.RadiobuttonPinnV9, 'Value', 1);
SetPinRadioButtonStatus(handles);

%Configuration
ConfigStruct.ImportPath=PatPath;

handles.ConfigStruct=ConfigStruct;

%Set position
CenterFigBottomCenter(handles.figure1, PFig);

% Choose default command line output for ROIExportMain
handles.ImageDataInfo=ImageDataInfo;

% Update handles structure
guidata(hObject, handles);

% Choose default command line output for ROIImportMain
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ROIImportMain wait for user response (see UIRESUME)
uiwait(handles.figure1);

function SetPinRadioButtonStatus(handles)
ImportStatus=get(handles.PushbuttonImport, 'Enable');

if isequal(ImportStatus, 'Off') || isequal(ImportStatus, 'off')
    set(handles.RadiobuttonPinnV9, 'Enable', 'Off');
    set(handles.RadiobuttonPinnV8, 'Enable', 'Off');
else
    FileName=get(handles.EditFile, 'String');
    if length(FileName) > 3
        ExtStr=FileName(end-2:end);
        if isequal(lower(ExtStr), 'roi')
            EnableFlag=1;
        else
            EnableFlag=0;
        end
    else
        EnableFlag=0;
    end
    
%     FormatList=get(handles.ListboxFormat, 'String');
%     CurrentV=get(handles.ListboxFormat, 'Value');
%     CurrentFormat=FormatList{CurrentV};
%    
%     if isequal(CurrentFormat, 'Pinnacle')
    if EnableFlag > 0
        set(handles.RadiobuttonPinnV9, 'Enable', 'On');
        set(handles.RadiobuttonPinnV8, 'Enable', 'On');
    else
        set(handles.RadiobuttonPinnV9, 'Enable', 'Off');
        set(handles.RadiobuttonPinnV8, 'Enable', 'Off');              
    end
end

function SetImportButtonStatus(handles)
FileName=get(handles.EditFile, 'String');
FormatList=get(handles.ListboxFormat, 'String'); 

if exist(FileName, 'file') == 2 && ~isempty(FormatList)
    set(handles.PushbuttonImport, 'Enable', 'On');
else
     set(handles.PushbuttonImport, 'Enable', 'Off');
end

% --- Outputs from this function are returned to the command line.
function varargout = ROIImportMain_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.structAxialROI;
delete(handles.figure1);



function EditFile_Callback(hObject, eventdata, handles)
% hObject    handle to EditFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditFile as text
%        str2double(get(hObject,'String')) returns contents of EditFile as a double

SetImportButtonStatus(handles);
SetPinRadioButtonStatus(handles);

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

%Get File Name
OldPath=pwd;
cd(handles.ConfigStruct.ImportPath);

[FileName, PathName] = uigetfile({'*.dcm; *.roi; *.mat; *.tif; *.nii', 'ROI Files(*.dcm, *.roi, *.mat, *.tif, *.nii)'; '*.*','All Files(*.*)'} ,'Select the ROI file');

cd(OldPath);

if FileName ~= 0
    handles.ConfigStruct.ImportPath=PathName;
    guidata(handles.figure1, handles);
    
    ROIFileName=[PathName, '\', FileName];
    set(handles.EditFile, 'String', ROIFileName);
end

EditFile_Callback(handles.EditFile, eventdata, handles);  
    


% --- Executes on selection change in ListboxFormat.
function ListboxFormat_Callback(hObject, eventdata, handles)
% hObject    handle to ListboxFormat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListboxFormat contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListboxFormat


% --- Executes during object creation, after setting all properties.
function ListboxFormat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListboxFormat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushbuttonHelp.
function PushbuttonHelp_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

%Format
FormatList=get(handles.ListboxFormat, 'String');
FormatValue=get(handles.ListboxFormat, 'Value');

%Export
ExportFormat=FormatList{FormatValue};
FormatFileName=[MFilePath, '\', MFileName, '.m'];

DisplayMethodHelp(FormatFileName, 1);


% --- Executes on button press in PushbuttonImport.
function PushbuttonImport_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonImport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Set Status
%Status
hFig=findobj(0, 'Type', 'figure', 'Name', 'Import ROIs');
hStatus=StatusProgressTextCenterIFOA('IBEX', 'Importing ROI file ...', hFig);

hFig=findobj(0, 'Type', 'figure');
set(hFig, 'Pointer', 'watch');
drawnow;

FileName=get(handles.EditFile, 'String');

%Format
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

FormatList=get(handles.ListboxFormat, 'String');

SucceedFlag=0;
for i=1:length(FormatList)
    Format=FormatList{i};
    
    fhandle=str2func([MFileName(1:end-4), 'Method_', Format]);
    structAxialROI=fhandle(FileName, handles.ImageDataInfo);
    
    if ~isempty(structAxialROI) && size(structAxialROI, 1) > 0
        %To solve the problem of different slice spacing
        structAxialROI=ResampleROI([], handles.ImageDataInfo, structAxialROI);
        
        SucceedFlag=1;
        break;
    end
end

handles.structAxialROI=structAxialROI;
guidata(handles.figure1, handles);

switch SucceedFlag 
    case 1
        hMsg=MsgboxGuiIFOA('ROI import is done!', 'Done', 'Help', 'modal');
        waitfor(hMsg);
        
        uiresume(handles.figure1);
    case 0
        hMsg=MsgboxGuiIFOA('No ROIs are imported.', 'Fail', 'error', 'modal');
        waitfor(hMsg);
end

%Set Status
hFig=findobj(0, 'Type', 'figure');
set(hFig, 'Pointer', 'arrow');

delete(hStatus);

drawnow;


 function structAxialROIFinal=ResampleROI(ROIBWInfo, ROIImageInfoNew, structAxialROI)

for k=1:length(structAxialROI)           
    %Interpolate
    if isempty(ROIBWInfo)
        %Interpolate ROI when importing ROI
        ContourZLoc={structAxialROI(k).ZLocation}';
        ContourZLoc=cell2mat(ContourZLoc);
        
        MinZLoc=min(ContourZLoc);
        MaxZLoc=max(ContourZLoc);
        
        EmptyFlag=1;
    else
        %Interpolate ROI in ROI editor
        ContourZLoc=ROIBWInfo.ZStart+((1:ROIBWInfo.ZDim)'-1)*ROIBWInfo.ZPixDim;
        
        MinZLoc=min(ContourZLoc);
        MaxZLoc=max(ContourZLoc);
        
        EmptyFlag=0;
    end

    %Initialize 
    structAxialROIFinal(k)=structAxialROI(k);
    structAxialROIFinal(k).ZLocation=[];
    structAxialROIFinal(k).CurvesCor=[];
    structAxialROIFinal(k).OrganCurveNum=0;
    
    ZLocation=structAxialROI(k).ZLocation;
    if isempty(ZLocation)
        if EmptyFlag > 0
            ROIBWInfo=[];
        end
        
        continue;
    end
    
    
    %BW Fill ROI
    if isempty(ROIBWInfo)
        ROIBWInfo.XPixDim=ROIImageInfoNew.XPixDim;
        ROIBWInfo.YPixDim=ROIImageInfoNew.YPixDim;
        
        ROIBWInfo=BWFillROINoZPix(ROIBWInfo, structAxialROI(k));
    end
    
    for i=1:ROIImageInfoNew.ZDim
        CurrentZLoc=ROIImageInfoNew.ZStart+(i-1)*ROIImageInfoNew.ZPixDim;
        
        if (CurrentZLoc > MinZLoc || abs(CurrentZLoc - MinZLoc)<0.001) && ...
                (CurrentZLoc < MaxZLoc || abs(CurrentZLoc - MaxZLoc)<0.001)
            
            TempIndex=find(abs(CurrentZLoc-ZLocation) <= 2*ROIImageInfoNew.ZPixDim/100);
            
            if ~isempty(TempIndex)
                %Copy ROIs
                ResultCurve=structAxialROI(k).CurvesCor(TempIndex);
            else
                ResultCurve=InterpolateROI(ROIBWInfo, CurrentZLoc, ContourZLoc);
            end
            
            %Update structAxialROI
            for j=1:length(ResultCurve)
                structAxialROIFinal(k).ZLocation=[structAxialROIFinal(k).ZLocation; CurrentZLoc];
                structAxialROIFinal(k).CurvesCor=[structAxialROIFinal(k).CurvesCor; ResultCurve(j)];
                structAxialROIFinal(k).OrganCurveNum=structAxialROIFinal(k).OrganCurveNum+1;
            end
            
        end
    end
    
    if EmptyFlag > 0
        ROIBWInfo=[];
    end
end

% --- Executes on button press in PushbuttonExit.
function PushbuttonExit_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.structAxialROI=[];
guidata(handles.figure1, handles);

uiresume(handles.figure1);

% --- Executes on button press in RadiobuttonPinnV9.
function RadiobuttonPinnV9_Callback(hObject, eventdata, handles)
% hObject    handle to RadiobuttonPinnV9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RadiobuttonPinnV9
if isequal(get(hObject,'Value'), 1) 
    set(handles.RadiobuttonPinnV8, 'Value', 0);
else
    set(handles.RadiobuttonPinnV8, 'Value', 1);
end


% --- Executes on button press in RadiobuttonPinnV8.
function RadiobuttonPinnV8_Callback(hObject, eventdata, handles)
% hObject    handle to RadiobuttonPinnV8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RadiobuttonPinnV8

if isequal(get(hObject,'Value'), 1) 
    set(handles.RadiobuttonPinnV9, 'Value', 0);
else
    set(handles.RadiobuttonPinnV9, 'Value', 1);
end



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
PushbuttonExit_Callback(handles.PushbuttonExit, eventdata, handles);
