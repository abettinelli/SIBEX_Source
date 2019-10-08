function varargout = GetMissDCMTag(varargin)
% GETMISSDCMTAG MATLAB code for GetMissDCMTag.fig
%      GETMISSDCMTAG, by itself, creates a new GETMISSDCMTAG or raises the existing
%      singleton*.
%
%      H = GETMISSDCMTAG returns the handle to a new GETMISSDCMTAG or the handle to
%      the existing singleton*.
%
%      GETMISSDCMTAG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GETMISSDCMTAG.M with the given input arguments.
%
%      GETMISSDCMTAG('Property','Value',...) creates a new GETMISSDCMTAG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GetMissDCMTag_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GetMissDCMTag_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GetMissDCMTag

% Last Modified by GUIDE v2.5 15-Sep-2014 15:48:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GetMissDCMTag_OpeningFcn, ...
                   'gui_OutputFcn',  @GetMissDCMTag_OutputFcn, ...
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


% --- Executes just before GetMissDCMTag is made visible.
function GetMissDCMTag_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GetMissDCMTag (see VARARGIN)

DCMTags=varargin{2};
MissNote=varargin{3};

set(handles.TextNote, 'String', MissNote);

InitializeUITablePara(DCMTags, handles);

handles.TableData=[];

% Choose default command line output for GetMissDCMTag
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GetMissDCMTag wait for user response (see UIRESUME)
uiwait(handles.figure1);

function InitializeUITablePara(Param, handles)
TableHeader=[];
TableHeader=[TableHeader, {['<html><b><center><font size="4" face="Calibri" color="rgb(0,0,100)">', 'Para.']}];
TableHeader=[TableHeader, {['<html><b><center><font size="4" face="Calibri" color="rgb(0,0,100)">', 'Value']}];

TableFormat={'char', 'char'};

TableEdit=[false, true];
TableWidth={134, 80};
    
TableData(:, 1)=Param;
TableData(:, 2)={' '; ' '};
    

set(handles.UITableDCMTag, 'Visible', 'on', 'Enable', 'on', 'Data', TableData, ...
        'ColumnName', TableHeader, 'ColumnFormat', TableFormat, ...
        'ColumnEditable', logical(TableEdit), 'ColumnWidth', TableWidth); 

% --- Outputs from this function are returned to the command line.
function varargout = GetMissDCMTag_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.TableData;

delete(handles.figure1);


% --- Executes on button press in PushbuttonOK.
function PushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.TableData=get(handles.UITableDCMTag, 'Data');
guidata(handles.figure1, handles);

uiresume(handles.figure1);

% --- Executes on button press in PushbuttonCancel.
function PushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume(handles.figure1);
