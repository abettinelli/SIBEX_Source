function varargout = DataSetMoveCopy(varargin)
% DATASETMOVECOPY MATLAB code for DataSetMoveCopy.fig
%      DATASETMOVECOPY, by itself, creates a new DATASETMOVECOPY or raises the existing
%      singleton*.
%
%      H = DATASETMOVECOPY returns the handle to a new DATASETMOVECOPY or the handle to
%      the existing singleton*.
%
%      DATASETMOVECOPY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATASETMOVECOPY.M with the given input arguments.
%
%      DATASETMOVECOPY('Property','Value',...) creates a new DATASETMOVECOPY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DataSetMoveCopy_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DataSetMoveCopy_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataSetMoveCopy

% Last Modified by GUIDE v2.5 12-Jul-2019 15:16:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataSetMoveCopy_OpeningFcn, ...
                   'gui_OutputFcn',  @DataSetMoveCopy_OutputFcn, ...
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


% --- Executes just before DataSetMoveCopy is made visible.
function DataSetMoveCopy_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DataSetMoveCopy (see VARARGIN)

handles.DataDir=varargin{2};
PFig=varargin{3};
CDataSetName=varargin{4};
ModeStr=varargin{5};

set(handles.figure1, 'Name', ModeStr);
set(handles.text1, 'String', [ModeStr, ' To: ']);

DisplayListbox(handles.DataDir, handles, CDataSetName);

CenterFigUpCenterUp(handles.figure1, PFig);

% Choose default command line output for DataSetList
handles.output = [];

% Update handles structure
guidata(hObject, handles);

uiwait(handles.figure1);


function DisplayListbox(DataDir, handles, CDataSetName)
FileList=GetFileList(DataDir);

FileList=FilterFlistList(FileList, '.mat');

TempIndex=strmatch(CDataSetName, FileList, 'exact');
FileList(TempIndex)=[];

set(handles.PushbuttonOK, 'Enable', 'off'); 

if isempty(FileList)
    set(handles.ListboxDataSet, 'String', {' '}, 'Enable', 'off', 'Value', [], 'Min', 0, 'Max', 2, 'Listboxtop', 1, 'Enable', 'off');      
else
     set(handles.ListboxDataSet, 'String', FileList, 'Enable', 'off', 'Value', [], 'Min', 0, 'Max', 2, 'Listboxtop', 1, 'Enable', 'on');        
end


function FileList=FilterFlistList(FileList, FilterStr)

for i=length(FileList):-1:1
    CFile=FileList{i};
    
    if ~(length(CFile) > length(FilterStr) && isequal(CFile(end-length(FilterStr)+1: end), FilterStr))
        FileList{i}=[];
    end
end


% --- Outputs from this function are returned to the command line.
function varargout = DataSetMoveCopy_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1);

% --- Executes on selection change in ListboxDataSet.
function ListboxDataSet_Callback(hObject, eventdata, handles)
% hObject    handle to ListboxDataSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListboxDataSet contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListboxDataSet
set(handles.PushbuttonOK, 'Enable', 'on'); 

% --- Executes during object creation, after setting all properties.
function ListboxDataSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListboxDataSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushbuttonOK.
function PushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DataList=get(handles.ListboxDataSet, 'String');
CurrentValue=get(handles.ListboxDataSet, 'Value');

if ~isempty(CurrentValue)
    DataSetName=DataList{CurrentValue};
    handles.output=DataSetName;
    guidata(handles.figure1, handles);
end

uiresume(handles.figure1);


% --- Executes on button press in PushbuttonCancel.
function PushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
uiresume(handles.figure1);
