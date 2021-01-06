function varargout = FeatureAddPreprocessPara(varargin)
% FEATUREADDPREPROCESSPARA MATLAB code for FeatureAddPreprocessPara.fig
%      FEATUREADDPREPROCESSPARA, by itself, creates a new FEATUREADDPREPROCESSPARA or raises the existing
%      singleton*.
%
%      H = FEATUREADDPREPROCESSPARA returns the handle to a new FEATUREADDPREPROCESSPARA or the handle to
%      the existing singleton*.
%
%      FEATUREADDPREPROCESSPARA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FEATUREADDPREPROCESSPARA.M with the given input arguments.
%
%      FEATUREADDPREPROCESSPARA('Property','Value',...) creates a new FEATUREADDPREPROCESSPARA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FeatureAddPreprocessPara_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FeatureAddPreprocessPara_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FeatureAddPreprocessPara

% Last Modified by GUIDE v2.5 18-Sep-2014 10:45:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FeatureAddPreprocessPara_OpeningFcn, ...
                   'gui_OutputFcn',  @FeatureAddPreprocessPara_OutputFcn, ...
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

% --- Executes just before FeatureAddPreprocessPara is made visible.
function FeatureAddPreprocessPara_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FeatureAddPreprocessPara (see VARARGIN)

PreprocessModule=varargin{2};
handles.ProgramPath=varargin{3};
Param=varargin{4};
Mode=varargin{5};

handles.Mode=Mode;

set(handles.PushbuttonReviewFormat, 'Visible', 'Off');
set(handles.TextVoxInfo, 'Visible', 'Off');

[ImageData, CMap]=imread('Question.png');
set(handles.PushbuttonHelp, 'CData', ImageData);

if iscell(PreprocessModule)
    PreprocessModule=char(PreprocessModule);
end

switch Mode
    case 'Preprocess'
        if isempty(Param)
            ConfigFile=[handles.ProgramPath, '\FeatureAlgorithm\Preprocess\', PreprocessModule, '.INI'];
        end
        set(handles.TextInfo, 'String', ['Para. for Preprocess ', PreprocessModule]);
        
        if isequal(PreprocessModule, 'Resample_VoxelSize')
            set(handles.PushbuttonReviewFormat, 'Visible', 'On');
            set(handles.TextVoxInfo, 'Visible', 'On');
        else
            set(handles.PushbuttonReviewFormat, 'Visible', 'Off');
            set(handles.TextVoxInfo, 'Visible', 'Off');
        end
                
        MethodFileName=[handles.ProgramPath, '\FeatureAlgorithm\Preprocess\', PreprocessModule, '.m'];        
    case 'Category'        
        set(handles.TextInfo, 'String', ['Para. for Category ', PreprocessModule]);        
               
        MethodFileName=[handles.ProgramPath, '\FeatureAlgorithm\Category\', PreprocessModule, '\', PreprocessModule, '_Category.m'];        
    case 'Feature'        
        set(handles.TextInfo, 'String', ['Para. for Feature ', PreprocessModule]);      
        
        [CategoryName, FeatureName]=GetInfo(PreprocessModule);
        MethodFileName=[handles.ProgramPath, '\FeatureAlgorithm\Category\', CategoryName, '\', CategoryName, '_Feature.m'];       
    case 'Manual'        
        set(handles.TextInfo, 'String', ['Para. for Feature ', PreprocessModule]);       
        MethodFileName=[];
end

handles.MethodFileName=MethodFileName;
handles.PreprocessModule=PreprocessModule;
handles.Mode=Mode;

if isempty(Param) && isequal(Mode, 'Preprocess')
    Param=GetParamFromINI(ConfigFile);
end

InitializeUITablePara(Param, handles);

if isequal(get(handles.TextVoxInfo, 'Visible'), 'On') || isequal(get(handles.TextVoxInfo, 'Visible'), 'on')
    UpdateTextVoxInfo(handles);
end

if length(varargin) > 5
    CenterFig(handles.figure1, varargin{6});    
end

%Parameters in INI file
handles.Param=Param;

% Choose default command line output for FeatureAddPreprocessPara
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FeatureAddPreprocessPara wait for user response (see UIRESUME)
uiwait(handles.figure1);

function UpdateTextVoxInfo(handles)
TableData=get(handles.UITablePara, 'Data');

if isequal(TableData, [{' '}, {' '}])
    set(handles.TextVoxInfo, 'String', ' ');
else
    FormatData=str2num(char(TableData(:, 2)));
    XVox=FormatData(1);
    YVox=FormatData(2);
    ZVox=FormatData(3);
    
    XFOV=512*XVox;
    YFOV=512*YVox;
    
    InfoStr=['For 512*512, XFOV=' num2str(XFOV, '%.2f'), 'cm. ','YFOV=',  num2str(YFOV, '%.2f'), 'cm.'];
    
%     XCutoff=FormatData(4);
%     YCutoff=FormatData(5);
%     ZCutoff=FormatData(6);   
%     
%     XFOVDiff=512*XVox*(1-XCutoff/100);
%     YFOVDiff=512*YVox*(1-YCutoff/100);
%     ZVoxDiff=ZVox*(1-ZCutoff/100);
%     
%     InfoStr=['For 512*512, XFOV: ' num2str(XFOV, '%.2f'), 'cm~=', num2str(XFOVDiff, '%.2f'), 'cm. ', ...
%         'YFOV: ',  num2str(YFOV, '%.2f'), 'cm~=', num2str(YFOVDiff, '%.2f'), 'cm. ', ...
%         'SP: ', num2str(ZVox, '%.2f'), 'cm~=', num2str(ZVoxDiff, '%.2f'), 'cm.'];
%     
    set(handles.TextVoxInfo, 'String', InfoStr);
end

function InitializeUITablePara(Param, handles)
TableHeader=[];
TableHeader=[TableHeader, {['<html><b><center><font size="4" face="Calibri" color="rgb(0,0,100)">', 'Para.']}];
TableHeader=[TableHeader, {['<html><b><center><font size="4" face="Calibri" color="rgb(0,0,100)">', 'Value']}];

TableFormat={'char', 'char'};

TableEdit=[false, true];
TableWidth={134, 80};

if isempty(Param)
    TableData=[{' '}, {' '}];
else
    if ~isequal(handles.Mode, 'Manual')
        TableData(:, 1)=fieldnames(Param);
        
        ParamValue=struct2cell(Param);
        ParamValue=ConvertCell2Char(ParamValue);
        
        TableData(:, 2)=ParamValue;
    else
        ItemLen=length(Param.ItemList);
        
        TableData(:, 1)=repmat({' '}, ItemLen, 1);
        TableData(1, 1)={'ItemEnum'};
        
        if iscell(Param.ItemList)
            TableData(:, 2)=Param.ItemList;
        else
            TableData(:, 2)=cellstr(num2str(Param.ItemList));            
        end
    end
end

set(handles.UITablePara, 'Visible', 'on', 'Enable', 'on', 'Data', TableData, ...
        'ColumnName', TableHeader, 'ColumnFormat', TableFormat, ...
        'ColumnEditable', logical(TableEdit), 'ColumnWidth', TableWidth); 
    
function ParamValueOut=ConvertCell2Char(ParamValue)

% keyboard
ParamValueOut=[];
for i=1:length(ParamValue)
    ParamValueOut=[ParamValueOut; cellstr(num2str(ParamValue{i}))];
end

% --- Outputs from this function are returned to the command line.
function varargout = FeatureAddPreprocessPara_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if handles.OK > 0
    TableData=get(handles.UITablePara, 'Data');
    
    Param=[];
    
    if ~isequal(TableData, [{' '}, {' '}])
        ParaName=TableData(:, 1);
        ParaValue=TableData(:, 2);
        
        if ~isequal(handles.Mode, 'Manual')
            for i=1:length(ParaName)
                [Param.(ParaName{i}), flag] =str2num(ParaValue{i}); % Bettinelli workaround
                if ~flag || (nnz(isnan(size(Param.(ParaName{i})))) > 0) % if not a number, paste the string
                    Param.(ParaName{i})=ParaValue{i};
                end
            end
        else
            Param.ItemList=ParaValue;
        end
    end
else
    Param=handles.Param;
end

varargout{1} = Param;

delete(handles.figure1);

% --- Executes on button press in PushbuttonOK.
function PushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% keyboard
handles.OK=1;
guidata(handles.figure1, handles);

uiresume(handles.figure1);

% --- Executes on button press in PushbuttonCancel.
function PushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.OK=0;
guidata(handles.figure1, handles);

uiresume(handles.figure1);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
PushbuttonCancel_Callback(handles.PushbuttonCancel, eventdata, handles);

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
    hFig=findobj(0, 'Type', 'figure', 'Name', 'Specify Feature');
    if isempty(hFig)
        hFig=findobj(0, 'Type', 'figure', 'Name', 'Result');
    end
    
    handlesT=guidata(hFig);
    
    DataSetList(1, handlesT.PatsParentDir, handlesT.figure1, 'Simple');
end

% --- Executes when entered data in editable cell(s) in UITablePara.
function UITablePara_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to UITablePara (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(handles.TextVoxInfo, 'Visible'), 'On') || isequal(get(handles.TextVoxInfo, 'Visible'), 'on')
    UpdateTextVoxInfo(handles);
end

% --- Executes on button press in PushbuttonHelp.
function PushbuttonHelp_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isequal(handles.Mode, 'Feature')
    DisplayMethodHelp(handles.MethodFileName, 1);
else
    [CategoryName, FeatureName]=GetInfo(handles.PreprocessModule);
    DisplayMethodHelp(handles.MethodFileName, 1, FeatureName);
end

function [CategoryName, FeatureName]=GetInfo(PreprocessModule)
TempIndex=strfind(PreprocessModule, '/');

CategoryName=PreprocessModule(1:TempIndex(1)-1);
FeatureName=PreprocessModule(TempIndex(1)+1:end);
