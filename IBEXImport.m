function varargout = IBEXImport(varargin)
% IBEXIMPORT MATLAB code for IBEXImport.fig
%      IBEXIMPORT, by itself, creates a new IBEXIMPORT or raises the existing
%      singleton*.
%
%      H = IBEXIMPORT returns the handle to a new IBEXIMPORT or the handle to
%      the existing singleton*.
%
%      IBEXIMPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IBEXIMPORT.M with the given input arguments.
%
%      IBEXIMPORT('Property','Value',...) creates a new IBEXIMPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IBEXImport_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IBEXImport_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IBEXImport

% Last Modified by GUIDE v2.5 19-Nov-2014 12:02:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IBEXImport_OpeningFcn, ...
                   'gui_OutputFcn',  @IBEXImport_OutputFcn, ...
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


% --- Executes just before IBEXImport is made visible.
function IBEXImport_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IBEXImport (see VARARGIN)

handles.ParentHandle=varargin{2};

%Check the data path
PatDataPath=[handles.ParentHandle.INIConfigInfo.DataDir, '\', handles.ParentHandle.CurrentUser, '\', handles.ParentHandle.CurrentSite];

if isempty(handles.ParentHandle.CurrentUser) || isempty(handles.ParentHandle.CurrentSite) || ~exist(PatDataPath, 'dir')
    MsgboxGuiIFOA('Please select location first!', 'Warn', 'warn');
    delete(handles.figure1);
    
    return;
end

%Parse import filter
ProgramPath=fileparts(mfilename('fullpath'));

DataDir=[ProgramPath, '\ImportExport\ImportModule'];
ImportDir=DisplayListboxDir(DataDir, handles);

%Set Status
ListboxDataType_Callback(handles.ListboxDataType, [], handles);

%Add import filter path
AddImportFilterPath;

handles.ProgramPath=ProgramPath;
handles.ImportDir=ImportDir;

%Set position
set(handles.ParentHandle.figure1, 'Units', 'pixels');
ParentPos=get(handles.ParentHandle.figure1, 'Position');

set(handles.figure1, 'Units', 'pixels');
GcfPos=get(handles.figure1, 'Position');

set(handles.figure1, 'Position', [ParentPos(1)+(ParentPos(3)-GcfPos(3)), ParentPos(2)+(ParentPos(4)-GcfPos(4)), GcfPos(3), GcfPos(4)]);

set(handles.figure1, 'Units', 'characters');


%Change application Icon
figure(handles.figure1);
drawnow;

uicontrol(handles.ListboxDataType);

% Choose default command line output for IBEXImport
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes IBEXImport wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function ImportDir=DisplayListboxDir(DataDir, handles)

DirList=GetImportModuleList(DataDir);

%Exclude ROI importers, Keep only patient importers
TempIndex=strmatch('ROI', DirList, 'exact');
if ~isempty(TempIndex)
    DirList(TempIndex)=[];
end

if isempty(DirList)
    set(handles.ListboxDataType, 'String', {' '}, 'Enable', 'off', 'Value', [], 'Min', 0, 'Max', 2, 'Listboxtop', 1, 'Enable', 'off');
else
    set(handles.ListboxDataType, 'String', DirList, 'Enable', 'off', 'Value', [], 'Min', 0, 'Max', 2, 'Listboxtop', 1, 'Enable', 'on');
end

ImportDir=DirList;




% --- Outputs from this function are returned to the command line.
function varargout = IBEXImport_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in ListboxDataType.
function ListboxDataType_Callback(hObject, eventdata, handles)
% hObject    handle to ListboxDataType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListboxDataType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListboxDataType

CurrentIndex=get(handles.ListboxDataType, 'Value');

if isempty(CurrentIndex)
    set(handles.PushbuttonNext, 'Enable', 'off'); 
    set(handles.PushbuttonConfig, 'Enable', 'off'); 
else
    if length(CurrentIndex) < 2
        set(handles.PushbuttonNext, 'Enable', 'on');
        set(handles.PushbuttonConfig, 'Enable', 'on');
    else
        set(handles.PushbuttonNext, 'Enable', 'off');
        set(handles.PushbuttonConfig, 'Enable', 'off');
        
        set(handles.ListboxDataType, 'String', handles.ImportDir, 'Enable', 'off', 'Value', [], 'Min', 0, 'Max', 2, 'Listboxtop', 1, 'Enable', 'on');
    
        MsgboxGuiIFOA('Only one module can be selected!', 'Warn', 'warn');
    end
end


% --- Executes during object creation, after setting all properties.
function ListboxDataType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListboxDataType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushbuttonNext.
function PushbuttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CurrentIndex=get(handles.ListboxDataType, 'Value');
if isempty(CurrentIndex)
    return;
end

ModuleName=handles.ImportDir{CurrentIndex};
ImportFuncHandle=str2func([ModuleName, 'ImportMain']);

handles.ParentHandle=CleanUpWSHandle(handles.ParentHandle);
handles.ParentHandle.Anonymize=get(handles.CheckboxAnonymize, 'Value');

ReturnFlag=ImportFuncHandle(handles.ParentHandle);
if ReturnFlag > 0
    PushbuttonExit_Callback(handles.PushbuttonExit, [], handles);
end


% --- Executes on button press in PushbuttonExit.
function PushbuttonExit_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure1_CloseRequestFcn(hObject, eventdata, handles);

% --- Executes on button press in PushbuttonConfig.
function PushbuttonConfig_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CurrentIndex=get(handles.ListboxDataType, 'Value');
if isempty(CurrentIndex)
    return;
end

ModuleName=handles.ImportDir{CurrentIndex};
ConfigFile=[handles.ProgramPath, '\ImportModule\',  ModuleName, '\', ModuleName, 'ImportMain.INI'];

if exist(ConfigFile, 'file')
    winopen(ConfigFile);
else
    MsgboxGuiIFOA('Configuration file doesn''t exit!', 'Warn', 'warn');
end    


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure


delete(handles.figure1);


% --- Executes on button press in CheckboxAnonymize.
function CheckboxAnonymize_Callback(hObject, eventdata, handles)
% hObject    handle to CheckboxAnonymize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CheckboxAnonymize
