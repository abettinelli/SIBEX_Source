function varargout = NewPlugInFeature(varargin)
% NEWPLUGINFEATURE MATLAB code for NewPlugInFeature.fig
%      NEWPLUGINFEATURE, by itself, creates a new NEWPLUGINFEATURE or raises the existing
%      singleton*.
%
%      H = NEWPLUGINFEATURE returns the handle to a new NEWPLUGINFEATURE or the handle to
%      the existing singleton*.
%
%      NEWPLUGINFEATURE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEWPLUGINFEATURE.M with the given input arguments.
%
%      NEWPLUGINFEATURE('Property','Value',...) creates a new NEWPLUGINFEATURE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NewPlugInFeature_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NewPlugInFeature_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NewPlugInFeature

% Last Modified by GUIDE v2.5 09-May-2014 14:37:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NewPlugInFeature_OpeningFcn, ...
                   'gui_OutputFcn',  @NewPlugInFeature_OutputFcn, ...
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


% --- Executes just before NewPlugInFeature is made visible.
function NewPlugInFeature_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NewPlugInFeature (see VARARGIN)

PFig=varargin{2};
CurrentPlugIn=varargin{3};

handles.NewPlugInName='';
handles.FeatureName='';
handles.CurrentPlugIn=CurrentPlugIn;

set(handles.EditPlugInName, 'String', handles.NewPlugInName);
set(handles.UITableFeature, 'Data', '');

CenterFigBottomCenter(handles.figure1, PFig);

SetStatus(handles);
SetStatusDelete(handles);



% Choose default command line output for NewPlugInFeature
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NewPlugInFeature wait for user response (see UIRESUME)
uiwait(handles.figure1);


function SetStatus(handles)
NewPlugInName=get(handles.EditPlugInName, 'String');
TableData=get(handles.UITableFeature, 'Data');

if ~isempty(NewPlugInName) && ~isempty(TableData)
    set(handles.PushbuttonCreate, 'Enable', 'on');
else
    set(handles.PushbuttonCreate, 'Enable', 'off');
end

% --- Outputs from this function are returned to the command line.
function varargout = NewPlugInFeature_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.NewPlugInName;
varargout{2} = handles.FeatureName;

delete(handles.figure1);



function EditPlugInName_Callback(hObject, eventdata, handles)
% hObject    handle to EditPlugInName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditPlugInName as text
%        str2double(get(hObject,'String')) returns contents of EditPlugInName as a double

NewPlugInName=get(handles.EditPlugInName, 'String');
if ~isempty(NewPlugInName)
    %Remove Special character
    SpecialChar={'!'; ':'; char(34); '#'; '\$'; '%'; '&'; '`'; '('; ')'; '\*'; '\+';  '/'; ';'; '<'; '='; '>'; '\?'; '@'; ','; '\.'; '[';  ']'; char(39); '{'; '\|'; '}'; '~'; ' '};
    NewPlugInName=regexprep(NewPlugInName, SpecialChar, '');
    
    set(handles.EditPlugInName, 'String', NewPlugInName);
    
    %Exist?
    TT=strcmpi(NewPlugInName, handles.CurrentPlugIn);
    TempIndex=find(TT);
    
    if ~isempty(TempIndex)
        MsgboxGuiIFOA('This name is already taken.', 'Prompt', 'help');
        set(handles.EditPlugInName, 'String', '');
    end    
end

SetStatus(handles);


% --- Executes during object creation, after setting all properties.
function EditPlugInName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditPlugInName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushbuttonCreate.
function PushbuttonCreate_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonCreate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

NewPlugInName=get(handles.EditPlugInName, 'String');
if ~isempty(NewPlugInName)
    handles.NewPlugInName=NewPlugInName;
else
    handles.NewPlugInName=[];
end

TableData=get(handles.UITableFeature, 'Data');
if isempty(TableData)
    handles.FeatureName=[];
else
    handles.FeatureName=TableData(:, 2);    
end

guidata(handles.figure1, handles);

uiresume(handles.figure1);


% --- Executes on button press in PushbuttonCancel.
function PushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.NewPlugInName=[];
handles.FeatureName=[];

guidata(handles.figure1, handles);

uiresume(handles.figure1);


% --- Executes on button press in PushbuttonNew.
function PushbuttonNew_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonNew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

TableData=get(handles.UITableFeature, 'Data');
if isempty(TableData)
    FeatureName=[];
else
    FeatureName=TableData(:, 2);    
end

FeatureName=NewPlugIn(1, 'New Feature', handles.figure1, FeatureName, 'New', 'Add');

if ~isempty(FeatureName)   
    TableData=[TableData; {false}, {FeatureName}];
    set(handles.UITableFeature, 'Data', TableData);
end

SetStatus(handles);


% --- Executes on button press in PushbuttonDelete.
function PushbuttonDelete_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Delete
TableData=get(handles.UITableFeature, 'Data');

SelectMat=TableData(:, 1);
SelectMat=cell2mat(SelectMat);

TempIndex=find(SelectMat);

TableData(TempIndex, :)=[];

set(handles.UITableFeature, 'Data', TableData);

%Set Status
SetStatus(handles);
SetStatusDelete(handles);


% --- Executes when entered data in editable cell(s) in UITableFeature.
function UITableFeature_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to UITableFeature (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

SetStatusDelete(handles);

function SetStatusDelete(handles)
TableData=get(handles.UITableFeature, 'Data');

if ~isempty(TableData)
    SelectMat=TableData(:, 1);
    SelectMat=cell2mat(SelectMat);
    
    TempIndex=find(SelectMat);
    if ~isempty(TempIndex)
        set(handles.PushbuttonDelete, 'Enable', 'On');
    else
        set(handles.PushbuttonDelete, 'Enable', 'Off');
    end
else
    set(handles.PushbuttonDelete, 'Enable', 'Off');
end
        


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
PushbuttonCancel_Callback(handles.PushbuttonCancel, eventdata, handles);
