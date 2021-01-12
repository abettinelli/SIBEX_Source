function varargout = FeatureSetCurrent(varargin)
% FEATURESETCURRENT MATLAB code for FeatureSetCurrent.fig
%      FEATURESETCURRENT, by itself, creates a new FEATURESETCURRENT or raises the existing
%      singleton*.
%
%      H = FEATURESETCURRENT returns the handle to a new FEATURESETCURRENT or the handle to
%      the existing singleton*.
%
%      FEATURESETCURRENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FEATURESETCURRENT.M with the given input arguments.
%
%      FEATURESETCURRENT('Property','Value',...) creates a new FEATURESETCURRENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FeatureSetCurrent_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FeatureSetCurrent_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FeatureSetCurrent

% Last Modified by GUIDE v2.5 16-Jul-2015 11:55:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FeatureSetCurrent_OpeningFcn, ...
                   'gui_OutputFcn',  @FeatureSetCurrent_OutputFcn, ...
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

% --- Executes just before FeatureSetCurrent is made visible.
function FeatureSetCurrent_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FeatureSetCurrent (see VARARGIN)

handles.PatsParentDir= varargin{2}; 
FeatureSetName= varargin{3};

set(handles.TextFeatureSetName, 'String', FeatureSetName);

FeatureSetFile=[handles.PatsParentDir, '\', FeatureSetName];

[Flag, TableFeatureItemID, TableData,  FeatureSetsInfo]=UpdateTableFeatureSetDisplay(FeatureSetFile, handles, 'Display');
if Flag < 1
    MsgboxGuiIFOA('Data Set file is corrupted.', 'Warn', 'warn');
    
    delete(handles.figure1);
    return;
end

handles.TableFeatureItemID=TableFeatureItemID;
handles.FeatureSetFile=FeatureSetFile;
handles.FeatureSetsInfo=FeatureSetsInfo;
handles.TableData=TableData;

hFig=findobj(0, 'Type', 'figure', 'Name', 'Specify Feature');
if isempty(hFig)
    hFig=findobj(0, 'Type', 'figure', 'Name', 'Result');
        if isempty(hFig)
            hFig=findobj(0, 'Type', 'figure', 'Name', 'S-IBEX');
        end
end

CenterFigCenterRight(handles.figure1,hFig);

%Get JTable
figure(handles.figure1);

for i=1:10
    handles.(['jUITableItem', num2str(i)])=GetJTable(handles.(['UITableItem', num2str(i)]));
    handles.(['jUITableItem', num2str(i)]).setRowHeight(25);
end


%Set figure units to normalized for resize
set(handles.figure1, 'Units', 'normalized');
hChild=get(handles.figure1, 'Children');
set(hChild, 'Units', 'normalized');


% Update handles structure
handles.Output=handles.figure1;
guidata(hObject, handles);

% Choose default command line output for FeatureSetCurrent
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FeatureSetCurrent wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = FeatureSetCurrent_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.output;

% --- Executes on button press in PushbuttonDelete.
function PushbuttonDelete_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isstr(eventdata)
    Mode=eventdata;
else
    Mode='Delete';
end

CurrentPage=GetPageNum(handles);
Offset=(CurrentPage-1)*10;

SelectStatus=GetSelectStatusTable(handles);
SelectIndex=find(cell2mat(SelectStatus));
SelectIndex=Offset+SelectIndex;

DeleteIndex=handles.TableFeatureItemID(SelectIndex);

if isequal(Mode, 'Delete')    
    %Update TableData
    handles.TableData(SelectIndex, :)=[];
    
    %Update Variables
    for i=1:length(DeleteIndex)    %Reassign TableFeatureItemID
        TIndex=find(handles.TableFeatureItemID > DeleteIndex(i));
        
        if ~isempty(TIndex)
            handles.TableFeatureItemID(TIndex)=handles.TableFeatureItemID(TIndex)-1;
        end
    end
    
    handles.TableFeatureItemID(SelectIndex)=[];    
end

if isequal(Mode, 'Copy')
    %Update TableData
    InsertItem=handles.TableData(SelectIndex, :);
    InsertItem(:, 1)={false};    
    handles.TableData=[handles.TableData; InsertItem];
    
    %Update Variables
    handles.TableFeatureItemID=[handles.TableFeatureItemID; max(handles.TableFeatureItemID)+(1:length(SelectIndex))'];
end


%Update Display
contents = get(handles.PopupmenuFeatureSetHeader,'String');
SortByStr=contents{get(handles.PopupmenuFeatureSetHeader,'Value')};

TableHeader=get(handles.UITableItem1, 'ColumnName');
TableHeader=GetHtmlValue(TableHeader);


[handles.TableFeatureItemID, handles.TableData]=SortTableData(handles.TableData, SortByStr, TableHeader, handles.TableFeatureItemID);

if isequal(SortByStr, ' ')
    %Keep the same order
    [handles.TableFeatureItemID, handles.TableData]=SortTableData(handles.TableData, SortByStr, TableHeader, handles.TableFeatureItemID);
end

TotalPage=floor((size(handles.TableData, 1)-1)/10)+1;

if CurrentPage >TotalPage
    GroupNum=TotalPage;
else
    GroupNum=CurrentPage;
end

DisplayFeatureTableData(handles, handles.TableData, GroupNum);

%Update file
if isequal(Mode, 'Delete')
    handles.FeatureSetsInfo(DeleteIndex)=[];
end

if isequal(Mode, 'Copy')
    handles.FeatureSetsInfo=[handles.FeatureSetsInfo; handles.FeatureSetsInfo(DeleteIndex)];
end
save(handles.FeatureSetFile, '-struct', 'handles', 'FeatureSetsInfo');

guidata(handles.figure1, handles);


%Update PushttonDelete status
eventdataNew.Indices(1)=1;
eventdataNew.Indices(2)=1;

UTTableItem_CellEditCallBack(handles.UITableItem1, eventdataNew, handles);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

% --- Executes on selection change in PopupmenuFeatureSetHeader.
function PopupmenuFeatureSetHeader_Callback(hObject, eventdata, handles)
% hObject    handle to PopupmenuFeatureSetHeader (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopupmenuFeatureSetHeader contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopupmenuFeatureSetHeader


contents = get(handles.PopupmenuFeatureSetHeader,'String');
SortByStr=contents{get(handles.PopupmenuFeatureSetHeader,'Value')};

TableHeader=get(handles.UITableItem1, 'ColumnName');
TableHeader=GetHtmlValue(TableHeader);

%Select Mat
[handles.TableFeatureItemID, handles.TableData]=SortTableData(handles.TableData, SortByStr, TableHeader, handles.TableFeatureItemID);

GroupNum=1;
DisplayFeatureTableData(handles, handles.TableData, GroupNum);

guidata(handles.figure1, handles);

% --- Executes during object creation, after setting all properties.
function PopupmenuFeatureSetHeader_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopupmenuFeatureSetHeader (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in PushbuttonPrev.
function PushbuttonPrev_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonPrev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NavigatePage(handles, 'Prev');

% --- Executes on button press in PushbuttonNext.
function PushbuttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NavigatePage(handles, 'Next');

function [CurrentPage, TotalPage]=GetPageNum(handles)
TextPage=get(handles.TextPage, 'String');

TempIndex=strfind(TextPage, '/');

CurrentPage=str2num(TextPage(1:TempIndex-1));
TotalPage=str2num(TextPage(TempIndex+1:end));

function NavigatePage(handles, Mode)
%Page Number
 [CurrentPage, TotalPage]=GetPageNum(handles);

switch Mode
    case 'Prev'
        ViewPage=CurrentPage-1;
        
        if ViewPage < 1
            return;
        end
        
    case 'Next'
        ViewPage=CurrentPage+1;
        
        if ViewPage > TotalPage
            return;
        end
end


%Update Table
DisplayFeatureTableData(handles, handles.TableData, ViewPage);

%Update PushttonDelete status
eventdata.Indices(1)=1;
eventdata.Indices(2)=1;

UTTableItem_CellEditCallBack(handles.UITableItem1, eventdata, handles);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

function SelectStatus=GetSelectStatusTable(handles)
SelectStatus=[];
for i=1:10
    TableData=get(handles.(['UITableItem', num2str(i)]), 'Data');
    
    if isempty(TableData)
        break;
    end    
    
    SelectStatus=[SelectStatus; TableData(1)];
end

% --- Executes when entered data in editable cell(s) in UITableItem1.
function UITableItem1_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to UITableItem1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

UTTableItem_CellEditCallBack(hObject, eventdata, handles);

% --- Executes when selected cell(s) is changed in UITableItem1.
function UITableItem1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to UITableItem1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

UITableItem_CellSelectionCallback(hObject, eventdata, handles);

% --- Executes when entered data in editable cell(s) in UITableItem2.
function UITableItem2_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to UITableItem2 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

UTTableItem_CellEditCallBack(hObject, eventdata, handles);

% --- Executes when selected cell(s) is changed in UITableItem2.
function UITableItem2_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to UITableItem2 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
UITableItem_CellSelectionCallback(hObject, eventdata, handles);

% --- Executes when entered data in editable cell(s) in UITableItem3.
function UITableItem3_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to UITableItem3 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

UTTableItem_CellEditCallBack(hObject, eventdata, handles);

% --- Executes when selected cell(s) is changed in UITableItem3.
function UITableItem3_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to UITableItem3 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
UITableItem_CellSelectionCallback(hObject, eventdata, handles);

% --- Executes when entered data in editable cell(s) in UITableItem4.
function UITableItem4_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to UITableItem4 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

UTTableItem_CellEditCallBack(hObject, eventdata, handles);

% --- Executes when selected cell(s) is changed in UITableItem4.
function UITableItem4_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to UITableItem4 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
UITableItem_CellSelectionCallback(hObject, eventdata, handles);

% --- Executes when entered data in editable cell(s) in UITableItem5.
function UITableItem5_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to UITableItem5 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

UTTableItem_CellEditCallBack(hObject, eventdata, handles);

% --- Executes when selected cell(s) is changed in UITableItem5.
function UITableItem5_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to UITableItem5 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
UITableItem_CellSelectionCallback(hObject, eventdata, handles);

% --- Executes when entered data in editable cell(s) in UITableItem6.
function UITableItem6_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to UITableItem6 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

UTTableItem_CellEditCallBack(hObject, eventdata, handles);

% --- Executes when selected cell(s) is changed in UITableItem6.
function UITableItem6_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to UITableItem6 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
UITableItem_CellSelectionCallback(hObject, eventdata, handles);

% --- Executes when entered data in editable cell(s) in UITableItem7.
function UITableItem7_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to UITableItem7 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

UTTableItem_CellEditCallBack(hObject, eventdata, handles);

% --- Executes when selected cell(s) is changed in UITableItem7.
function UITableItem7_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to UITableItem7 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
UITableItem_CellSelectionCallback(hObject, eventdata, handles);

% --- Executes when entered data in editable cell(s) in UITableItem8.
function UITableItem8_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to UITableItem8 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

UTTableItem_CellEditCallBack(hObject, eventdata, handles);

% --- Executes when selected cell(s) is changed in UITableItem8.
function UITableItem8_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to UITableItem8 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
UITableItem_CellSelectionCallback(hObject, eventdata, handles);

% --- Executes when entered data in editable cell(s) in UITableItem9.
function UITableItem9_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to UITableItem9 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

UTTableItem_CellEditCallBack(hObject, eventdata, handles);

% --- Executes when selected cell(s) is changed in UITableItem9.
function UITableItem9_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to UITableItem9 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
UITableItem_CellSelectionCallback(hObject, eventdata, handles);

% --- Executes when entered data in editable cell(s) in UITableItem10.
function UITableItem10_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to UITableItem10 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

UTTableItem_CellEditCallBack(hObject, eventdata, handles);

% --- Executes when selected cell(s) is changed in UITableItem10.
function UITableItem10_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to UITableItem10 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
UITableItem_CellSelectionCallback(hObject, eventdata, handles);

function UITableItem_CellSelectionCallback(hObject, eventdata, handles)

if isempty(eventdata.Indices)
    return;
end

RowIndex=eventdata.Indices(1);
ColumnIndex=eventdata.Indices(2);


switch hObject
    case handles.UITableItem1
        ItemIndex=1;
    case handles.UITableItem2
        ItemIndex=2;
    case handles.UITableItem3
        ItemIndex=3;
    case handles.UITableItem4
        ItemIndex=4;
    case handles.UITableItem5
        ItemIndex=5;
    case handles.UITableItem6
        ItemIndex=6;
    case handles.UITableItem7
        ItemIndex=7;
    case handles.UITableItem8
        ItemIndex=8;
    case handles.UITableItem9
        ItemIndex=9;
    case handles.UITableItem10
        ItemIndex=10;
end

%Offset
CurrentPage=GetPageNum(handles);
Offset=(CurrentPage-1)*10;

FeatureItemIndex=handles.TableFeatureItemID(Offset+ItemIndex);

CFeatureSetInfo=handles.FeatureSetsInfo(FeatureItemIndex);

%ProgramPath
ProgramPath=fileparts(mfilename('fullpath'));

TempIndex=strfind(ProgramPath, '\');
ProgramPath=ProgramPath(1:TempIndex(end)-1);

%Preprocess
if ColumnIndex == 3    
    TableData=get(hObject, 'Data');
    CurrentValue=TableData{1, ColumnIndex-1};
    
    if ~isempty(CFeatureSetInfo.PreprocessStore)
        Module={CFeatureSetInfo.PreprocessStore.Name};
        
        TempIndex=strmatch(CurrentValue, Module, 'exact');
        Param=CFeatureSetInfo.PreprocessStore(TempIndex).Value;
        
        ModulePara=FeatureAddPreprocessPara(1, CurrentValue, ProgramPath, Param, 'Preprocess', handles.figure1);
        
        CFeatureSetInfo.PreprocessStore(TempIndex).Value=ModulePara;
        
        handles.FeatureSetsInfo(FeatureItemIndex)=CFeatureSetInfo;
        
        save(handles.FeatureSetFile, '-struct', 'handles', 'FeatureSetsInfo');
        
        guidata(handles.figure1, handles);
    end
end

%Category
if ColumnIndex == 5
    TableData=get(hObject, 'Data');
    CurrentValue=TableData{1, ColumnIndex-1};
    
    Module={CFeatureSetInfo.CategoryStore.Name};
    
    TempIndex=strmatch(CurrentValue, Module, 'exact');
    Param=CFeatureSetInfo.CategoryStore(TempIndex).Value;    
    
    ModulePara=FeatureAddPreprocessPara(1, Module, ProgramPath, Param, 'Category', handles.figure1);
    
    CFeatureSetInfo.CategoryStore(TempIndex).Value=ModulePara;
    
    handles.FeatureSetsInfo(FeatureItemIndex)=CFeatureSetInfo;
    
    save(handles.FeatureSetFile, '-struct', 'handles', 'FeatureSetsInfo');
    
    guidata(handles.figure1, handles);        
end


%Feature
if ColumnIndex == 7
    TableData=get(hObject, 'Data');
    CurrentValue=TableData{1, ColumnIndex-1};
    
    Module={CFeatureSetInfo.FeatureStore.Name};
      
    TempIndex=strmatch(CurrentValue, Module, 'exact');
    Param=CFeatureSetInfo.FeatureStore(TempIndex).Value;    
    
    CategoryValue=TableData{1, ColumnIndex-3};
    
    ModulePara=FeatureAddPreprocessPara(1, [CategoryValue, '/', CurrentValue], ProgramPath, Param, 'Feature', handles.figure1);
    
    CFeatureSetInfo.FeatureStore(TempIndex).Value=ModulePara;
    
    handles.FeatureSetsInfo(FeatureItemIndex)=CFeatureSetInfo;
    
    save(handles.FeatureSetFile, '-struct', 'handles', 'FeatureSetsInfo');
    
    guidata(handles.figure1, handles);      
end

function UTTableItem_CellEditCallBack(hObject, eventdata, handles)
if isempty(eventdata.Indices)
    return;
end

RowIndex=eventdata.Indices(1);
ColumnIndex=eventdata.Indices(2);


switch hObject
    case handles.UITableItem1
        ItemIndex=1;
    case handles.UITableItem2
        ItemIndex=2;
    case handles.UITableItem3
        ItemIndex=3;
    case handles.UITableItem4
        ItemIndex=4;
    case handles.UITableItem5
        ItemIndex=5;
    case handles.UITableItem6
        ItemIndex=6;
    case handles.UITableItem7
        ItemIndex=7;
    case handles.UITableItem8
        ItemIndex=8;
    case handles.UITableItem9
        ItemIndex=9;
    case handles.UITableItem10
        ItemIndex=10;
end

%Selection
if ColumnIndex == 1
    UpdateTableSelectStatus(handles);
    handles=guidata(handles.figure1);
    guidata(handles.figure1, handles);
    
    SelectStatus=GetSelectStatusTable(handles);
    SelectIndex=find(cell2mat(SelectStatus));
    
    if ~isempty(SelectIndex)
        set(handles.PushbuttonDelete, 'Enable', 'on');
        set(handles.PushbuttonCopy, 'Enable', 'on');
    else
        set(handles.PushbuttonDelete, 'Enable', 'off');
        set(handles.PushbuttonCopy, 'Enable', 'off');
    end
end

%Comment
if ColumnIndex == 8
    CurrentPage=GetPageNum(handles);
    Offset=(CurrentPage-1)*10;
    
    TableData=get(hObject, 'Data');
    CurrentValue=TableData{1, ColumnIndex};
    
    FeatureItemIndex=handles.TableFeatureItemID(Offset+ItemIndex);
    
    UpdateFeatureSetFile(CurrentValue, FeatureItemIndex, handles.FeatureSetFile);    
end

function UpdateFeatureSetFile(CurrentValue, FeatureItemIndex, FeatureSetFile)
load(FeatureSetFile, '-mat', 'FeatureSetsInfo');

FeatureSetsInfo(FeatureItemIndex).Comment=CurrentValue;

save(FeatureSetFile, 'FeatureSetsInfo');

function UpdateTableSelectStatus(handles)
[CurrentPage, TotalPage]=GetPageNum(handles);

SelectStatus=GetSelectStatusTable(handles);

if ~isempty(SelectStatus)
    StartIndex=(CurrentPage-1)*10+1;
    EndIndex=(CurrentPage-1)*10+length(SelectStatus);
    
    handles.TableData(StartIndex:EndIndex, 1)=SelectStatus;
    guidata(handles.figure1, handles);
end

% --- Executes on button press in PushbuttonCopy.
function PushbuttonCopy_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonCopy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

PushbuttonDelete_Callback(hObject, 'Copy', handles);
