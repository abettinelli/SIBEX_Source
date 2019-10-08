function varargout = FeatureSetList(varargin)
% FEATURESETLIST MATLAB code for FeatureSetList.fig
%      FEATURESETLIST, by itself, creates a new FEATURESETLIST or raises the existing
%      singleton*.
%
%      H = FEATURESETLIST returns the handle to a new FEATURESETLIST or the handle to
%      the existing singleton*.
%
%      FEATURESETLIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FEATURESETLIST.M with the given input arguments.
%
%      FEATURESETLIST('Property','Value',...) creates a new FEATURESETLIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FeatureSetList_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FeatureSetList_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FeatureSetList

% Last Modified by GUIDE v2.5 21-Jan-2014 15:48:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FeatureSetList_OpeningFcn, ...
                   'gui_OutputFcn',  @FeatureSetList_OutputFcn, ...
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


% --- Executes just before FeatureSetList is made visible.
function FeatureSetList_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FeatureSetList (see VARARGIN)

DataDir=varargin{2};
PFig=varargin{3};

if length(varargin)> 3
    handles.TestType=varargin{4};
    handles.TestStruct=varargin{5};
end
       
handles.DataDir=[DataDir, '\1FeatureModelSet_Algorithm'];

DisplayListbox(handles.DataDir, handles);

CenterFig(handles.figure1, PFig);

% Choose default command line output for FeatureSetList
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FeatureSetList wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FeatureSetList_OutputFcn(hObject, eventdata, handles) 
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

hFig=FeatureSetCurrent(1, handles.DataDir, DataSetName);

% TempName=get(hFig, 'name');
% SetTopWindow(TempName);
% pause(0.01);
% drawnow;


FigAll=findobj(0, 'Type', 'figure');
set(FigAll, 'Pointer', 'arrow');
drawnow;

PushbuttonExit_Callback(handles.PushbuttonExit, eventdata, handles);

% --- Executes on button press in PushbuttonExit.
function PushbuttonExit_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.figure1);


% --- Executes on button press in PushbuttonNew.
function PushbuttonNew_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonNew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

TempName=InputTextIFOA(1, 'New Feature Set Name: ',  ['FeatureSet_', datestr(now, 30)], get(handles.ListboxDataSet, 'String'), handles.figure1);

if isempty(TempName)
    return;
end

if length(TempName < 4) || ~isequal(TempName(end-3:end), '.mat')
    FileName=[TempName, '.mat'];
else
    FileName=TempName;
end

FeatureSetsInfo=[];
save([handles.DataDir, '\', FileName], 'FeatureSetsInfo');

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

PushbuttonExit_Callback(handles.PushbuttonExit, eventdata, handles);
