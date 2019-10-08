function varargout = NewPlugIn(varargin)
% NEWPLUGIN MATLAB code for NewPlugIn.fig
%      NEWPLUGIN, by itself, creates a new NEWPLUGIN or raises the existing
%      singleton*.
%
%      H = NEWPLUGIN returns the handle to a new NEWPLUGIN or the handle to
%      the existing singleton*.
%
%      NEWPLUGIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEWPLUGIN.M with the given input arguments.
%
%      NEWPLUGIN('Property','Value',...) creates a new NEWPLUGIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NewPlugIn_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NewPlugIn_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NewPlugIn

% Last Modified by GUIDE v2.5 09-May-2014 13:55:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NewPlugIn_OpeningFcn, ...
                   'gui_OutputFcn',  @NewPlugIn_OutputFcn, ...
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


% --- Executes just before NewPlugIn is made visible.
function NewPlugIn_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NewPlugIn (see VARARGIN)

PlugInName=varargin{2};
PFig=varargin{3};
CurrentPlugIn=varargin{4};
FigureTitle=varargin{5};
ButtonName=varargin{6};

handles.NewPlugInName='';
handles.CurrentPlugIn=CurrentPlugIn;

set(handles.TextTitle, 'String', PlugInName);
set(handles.EditPlugInName, 'String', handles.NewPlugInName);
set(handles.figure1, 'Name', FigureTitle);
set(handles.PushbuttonCreate, 'String', ButtonName);

CenterFigBottomCenter(handles.figure1, PFig);


% Choose default command line output for NewPlugIn
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NewPlugIn wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NewPlugIn_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.NewPlugInName;
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

guidata(handles.figure1, handles);

uiresume(handles.figure1);


% --- Executes on button press in PushbuttonCancel.
function PushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.NewPlugInName=[];
guidata(handles.figure1, handles);

uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
PushbuttonCancel_Callback(handles.PushbuttonCancel, eventdata, handles);
