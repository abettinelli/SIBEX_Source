function varargout = FeatureAddPreprocess(varargin)
% FEATUREADDPREPROCESS MATLAB code for FeatureAddPreprocess.fig
%      FEATUREADDPREPROCESS, by itself, creates a new FEATUREADDPREPROCESS or raises the existing
%      singleton*.
%
%      H = FEATUREADDPREPROCESS returns the handle to a new FEATUREADDPREPROCESS or the handle to
%      the existing singleton*.
%
%      FEATUREADDPREPROCESS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FEATUREADDPREPROCESS.M with the given input arguments.
%
%      FEATUREADDPREPROCESS('Property','Value',...) creates a new FEATUREADDPREPROCESS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FeatureAddPreprocess_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FeatureAddPreprocess_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FeatureAddPreprocess

% Last Modified by GUIDE v2.5 29-Jul-2014 16:01:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FeatureAddPreprocess_OpeningFcn, ...
                   'gui_OutputFcn',  @FeatureAddPreprocess_OutputFcn, ...
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


% --- Executes just before FeatureAddPreprocess is made visible.
function FeatureAddPreprocess_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FeatureAddPreprocess (see VARARGIN)

PFig=varargin{2};
handles.PFig=PFig;

set(handles.PushbuttonReviewFormat, 'Visible', 'Off');

%Preprocessing
ProgramPath=fileparts(mfilename('fullpath'));

TempIndex=strfind(ProgramPath, '\');
ProgramPath=ProgramPath(1:TempIndex(end)-1);

InitializeUITableMethod(ProgramPath, handles);

handles.ProgramPath=ProgramPath;

handles.ParaStore=[];

CenterFig(handles.figure1, PFig);

% Choose default command line output for FeatureAddPreprocess
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FeatureAddPreprocess wait for user response (see UIRESUME)
uiwait(handles.figure1);


function InitializeUITableMethod(ProgramPath, handles)

% InfoPic=[ProgramPath, '\Pic\FeatureInfo.png'];
% InfoImgHtml=['<html><img src="file:/', InfoPic, '"></html>'];

% TestPic=[ProgramPath, '\Pic\FeatureTest.png'];    
% TestImgHtml=['<html><img src="file:/', TestPic, '"></html>'];
% TableData(:, 4)=[repmat({TestImgHtml}, NumMethod, 1)];

% NumMethod=length(PreprocessMethod);
% 
% TableData(:, 1)=PreprocessMethod;
% TableData(:, 2)=[repmat({InfoImgHtml}, NumMethod, 1)];

TableHeader=[];
TableHeader=[TableHeader, {['<html><b><center><font size="4" face="Calibri" color="rgb(0,0,100)">', 'Module']}];
TableHeader=[TableHeader, {['<html><b><center><font size="4" face="Calibri" color="rgb(0,0,100)">', 'Para.']}];

PreprocessMethod=GetPreprocessMethod([ProgramPath, '\FeatureAlgorithm\Preprocess']);
PreprocessMethod=[{' '}; PreprocessMethod];

TableFormat={PreprocessMethod', 'char'};

TableEdit=[true, false];
TableWidth={255, 50};

TableData=[{' '}, {' '}];

set(handles.PushbuttonAdd, 'Enable', 'Off');
set(handles.PushbuttonHelp, 'Enable', 'Off');

% [ImageData, CMap]=imread('Question.png');
% set(handles.PushbuttonHelp, 'CData', ImageData);
configureButton(handles.PushbuttonHelp,[ProgramPath '\Pic\Question.png'])

set(handles.UITableMethod, 'Visible', 'on', 'Enable', 'on', 'Data', TableData, ...
        'ColumnName', TableHeader, 'ColumnFormat', TableFormat, ...
        'ColumnEditable', logical(TableEdit), 'ColumnWidth', TableWidth); 

function configureButton(p, CIcon_p)

str = ['<html><img align="middle" src="file:/', CIcon_p, '">'];
set(p,'String', str);

% --- Outputs from this function are returned to the command line.
function varargout = FeatureAddPreprocess_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if handles.OK < 1
    PreprocessMethod=[];
else
    TableData=get(handles.UITableMethod, 'Data');
    
    PreprocessModule=TableData{1, 1};

    ItemIndex=GetStoreIndex(PreprocessModule, handles, 'Preprocess');    
  
    if ItemIndex <= length(handles.ParaStore)
        %Parameters reviewed
        PreprocessModulePara =handles.ParaStore(ItemIndex).Value;
    else
        %Parameters not reviewed
        ConfigFile=[handles.ProgramPath, '\FeatureAlgorithm\Preprocess\', PreprocessModule, '.INI'];
        Param=GetParamFromINI(ConfigFile);
        
        PreprocessModulePara=Param;
    end
    
    PreprocessMethod.Name=PreprocessModule;
    PreprocessMethod.Value=PreprocessModulePara;        
end
             
varargout{1} = PreprocessMethod;

delete(handles.figure1);



% --- Executes on button press in PushbuttonAdd.
function PushbuttonAdd_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles.OK=1;
guidata(handles.figure1, handles);

uiresume(handles.figure1);


% --- Executes on button press in PushbuttonExit.
function PushbuttonExit_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.OK=0;
guidata(handles.figure1, handles);

uiresume(handles.figure1);


% --- Executes when entered data in editable cell(s) in UITableMethod.
function UITableMethod_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to UITableMethod (see GCBO)
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
    TableData=get(handles.UITableMethod, 'Data');
    
    CurrentMethod=TableData(RowIndex, ColumnIndex);
    
    if ~isequal(CurrentMethod, {' '})
        InfoPic=[handles.ProgramPath, '\Pic\FeatureInfo.png'];
        InfoImgHtml=['<html><img src="file:/', InfoPic, '"></html>'];
        
        TableData(1, 2)={InfoImgHtml};
        
        set(handles.PushbuttonAdd, 'Enable', 'On');
        set(handles.PushbuttonHelp, 'Enable', 'On');
        
        if isequal(CurrentMethod, {'Resample_VoxelSize'})
            set(handles.PushbuttonReviewFormat, 'Visible', 'Off');
        else
            set(handles.PushbuttonReviewFormat, 'Visible', 'Off');
        end        
    else
        TableData(1, 2)={' '};
        
        set(handles.PushbuttonAdd, 'Enable', 'Off');
        set(handles.PushbuttonHelp, 'Enable', 'Off');
        set(handles.PushbuttonReviewFormat, 'Visible', 'Off');

    end
    
    set(handles.UITableMethod, 'Data', TableData);
end


% --- Executes when selected cell(s) is changed in UITableMethod.
function UITableMethod_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to UITableMethod (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

if isempty(eventdata.Indices)
    return;
end

RowIndex=eventdata.Indices(1);
ColumnIndex=eventdata.Indices(2);

if ColumnIndex == 2
    TableData=get(handles.UITableMethod, 'Data');
    
    CurrentData=TableData(RowIndex, ColumnIndex);
    
    if ~isequal(CurrentData, {' '})
        
        PreprocessModule=TableData{RowIndex, ColumnIndex-1};
        
        %Preset  
        %ItemIndex       
        ItemIndex=GetStoreIndex(PreprocessModule, handles, 'Preprocess');
    
        Param=[];
        if ItemIndex <= length(handles.ParaStore)
            Param=handles.ParaStore(ItemIndex).Value;
        end
        
        PreprocessModulePara=FeatureAddPreprocessPara(1, PreprocessModule, handles.ProgramPath, Param, 'Preprocess', handles.figure1);
        
        %Store
        handles.ParaStore(ItemIndex).Name=PreprocessModule;
        handles.ParaStore(ItemIndex).Value=PreprocessModulePara;
        
        guidata(handles.figure1, handles);
    end
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
PushbuttonExit_Callback(handles.PushbuttonExit, [], handles);


% --- Executes on button press in PushbuttonReviewFormat.
function PushbuttonReviewFormat_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonReviewFormat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Show Data Set
hFig=findobj(0, 'Type', 'figure', 'Name', 'Current Data Set');
if ~isempty(hFig)    
    figure(hFig);
    return;
else
    handlesT=guidata(handles.PFig);
    DataSetList(1, handlesT.PatsParentDir, handlesT.figure1, 'Simple');
end


% --- Executes on button press in PushbuttonHelp.
function PushbuttonHelp_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

TableData=get(handles.UITableMethod, 'Data');
if ~isempty(TableData)
     PreprocessModule=TableData{1, 1};
       
     MethodFileName=[handles.ProgramPath, '\FeatureAlgorithm\Preprocess\', PreprocessModule, '.m'];
          
     DisplayMethodHelp(MethodFileName, 1);
end




    
