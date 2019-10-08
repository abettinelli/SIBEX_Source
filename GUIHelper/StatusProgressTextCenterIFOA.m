function varargout = StatusProgressTextCenterIFOA(varargin)
% STATUSPROGRESSTEXTCENTERIFOA M-file for StatusProgressTextCenterIFOA.fig
%      STATUSPROGRESSTEXTCENTERIFOA, by itself, creates a new STATUSPROGRESSTEXTCENTERIFOA or raises the existing
%      singleton*.
%
%      H = STATUSPROGRESSTEXTCENTERIFOA returns the handle to a new STATUSPROGRESSTEXTCENTERIFOA or the handle to
%      the existing singleton*.
%
%      STATUSPROGRESSTEXTCENTERIFOA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STATUSPROGRESSTEXTCENTERIFOA.M with the given input arguments.
%
%      STATUSPROGRESSTEXTCENTERIFOA('Property','Value',...) creates a new STATUSPROGRESSTEXTCENTERIFOA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StatusProgressTextCenter_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StatusProgressTextCenterIFOA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% ==============================
% Copyright (C) 2004
% Lifei(Joy) Zhang
% lifzhang@mdanderson.org
%Department of Radiation Physics
% MD Anderson Cancer Center
% ==============================

%-------Explicit Compile: Begin
%# function StatusProgressTextCenterIFOA_OpeningFcn
%# function figure1_CreateFcn
%# function figure1_DeleteFcn
%# function PushbuttonOk_Callback
%-------Explicit Compile: End


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StatusProgressTextCenterIFOA_OpeningFcn, ...
                   'gui_OutputFcn',  @StatusProgressTextCenterIFOA_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%---Explicit Compilation Beginning
%# function figure1_CreateFcn 
%# function figure1_DeleteFcn
%# function PushbuttonOk_Callback
%# function StatusProgressTextCenterIFOA_OpeningFcn
%# function StatusProgressTextCenterIFOA_OutputFcn
%---Explicit Compilation Ending


% --- Executes just before StatusProgressTextCenterIFOA is made visible.
function StatusProgressTextCenterIFOA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StatusProgressTextCenterIFOA (see VARARGIN)


%Input Data
handles.TextTitle=varargin{1};
handles.TextContent=varargin{2};
ParentFig=varargin{3};


%Display Title and prompting data
set(handles.figure1, 'Name', handles.TextTitle);
set(handles.TextStatus, 'String', handles.TextContent);


%Set Watch
set(handles.figure1, 'Pointer', 'watch');

%Set Position 
OldUnits1=get(handles.figure1, 'Units');
set(handles.figure1, 'Units', 'pixels');
GcfPos=get(handles.figure1, 'Position');

OldUnits2=get(ParentFig, 'Units');
set(ParentFig, 'Units', 'pixels');
ParentPos=get(ParentFig, 'Position');

set(handles.figure1, 'Position', [ParentPos(1)+round((ParentPos(3)-GcfPos(3))/2), ParentPos(2)+round((ParentPos(4)-GcfPos(4))/2), GcfPos(3), GcfPos(4)]);

set(handles.figure1, 'Units', OldUnits1);
set(ParentFig, 'Units', OldUnits2);

%Change application Icon
figure(handles.figure1);
drawnow;


guidata(hObject, handles);

% Choose default command line output for StatusProgressTextCenterIFOA
handles.output = handles.figure1;



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes StatusProgressTextCenterIFOA wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% uiresume;


% --- Outputs from this function are returned to the command line.
function varargout = StatusProgressTextCenterIFOA_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% uiresume;


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PushbuttonOk.
function PushbuttonOk_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonOk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(gcf);
