function varargout = IBEXFeature(varargin)
% IBEXFEATURE MATLAB code for IBEXFeature.fig
%      IBEXFEATURE, by itself, creates a new IBEXFEATURE or raises the existing
%      singleton*.
%
%      H = IBEXFEATURE returns the handle to a new IBEXFEATURE or the handle to
%      the existing singleton*.
%
%      IBEXFEATURE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IBEXFEATURE.M with the given input arguments.
%
%      IBEXFEATURE('Property','Value',...) creates a new IBEXFEATURE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IBEXFeature_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IBEXFeature_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IBEXFeature

% Last Modified by GUIDE v2.5 07-Oct-2014 12:01:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IBEXFeature_OpeningFcn, ...
                   'gui_OutputFcn',  @IBEXFeature_OutputFcn, ...
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

% --- Executes just before IBEXFeature is made visible.
function IBEXFeature_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IBEXFeature (see VARARGIN)


PHandles=varargin{2};

handles.ProgramPath=fileparts(mfilename('fullpath'));

handles.PatsParentDir=[PHandles.INIConfigInfo.DataDir, '\', PHandles.CurrentUser, '\', PHandles.CurrentSite];

handles.HightColor=[0, 255, 0];
% handles.TableSetValuePause=1E-90;
handles.TableSetValuePause=1E-1000;

%Store parameter
handles.PreprocessStore=[];
handles.CategoryStore=[];
handles.FeatureStore=[];

%Create common folder
CreateSiteFolder(handles.PatsParentDir);

%Initialize
InitializeFig(handles);

%Add Category path
Category=GetFeatureCategoryFolder;
if ~isempty(Category)
    AddCategoryFilterPath(Category);
end

%Figure Appearance
handles.ParentFig=PHandles.figure1;
set(handles.ParentFig, 'Visible', 'off');

CenterFigOneThirdX(handles.figure1);

figure(handles.figure1);

%Set figure units to normalized for resize
set(handles.figure1, 'Units', 'normalized');
hChild=get(handles.figure1, 'Children');
set(hChild, 'Units', 'normalized');

%Get JTable
handles.jUITablePreprocess=GetJTable(handles.UITablePreprocess);
handles.jUITableCategory=GetJTable(handles.UITableCategory);
handles.jUITableCategoryFeature=GetJTable(handles.UITableCategoryFeature);

handles.jUITablePreprocess.setRowHeight(25);
handles.jUITableCategory.setRowHeight(25);
handles.jUITableCategoryFeature.setRowHeight(25);

% Choose default command line output for IBEXFeature
handles.output = hObject;

% Update handles structure
guidata(handles.figure1, handles);

% UIWAIT makes IBEXFeature wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%Import path is added when import GUI is open

function InitializeFig(handles)
%Set text on UI
TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Add to<br />Feature Set</font></html>';
set(handles.PushbuttonAddFeatureSet, 'String', TextStr);

TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Show<br />Data Set</font></html>';
set(handles.PushbuttonShowDataSet, 'String', TextStr);

TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Show<br />Feature Set</font></html>';
set(handles.PushbuttonShowFeatureSet, 'String', TextStr);

TextStr='<html><b><center><font size="4" face="Calibri" color="rgb(0,0,0)">Exit</font></html>';
set(handles.PushbuttonExit, 'String', TextStr);

%UITablePreprocess
TableHeader=[];
TableHeader=[TableHeader, {['<html><b><center><font size="4" face="Calibri" color="rgb(0,0,100)">', 'Order']}];
TableHeader=[TableHeader, {['<html><b><center><font size="4" face="Calibri" color="rgb(0,0,100)">', 'Name']}];
TableHeader=[TableHeader, {['<html><b><center><font size="4" face="Calibri" color="rgb(0,0,100)">', 'Para.']}];
% TableHeader=[TableHeader, {['<html><b><center><font size="4" face="Calibri" color="rgb(0,0,100)">', ' ']}];

TableFormat={'numeric', 'char', 'char'}; %, 'char'
TableEdit=[false, false, false]; %, false
TableWidth={60, 200, 60}; %, 50

set(handles.UITablePreprocess, 'Visible', 'on', 'Enable', 'on', ...
        'ColumnName', TableHeader, 'ColumnFormat', TableFormat, ...
        'ColumnEditable', logical(TableEdit), 'ColumnWidth', TableWidth); 

UpdateUITablePreprocess(handles);

set(handles.PushbuttonDeletePreprocess, 'Enable', 'Off');

%UITableCategory
TableHeader=[];
TableHeader=[TableHeader, {['<html><b><center><font size="4" face="Calibri" color="rgb(0,0,100)">', 'Name']}];
TableHeader=[TableHeader, {['<html><b><center><font size="4" face="Calibri" color="rgb(0,0,100)">', 'Para.']}];
% TableHeader=[TableHeader, {['<html><b><center><font size="4" face="Calibri" color="rgb(0,0,100)">', ' ']}];

Category=GetFeatureCategoryFolder;
Category=[{' '}; Category];

TableFormat={Category', 'char'}; %, 'char'
TableEdit=[ true, false]; %, false
TableWidth={220, 60}; %, 60
TableData=[{' '}, {' '}]; %, {' '}

set(handles.UITableCategory, 'Visible', 'on', 'Enable', 'on', ...
        'ColumnName', TableHeader, 'ColumnFormat', TableFormat, ...
        'ColumnEditable', logical(TableEdit), 'ColumnWidth', TableWidth, 'Data', TableData);
    
%UITableCategoryFeature
TableHeader=[];
TableHeader=[TableHeader, {['<html><b><center><font size="4" face="Calibri" color="rgb(0,0,100)">', ' ']}];
TableHeader=[TableHeader, {['<html><b><center><font size="4" face="Calibri" color="rgb(0,0,100)">', 'Name']}];
TableHeader=[TableHeader, {['<html><b><center><font size="4" face="Calibri" color="rgb(0,0,100)">', 'Para.']}];
% TableHeader=[TableHeader, {['<html><b><center><font size="4" face="Calibri" color="rgb(0,0,100)">', ' ']}];

TableFormat={'logical', 'char', 'char'}; %, 'char'
TableEdit=[true, false, false]; %, false
TableWidth={40, 200, 60}; %, 60

set(handles.UITableCategoryFeature, 'Visible', 'on', 'Enable', 'on', ...
    'ColumnName', TableHeader, 'ColumnFormat', TableFormat, ...
    'ColumnEditable', logical(TableEdit), 'ColumnWidth', TableWidth);

UpdateUITableCategoryFeature(handles);

% --- Outputs from this function are returned to the command line.
function varargout = IBEXFeature_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in ListboxCategoryPara.
function ListboxCategoryPara_Callback(hObject, eventdata, handles)
% hObject    handle to ListboxCategoryPara (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListboxCategoryPara contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListboxCategoryPara

% --- Executes during object creation, after setting all properties.
function ListboxCategoryPara_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListboxCategoryPara (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in ListboxPreprocessPara.
function ListboxPreprocessPara_Callback(hObject, eventdata, handles)
% hObject    handle to ListboxPreprocessPara (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListboxPreprocessPara contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListboxPreprocessPara

% --- Executes during object creation, after setting all properties.
function ListboxPreprocessPara_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListboxPreprocessPara (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in ListboxCategoryFeaturePara.
function ListboxCategoryFeaturePara_Callback(hObject, eventdata, handles)
% hObject    handle to ListboxCategoryFeaturePara (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListboxCategoryFeaturePara contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListboxCategoryFeaturePara

% --- Executes during object creation, after setting all properties.
function ListboxCategoryFeaturePara_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListboxCategoryFeaturePara (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in PushbuttonPreprocessReview.
function PushbuttonPreprocessReview_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonPreprocessReview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in PushbuttonCategoryReview.
function PushbuttonCategoryReview_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonCategoryReview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in PushbuttonShowFeatureSet.
function PushbuttonShowFeatureSet_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonShowFeatureSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Show Data Set
hFig=findobj(0, 'Type', 'figure', 'Name', 'Current Feature Set');
if ~isempty(hFig)    
    figure(hFig);
    return;
else
    FeatureSetList(1, handles.PatsParentDir, handles.figure1);
end

% --- Executes on button press in PushbuttonAddFeatureSet.
function PushbuttonAddFeatureSet_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonAddFeatureSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Close Data Set 
hFig=findobj(0, 'Type', 'figure', 'Name', 'Current Feature Set');
if isempty(hFig)        
    FeatureSetName=[];
else
    hFeatureSetName=findobj(hFig, 'Tag', 'TextFeatureSetName');
    FeatureSetName=get(hFeatureSetName, 'String');
    
    delete(hFig);
end

%Sanity Check
TableData=get(handles.UITableCategoryFeature, 'Data');
if isempty(TableData)
    hFig=MsgboxGuiIFOA('No features are available.', 'Warn', 'warn');       
    return;
end

SelectMat=cell2mat(TableData(:, 1));
TempIndex=find(SelectMat);
if isempty(TempIndex)
    hFig=MsgboxGuiIFOA('No features are selected.', 'Warn', 'warn');       
    return;
end


%Show Data Set
if ~isempty(FeatureSetName)
    hFig=FeatureSetCurrent(1, [handles.PatsParentDir, '\1FeatureModelSet_Algorithm'], FeatureSetName);
    
%     TempName=get(hFig, 'name');
%     SetTopWindow(TempName);
%     pause(0.01);
%     drawnow;
else
    hFig=FeatureSetList(1, handles.PatsParentDir, handles.figure1);  
    waitfor(hFig);    
end

%Add to file
Flag=AddToFeatureSet(handles);


%Clean workspace
handles.CategoryStore=[];
handles.FeatureStore=[];

guidata(handles.figure1, handles);

UpdateUITableCategoryFeature(handles);

TableDataC(1, 1)={' '};
TableDataC(1, 2)={' '};
% TableDataC(1, 3)={' '};
set(handles.UITableCategory, 'Data', TableDataC);

% handles.PreprocessStore=[];
% UpdateUITablePreprocess(handles);

function Flag=AddToFeatureSet(handles)
Flag=1;

hFig=findobj(0, 'Type', 'figure', 'Name', 'Current Feature Set');
if isempty(hFig)
    Flag=0;
    return;
end

hDataSetName=findobj(hFig, 'Tag', 'TextFeatureSetName');
FeatureSetName=get(hDataSetName, 'String');

FeatureSetFile=[handles.PatsParentDir, '\1FeatureModelSet_Algorithm\', FeatureSetName];

CFeatureSethandles=guidata(hFig);

FeatureSetsInfo=CFeatureSethandles.FeatureSetsInfo;

if size(FeatureSetsInfo, 1) < 1
    FeatureSetsInfo=[];    
end

CFeatureSetInfo=[];
%Preprocess Info.
TableData=get(handles.UITablePreprocess, 'Data');
if isempty(TableData)
    CFeatureSetInfo.Preprocess={' '};    
else
    CFeatureSetInfo.Preprocess=TableData(:, 2);
end
CFeatureSetInfo.PreprocessStore=handles.PreprocessStore;

%Category Info.
TableData=get(handles.UITableCategory, 'Data');
if isempty(TableData)
    CFeatureSetInfo.Category={' '};   
    CFeatureSetInfo.CategoryStore=[];
else
    CFeatureSetInfo.Category=TableData(:, 1);
    ItemIndex=GetStoreIndex(TableData{:, 1}, handles, 'Category');
    CFeatureSetInfo.CategoryStore=handles.CategoryStore(ItemIndex);
end

%Feature Info.
TableData=get(handles.UITableCategoryFeature, 'Data');
if isempty(TableData)
    CFeatureSetInfo.Feature={' '};    
     CFeatureSetInfo.FeatureStore=[];
else
    SelectMat=cell2mat(TableData(:, 1));
    SelectIndex=find(SelectMat);    
    CFeatureSetInfo.Feature=TableData(SelectIndex, 2);
    CFeatureSetInfo.FeatureStore=handles.FeatureStore(SelectIndex);
end

CFeatureSetInfo.Comment=' ';
CFeatureSetInfo.CreationDate=datestr(now, 30);

FeatureSetsInfo=[FeatureSetsInfo; CFeatureSetInfo];

%Save to file
save(FeatureSetFile, 'FeatureSetsInfo');

%Update display
[Flag, TableFeatureItemID, TableData, FeatureSetsInfo]=UpdateTableFeatureSetDisplay(FeatureSetsInfo, CFeatureSethandles, 'Add');

set(CFeatureSethandles.PushbuttonDelete, 'Enable', 'On');
set(CFeatureSethandles.PushbuttonCopy, 'Enable', 'On');

CFeatureSethandles.TableFeatureItemID=TableFeatureItemID;
CFeatureSethandles.FeatureSetsInfo=FeatureSetsInfo;
CFeatureSethandles.TableData=TableData;

guidata(CFeatureSethandles.figure1, CFeatureSethandles);

% --- Executes on button press in PushbuttonExit.
function PushbuttonExit_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.ParentFig, 'Visible', 'on');
delete(handles.figure1);

% --- Executes on button press in PushbuttonShowDataSet.
function PushbuttonShowDataSet_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonShowDataSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Show Data Set
hFig=findobj(0, 'Type', 'figure', 'Name', 'Current Data Set');
if ~isempty(hFig)    
    figure(hFig);
    return;
else
    DataSetList(1, handles.PatsParentDir, handles.figure1);
end

% --- Executes on button press in PushbuttonDeletePreprocess.
function PushbuttonDeletePreprocess_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonDeletePreprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

RowIndex=handles.jUITablePreprocess.getSelectedRow + 1;
ColumnIndex=handles.jUITablePreprocess.getSelectedColumn  + 1;

handles.PreprocessStore(RowIndex)=[];
guidata(handles.figure1, handles);

UpdateUITablePreprocess(handles);

% --- Executes on button press in PushbuttonAddPreprocess.
function PushbuttonAddPreprocess_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonAddPreprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Delete Status
set(handles.PushbuttonDeletePreprocess, 'Enable', 'Off');    

%Add Preprocess module
PreprocessMethod=FeatureAddPreprocess(1, handles.figure1);

%Save
handles.PreprocessStore=[handles.PreprocessStore; PreprocessMethod];
guidata(handles.figure1, handles);

%Update Table
if ~isempty(PreprocessMethod)
    UpdateUITablePreprocess(handles);
end

function UpdateUITableCategoryFeature(handles)
if isempty(handles.FeatureStore)
    set(handles.UITableCategoryFeature, 'Data', '');
else        
    InfoPic=[handles.ProgramPath, '\Pic\FeatureInfo.png'];
    InfoImgHtml=['<html><img src="file:/', InfoPic, '"></html>'];
    
%     TestPic=[handles.ProgramPath, '\Pic\FeatureTest.png'];
%     TestImgHtml=['<html><img src="file:/', TestPic, '"></html>'];
           
    ItemLen=length(handles.FeatureStore);   

    TableData(:, 1)=repmat({true}, ItemLen, 1);
    TableData(:, 2)={handles.FeatureStore.Name}';
    
    TableData(:, 3)=repmat({InfoImgHtml}, ItemLen, 1);    
%     TableData(:, 4)=repmat({TestImgHtml}, ItemLen, 1);   
        
    set(handles.UITableCategoryFeature, 'Data', TableData);
end

function UpdateUITablePreprocess(handles)
if isempty(handles.PreprocessStore)
    set(handles.UITablePreprocess, 'Data', '');
else    
    InfoPic=[handles.ProgramPath, '\Pic\FeatureInfo.png'];
    InfoImgHtml=['<html><img src="file:/', InfoPic, '"></html>'];
    
%     TestPic=[handles.ProgramPath, '\Pic\FeatureTest.png'];
%     TestImgHtml=['<html><img src="file:/', TestPic, '"></html>'];
           
    ItemLen=length(handles.PreprocessStore);
    
%     TableData(:, 1)=cellstr(num2str((1:ItemLen)'));
    TableData(:, 1)=num2cell((1:ItemLen)');
    TableData(:, 2)={handles.PreprocessStore.Name}';
    
    TableData(:, 3)=repmat({InfoImgHtml}, ItemLen, 1);
%     TableData(:, 4)=repmat({TestImgHtml}, ItemLen, 1);
    
    set(handles.UITablePreprocess, 'Data', TableData);
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure
PushbuttonExit_Callback(handles.PushbuttonExit, eventdata, handles);

% --- Executes when selected cell(s) is changed in UITablePreprocess.
function UITablePreprocess_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to UITablePreprocess (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

if isempty(eventdata.Indices)
    return;
end

RowIndex=eventdata.Indices(1);
ColumnIndex=eventdata.Indices(2);

%Selection
if ColumnIndex == 1
    %Delete Status
    set(handles.PushbuttonDeletePreprocess, 'Enable', 'Off');    
end

%Module
if ColumnIndex == 2
    %Delete Status
    set(handles.PushbuttonDeletePreprocess, 'Enable', 'On');    
end

%Params
if ColumnIndex == 3        
    %Delete Status
    set(handles.PushbuttonDeletePreprocess, 'Enable', 'Off');
    
    %Params
    TableData=get(handles.UITablePreprocess, 'Data');
    
    PreprocessModule=TableData{RowIndex, 2};    
    ProgramPath=fileparts(mfilename('fullpath'));
    Param=handles.PreprocessStore(RowIndex).Value;
    
    PreprocessModulePara=FeatureAddPreprocessPara(1, PreprocessModule, ProgramPath, Param, 'Preprocess', handles.figure1);
    
    handles.PreprocessStore(RowIndex).Value=PreprocessModulePara;
    
    guidata(handles.figure1, handles);
end

% %Test
% if ColumnIndex == 4    
%     %Delete Status
%     set(handles.PushbuttonDeletePreprocess, 'Enable', 'Off');
%     
%     %Show DataSet List    
%     hFig=findobj(0, 'Type', 'figure', 'Name', 'Current Data Set');
%     if ~isempty(hFig)
%         delete(hFig);
%     end
%     
%     PreprocessStore=handles.PreprocessStore(1:RowIndex);
%     DataSetList(1, handles.PatsParentDir, handles.figure1, 'Preprocess', {PreprocessStore});
% end

% --- Executes when selected cell(s) is changed in UITableCategory.
function UITableCategory_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to UITableCategory (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

if isempty(eventdata.Indices)
    return;
end

RowIndex=eventdata.Indices(1);
ColumnIndex=eventdata.Indices(2);

%Selection
%Params
if ColumnIndex == 2        
    %Params
    TableData=get(handles.UITableCategory, 'Data');
    
    Module=TableData{RowIndex, 1};    
        
    ItemIndex=GetStoreIndex(Module, handles, 'Category');            
    Param=handles.CategoryStore(ItemIndex).Value;
    
    ModulePara=FeatureAddPreprocessPara(1, Module, handles.ProgramPath, Param, 'Category', handles.figure1);
    
    handles.CategoryStore(ItemIndex).Value=ModulePara;
    
    guidata(handles.figure1, handles);
end

%Test
% if ColumnIndex == 3    
%    
%     %Show DataSet List    
%     hFig=findobj(0, 'Type', 'figure', 'Name', 'Current Data Set');
%     if ~isempty(hFig)
%         delete(hFig);
%     end
%     
%     %Get input parameters 
%     TableData=get(handles.UITableCategory, 'Data');
%     
%     Module=TableData{RowIndex, 1};    
%     ItemIndex=GetStoreIndex(Module, handles, 'Category');  
%     
%     CategoryStore=handles.CategoryStore(ItemIndex);
%     
%     %Add Preprocess and Catogry Store
%     TableData=get(handles.UITablePreprocess, 'Data');    
%     if ~isequal(TableData, '')
%         PreprocessStore=handles.PreprocessStore(1:size(TableData, 1));
%     else
%         PreprocessStore=[];
%     end
%     
%     DataSetList(1, handles.PatsParentDir, handles.figure1, 'Category', {PreprocessStore, CategoryStore});
% end

% --- Executes when selected cell(s) is changed in UITableCategoryFeature.
function UITableCategoryFeature_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to UITableCategoryFeature (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

if isempty(eventdata.Indices)
    return;
end

RowIndex=eventdata.Indices(1);
ColumnIndex=eventdata.Indices(2);

%Params
if ColumnIndex == 3        
      
    %Params
    TableData=get(handles.UITableCategoryFeature, 'Data');
    
    Module=TableData{RowIndex, 2};    
    Param=handles.FeatureStore(RowIndex).Value;
    
    TableData=get(handles.UITableCategory, 'Data');    
    CModule=TableData{1, 1};    
    
    if ~isequal(CModule, 'Manual')
        ModulePara=FeatureAddPreprocessPara(1, [CModule, '/', Module], handles.ProgramPath, Param, 'Feature', handles.figure1);
    else
        ModulePara=FeatureAddPreprocessPara(1, Module, handles.ProgramPath, Param, 'Manual', handles.figure1);
    end
    
    handles.FeatureStore(RowIndex).Value=ModulePara;
    
    %Sync params for all group features: Local entropy, Local range, Local std
    handles.FeatureStore=SyncFeatureParams(Module, handles.FeatureStore, 'LocalEntropy', ModulePara);
    handles.FeatureStore=SyncFeatureParams(Module, handles.FeatureStore, 'LocalRange', ModulePara);
    handles.FeatureStore=SyncFeatureParams(Module, handles.FeatureStore, 'LocalStd', ModulePara);
            
    guidata(handles.figure1, handles);
end

% %Test
% if ColumnIndex == 4    
%         %Show DataSet List    
%     hFig=findobj(0, 'Type', 'figure', 'Name', 'Current Data Set');
%     if ~isempty(hFig)
%         delete(hFig);
%     end
%     
%     %Add Preprocess Category, and Feature Store
%     FeatureStore=handles.FeatureStore(RowIndex);
%     
%     TableData=get(handles.UITablePreprocess, 'Data');    
%     if ~isequal(TableData, '')
%         PreprocessStore=handles.PreprocessStore(1:size(TableData, 1));
%     else
%         PreprocessStore=[];
%     end
%     
%     TableData=get(handles.UITableCategory, 'Data');
%     
%     Module=TableData{1, 1};
%     ItemIndex=GetStoreIndex(Module, handles, 'Category');
%     
%     CategoryStore=handles.CategoryStore(ItemIndex);
%     
%     DataSetList(1, handles.PatsParentDir, handles.figure1, 'Feature', {PreprocessStore, CategoryStore, FeatureStore});    
% end

% --- Executes when entered data in editable cell(s) in UITableCategory.
function UITableCategory_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to UITableCategory (see GCBO)
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

if ColumnIndex == 1
    TableData=get(handles.UITableCategory, 'Data');
    
    CurrentMethod=TableData(RowIndex, ColumnIndex);
    
    if ~isequal(CurrentMethod, {' '})
        InfoPic=[handles.ProgramPath, '\Pic\FeatureInfo.png'];
        InfoImgHtml=['<html><img src="file:/', InfoPic, '"></html>'];
        
%         TestPic=[handles.ProgramPath, '\Pic\FeatureTest.png'];
%         TestImgHtml=['<html><img src="file:/', TestPic, '"></html>'];
        
        TableData(1, 2)={InfoImgHtml};
%         TableData(1, 3)={TestImgHtml};
    else
        TableData(1, 2)={' '};
        TableData(1, 3)={' '};
    end
    
    %Update Table
    set(handles.UITableCategory, 'Data', TableData);
    
    %Update Param
    if ~isequal(CurrentMethod, {' '})
        Module=CurrentMethod{1};
        ItemIndex=GetStoreIndex(Module, handles, 'Category');
        
        %Read Param
        if ~(ItemIndex<=length(handles.CategoryStore))
            ConfigFile=[handles.ProgramPath, '\FeatureAlgorithm\Category\', Module, '\', Module, '_Category.INI'];
            Param=GetParamFromINI(ConfigFile);
            
            handles.CategoryStore(ItemIndex).Name=Module;
            handles.CategoryStore(ItemIndex).Value=Param;
            
            guidata(handles.figure1, handles);
        end        
        
        %Update Feature Table
         try
             FeatureFuncH=str2func([Module, '_Feature']);
       
            FeatureInfo=FeatureFuncH([], [], 'ParseFeature');
            
            %%% Bettinelli Mod -> keep IBSI order - don't sort by name
            % FeatureInfo=sortStruct(FeatureInfo, 'Name'); 
            
            handles.FeatureStore=FeatureInfo;
        catch
            handles.FeatureStore=[];
        end
        
        guidata(handles.figure1, handles);
                
        UpdateUITableCategoryFeature(handles);
    end
       
    
end

% --- Executes when entered data in editable cell(s) in UITableCategoryFeature.
function UITableCategoryFeature_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to UITableCategoryFeature (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over TextFeature.
function TextFeature_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to TextFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

TableData=get(handles.UITableCategoryFeature, 'Data');

if ~isempty(TableData)
    SelectMat=cell2mat(TableData(:, 1));
    
    TempIndex=find(SelectMat);
    if ~isempty(TempIndex)
        SelectMat=repmat({false}, size(SelectMat));
    else
        SelectMat=repmat({true}, size(SelectMat));
    end
    
    TableData(:, 1)=SelectMat;
    
    set(handles.UITableCategoryFeature, 'Data', TableData);
end
