function varargout = DataSetCurrent(varargin)
% DATASETCURRENT MATLAB code for DataSetCurrent.fig
%      DATASETCURRENT, by itself, creates a new DATASETCURRENT or raises the existing
%      singleton*.
%
%      H = DATASETCURRENT returns the handle to a new DATASETCURRENT or the handle to
%      the existing singleton*.
%
%      DATASETCURRENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATASETCURRENT.M with the given input arguments.
%
%      DATASETCURRENT('Property','Value',...) creates a new DATASETCURRENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DataSetCurrent_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DataSetCurrent_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataSetCurrent

% Last Modified by GUIDE v2.5 17-Jun-2015 10:13:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataSetCurrent_OpeningFcn, ...
                   'gui_OutputFcn',  @DataSetCurrent_OutputFcn, ...
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


% --- Executes just before DataSetCurrent is made visible.
function DataSetCurrent_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DataSetCurrent (see VARARGIN)

handles.DataDir= varargin{2}; 
DataSetName= varargin{3};

handles.SimpleFormatDisplay=0;

if length(varargin) == 4
    handles.SimpleFormatDisplay= varargin{4};
end

if length(varargin) == 5
    handles.TestType=varargin{4};
    handles.TestStruct=varargin{5};
    
    set(handles.TextTestType, 'String', 'Test Info.:');
    InfoStr=GetTestInfoStr(handles);
    set(handles.TextTestInfo, 'String', InfoStr);
    
    set(handles.PushbuttonReview, 'String', 'Test');
    
    handles.SimpleFormatDisplay=0;
else
    set(handles.TextTestType, 'String', '');
    set(handles.TextTestInfo, 'String', '');
end

if handles.SimpleFormatDisplay > 0
    set(handles.PushbuttonReview, 'Visible', 'Off');
    set(handles.PushbuttonDelete, 'Visible', 'Off');
    set(handles.PushbuttonMove, 'Visible', 'Off');
    set(handles.PushbuttonCopy, 'Visible', 'Off');
end

set(handles.TextDataSetName, 'String', DataSetName);

DataSetFile=[handles.DataDir, '\', DataSetName];

[Flag, TableDataItemID, DataSetsInfo]=UpdateTableDataSetDisplay(DataSetFile, handles);
if Flag < 1
    MsgboxGuiIFOA('Data Set file is corrupted.', 'Warn', 'warn');
    
    delete(handles.figure1);
    return;
end

set(handles.TextDataSetName, 'String', DataSetName);
set(handles.TextNum, 'String', [num2str(length(TableDataItemID)), ' items']);

handles.TableDataItemID=TableDataItemID;
handles.DataSetFile=DataSetFile;
handles.DataSetsInfo=DataSetsInfo;
handles.DataSetName=DataSetName;

CenterFigBottomCenter(handles.figure1);

if handles.SimpleFormatDisplay > 0
    UpdateTextWithFormatInfo(handles);    
end

%Get JTable
figure(handles.figure1);

jScroll = findjobj(handles.UITableDataSet);
try jScroll = jScroll(1); jScroll = jScroll.getViewport;  catch, end  % may possibly already be the viewport
try jScroll = jScroll.getComponent(0).getViewport;  catch, end  % HG2
jUITableDataSet = jScroll.getView;

handles.jUITableDataSet=jUITableDataSet;

%jUITableDataSet.setAutoResizeMode(jUITableDataSet.AUTO_RESIZE_SUBSEQUENT_COLUMNS);

%Set figure units to normalized for resize
set(handles.figure1, 'Units', 'normalized');
hChild=get(handles.figure1, 'Children');
set(hChild, 'Units', 'normalized');


% Update handles structure
handles.Output=handles.figure1;
guidata(hObject, handles);

% UIWAIT makes DataSetCurrent wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function UpdateTextWithFormatInfo(handles)
XPixDimList=cell2mat({handles.DataSetsInfo.XPixDim}');
YPixDimList=cell2mat({handles.DataSetsInfo.YPixDim}');
ZPixDimList=cell2mat({handles.DataSetsInfo.ZPixDim}');

XMin=min(XPixDimList(:)); XMax=max(XPixDimList(:));
YMin=min(YPixDimList(:)); YMax=max(YPixDimList(:));
ZMin=min(ZPixDimList(:)); ZMax=max(ZPixDimList(:));

TempStr=get(handles.TextDataSetName, 'String');

TempStr=[TempStr, '     Format:  XPixDim: [', num2str(XMin), ', ', num2str(XMax), ']. ', ...
    'YPixDim: [', num2str(YMin), ', ', num2str(YMax), ']. ', ...
    'ZPixDim: [', num2str(ZMin), ', ', num2str(ZMax), '].'];

set(handles.TextDataSetName, 'String', TempStr);

% --- Outputs from this function are returned to the command line.
function varargout = DataSetCurrent_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1}=handles.Output;

% --- Executes on button press in PushbuttonDelete.
function PushbuttonDelete_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hFig=findobj(0, 'Type', 'figure', 'Name', 'Review');
if ~isempty(hFig)
    WindowAPI(handles.figure1, 'minimize');
    hFig2=MsgboxGuiIFOA('Data set is being reviewed. Action can''t be performed!', 'Warn', 'warn');    
    waitfor(hFig2);
    
    WindowAPI(handles.figure1, 'restore');
    
    figure(hFig);
    
    return;    
end

TableData=get(handles.UITableDataSet, 'Data');
SelectMat=TableData(:, 1);

SelectIndex=cellfun(@IsTrueCell, SelectMat);
SelectIndex=find(SelectIndex > 0);

%Update Table
TableData(SelectIndex, :)=[];
set(handles.UITableDataSet, 'Data', TableData);

%Update Variables and files
DeleteIndex=handles.TableDataItemID(SelectIndex);

for i=1:length(DeleteIndex)    %Reassign TableFeatureItemID       
    TIndex=find(handles.TableDataItemID > DeleteIndex(i));    
    
    if ~isempty(TIndex)
        handles.TableDataItemID(TIndex)=handles.TableDataItemID(TIndex)-1;
    end
end

handles.TableDataItemID(SelectIndex)=[];


load(handles.DataSetFile, '-mat', 'DataSetsInfo');
DataSetsInfo(DeleteIndex)=[];

handles.DataSetsInfo(DeleteIndex)=[];

save(handles.DataSetFile, 'DataSetsInfo')

%Update status
TableData=get(handles.UITableDataSet, 'Data');
SelectMat=TableData(:, 1);

SelectIndex=cellfun(@IsTrueCell, SelectMat);
SelectIndex=find(SelectIndex > 0);

if isempty(handles.DataSetsInfo) ||  isempty(SelectIndex)
    set(handles.PushbuttonReview, 'Enable', 'Off');
    set(handles.PushbuttonDelete, 'Enable', 'Off');
    set(handles.PushbuttonMove, 'Enable', 'Off');
    set(handles.PushbuttonCopy, 'Enable', 'Off');
end

set(handles.TextNum, 'String', [num2str(size(TableData, 1)), ' items']);

guidata(handles.figure1, handles);


% --- Executes on button press in PushbuttonSortBy.
function PushbuttonSortBy_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonSortBy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on selection change in PopupmenuDataSetHeader.
function PopupmenuDataSetHeader_Callback(hObject, eventdata, handles)
% hObject    handle to PopupmenuDataSetHeader (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopupmenuDataSetHeader contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopupmenuDataSetHeader

TableData=get(handles.UITableDataSet, 'Data');
TableHeader=get(handles.UITableDataSet, 'ColumnName');
TableHeader=GetHtmlValue(TableHeader);

contents = get(handles.PopupmenuDataSetHeader,'String');
SortByStr=contents{get(handles.PopupmenuDataSetHeader,'Value')};

[handles.TableDataItemID, TableData]=SortTableData(TableData, SortByStr, TableHeader, handles.TableDataItemID);

set(handles.UITableDataSet, 'Data', TableData);

guidata(handles.figure1, handles);


% --- Executes during object creation, after setting all properties.
function PopupmenuDataSetHeader_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopupmenuDataSetHeader (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in UITableDataSet.
function UITableDataSet_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to UITableDataSet (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

if isempty(eventdata.Indices)
    return;
end

RowIndex=eventdata.Indices(1);
ColumnIndex=eventdata.Indices(2);

%Selection
if ColumnIndex == 1
    TableData=get(handles.UITableDataSet, 'Data');
    SelectMat=TableData(:, 1);
    
    SelectIndex=cellfun(@IsTrueCell, SelectMat);
    SelectIndex=find(SelectIndex > 0);
    
    if ~isempty(SelectIndex)
        set(handles.PushbuttonDelete, 'Enable', 'on');
        set(handles.PushbuttonMove, 'Enable', 'on');
        set(handles.PushbuttonCopy, 'Enable', 'on');
    else
        set(handles.PushbuttonDelete, 'Enable', 'off');
        set(handles.PushbuttonMove, 'Enable', 'off');
        set(handles.PushbuttonCopy, 'Enable', 'off');
    end
end

%Comment
TableHeader=get(handles.UITableDataSet, 'ColumnName');
TableHeader=GetHtmlValue(TableHeader);

TempIndex=strmatch('Comment', TableHeader, 'exact');
if abs(ColumnIndex-TempIndex) < 0.00004
    TableData=get(handles.UITableDataSet, 'Data');
    CurrentValue=TableData{RowIndex, ColumnIndex};   
    
    DataItemIndex=handles.TableDataItemID(RowIndex);
    
    UpdateDataSetFile(CurrentValue, DataItemIndex, handles.DataSetFile);
end

function UpdateDataSetFile(CurrentValue, DataItemIndex, DataSetFile)
load(DataSetFile, '-mat', 'DataSetsInfo');

DataSetsInfo(DataItemIndex).Comment=CurrentValue;

save(DataSetFile, 'DataSetsInfo');


% --- Executes on button press in PushbuttonReview.
function PushbuttonReview_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonReview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

RowIndex=handles.jUITableDataSet.getSelectedRow + 1;
ColumnIndex=handles.jUITableDataSet.getSelectedColumn  + 1;

if ColumnIndex < 2
    return;
end

AllFig=findobj(0, 'Type', 'figure');
set(AllFig, 'Pointer', 'watch');
drawnow;

TableDataItemID=handles.TableDataItemID(RowIndex);
CDataSetInfo=handles.DataSetsInfo(TableDataItemID);

if isfield(handles, 'TestType')
    ROIEditorDataSet(1, CDataSetInfo, handles.figure1, TableDataItemID, handles.DataSetsInfo, handles.DataSetFile, handles.TestType, handles.TestStruct);
else
    ROIEditorDataSet(1, CDataSetInfo, handles.figure1, TableDataItemID, handles.DataSetsInfo, handles.DataSetFile);
end

AllFig=findobj(0, 'Type', 'figure');
set(AllFig, 'Pointer', 'arrow');
drawnow;

if isfield(handles, 'TestType')
    delete(handles.figure1);
end

% --- Executes when selected cell(s) is changed in UITableDataSet.
function UITableDataSet_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to UITableDataSet (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

if  numel(eventdata.Indices) < 1
    return;
end

RowIndex=eventdata.Indices(1);
ColumnIndex=eventdata.Indices(2);

if ColumnIndex < 2
    set(handles.PushbuttonReview, 'Enable', 'off');
else
    set(handles.PushbuttonReview, 'Enable', 'on');    
end


% --- Executes on button press in PushbuttonAnonymize.
function PushbuttonAnonymize_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonAnonymize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Anonymize
FigAll=findobj(0, 'Type', 'figure');
set(FigAll, 'Pointer', 'watch');
drawnow;

load(handles.DataSetFile, '-mat', 'DataSetsInfo');

if exist('DataSetsInfo', 'var') && ~isempty(DataSetsInfo)
    for i=1:size(DataSetsInfo, 1)
        LastName=['Pat', num2str(i)];
        FirstName=' ';
        MiddleName=' ';
        MRN='111111';
        
       DataSetsInfo(i).DBName=[LastName, '^', FirstName];       
       DataSetsInfo(i).MRN=MRN;
    end
    
    save(handles.DataSetFile, 'DataSetsInfo');
end

FigAll=findobj(0, 'Type', 'figure');
set(FigAll, 'Pointer', 'arrow');
drawnow;


[Flag, TableDataItemID, DataSetsInfo]=UpdateTableDataSetDisplay(handles.DataSetFile, handles);

handles.TableDataItemID=TableDataItemID;
handles.DataSetsInfo=DataSetsInfo;

guidata(handles.figure1, handles);


% --- Executes on button press in PushbuttonMove.
function PushbuttonMove_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonMove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

PushbuttonCopy_Callback(handles.PushbuttonCopy, 'Move', handles)


% --- Executes on button press in PushbuttonCopy.
function PushbuttonCopy_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonCopy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(eventdata, 'Move')
    ModeStr='Move';
else
    ModeStr='Copy';
end

%Copy data items
Output=DataSetMoveCopy(1, handles.DataDir, handles.figure1, handles.DataSetName, ModeStr);
if ~isempty(Output)
    NewDataSetFile=[handles.DataDir, '\', Output];   
        
    TableData=get(handles.UITableDataSet, 'Data');
    SelectMat=TableData(:, 1);
    
    SelectIndex=cellfun(@IsTrueCell, SelectMat);
    SelectIndex=find(SelectIndex > 0);
       
    %Update Variables and files
    DeleteIndex=handles.TableDataItemID(SelectIndex);
            
    %Set Status
    hFig=findobj(0, 'Type', 'figure');
    set(hFig, 'Pointer', 'watch');
    drawnow;
    
    %Get data items to be moved or copied
    load(handles.DataSetFile, '-mat', 'DataSetsInfo');
    NewDataItem=DataSetsInfo(DeleteIndex);
    clear('DataSetsInfo');
        
    try
        load(NewDataSetFile, '-mat', 'DataSetsInfo');
    catch        
        DataSetsInfo=[];        
    end    
    DataSetsInfo=[DataSetsInfo; NewDataItem];
    
    save(NewDataSetFile, 'DataSetsInfo');
    
    if isequal(ModeStr, 'Move')
        PushbuttonDelete_Callback(handles.PushbuttonDelete, [], handles);
    end
    
     %Set Status
    hFig=findobj(0, 'Type', 'figure');
    set(hFig, 'Pointer', 'arrow');
    drawnow;
end
