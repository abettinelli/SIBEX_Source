function varargout = ROIExportMain(varargin)
% ROIEXPORTMAIN MATLAB code for ROIExportMain.fig
%      ROIEXPORTMAIN, by itself, creates a new ROIEXPORTMAIN or raises the existing
%      singleton*.
%
%      H = ROIEXPORTMAIN returns the handle to a new ROIEXPORTMAIN or the handle to
%      the existing singleton*.
%
%      ROIEXPORTMAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROIEXPORTMAIN.M with the given input arguments.
%
%      ROIEXPORTMAIN('Property','Value',...) creates a new ROIEXPORTMAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROIExportMain_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROIExportMain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ROIExportMain

% Last Modified by GUIDE v2.5 12-Jul-2019 11:39:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ROIExportMain_OpeningFcn, ...
                   'gui_OutputFcn',  @ROIExportMain_OutputFcn, ...
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


% --- Executes just before ROIExportMain is made visible.
function ROIExportMain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ROIExportMain (see VARARGIN)

%Input parameters
ExportPath=varargin{2};
structAxialROI=varargin{3};
BWMatInfo=varargin{4};
PatInfo=varargin{5};
PFig=varargin{6};

%Importers
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));
FormatList=GetExportModuleFormatList(MFilePath, MFileName(1:end-4));

%Set UI
set(handles.EditDir, 'String', ExportPath);
set(handles.EditMRN, 'String', PatInfo.MRN);
set(handles.EditName, 'String', [PatInfo.LastName, ', ', PatInfo.FirstName]);
set(handles.ListboxFormat, 'String', FormatList);

[ImageData, CMap]=imread('Question.jpg');
set(handles.PushbuttonHelp, 'CData', ImageData);

if isempty(FormatList)
    set(handles.PushbuttonHelp, 'Enable', 'Off');
else
    set(handles.PushbuttonHelp, 'Enable', 'On');
end

%Set position
CenterFigBottomCenter(handles.figure1, PFig);

% Choose default command line output for ROIExportMain
handles.ExportPath=ExportPath;
handles.structAxialROI=structAxialROI;
handles.BWMatInfo=BWMatInfo;
handles.PatInfo=PatInfo;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ROIExportMain wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ROIExportMain_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.ExportPath;

delete(handles.figure1);


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


% --- Executes on button press in PushbuttonExport.
function PushbuttonExport_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Set Status
hFig=findobj(0, 'Type', 'figure');
set(hFig, 'Pointer', 'watch');
drawnow;


%Save path back
handles.ExportPath=get(handles.EditDir, 'String');
guidata(handles.figure1, handles);

%Get information
MRNStr=get(handles.EditMRN, 'String');

PatStr=get(handles.EditName, 'String');
TempIndex=strfind(PatStr, ',');
if ~isempty(TempIndex)
    LastName=PatStr(1:TempIndex(1)-1);
    FirstName=PatStr(TempIndex(1)+1:end);
else
    TempIndex=strfind(PatStr, ' ');
    if ~isempty(TempIndex)        
        FirstName=PatStr(1:TempIndex(1)-1);
        LastName=PatStr(TempIndex(1)+1:end);
    else
        if ~isempty(PatStr)
            LastName=PatStr;
            FirstName='';
        else
            LastName='IBEX';
            FirstName='';
        end        
    end
end

PatInfo=handles.PatInfo;

PatInfo.MRN=MRNStr;
PatInfo.FirstName=FirstName;
PatInfo.LastName=LastName;

[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

%Format
FormatList=get(handles.ListboxFormat, 'String');
FormatValue=get(handles.ListboxFormat, 'Value');

%Export
ExportFormat=FormatList{FormatValue};
fhandle=str2func([MFileName(1:end-4), 'Method_', ExportFormat]);
ReturnFlag=fhandle(handles.ExportPath, handles.structAxialROI, handles.BWMatInfo, PatInfo);

switch ReturnFlag 
    case 1
        hMsg=MsgboxGuiIFOA(['ROI ', ExportFormat, ' export is done!'], 'Done', 'Help', 'modal');
        waitfor(hMsg);
        
        uiresume(handles.figure1);
    case 0
        hMsg=MsgboxGuiIFOA(['ROI ', ExportFormat, ' export failed!'], 'Fail', 'error', 'modal');
        waitfor(hMsg);
end

%Set Status
hFig=findobj(0, 'Type', 'figure');
set(hFig, 'Pointer', 'arrow');
drawnow;


% --- Executes on button press in PushbuttonExit.
function PushbuttonExit_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ExportPath=[];
guidata(handles.figure1, handles);

uiresume(handles.figure1);


function EditMRN_Callback(hObject, eventdata, handles)
% hObject    handle to EditMRN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditMRN as text
%        str2double(get(hObject,'String')) returns contents of EditMRN as a double


% --- Executes during object creation, after setting all properties.
function EditMRN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditMRN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditName_Callback(hObject, eventdata, handles)
% hObject    handle to EditName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditName as text
%        str2double(get(hObject,'String')) returns contents of EditName as a double


% --- Executes during object creation, after setting all properties.
function EditName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditDir_Callback(hObject, eventdata, handles)
% hObject    handle to EditDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditDir as text
%        str2double(get(hObject,'String')) returns contents of EditDir as a double


NewDir=get(hObject,'String');
if ~exist(NewDir, 'dir')
    try
        mkdir(NewDir);
        handles.ExportPath=NewDir;
        
        guidata(handles.figure1, handles);
    catch
        set(hObject,'String', handles.ExportPath);
    end
end




% --- Executes during object creation, after setting all properties.
function EditDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushbuttonDir.
function PushbuttonDir_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

TempPath=uigetdir(handles.ExportPath, 'Select Export directory:');

if TempPath ~= 0        
    set(handles.EditDir, 'String', TempPath);    
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
PushbuttonExit_Callback(handles.PushbuttonExit, eventdata, handles);


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
FormatFileName=[MFilePath, '\', MFileName(1:end-4), 'Method_', ExportFormat, '.m'];

DisplayMethodHelp(FormatFileName, 1);
