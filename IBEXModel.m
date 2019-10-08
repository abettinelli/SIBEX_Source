function varargout = IBEXModel(varargin)
% IBEXMODEL MATLAB code for IBEXModel.fig
%      IBEXMODEL, by itself, creates a new IBEXMODEL or raises the existing
%      singleton*.
%
%      H = IBEXMODEL returns the handle to a new IBEXMODEL or the handle to
%      the existing singleton*.
%
%      IBEXMODEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IBEXMODEL.M with the given input arguments.
%
%      IBEXMODEL('Property','Value',...) creates a new IBEXMODEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IBEXModel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IBEXModel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IBEXModel

% Last Modified by GUIDE v2.5 07-Oct-2014 12:00:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IBEXModel_OpeningFcn, ...
                   'gui_OutputFcn',  @IBEXModel_OutputFcn, ...
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


% --- Executes just before IBEXModel is made visible.
function IBEXModel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IBEXModel (see VARARGIN)

%Initialize
InitializeFig(handles);


% Choose default command line output for IBEXModel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes IBEXModel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function InitializeFig(handles)
%Set text on UI
TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Add <br />Feature</font></html>';
set(handles.PushbuttonAddFeature, 'String', TextStr);

TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Add<br />Expression</font></html>';
set(handles.PushbuttonAddCoe, 'String', TextStr);

TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Delete<br />Component</font></html>';
set(handles.PushbuttonDelete, 'String', TextStr);


% --- Outputs from this function are returned to the command line.
function varargout = IBEXModel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in PushbuttonAddFeature.
function PushbuttonAddFeature_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonAddFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PushbuttonAddCoe.
function PushbuttonAddCoe_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonAddCoe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PushbuttonDelete.
function PushbuttonDelete_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PushbuttonSave.
function PushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
