function varargout = DataSetList(varargin)
% DATASETLIST MATLAB code for DataSetList.fig
%      DATASETLIST, by itself, creates a new DATASETLIST or raises the existing
%      singleton*.
%
%      H = DATASETLIST returns the handle to a new DATASETLIST or the handle to
%      the existing singleton*.
%
%      DATASETLIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATASETLIST.M with the given input arguments.
%
%      DATASETLIST('Property','Value',...) creates a new DATASETLIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DataSetList_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DataSetList_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataSetList

% Last Modified by GUIDE v2.5 12-Jul-2019 09:41:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataSetList_OpeningFcn, ...
                   'gui_OutputFcn',  @DataSetList_OutputFcn, ...
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


% --- Executes just before DataSetList is made visible.
function DataSetList_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DataSetList (see VARARGIN)

DataDir=varargin{2};
PFig=varargin{3};

 handles.SimpleFormatDisplay=0;
 
if length(varargin) == 4
    handles.SimpleFormatDisplay=1;
else
    handles.SimpleFormatDisplay=0;
end

if length(varargin) == 5  %Reviw 
    handles.TestType=varargin{4};
    handles.TestStruct=varargin{5};
end
       
handles.DataDir=[DataDir, '\1FeatureDataSet_ImageROI'];

DisplayListbox(handles.DataDir, handles);

CenterFigCenterLeft(handles.figure1, PFig);

% Choose default command line output for DataSetList
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DataSetList wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DataSetList_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in ListboxDataSet.
function ListboxDataSet_Callback(hObject, eventdata, handles)
% hObject    handle to ListboxDataSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListboxDataSet contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListboxDataSet
set(handles.ListboxDataSet,  'Min', 0, 'Max', 1, 'Listboxtop', 1);

set(handles.PushbuttonOpen, 'Enable', 'on'); 
set(handles.PushbuttonAnonymize, 'Enable', 'on'); 


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


% --- Executes on button press in PushbuttonOpen.
function PushbuttonOpen_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(handles.ListboxDataSet,'String'));
DataSetName=contents{get(handles.ListboxDataSet,'Value')};
 
FigAll=findobj(0, 'Type', 'figure');
set(FigAll, 'Pointer', 'watch');
drawnow;

if isfield(handles, 'TestType')
    hFig=DataSetCurrent(1, handles.DataDir, DataSetName, handles.TestType, handles.TestStruct);
else
    hFig=DataSetCurrent(1, handles.DataDir, DataSetName, handles.SimpleFormatDisplay);
end

TempName=get(hFig, 'name');
SetTopWindow(TempName);
pause(0.01);
drawnow;


FigAll=findobj(0, 'Type', 'figure');
set(FigAll, 'Pointer', 'arrow');
drawnow;

delete(handles.figure1);

% --- Executes on button press in PushbuttonNew.
function PushbuttonNew_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonNew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

TempName=InputTextIFOA(1, 'New Data Set Name: ',  ['DataSet_', datestr(now, 30)], get(handles.ListboxDataSet, 'String'), handles.figure1);

if isempty(TempName)
    return;
end

if length(TempName < 4) || ~isequal(TempName(end-3:end), '.mat')
    FileName=[TempName, '.mat'];
else
    FileName=TempName;
end

DataSetsInfo=[];
save([handles.DataDir, '\', FileName], 'DataSetsInfo');

DisplayListbox(handles.DataDir, handles);

DataSetList=get(handles.ListboxDataSet, 'String');
CurrentValue=strmatch(FileName, DataSetList, 'exact');
set(handles.ListboxDataSet, 'Value', CurrentValue, 'ListboxTop', 1);

ListboxDataSet_Callback(handles.ListboxDataSet, [], handles);

PushbuttonOpen_Callback(handles.PushbuttonOpen, [], handles);


function DisplayListbox(DataDir, handles)
FileList=GetFileList(DataDir);

FileList=FilterFlistList(FileList, '.mat');

if isempty(FileList)
    set(handles.ListboxDataSet, 'String', {' '}, 'Enable', 'off', 'Value', [], 'Min', 0, 'Max', 2, 'Listboxtop', 1, 'Enable', 'off');    
else
     set(handles.ListboxDataSet, 'String', FileList, 'Enable', 'off', 'Value', [], 'Min', 0, 'Max', 2, 'Listboxtop', 1, 'Enable', 'on');        
end
set(handles.PushbuttonOpen, 'Enable', 'off'); 
set(handles.PushbuttonAnonymize, 'Enable', 'off'); 

function FileList=FilterFlistList(FileList, FilterStr)

for i=length(FileList):-1:1
    CFile=FileList{i};
    
    if ~(length(CFile) > length(FilterStr) && isequal(CFile(end-length(FilterStr)+1: end), FilterStr))
        FileList{i}=[];
    end
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.figure1);

% --- Executes on button press in PushbuttonAnonymize.
function PushbuttonAnonymize_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonAnonymize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Answer = QuestdlgIFOA('Patient''s information will be anonymized! Continue?', 'Confirm','Continue','Cancel', 'Continue');
if ~isequal(Answer, 'Continue')
    return;
end

contents = cellstr(get(handles.ListboxDataSet,'String'));
DataSetName=contents{get(handles.ListboxDataSet,'Value')};
 
FigAll=findobj(0, 'Type', 'figure');
set(FigAll, 'Pointer', 'watch');
drawnow;

DataSetFile=[handles.DataDir, '\', DataSetName];

load(DataSetFile, '-mat', 'DataSetsInfo');

if exist('DataSetsInfo', 'var') && ~isempty(DataSetsInfo)
    for i=1:size(DataSetsInfo, 1)
        LastName=['Pat', num2str(i)];
        FirstName=' ';
        MiddleName=' ';
        MRN='111111';
        
       DataSetsInfo(i).DBName=[LastName, '^', FirstName];       
       DataSetsInfo(i).MRN=MRN;
    end
    
    save(DataSetFile, 'DataSetsInfo');
end

FigAll=findobj(0, 'Type', 'figure');
set(FigAll, 'Pointer', 'arrow');
drawnow;
