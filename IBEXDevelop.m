function varargout = IBEXDevelop(varargin)
% IBEXDEVELOP MATLAB code for IBEXDevelop.fig
%      IBEXDEVELOP, by itself, creates a new IBEXDEVELOP or raises the existing
%      singleton*.
%
%      H = IBEXDEVELOP returns the handle to a new IBEXDEVELOP or the handle to
%      the existing singleton*.
%
%      IBEXDEVELOP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IBEXDEVELOP.M with the given input arguments.
%
%      IBEXDEVELOP('Property','Value',...) creates a new IBEXDEVELOP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IBEXDevelop_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IBEXDevelop_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IBEXDevelop

% Last Modified by GUIDE v2.5 07-Oct-2014 11:52:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IBEXDevelop_OpeningFcn, ...
                   'gui_OutputFcn',  @IBEXDevelop_OutputFcn, ...
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


% --- Executes just before IBEXDevelop is made visible.
function IBEXDevelop_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IBEXDevelop (see VARARGIN)

Phandles=varargin{2};
handles.Phandles=Phandles;

InitializeButton(handles);

CenterFigBottomCenter(handles.figure1, Phandles.figure1);

[MFilePath, MFileName]=fileparts(mfilename('fullpath'));
handles.ProgramPath=MFilePath;

% Choose default command line output for IBEXDevelop\
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes IBEXDevelop wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function InitializeButton(handles)      
set(handles.PushbuttonImportPlugIn, 'String', 'New Import PlugIn');
      
set(handles.PushbuttonPreprocessPlugIn, 'String', 'New Preprocess PlugIn');
     
set(handles.PushbuttonFeaturePlugIn, 'String', 'New Feature PlugIn');
   
set(handles.PushbuttonStandAlonePlugIn, 'String', 'New Stand-Alone PlugIn');


% --- Outputs from this function are returned to the command line.
function varargout = IBEXDevelop_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in PushbuttonImportPlugIn.
function PushbuttonImportPlugIn_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonImportPlugIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get PlugIn Name
DataDir=[handles.ProgramPath, '\ImportExport\ImportModule'];
CurrentPlugIn=GetImportModuleList(DataDir);

PlugInName=NewPlugIn(1, 'PlugIn--  Import', handles.figure1, CurrentPlugIn, 'New', 'Create');

%Create the template files
if ~isempty(PlugInName)
    PlugInFolder=[handles.ProgramPath, '\ImportExport\ImportModule\', PlugInName];
    if ~exist(PlugInFolder, 'dir')
        mkdir(PlugInFolder);
    end
    
    copyfile([handles.ProgramPath, '\DeveloperStudio\TemplateImportModule_ImportMain.m'], ...
        [PlugInFolder, '\', PlugInName, 'ImportMain.m']);
    
    copyfile([handles.ProgramPath, '\DeveloperStudio\TemplateImportModule_ImportMain.INI'], ...
        [PlugInFolder, '\', PlugInName, 'ImportMain.INI']);
    
    UpdateFileContentKeyword([PlugInFolder, '\', PlugInName, 'ImportMain.m'], 'TemplateImportModule_', PlugInName);
    
    MsgboxGuiIFOA(['DONE:       ', PlugInName, ' import PlugIn skeleton is created.', sprintf('\n'), ...
    'Skeleton Import PlugIn copys the example patient to the local database.', ...    
    sprintf('\n'), sprintf('\n'), 'TO TEST:  Go to Import->', PlugInName, '->Next.', ...        
        sprintf('\n'), sprintf('\n'), 'TO EDIT:  Modify ', PlugInName, 'ImportMain.m and ', PlugInName 'ImportMain.INI.'], 'Prompt', 'help');
    
    edit([PlugInFolder, '\', PlugInName, 'ImportMain.INI']);
    edit([PlugInFolder, '\', PlugInName, 'ImportMain.m']);
        
    figure1_CloseRequestFcn(hObject, eventdata, handles);
end


% --- Executes on button press in PushbuttonPreprocessPlugIn.
function PushbuttonPreprocessPlugIn_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonPreprocessPlugIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Get PlugIn Name
DataDir=[handles.ProgramPath, '\FeatureAlgorithm\Preprocess'];
CurrentPlugIn=GetPreprocessMethod(DataDir);

PlugInName=NewPlugIn(1, 'PlugIn--  Preprocess', handles.figure1, CurrentPlugIn, 'New', 'Create');

%Create the template files
if ~isempty(PlugInName)    
    PlugInFolder=DataDir;
    
    copyfile([handles.ProgramPath, '\DeveloperStudio\TemplatePreprocess.m'], ...
        [PlugInFolder, '\', PlugInName, '.m']);
    
    copyfile([handles.ProgramPath, '\DeveloperStudio\TemplatePreprocess.INI'], ...
        [PlugInFolder, '\', PlugInName, '.INI']);
    
    UpdateFileContentKeyword([PlugInFolder, '\', PlugInName, '.m'], 'TemplatePreprocess', PlugInName);
    
    MsgboxGuiIFOA(['DONE:       ', PlugInName, ' preprocess PlugIn skeleton is created.', sprintf('\n'), ...
        'Skeleton Preprocess PlugIn smoothes the image and erodes binary mask.', ...
        sprintf('\n'), sprintf('\n'), 'TO TEST:  Go to Feature->Preprocess-> Add ', PlugInName, '->Test.', ...        
        sprintf('\n'), sprintf('\n'), 'TO EDIT:  Modify ', PlugInName, '.m and ', PlugInName '.INI.'], 'Prompt', 'help');
    
    edit([PlugInFolder, '\', PlugInName, '.INI']);
    edit([PlugInFolder, '\', PlugInName, '.m']);    
    
    figure1_CloseRequestFcn(hObject, eventdata, handles);
end


% --- Executes on button press in PushbuttonFeaturePlugIn.
function PushbuttonFeaturePlugIn_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonFeaturePlugIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Get PlugIn Name

CurrentPlugIn=GetFeatureCategoryFolder;
[PlugInName, FeatureName]=NewPlugInFeature(1, handles.figure1, CurrentPlugIn);

%Create the template files
if ~isempty(PlugInName)    
    
    PlugInFolder=[handles.ProgramPath, '\FeatureAlgorithm\Category\', PlugInName];
    
    if ~exist(PlugInFolder, 'dir')
        mkdir(PlugInFolder);
    end
    
    copyfile([handles.ProgramPath, '\DeveloperStudio\Template_Category.m'], ...
        [PlugInFolder, '\', PlugInName,  '_Category.m']);
    
    copyfile([handles.ProgramPath, '\DeveloperStudio\Template_Category.INI'], ...
        [PlugInFolder, '\', PlugInName, '_Category.INI']);
    
    copyfile([handles.ProgramPath, '\DeveloperStudio\Template_Feature.m'], ...
        [PlugInFolder, '\', PlugInName, '_Feature.m']);
    
    GenerateFeatureINI([handles.ProgramPath, '\DeveloperStudio\Template_Feature.INI'], [PlugInFolder, '\', PlugInName, '_Feature'], FeatureName);
        
    UpdateFileContentKeyword([PlugInFolder, '\', PlugInName,  '_Category.m'], 'Template', PlugInName);
    UpdateFileContentKeyword([PlugInFolder, '\', PlugInName,  '_Feature.m'], 'Template', PlugInName);
    
    UpdateFileFeatureName([PlugInFolder, '\', PlugInName,  '_Feature.m'], FeatureName);
    
    MsgboxGuiIFOA(['DONE:       ', PlugInName, ' feature PlugIn skeleton is created.',  sprintf('\n'), ...
        'Skeleton features return the ROI Intensity Max.', ...
        sprintf('\n'), sprintf('\n'), 'TO TEST:  Go to Feature->Category-> ', PlugInName, '->Feature->*Name*->Test.', ...        
        sprintf('\n'), sprintf('\n'), 'TO EDIT:  Modify ', PlugInName, '_Category.m/.INI and ', PlugInName, '_Feature.m/.INI.'], 'Prompt', 'help');
    
    
    edit([PlugInFolder, '\', PlugInName, '_Category.INI']);
    for i=1:length(FeatureName)
        edit([PlugInFolder, '\', PlugInName, '_Feature_', FeatureName{i}, '.INI']);
    end
    
    edit([PlugInFolder, '\', PlugInName, '_Category.m']);    
    edit([PlugInFolder, '\', PlugInName, '_Feature.m']);
        
    figure1_CloseRequestFcn(hObject, eventdata, handles);
end

function GenerateFeatureINI(TemplateFile, FilePrefix, FeatureName)
for i=1:length(FeatureName)
     copyfile(TemplateFile,  [FilePrefix, '_', FeatureName{i}, '.INI']);
end


% --- Executes on button press in PushbuttonStandAlonePlugIn.
function PushbuttonStandAlonePlugIn_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonStandAlonePlugIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(handles.figure1);
