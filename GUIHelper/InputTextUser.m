function varargout = InputTextUser(varargin)
% INPUTTEXTUSER M-file for InputTextUser.fig
%      INPUTTEXTUSER, by itself, creates a new INPUTTEXTUSER or raises the existing
%      singleton*.
%
%      H = INPUTTEXTUSER returns the handle to a new INPUTTEXTUSER or the handle to
%      the existing singleton*.
%
%      INPUTTEXTUSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INPUTTEXTUSER.M with the given input arguments.
%
%      INPUTTEXTUSER('Property','Value',...) creates a new INPUTTEXTUSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before InputTextMachine_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to InputTextUser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help InputTextUser

% Last Modified by GUIDE v2.5 29-Oct-2013 12:50:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @InputTextUser_OpeningFcn, ...
                   'gui_OutputFcn',  @InputTextUser_OutputFcn, ...
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


% --- Executes just before InputTextUser is made visible.
function InputTextUser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to InputTextUser (see VARARGIN)


handles.StrText=varargin{2};
handles.StrEdit=varargin{3};
handles.StrOrgans=varargin{4};
handles.ProgramPath=varargin{5};

set(handles.TextStr, 'String', handles.StrText);
set(handles.EditText, 'String', handles.StrEdit);


%Set position to half inital width
OldUnit=get(handles.figure1, 'Units');

set(handles.figure1, 'Units', 'pixels');
GcfPos=get(handles.figure1, 'Position');

set(0,'Units','pixels')
scnsize = get(0,'ScreenSize');

set(handles.figure1, 'Position', [round((scnsize(3)-GcfPos(3))/2), round((scnsize(4)-GcfPos(4))/2), GcfPos(3), GcfPos(4)]);

set(handles.figure1, 'Units', OldUnit);


% Choose default command line output for InputTextUser
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%Change ICon
figure(handles.figure1);
drawnow;


uicontrol(handles.EditText);

% UIWAIT makes InputTextUser wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = InputTextUser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.StrEdit;

delete(handles.figure1);



function EditText_Callback(hObject, eventdata, handles)
% hObject    handle to EditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditText as text
%        str2double(get(hObject,'String')) returns contents of EditText as a double

TempStr=get(hObject,'String');
Index=strmatch(TempStr, handles.StrOrgans,  'exact');

if isempty(Index)
   handles.StrEdit=TempStr;
else
    MsgboxGuiIFOA('This name is already taken.', 'Prompt', 'help');
    set(handles.EditText, 'String', handles.StrEdit);
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EditText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushbuttonOK.
function PushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


Index=strmatch(handles.StrEdit, handles.StrOrgans,  'exact');

if isempty(Index)
   uiresume(handles.figure1);
else
    MsgboxGuiIFOA('This name is already taken.', 'Prompt', 'help');
    set(handles.EditText, 'String', handles.StrEdit);
end



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

handles.StrEdit='';
guidata(handles.figure1, handles);

uiresume(handles.figure1);




% --- Executes on button press in PushbuttonCancel.
function PushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure1_CloseRequestFcn(hObject, eventdata, handles);
