function varargout = IBEXResult(varargin)
% IBEXRESULT MATLAB code for IBEXResult.fig
%      IBEXRESULT, by itself, creates a new IBEXRESULT or raises the existing
%      singleton*.
%
%      H = IBEXRESULT returns the handle to a new IBEXRESULT or the handle to
%      the existing singleton*.
%
%      IBEXRESULT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IBEXRESULT.M with the given input arguments.
%
%      IBEXRESULT('Property','Value',...) creates a new IBEXRESULT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IBEXResult_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IBEXResult_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IBEXResult

% Last Modified by GUIDE v2.5 07-Oct-2014 12:00:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @IBEXResult_OpeningFcn, ...
    'gui_OutputFcn',  @IBEXResult_OutputFcn, ...
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

% --- Executes just before IBEXResult is made visible.
function IBEXResult_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IBEXResult (see VARARGIN)

PHandles=varargin{2};

DataDir=[PHandles.INIConfigInfo.DataDir, '\', PHandles.CurrentUser, '\', PHandles.CurrentSite];

handles.PatsParentDir=DataDir;

handles.FeatureDir=[DataDir, '\1FeatureModelSet_Algorithm'];
handles.DataDir=[DataDir, '\1FeatureDataSet_ImageROI'];
handles.FileDir=[handles.PatsParentDir, '\1FeatureResultSet_Result'];

InitializeFig(handles)

%Figure Appearance
handles.ParentFig=PHandles.figure1;
set(handles.ParentFig, 'Visible', 'off');

CenterFig(handles.figure1,handles.ParentFig); %OneThirdX

figure(handles.figure1);

%Set figure units to normalized for resize
set(handles.figure1, 'Units', 'normalized');
hChild=get(handles.figure1, 'Children');
set(hChild, 'Units', 'normalized');

% Choose default command line output for FeatureSetList
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Choose default command line output for IBEXResult
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(handles.figure1, 'CurrentAxes', handles.axes1);
plot([30 610; 30 610]', [261 261; 341 341]','color', [0 0.4470 0.7410])
xlim([0 640])
ylim([0 640])
set(gca,'XTick', [], 'YTick', []);
set(gca,'Visible','off')
delta = 610-30;
x = [0 delta delta 0]+30;
y = [31 31 51 51];
patch('XData',x,'YData',y,'EdgeColor','none','FaceColor',[1 1 1]);
patch('XData',[0 0 0 0],'YData',y,'EdgeColor','none','FaceColor',[0, 0.4470, 0.7410]);
patch('XData',x,'YData',y,'EdgeColor',[0.5 0.5 0.5],'FaceColor','none','LineWidth',1);

% UIWAIT makes IBEXResult wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function InitializeFig(handles)

DisplayListbox(handles.DataDir, handles, 'Data');
DisplayListbox(handles.FeatureDir, handles, 'Feature');

TextStr='<html><b><center><font face="Calibri">View Feature</font></html>';
set(handles.PushbuttonViewFeatureSet, 'String', 'View Feature');

TextStr='<html><b><center><font face="Calibri">View Data</font></html>';
set(handles.PushbuttonViewDataSet, 'String', 'View Data');

set(handles.PushbuttonViewDataSet, 'Enable', 'Off');
set(handles.PushbuttonViewFeatureSet, 'Enable', 'Off');
set(handles.PushbuttonComputeResult, 'Enable', 'Off');

set(handles.ListboxStatus, 'String', ' ');

function DisplayListbox(DataDir, handles, Mode)
FileList=GetFileList(DataDir);

FileList=FilterFlistList(FileList, '.mat');

switch Mode
    case 'Data'
        ListboxDataSet=handles.ListboxDataSet;
    case 'Feature'
        ListboxDataSet=handles.ListboxFeatureSet;
end

if isempty(FileList)
    set(ListboxDataSet, 'String', {' '}, 'Enable', 'off', 'Value', [], 'Min', 0, 'Max', 2, 'Listboxtop', 1, 'Enable', 'off');
else
    set(ListboxDataSet, 'String', FileList, 'Enable', 'off', 'Value', [], 'Min', 0, 'Max', 2, 'Listboxtop', 1, 'Enable', 'on');
end

function FileList=FilterFlistList(FileList, FilterStr)

for i=length(FileList):-1:1
    CFile=FileList{i};
    
    if ~(length(CFile) > length(FilterStr) && isequal(CFile(end-length(FilterStr)+1: end), FilterStr))
        FileList{i}=[];
    end
end

% --- Outputs from this function are returned to the command line.
function varargout = IBEXResult_OutputFcn(hObject, eventdata, handles)
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
set(handles.PushbuttonViewDataSet, 'Enable', 'on');

if ~isempty(get(handles.ListboxDataSet, 'Value')) && ~isempty(get(handles.ListboxFeatureSet, 'Value'))
    set(handles.PushbuttonComputeResult, 'Enable', 'On');
else
    set(handles.PushbuttonComputeResult, 'Enable', 'Off');
end

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

% --- Executes on selection change in ListboxFeatureSet.
function ListboxFeatureSet_Callback(hObject, eventdata, handles)
% hObject    handle to ListboxFeatureSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListboxFeatureSet contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListboxFeatureSet

set(handles.ListboxFeatureSet,  'Min', 0, 'Max', 1, 'Listboxtop', 1);
set(handles.PushbuttonViewFeatureSet, 'Enable', 'on');

if ~isempty(get(handles.ListboxDataSet, 'Value')) && ~isempty(get(handles.ListboxFeatureSet, 'Value'))
    set(handles.PushbuttonComputeResult, 'Enable', 'On');
else
    set(handles.PushbuttonComputeResult, 'Enable', 'Off');
end

% --- Executes during object creation, after setting all properties.
function ListboxFeatureSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListboxFeatureSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in PushbuttonComputeResult.
function PushbuttonComputeResult_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonComputeResult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get Result File Name
CurrentDir=pwd;

FileDir=handles.FileDir;
if ~exist(FileDir, 'dir')
    mkdir(FileDir);
end
cd(FileDir);

DataSetName=GetDataSetName(handles);
[FileName, FilePath] = uiputfile([DataSetName, '_', datestr(now, 30), '.xlsx'],'Save file name');

cd(CurrentDir);

if FileName == 0
    return;
else
    handles.FileDir=FilePath;
    guidata(handles.figure1, handles);
end

%Clear file
if exist([FilePath, '\', FileName], 'file')
    delete([FilePath, '\', FileName]);
    
    if exist([FilePath, '\', FileName], 'file')
        hMsg=MsgboxGuiIFOA('File already exists and can''t be deleted!', 'Error', 'error', 'modal');
        waitfor(hMsg);
        return;
    end
end

% %Close Data View
% hFig=findobj(0, 'Type', 'figure', 'Name', 'Current Data Set');
% if ~isempty(hFig)
%     delete(hFig);
% end
%
% %Close Feature View
% hFig=findobj(0, 'Type', 'figure', 'Name', 'Current Feature Set');
% if ~isempty(hFig)
%     delete(hFig);
% end

%Status
set(handles.ListboxStatus, 'String', {' '},'Value', [], 'Min', 0, 'Max', 2, 'ListboxTop', 1);


%---------Compute-------%
%1. Load raw data
DataSetFile=GetDateSetFile(handles, 'Data');
FeatureSetFile=GetDateSetFile(handles, 'Feature');

load(DataSetFile, '-mat', 'DataSetsInfo');
load(FeatureSetFile, '-mat', 'FeatureSetsInfo');

%2. Result file Header
HeaderCell=[{' '}, {' '}, {' '}, {' '}; {'Index'}, {'Image'}, {'ROI '}, {'MRN '}];

tic
CategoryIndex = {};
for current_category=1:length(FeatureSetsInfo)
    CategoryName=FeatureSetsInfo(current_category).Category{1};
    
    FeatureName=(FeatureSetsInfo(current_category).Feature)';
    
    TempStr=['F', num2str(current_category),'-', CategoryName];
    CategoryNameStr=repmat({TempStr}, 1, length(FeatureName));
    CategoryIndex=[CategoryIndex repmat({['F' num2str(current_category)]}, 1, length(FeatureName))];
    
    TempM=[CategoryNameStr; FeatureName];
    HeaderCell=[HeaderCell, TempM];
end

% HEADER 2
InfoID = [];
for c=1:length(FeatureSetsInfo) % For each category
    
    % Current Structs Preprocessing, Category, Features
    currPre=FeatureSetsInfo(c).PreprocessStore;
    currCat=FeatureSetsInfo(c).CategoryStore;
    currFeat=FeatureSetsInfo(c).FeatureStore;
    
    CategoryFuncH=str2func([currCat.Name, '_Category']);
    ParentInfoID=CategoryFuncH([], 'InfoID', currCat.Value);
    FeatureFuncH=str2func([currCat.Name, '_Feature']);
    InfoID=[InfoID, FeatureFuncH(ParentInfoID, currFeat, 'InfoID')];
end

InfoCatAbbreviation = strrep(strcat({InfoID.CatAbbreviation}, {' ('}, {InfoID.AggregationMethod}, {')'}),{' ()'},'');
InfoCategoryName    = strrep(strcat({InfoID.Category}, {' ('}, {InfoID.AggregationMethod}, {')'}),{' ()'},'');
InfoCategoryID      = strcat({InfoID.CategoryID}, {' - '}, {InfoID.AggregationMethodID});
InfoFeatureName     = {InfoID.FeatureName};
InfoFeatureID       = {InfoID.FeatureID};

%3. Result file Middle
HeaderCellR = {};
ResultCell={};
counter = 0;
for current_subject=1:length(DataSetsInfo) % For each subject
    
    CDataSetInfo=DataSetsInfo(current_subject);
    
    StatusStrT=['D', num2str(current_subject),'(', CDataSetInfo.DBName, '-', CDataSetInfo.ROIName, ')'];
    currHeaderRow=[{['D', num2str(current_subject)]}, {CDataSetInfo.DBName}, {CDataSetInfo.ROIName}];
    currHeaderRow=[currHeaderRow, {CDataSetInfo.MRN}];
    
    cResultValue={};
    for current_category=1:length(FeatureSetsInfo) % For each category
        
        % Update progress bar
        counter = counter+1;
        CDataSetInfo=DataSetsInfo(current_subject);
        percentage = counter/(length(FeatureSetsInfo)*length(DataSetsInfo));
        set(handles.figure1, 'CurrentAxes', handles.axes1);
        delta = 610-30;
        x = [0 (delta)*percentage (delta)*percentage 0]+30;
        h= gca;
        h.Children(2).XData = x;
        
        % Current Structs Preprocessing, Category, Features
        TestStructPre=FeatureSetsInfo(current_category).PreprocessStore;
        TestStructCat=FeatureSetsInfo(current_category).CategoryStore;
        TestStructFeat=FeatureSetsInfo(current_category).FeatureStore;
        
        FeatureValue=cell(1,size(TestStructFeat,2));
        try
            % Update Status Preprocessing
            CategoryName=FeatureSetsInfo(current_category).Category{1};
            StatusStr=[datestr(now, 13), ': Preprocessing ', StatusStrT, ' & F', num2str(current_category),'(', CategoryName, ')...'];
            SetListboxStatus(handles.ListboxStatus, StatusStr);
            
            flag = 1;
            % Compute Preprocess
            if ~isempty(TestStructPre)
                CDataSetInfo=PreprocessImage(TestStructPre, CDataSetInfo);
            end
            
            flag = 2;
            % Compute Parent Info
            CategoryFuncH=str2func([TestStructCat.Name, '_Category']);
            ParentInfo=CategoryFuncH(CDataSetInfo, 'Child', TestStructCat.Value);
            
            % Update Status Category
            StatusStr=[datestr(now, 13), ': Computing features on ', StatusStrT, ' & F', num2str(current_category),'(', CategoryName, ')...'];
            SetListboxStatus(handles.ListboxStatus,  StatusStr);
            
            flag = 3;
            % Compute Features
            FeatureFuncH=str2func([TestStructCat.Name, '_Feature']);
            FeatureInfo=FeatureFuncH(ParentInfo, TestStructFeat, 'NoReview');
            FeatureValue={FeatureInfo.FeatureValue};
        catch
            switch flag
                case 1
                    warning(['Not able preprocess '  CDataSetInfo.DBName ' for ' TestStructCat.Name ])
                case 2
                    warning(['Not able to calculate parent data for ' TestStructCat.Name ' for ' CDataSetInfo.DBName ])
                case 3
                    warning(['Not able to calculate some features of ' TestStructCat.Name ' for ' CDataSetInfo.DBName ])
            end
            EmptyIndex=cellfun('isempty', FeatureValue);
            FeatureValue(~EmptyIndex)={[]};
        end
        
        EmptyIndex=cellfun('isempty', FeatureValue);
        FeatureValue(EmptyIndex)={NaN};
        
        cResultValue=[cResultValue, FeatureValue];
        
    end
    HeaderCellR=[HeaderCellR;currHeaderRow];
    ResultCell=[ResultCell;cResultValue];
end

% CHECK MULTIPLE FEATURE VALUES
% ResultCellb = ResultCell;
% ResultCellb = cellfun(@(x)cat(1,x,x+1),ResultCellb,'UniformOutput',false);
% [ResultCell2, InfoCatAbbreviation2, InfoCategoryName2, InfoCategoryID2, InfoFeatureName2,EInfoFeatureID2]=expandResult(ResultCellb, InfoCatAbbreviation, InfoCategoryName, InfoCategoryID, InfoFeatureName, InfoFeatureID);
[ResultCell,InfoCatAbbreviation,InfoCategoryName,InfoCategoryID,InfoFeatureName,InfoFeatureID]=expandResult(ResultCell, InfoCatAbbreviation, InfoCategoryName, InfoCategoryID, InfoFeatureName, InfoFeatureID);

% Update HeaderCell
HeaderCellCol = HeaderCell;
HeaderCellCol(1, 5:end) = CategoryIndex;
HeaderCellCol(2, 5:end) = InfoCatAbbreviation;
HeaderCellCol(3, 5:end) = InfoCategoryID;
HeaderCellCol(4, 5:end) = InfoFeatureName;
HeaderCellCol(5, 5:end) = InfoFeatureID;
HeaderCellCol(1:5,1:4)=[{' '}, {' '}, {' '}, {['Index ' char(8594)]};
    {' '}, {' '}, {' '}, {['Family Name ' char(8594)]};
    {' '}, {' '}, {' '}, {['Family ID ' char(8594)]};
    {' '}, {' '}, {' '}, {['Feature Name ' char(8594)]};
    {['Index ' char(8595)]}, {['Image ' char(8595)]}, {['ROI ' char(8595)]}, {['MRN ' char(8595) ' \ Feature ID ' char(8594)]}];

InfoCell=repmat([{' '}; {' '}; {' '}], 1, size([HeaderCellR, ResultCell], 2));

InfoCell{1 , 1}='DataSet File: ';
InfoCell{1 , 2}= DataSetFile;

InfoCell{2, 1}='FeatureSet File: ';
InfoCell{2, 2}=FeatureSetFile;

%Status
StatusStr=[datestr(now, 13), ': Writing result to file..'];
SetListboxStatus(handles.ListboxStatus, StatusStr);

%Write result to file
warning('OFF', 'MATLAB:xlswrite:AddSheet')

ResutlInfo=[InfoCell; HeaderCellCol; HeaderCellR, ResultCell];
FileStatus=xlswrite([FilePath, '\', FileName], ResutlInfo, 'Result');

if FileStatus < 1
    %Write Txt file
    [~, TxtFileName]=fileparts(FileName);
    TxtFileNameResult =[FilePath, '\', TxtFileName, '_Result.txt'];
    WriteCellDataFile(TxtFileNameResult, ResutlInfo);
end

%Status
StatusStr=[datestr(now, 13), ': Writing data set info. to file..'];
SetListboxStatus(handles.ListboxStatus, StatusStr);

%Write data set info. to file
DataInfo=GetDataSetInfo(DataSetsInfo, DataSetFile);
if FileStatus >  0
    
    xlswrite([FilePath, '\', FileName], DataInfo, 'Data Info.');
else
    TxtFileNameResult =[FilePath, '\', TxtFileName, '_DataInfo.txt'];
    WriteCellDataFile(TxtFileNameResult, DataInfo);
end

%Status
StatusStr=[datestr(now, 13), ': Writing feature set info. to file..'];
SetListboxStatus(handles.ListboxStatus, StatusStr);

%Write feature set info. to file
FeatureInfo=GetFeatureSetInfo(FeatureSetsInfo, FeatureSetFile);
if FileStatus > 0
    xlswrite([FilePath, '\', FileName], FeatureInfo, 'Feature Info.');
else
    TxtFileNameResult =[FilePath, '\', TxtFileName, '_FeatureInfo.txt'];
    WriteCellDataFile(TxtFileNameResult, FeatureInfo);
end

TotalTime=toc;

StatusStr=[datestr(now, 13), ': Done.'];
SetListboxStatus(handles.ListboxStatus, StatusStr);

h= gca;
h.Children(2).XData = [0 0 0 0];

%Delete the default Sheet1, Sheet2, Sheet3
if FileStatus > 0
    try
        DeleteExcelDefaultSheet([FilePath, '\', FileName]);
    catch
    end
end

StatusStr=[datestr(now, 13), ': Total time is ', num2str(TotalTime), 's.'];
SetListboxStatus(handles.ListboxStatus, StatusStr);

warning('on', 'MATLAB:xlswrite:AddSheet')

function WriteCellDataFile(FileName, CellData)
FID= fopen(FileName, 'w');

for i=1:size(CellData, 1)
    for j=1:size(CellData, 2)
        CurrentCell=CellData{i, j};
        if ~isstr(CurrentCell)
            CurrentCell=num2str(CurrentCell);
        end
        
        fprintf(FID, '%s\t', CurrentCell);
    end
    fprintf(FID, '\n');
end
fclose(FID);

function DeleteExcelDefaultSheet(FileName)
sheetNames = {'Sheet', 'Foglio', 'Tabelle'};

objExcel = actxserver('Excel.Application');

objExcel.Workbooks.Open(FileName); % Full path is necessary!

% Delete sheets.
for i = 1:length(sheetNames)
    try
        % Throws an error if the sheets do not exist.
        objExcel.ActiveWorkbook.Worksheets.Item([sheetNames{i} '1']).Delete;
        objExcel.ActiveWorkbook.Worksheets.Item([sheetNames{i} '2']).Delete;
        objExcel.ActiveWorkbook.Worksheets.Item([sheetNames{i} '3']).Delete;
    catch
        % Do nothing.
    end
end
% Save, close and clean up.
objExcel.ActiveWorkbook.Save;
objExcel.ActiveWorkbook.Close;
objExcel.Quit;
objExcel.delete;

function DataInfo=GetDataSetInfo(DataSetsInfo, DataSetFile)
DataInfo=[];
TitleInfo=[{' '}];

%Data Info
InfoField={'Modality', 'MRN', 'DBName', 'ROIName', 'XPixDim', 'YPixDim', 'ZPixDim', 'XDim', 'YDim', 'ZDim', 'XStart', 'YStart', 'ZStart', 'ScaleValue'};
TitleInfo=[TitleInfo, InfoField];
for i=1:length(InfoField)
    DataInfo=[DataInfo, {DataSetsInfo.(InfoField{i})}'];
end

InfoField={'XPixDim', 'YPixDim', 'ZPixDim', 'XDim', 'YDim', 'ZDim', 'XStart', 'YStart', 'ZStart'};
TitleInfo=[TitleInfo, strcat('ROI', InfoField)];

TT={DataSetsInfo.ROIBWInfo}';
TStruct=[];
TStruct=[TStruct, TT{1:end}];

for i=1:length(InfoField)
    DataInfo=[DataInfo,  {TStruct.(InfoField{i})}'];
end

InfoField={'ImageID', 'Comment', 'ScanTime', 'SeriesInfo', 'CreationDate'};
TitleInfo=[TitleInfo, InfoField];
for i=1:length(InfoField)
    DataInfo=[DataInfo, {DataSetsInfo.(InfoField{i})}'];
end

%ItemNum
ItemNum=strcat('DataItem-', num2str((1:length(DataSetsInfo))'));

DataInfo=[cellstr(ItemNum), DataInfo];

%HeaderInfo
InfoCell=repmat([{' '}; {' '}], 1, size(DataInfo, 2));

InfoCell{1 , 1}='DataSet File: ';
InfoCell{1 , 2}= DataSetFile;

DataInfo=[InfoCell; TitleInfo; DataInfo];

function DataInfo=GetFeatureSetInfo(FeatureSetsInfo, FeatureSetFile)

DataInfo=[];

FeatureHeader={'Category', 'Parameters', 'Feature', 'Parameters', 'Preprocess', 'Parameters'};
for i=1:length(FeatureSetsInfo)
    
    DataInfoT=[];
    
    FeatureItem=repmat({' '}, 1, length(FeatureHeader));
    FeatureItem{1}=['FeatureItem-', num2str(i)];
    
    RowNum=max(length(FeatureSetsInfo(i).PreprocessStore), length(FeatureSetsInfo(i).FeatureStore));
    DataInfoT=repmat({' '}, RowNum, length(FeatureHeader));
    
    %Category
    DataInfoT{1, 1}=FeatureSetsInfo(i).CategoryStore.Name;
    DataInfoT{1, 2}=GetParaStr(FeatureSetsInfo(i).CategoryStore.Value);
    
    %Feature
    for j=1:length(FeatureSetsInfo(i).FeatureStore)
        DataInfoT{j, 3}=FeatureSetsInfo(i).FeatureStore(j).Name;
        DataInfoT{j, 4}=GetParaStr(FeatureSetsInfo(i).FeatureStore(j).Value);
    end
    
    %Preprocess
    for j=1:length(FeatureSetsInfo(i).PreprocessStore)
        DataInfoT{j, 5}=FeatureSetsInfo(i).PreprocessStore(j).Name;
        DataInfoT{j, 6}=GetParaStr(FeatureSetsInfo(i).PreprocessStore(j).Value);
    end
    
    DataInfo=[DataInfo; FeatureItem; FeatureHeader; DataInfoT; repmat({' '}, 1, length(FeatureHeader))];
end

%HeaderInfo
InfoCell=repmat([{' '}; {' '}], 1, size(DataInfo, 2));

InfoCell{1 , 1}='FeatureSet File: ';
InfoCell{1 , 2}= FeatureSetFile;

DataInfo=[InfoCell; DataInfo];

function ParaStr=GetParaStr(ParaStruct)
ParaStr='';

if isempty(ParaStruct)
    return;
end

FieldName=fieldnames(ParaStruct);
for i=1:length(FieldName)
    ParaStr=[ParaStr, FieldName{i}, '='];
    currentParameter = ParaStruct.(FieldName{i});
    
    if isnumeric(currentParameter)
        if length(currentParameter)>1
            FieldStr=['[' num2str(currentParameter) ']'];
        else
            FieldStr=num2str(currentParameter);
        end
    elseif islogical(currentParameter)
        FieldStr=num2str(double(currentParameter));
    elseif ischar(currentParameter)
        FieldStr=['''' currentParameter ''''];
    end
    ParaStr=[ParaStr, FieldStr, '; '];
end

function SetListboxStatus(ListboxStatus,  NewStatusStr)
OldStatusStr=get(ListboxStatus, 'String');
NewStatusStr=[OldStatusStr; {NewStatusStr}];

set(ListboxStatus, 'String', NewStatusStr, 'Min', 0, 'Max', 1, 'Value', length(NewStatusStr));
drawnow;

% --- Executes on button press in PushbuttonViewDataSet.
function PushbuttonViewDataSet_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonViewDataSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DisplayDataSet(handles, 'Data');

% --- Executes on button press in PushbuttonViewFeatureSet.
function PushbuttonViewFeatureSet_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonViewFeatureSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DisplayDataSet(handles, 'Feature');

function DataSetName=GetDataSetName(handles)
contents = cellstr(get(handles.ListboxDataSet,'String'));
DataSetName=contents{get(handles.ListboxDataSet,'Value')};
[~, DataSetName]=fileparts(DataSetName);

function DateSetFile=GetDateSetFile(handles, Mode)
switch Mode
    case 'Data'
        ListboxDataSet=handles.ListboxDataSet;
    case 'Feature'
        ListboxDataSet=handles.ListboxFeatureSet;
end

contents = cellstr(get(ListboxDataSet,'String'));
DataSetName=contents{get(ListboxDataSet,'Value')};


switch Mode
    case 'Data'
        DateSetFile=[handles.DataDir, '\', DataSetName];
    case 'Feature'
        DateSetFile=[handles.FeatureDir, '\', DataSetName];
end

function DisplayDataSet(handles, Mode)

switch Mode
    case 'Data'
        ListboxDataSet=handles.ListboxDataSet;
    case 'Feature'
        ListboxDataSet=handles.ListboxFeatureSet;
end

contents = cellstr(get(ListboxDataSet,'String'));
DataSetName=contents{get(ListboxDataSet,'Value')};

FigAll=findobj(0, 'Type', 'figure');
set(FigAll, 'Pointer', 'watch');
drawnow;

switch Mode
    case 'Data'
        DataSetCurrent(1, handles.DataDir, DataSetName);
    case 'Feature'
        FeatureSetCurrent(1, handles.FeatureDir, DataSetName);
end

FigAll=findobj(0, 'Type', 'figure');
set(FigAll, 'Pointer', 'arrow');
drawnow;

% --- Executes on selection change in ListboxStatus.
function ListboxStatus_Callback(hObject, eventdata, handles)
% hObject    handle to ListboxStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Hints: contents = cellstr(get(hObject,'String')) returns ListboxStatus contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListboxStatus
%
% --- Executes during object creation, after setting all properties.

function ListboxStatus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListboxStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
set(handles.ParentFig, 'Visible', 'on');
delete(handles.figure1);
