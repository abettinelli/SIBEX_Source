function varargout = PlanPatV9IFOA(varargin)
% PLANPATV9IFOA M-file for PlanPatV9IFOA.fig
%      PLANPATV9IFOA, by itself, creates a new PLANPATV9IFOA or raises the existing
%      singleton*.
%
%      H = PLANPATV9IFOA returns the handle to a new PLANPATV9IFOA or the handle to
%      the existing singleton*.
%
%      PLANPATV9IFOA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLANPATV9IFOA.M with the given input arguments.
%
%      PLANPATV9IFOA('Property','Value',...) creates a new PLANPATV9IFOA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlanPatV9_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlanPatV9IFOA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PlanPatV9IFOA

% Last Modified by GUIDE v2.5 30-Oct-2013 13:45:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlanPatV9IFOA_OpeningFcn, ...
                   'gui_OutputFcn',  @PlanPatV9IFOA_OutputFcn, ...
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


% --- Executes just before PlanPatV9IFOA is made visible.
function PlanPatV9IFOA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlanPatV9IFOA (see VARARGIN)

PHandle=varargin{2};

handles.ProgramPath=PHandle.ProgramPath;
handles.QueryData=PHandle.QueryData;
handles.HostName=varargin{3};
handles.DBName=varargin{4};

handles.FTPUser=varargin{5};
handles.FTPPassword=varargin{6};

handles.ParentGcf=PHandle.ParentHandles.figure1;


handles.PatDataPath=[PHandle.ParentHandles.INIConfigInfo.DataDir, '\', PHandle.ParentHandles.CurrentUser, '\', PHandle.ParentHandles.CurrentSite];
handles.Anonymize=PHandle.ParentHandles.Anonymize;


%---Change Posistion
SetPositionBottom(PHandle.figure1, handles.figure1);

%Set TextHead
set(handles.TextHead, 'String', [handles.HostName, ' Data, ', handles.DBName, ' Database.']);


if ~isempty(handles.QueryData)
    
    %Get Patient List
    PatsList=[];
    for i=1:length(handles.QueryData.LastName)       
        
        PatsList=[PatsList; {[sprintf('%-18.18s', handles.QueryData.LastName{i}), sprintf('%-13.13s',  handles.QueryData.FirstName{i}), sprintf('%-15.15s',  handles.QueryData.MiddleName{i}),...
                    sprintf('%-13.13s',  handles.QueryData.MRN{i}), sprintf('%-13.13s', handles.QueryData.RadiationOncologist{i}), ...
                    sprintf('%-28.28s',  [handles.QueryData.InstitutionID{i}, ', ', handles.QueryData.Institution{i}])]}];
    end    
           
    set(handles.ListboxPat, 'String', PatsList, 'ListboxTop', 1, 'Value', 1);
    
    set(handles.PushbuttonTrans, 'Enable', 'on');    
    
else
    set(handles.ListboxPat, 'String', '', 'ListboxTop', 1, 'Value', 1);
    set(handles.PushbuttonTrans, 'Enable', 'off');
end

%Change Icon
figure(handles.figure1);
drawnow;

% Choose default command line output for PlanPat
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% Choose default command line output for PlanPatV9IFOA
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PlanPatV9IFOA wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function SetPositionBottom(PHandleF, CHandleF)
OldUnit=get(PHandleF, 'Units');
set(PHandleF, 'Units', 'Pixels');

PrefacePos=get(PHandleF, 'Position');
set(PHandleF, 'Units', OldUnit);


OldUnit=get(CHandleF, 'Units');
set(CHandleF, 'Units', 'pixels');
FigPos=get(CHandleF,'Position');

set(CHandleF,'Position', [PrefacePos(1)-FigPos(3)-5, PrefacePos(2), FigPos(3), FigPos(4)]);
set(CHandleF, 'Units', OldUnit);

% --- Outputs from this function are returned to the command line.
function varargout = PlanPatV9IFOA_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in PushbuttonTrans.
function PushbuttonTrans_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonTrans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Update handles
handles=guidata(handles.figure1);

TempStr=datestr(now, 30);

PlanDestPath=[handles.PatDataPath,'\Pat' TempStr,];
mkdir(PlanDestPath);

handles.PlanDestPath=PlanDestPath;

%Source Path
TempV=get(handles.ListboxPat, 'Value');
SourcePath=[handles.QueryData.RelativePath, '/' , handles.QueryData.PatPath{TempV}];


set(handles.figure1, 'Visible', 'off');

%Status----
hStatus=StatusProgressTextCenterIFOA('Transferring', ['Transferring data from ', handles.HostName, '...'], handles.ParentGcf);
drawnow;

hText=findobj(hStatus, 'Style', 'Text');

Flag=FTPPlanDataIFOA(handles.HostName, deblank(SourcePath), PlanDestPath, hText, ...
    handles.ParentGcf, handles.FTPUser, handles.FTPPassword, handles.Anonymize);

set(handles.figure1, 'Visible', 'on');

%Change Icon
figure(handles.figure1);
drawnow;

%Status----
hFig=findobj(0, 'Type', 'figure');
for iii=1:length(hFig)
    if isequal(get(hFig(iii), 'UserData'), 'StatusFig')
        delete(hFig(iii));
    end
end

%Deal with the exception
if Flag ~= 0
    
    if Flag ~= 7
        switch Flag
            case 1
                TempStr22='Error occurs with Ftp connection.';
            case 2
                TempStr22='Error occurs with no patient directory.';
            case 3
                TempStr22='Error occurs with no Patient file.';
            case 4
                TempStr22='Error occurs with no existing image data.';
            case 5
                TempStr22='Error occurs with imcomplete image data info.';
            case 6
                TempStr22='Error occurs with no image header files.';
            case 8
                TempStr22='No image sets are selected.';
        end
        MsgboxGuiIFOA(TempStr22, 'Error', 'error', 'modal', handles.ProgramPath);
    end
    
    rmdir(handles.PlanDestPath, 's');   
else
    MsgboxGuiIFOA('Data is successfully imported.', 'Confirm', 'help', 'modal', handles.ProgramPath);    
end      

% --- Executes on button press in PushbuttonExit.
function PushbuttonExit_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in ListboxPat.
function ListboxPat_Callback(hObject, eventdata, handles)
% hObject    handle to ListboxPat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ListboxPat contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListboxPat


% --- Executes during object creation, after setting all properties.
function ListboxPat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListboxPat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
