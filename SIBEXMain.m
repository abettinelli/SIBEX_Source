function varargout = SIBEXMain(varargin)
% IBEXMAIN MATLAB code for IBEXMain.fig
%      IBEXMAIN, by itself, creates a new IBEXMAIN or raises the existing
%      singleton*.
%
%      H = IBEXMAIN returns the handle to a new IBEXMAIN or the handle to
%      the existing singleton*.
%
%      SIBEXMAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIBEXMAIN.M with the given input arguments.
%
%      SIBEXMAIN('Property','Value',...) creates a new SIBEXMAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SIBEXMain_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SIBEXMain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SIBEXMain

% Last Modified by GUIDE v2.5 19-Dec-2020 00:09:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IBEXMain_OpeningFcn, ...
                   'gui_OutputFcn',  @IBEXMain_OutputFcn, ...
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

% --- Executes just before IBEXMain is made visible.
function IBEXMain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IBEXMain (see VARARGIN)

%Compatibility
set(0, 'defaultuicontrolbackgroundcolor', [212/255,208/255,200/255]);
set(0, 'defaultUipanelBackgroundColor', [212/255,208/255,200/255]);

disp('Starting S-IBEX...');

[ProgramPath, FName, FileType]=fileparts(mfilename('fullpath'));

handles.ProgramPath=ProgramPath;

%Release Date
ReleaseDate=[2017 08 15 00 00 00];
set(handles.TextReleaseDate, 'String', ['Release Date: ', num2str(ReleaseDate(1)), '-', num2str(ReleaseDate(2)), '-', num2str(ReleaseDate(3))]);

%Code is too old 
ThresholdTime=6*30*24*60*60;
CurrentDate=datevec(now);

ElapseTime=abs(etime(CurrentDate, ReleaseDate));

% if ElapseTime > ThresholdTime
%     h=msgbox('IBEX is too old. Please contact Dr. Laurence Court(LECourt@mdanderson.org) to get the new version.', 'Error', 'error');
%     waitfor(h);
%     
%     exit;
% end


%Add path
addpath(handles.ProgramPath);
AddSubPath(handles);

%Read configuration
if ~isdeployed
    ConfigFile=fullfile(handles.ProgramPath, 'SIBEX.INI');
else
    CTFPath=ctfroot;
    TempIndex=strfind(CTFPath, filesep);
    CTFPath=CTFPath(1:TempIndex(end)-1);   
    
    ConfigFile=fullfile(CTFPath, 'SIBEX.INI');
end

%Sanity check on the configuration file
if exist(ConfigFile, 'file')
    ConfigInfo=GetConfigInfo(ConfigFile);
    
    if isfield(ConfigInfo, 'DataDir')
        if ~exist(ConfigInfo.DataDir, 'dir')
            %Create the default path
            CreateDefaultUserSite(ConfigInfo.DataDir);                    
            
            %Copy the example patient           
            try
                DeveloperStudioPath=fullfile(handles.ProgramPath, 'DeveloperStudio');
                
                mkdir(fullfile(ConfigInfo.DataDir, 'User1', 'Site1', '1FeatureDataSet_ImageROI'));
                mkdir(fullfile(ConfigInfo.DataDir, 'User1', 'Site1', '1FeatureModelSet_Algorithm'));
                mkdir(fullfile(ConfigInfo.DataDir, 'User1', 'Site1', '1FeatureResultSet_Result'));
                
                copyfile(fullfile(DeveloperStudioPath, 'ImportExample', '*.*'), fullfile(ConfigInfo.DataDir, 'User1', 'Site1'));
                copyfile(fullfile(DeveloperStudioPath, 'DataFeatureSetExample', 'DataSet', '*.*'), fullfile(ConfigInfo.DataDir, 'User1', 'Site1', '1FeatureDataSet_ImageROI'));
                copyfile(fullfile(DeveloperStudioPath, 'DataFeatureSetExample', 'FeatureSet', '*.*'), fullfile(ConfigInfo.DataDir, 'User1', 'Site1', '1FeatureModelSet_Algorithm'));
                copyfile(fullfile(DeveloperStudioPath, 'DataFeatureSetExample', 'Result', '*.*'), fullfile(ConfigInfo.DataDir, 'User1', 'Site1', '1FeatureResultSet_Result'));
            catch
                
            end
        else
            TempDir=GetDirList(ConfigInfo.DataDir);
            
            if isempty(TempDir)
                CreateDefaultUserSite(ConfigInfo.DataDir);   
            end            
        end
        
    else
        hMsg=MsgboxGuiIFOA('Data directory is not specified in the configuration file.', 'Error', 'error', 'modal');
        waitfor(hMsg);
        
        exit;
    end
    
    %Default UserType to be the regular user
    if ~isfield(ConfigInfo, 'UserType')
        ConfigInfo.UserType=0;
    end
    
    %Default UserType to be the regular user
    if ~isfield(ConfigInfo, 'PadROI')
        ConfigInfo.PadROI=10;
    end    
    
    %Pref file
    handles.PrefFile=fullfile(handles.ProgramPath, 'Config', 'IBEXLocation.INI');    
    if exist(handles.PrefFile, 'file')
        [handles.CurrentUser, handles.CurrentSite]=GetPrefLocation(handles.PrefFile);
    else
        handles.CurrentUser=[];
        handles.CurrentSite=[];
    end
    
else
    hMsg=msgbox('No configuration file is found!', 'Error', 'error', 'modal');
    waitfor(hMsg);
    
    exit;
end

%Set text on UI
SetPushbuttonIcon(handles);

%Display image
DisplayMainImage(handles);

%Turn on log
try
    TurnOnDiary(handles.ProgramPath);
catch
end

%Position
CenterFig(handles.figure1);

%Save Variables
handles.INIConfigInfo=ConfigInfo;

% Choose default command line output for IBEXMain
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


%write out FeatureList file: If deployed or .p, from FeatureList file. If matlab .m, refresh featurelist file

try
    if ~isdeployed
        CreateRunTimeFeature(handles.ProgramPath);
        CreateRunTimeDoc(handles.ProgramPath);
    end
    
    %Developer Studio
    if ConfigInfo.UserType > 0 && ~isdeployed
        set(handles.PushbuttonDevelop, 'Visible', 'On');
    else
        set(handles.PushbuttonDevelop, 'Visible', 'Off');
    end
    
    %First User
    Flag=UserSanityCheck;
    if Flag < 1
        exit;
    end
catch
    
end

%Set web link
figure(handles.figure1);

SetWebLink(handles, 0);
SetWebLink(handles, 1);
% SetWebLink(handles, 2); % request support

disp('S-IBEX is ready to use.');
% UIWAIT makes IBEXMain wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function TurnOnDiary(ProgramPath)
diary off;
DiaryFileName=get(0, 'DiaryFile');
if exist(DiaryFileName, 'file')
    delete(DiaryFileName);
end
diary on;

function TurnOffDiary(ProgramPath)
diary off;
DiaryFileName=get(0, 'DiaryFile');
if exist(DiaryFileName, 'file')
    delete(DiaryFileName);
end

function Flag=UserSanityCheck
Flag =1; 
UserPath=getenv('APPDATA');
TempIndex=strfind(UserPath, filesep);
UserPath=UserPath(1:TempIndex(3)-1);

%First Use?
if exist(fullfile(UserPath, 'LCLZV10'), 'file')
    FirstUseFile=fullfile(UserPath, 'LCLZV10');
else
    FirstUseFile=fullfile(UserPath, 'LCLZV10');
end

try
    if ~exist(FirstUseFile, 'file')
        %Write status     
        FID=fopen(FirstUseFile, 'w');
        fclose(FID);   
       
        SendMailForFeedback;
        %SendMailForNewUser;        
        %SendMailNet;
    end
catch    
end

function AddSubPath(handles)
addpath(fullfile(handles.ProgramPath, 'AutoSeg'));
addpath(fullfile(handles.ProgramPath, 'Config'));
addpath(fullfile(handles.ProgramPath, 'GUIHelper'));
addpath(fullfile(handles.ProgramPath, 'GUIHelperSpecifyData'));
addpath(fullfile(handles.ProgramPath, 'Helper'));
addpath(fullfile(handles.ProgramPath, 'ImportExport'));
addpath(fullfile(handles.ProgramPath, 'ImportExport', 'Helper'));
addpath(fullfile(handles.ProgramPath, 'ImportExport', 'ImportModule'));
addpath(fullfile(handles.ProgramPath, 'Pic'));
addpath(fullfile(handles.ProgramPath, 'Utils'));
addpath(fullfile(handles.ProgramPath, 'DeveloperStudio'));
addpath(fullfile(handles.ProgramPath, 'FeatureAlgorithm'));
addpath(fullfile(handles.ProgramPath, 'FeatureAlgorithm', 'Category'));
addpath(fullfile(handles.ProgramPath, 'FeatureAlgorithm', 'Preprocess'));
addpath(fullfile(handles.ProgramPath, 'FeatureAlgorithm', 'Preprocess', 'Helper'));

%Add Category Path
Category=GetFeatureCategoryFolder;
if ~isempty(Category)
    AddCategoryFilterPath(Category);
end

%Add Import/Export Path
AddImportFilterPath;
AddExportFilterPath;

function SetWebLink(handles, Mode)
switch Mode
    case 0
        LabelStr= '<html><left><a href="">S-IBEX is Intended for Research Use Only.';
        set(handles.PushbuttonWebLink2, 'string', LabelStr);
    case 1
        LabelStr= '<html><left><a href="">Medical Physics, 42, 1341-1353 (2015)';        
        set(handles.PushbuttonWebLink, 'string', LabelStr);
    case 2
        LabelStr= '<html><left><a href="">Report Bugs/Feedback';
        set(handles.PushbuttonFeedback, 'string', LabelStr);
end

switch Mode
    case 0
        JButton=findjobj(handles.PushbuttonWebLink2);
    case 1
        JButton=findjobj(handles.PushbuttonWebLink);
    case 2
        JButton=findjobj(handles.PushbuttonFeedback);
end
JButton.setCursor(java.awt.Cursor(java.awt.Cursor.HAND_CURSOR));
JButton.setContentAreaFilled(0); 
JButton.setBorder([]);
JButton.setBorderPainted(0);

function SetPushbuttonIcon(handles)
configureButton(handles.PushbuttonSite,[handles.ProgramPath '\Pic\MainLocation.png'],'Location')
configureButton(handles.PushbuttonImportPat,[handles.ProgramPath '\Pic\MainImport.png'],'Import')
configureButton(handles.PushbuttonSpecifyData,[handles.ProgramPath '\Pic\MainData.png'],'Data')
configureButton(handles.PushbuttonSpecifyModel,[handles.ProgramPath '\Pic\MainMethod.png'],'Feature')
configureButton(handles.PushbuttonGetView,[handles.ProgramPath '\Pic\MainResult.png'],'Result')
configureButton(handles.pushbutton13,[handles.ProgramPath '\Pic\MainShowDataSet.png'],'Show DataSet')
configureButton(handles.PushbuttonDevelop,[handles.ProgramPath '\Pic\MainDevelop.png'],'Develop')

function CreateDefaultUserSite(DataDir)
try
    if ~exist(DataDir, 'dir')
        mkdir(DataDir);
    end
    
    mkdir(fullfile(DataDir, 'User1'));
    mkdir(fullfile(DataDir, 'User1', 'Site1'));
catch
    hMsg=msgbox('The data directory can''t be created.', 'Error', 'error', 'modal');
    waitfor(hMsg);
    
    exit;
end

function [PrefUser, PrefSite]=GetPrefLocation(PrefFile)

FID=fopen(PrefFile, 'r');
TempContent=textscan(FID, '%s', 'delimiter', '\n');
fclose(FID);

cellFileInfo=TempContent{1};
clear('TempContent');

for i=1:length(cellFileInfo)
    eval(cellFileInfo{i});
end

if exist('User', 'var')
    PrefUser=User;
else
    PrefUser='';
end

if exist('Site', 'var')
    PrefSite=Site;
else
    PrefSite='';
end

function ConfigInfo=GetConfigInfo(ConfigFile)
ConfigInfo=[];

FID=fopen(ConfigFile, 'r');
TempContent=textscan(FID, '%s', 'delimiter', '\n');
fclose(FID);

cellFileInfo=TempContent{1};
clear('TempContent');

for i=1:length(cellFileInfo)
    eval(cellFileInfo{i});
end

if exist('DataDir', 'var')
    ConfigInfo.DataDir=DataDir;
end

if exist('UserType', 'var')
    ConfigInfo.UserType=UserType;
end

if exist('ROICurrentImageOnly', 'var')
    ConfigInfo.ROICurrentImageOnly=ROICurrentImageOnly;
end

if exist('ThresholdNonUniformSP', 'var')
   ConfigInfo.ThresholdNonUniformSP=ThresholdNonUniformSP;
else
    ConfigInfo.ThresholdNonUniformSP=0.05;
end

if exist('PadROI', 'var')
   ConfigInfo.PadROI=PadROI;
else
    ConfigInfo.PadROI=10;
end

function DisplayMainImage(handles)
set(handles.figure1, 'CurrentAxes', handles.axes3);

plot([30 420; 30 420; 30 420; 30 420; 30 420]', [119 119; 199 199; 279 279; 359 359; 439 439]','color', [0 0.4470 0.7410])
xlim([0 650])
ylim([0 569])
set(gca,'XTick', [], 'YTick', []);
set(gca,'Visible','off')

set(handles.figure1, 'CurrentAxes', handles.AxesImage);
% imshow(PrefaceImage);
load('Pic\FV.mat')
plot3(V(:,1),V(:,2),V(:,3),'.','Markersize',16,'color', [0 0.4470 0.7410])
hold on

for i = 1:size(F,1)
    idx = F(i,:);
    idx = idx(:,[1 2 3]);
    plot3(V(idx,1),V(idx,2),V(idx,3),'--','color', [0.5 0.5 0.5])
end
axis equal
rotate3d(gca,'on')
set(gca,'XTick', [], 'YTick', []);
set(gca,'Visible','off')
view(-25,20)

hManager = uigetmodemanager(gcf);
hManager.CurrentMode.ModeStateData.textState = 0;

% --- Outputs from this function are returned to the command line.
function varargout = IBEXMain_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in PushbuttonSite.
function PushbuttonSite_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonSite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set(hObject,'enable','on','BackgroundColor',[204 232 255]/255);
IBEXLocation(1, handles);

% --- Executes on button press in PushbuttonImportPat.
function PushbuttonImportPat_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonImportPat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set(hObject,'enable','on','BackgroundColor',[204 232 255]/255);
IBEXImport(1, handles);

% --- Executes on button press in PushbuttonSpecifyData.
function PushbuttonSpecifyData_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonSpecifyData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set(hObject,'enable','on','BackgroundColor',[204 232 255]/255);
IBEXData(1, handles);

% --- Executes on button press in PushbuttonSpecifyModel.
function PushbuttonSpecifyModel_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonSpecifyModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set(hObject,'enable','on','BackgroundColor',[204 232 255]/255);
IBEXFeature(1, handles);

function RemoveModulePath(ProgramPath, ModeStr)
switch ModeStr
    case 'Import'
        DataDir=fullfile(ProgramPath, 'ImportExport', 'ImportModule');
    case 'Export'
        DataDir=fullfile(ProgramPath, 'ImportExport', 'ExportModule');
    case  'FeatureCategory'
        DataDir=fullfile(ProgramPath, 'FeatureAlgorithm', 'Category');
end

DirList=GetDirList(DataDir);

if ~isempty(DirList)
    for i=1:length(DirList)
        rmpath(fullfile(DataDir, DirList{i}));
        
        HelperPath=fullfile(DataDir, DirList{i}, 'Helper');
        if exist(HelperPath, 'dir')
            rmpath(HelperPath);
        end
    end
end

if isdeployed
    exit;
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
try
    TurnOffDiary(handles.ProgramPath);
catch
end

warning('off','MATLAB:rmpath:DirNotFound')
RemoveModulePath(handles.ProgramPath, 'Import');
RemoveModulePath(handles.ProgramPath, 'Export');
RemoveModulePath(handles.ProgramPath, 'FeatureCategory');

rmpath(handles.ProgramPath);
rmpath(fullfile(handles.ProgramPath, 'AutoSeg'));
rmpath(fullfile(handles.ProgramPath, 'Config'));
rmpath(fullfile(handles.ProgramPath, 'GUIHelper'));
rmpath(fullfile(handles.ProgramPath, 'GUIHelperSpecifyData'));
rmpath(fullfile(handles.ProgramPath, 'Helper'));
rmpath(fullfile(handles.ProgramPath, 'ImportExport'));
rmpath(fullfile(handles.ProgramPath, 'ImportExport', 'Helper'));
rmpath(fullfile(handles.ProgramPath, 'ImportExport', 'ImportModule'));
rmpath(fullfile(handles.ProgramPath, 'Pic'));
rmpath(fullfile(handles.ProgramPath, 'Utils'));
rmpath(fullfile(handles.ProgramPath, 'DeveloperStudio'));
rmpath(fullfile(handles.ProgramPath, 'FeatureAlgorithm'));
rmpath(fullfile(handles.ProgramPath, 'FeatureAlgorithm', 'Category'));
rmpath(fullfile(handles.ProgramPath, 'FeatureAlgorithm', 'Preprocess'));
rmpath(fullfile(handles.ProgramPath, 'FeatureAlgorithm', 'Preprocess', 'Helper'));
warning('on','MATLAB:rmpath:DirNotFound')

delete(handles.figure1);

% --- Executes on button press in PushbuttonGetView.
function PushbuttonGetView_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonGetView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set(hObject,'enable','on','BackgroundColor',[204 232 255]/255);
IBEXResult(1, handles);

% --- Executes on button press in PushbuttonDevelop.
function PushbuttonDevelop_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonDevelop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set(hObject,'enable','on','BackgroundColor',[204 232 255]/255);
IBEXDevelop(1, handles);

% --- Executes on button press in PushbuttonWebLink.
function PushbuttonWebLink_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonWebLink (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

web('http://dx.doi.org/10.1118/1.4908210');

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text10.
function text10_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over PushbuttonWebLink.
function PushbuttonWebLink_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to PushbuttonWebLink (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in PushbuttonWebLink2.
function PushbuttonWebLink2_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonWebLink2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
LicenseFile=fullfile(handles.ProgramPath, 'License.txt');
winopen(LicenseFile);

% --- Executes on button press in PushbuttonFeedback.
function PushbuttonFeedback_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonFeedback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

HFig=findobj(0, 'Type', 'figure');
set(HFig, 'Pointer', 'watch');
drawnow;

IBEXFeedback(1, handles.figure1);

HFig=findobj(0, 'Type', 'figure');
set(HFig, 'Pointer', 'arrow');
drawnow;

% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% function PushbuttonShowDataSet_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonShowDataSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set(hObject,'enable','on','BackgroundColor',[204 232 255]/255);

PatsParentDir = fullfile(handles.INIConfigInfo.DataDir, handles.CurrentUser, handles.CurrentSite);

%Show Data Set
hFig=findobj(0, 'Type', 'figure', 'Name', 'Current Data Set');
if ~isempty(hFig)    
    figure(hFig);
    return;
else
    DataSetList(1, PatsParentDir, handles.figure1);
end

function configureButton(p, CIcon_p, txt)

pxPos = getpixelposition(p);
% str = ['<html><div width="' num2str(pxPos(3)+50) 'px"; height="50px" align="left">&nbsp;&nbsp;<img src = "file:/', CIcon_p, '" style="vertical-align: middle;">&nbsp;&nbsp;' txt ''];
str = ['<html><div width="200px"; height="0px" align="left">&nbsp;&nbsp;<img align="middle" src="file:/', CIcon_p, '">&nbsp;&nbsp;' txt ];
set(p,'String', str, 'FontSize', 20);


% --- Executes on button press in PushbuttonShowFeatureSet.
function pushbuttonShowFeatureSet_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonShowFeatureSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Show Data Set

PatsParentDir = fullfile(handles.INIConfigInfo.DataDir, handles.CurrentUser, handles.CurrentSite);

hFig=findobj(0, 'Type', 'figure', 'Name', 'Current Feature Set');
if ~isempty(hFig)    
    figure(hFig);
    return;
else
    FeatureSetList(1, PatsParentDir, handles.figure1);
end
