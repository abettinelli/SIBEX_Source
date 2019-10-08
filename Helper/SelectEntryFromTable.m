function varargout = SelectEntryFromTable(varargin)
% SELECTENTRYFROMTABLE MATLAB code for SelectEntryFromTable.fig
%      SELECTENTRYFROMTABLE, by itself, creates a new SELECTENTRYFROMTABLE or raises the existing
%      singleton*.
%
%      H = SELECTENTRYFROMTABLE returns the handle to a new SELECTENTRYFROMTABLE or the handle to
%      the existing singleton*.
%
%      SELECTENTRYFROMTABLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTENTRYFROMTABLE.M with the given input arguments.
%
%      SELECTENTRYFROMTABLE('Property','Value',...) creates a new SELECTENTRYFROMTABLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SelectEntryFromTable_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SelectEntryFromTable_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SelectEntryFromTable

% Last Modified by GUIDE v2.5 11-Nov-2013 11:51:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SelectEntryFromTable_OpeningFcn, ...
                   'gui_OutputFcn',  @SelectEntryFromTable_OutputFcn, ...
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


% --- Executes just before SelectEntryFromTable is made visible.
function SelectEntryFromTable_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SelectEntryFromTable (see VARARGIN)

RawData=varargin{2};
TextStr=varargin{3};
TableFieldWidth=varargin{4};
ParentGcf=varargin{5};

%Set Position
SetFigPos(ParentGcf, handles.figure1);

%Set Text
set(handles.TextStr, 'String', TextStr);

%Set Table
TableHeader=fieldnames(RawData);
TableData=struct2cell(RawData);
TableData=reshape(TableData, [size(TableData, 1), size(TableData, 3)]);
TableData=TableData';

TableHeader=FormatTableHeader(TableHeader);
TableEdit=[true, repmat(false, 1,  size(TableData, 2))];
TableFormat=[{'logical'},  repmat({'char'}, 1,  size(TableData, 2))];

TableData=[repmat({false}, size(TableData, 1), 1), TableData];
TableColWidth=[{40}, TableFieldWidth];


set(handles.UITableData, 'Visible', 'on', 'Enable', 'on', 'Data', TableData, ...
        'ColumnName', TableHeader, 'ColumnFormat', TableFormat, ...
        'ColumnEditable', TableEdit, 'ColumnWidth', TableColWidth); 

figure(handles.figure1);

%Set Table
jScroll = findjobj(handles.UITableData);
try jScroll = jScroll(1); jScroll = jScroll.getViewport;  catch, end  % may possibly already be the viewport
try jScroll = jScroll.getComponent(0).getViewport;  catch, end  % HG2
jUITable= jScroll.getView;

%Set Table resize
jUITable.setAutoResizeMode(jUITable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);
jUITable.setColumnResizable(true);
jUITable.setRowResizable(true);
jUITable.setRowHeight(23);

handles.jUITable=jUITable;
    
% Choose default command line output for SelectEntryFromTable
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SelectEntryFromTable wait for user response (see UIRESUME)
uiwait(handles.figure1);


function SetFigPos(ParentGcf, CurrentFig)
OldUnit=get(ParentGcf, 'Units');
set(ParentGcf, 'Units', 'pixels');
ParentPos=get(ParentGcf, 'Position');
set(ParentGcf, 'Units', OldUnit);

OldUnit=get(CurrentFig, 'Units');
set(CurrentFig, 'Units', 'pixels');
FigPos=get(CurrentFig, 'Position');

set(CurrentFig, 'Position', [ParentPos(1), ParentPos(2)+ParentPos(4)-FigPos(4), FigPos(3), FigPos(4)]);

set(CurrentFig, 'Units', 'normalized');
hChild=get(CurrentFig, 'Children');
set(hChild, 'Units', 'normalized');



% --- Outputs from this function are returned to the command line.
function varargout = SelectEntryFromTable_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Get default command line output from handles structure

varargout{1} = handles.GoFlag;

if handles.GoFlag > 0
    TableData=get(handles.UITableData, 'Data');
    SelectIndex=TableData(:, 1);
    SelectIndex=cell2mat(SelectIndex);
else
    SelectIndex=[];
end

varargout{2}=SelectIndex;

delete(handles.figure1);


% --- Executes on button press in PushbuttonOK.
function PushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.GoFlag=1;
guidata(handles.figure1, handles);

uiresume(handles.figure1);

% --- Executes on button press in PushbuttonCancel.
function PushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.GoFlag=0;
guidata(handles.figure1, handles);

uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
PushbuttonCancel_Callback(handles.PushbuttonCancel, [], handles);
