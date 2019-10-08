function varargout = Pinnacle9ImportMain(varargin)
% PINNACLE9IMPORTMAIN MATLAB code for Pinnacle9ImportMain.fig
%      PINNACLE9IMPORTMAIN, by itself, creates a new PINNACLE9IMPORTMAIN or raises the existing
%      singleton*.
%
%      H = PINNACLE9IMPORTMAIN returns the handle to a new PINNACLE9IMPORTMAIN or the handle to
%      the existing singleton*.
%
%      PINNACLE9IMPORTMAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PINNACLE9IMPORTMAIN.M with the given input arguments.
%
%      PINNACLE9IMPORTMAIN('Property','Value',...) creates a new PINNACLE9IMPORTMAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Pinnacle9ImportMain_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Pinnacle9ImportMain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Pinnacle9ImportMain

% Last Modified by GUIDE v2.5 21-Mar-2014 09:56:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Pinnacle9ImportMain_OpeningFcn, ...
                   'gui_OutputFcn',  @Pinnacle9ImportMain_OutputFcn, ...
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


% --- Executes just before Pinnacle9ImportMain is made visible.
function Pinnacle9ImportMain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Pinnacle9ImportMain (see VARARGIN)


ParentHandles=varargin{1};

handles.ParentHandles=ParentHandles;
handles.ProgramPath=handles.ParentHandles.ProgramPath;

[CProgramPath, CFileName]=fileparts(mfilename('fullpath'));

ConfigFile=[CProgramPath, '\', CFileName, '.INI'];
if exist(ConfigFile, 'file')
    [PinnV9Config, ErrorStr]=ValidateConfigFilePinnV9(ConfigFile);
else
    PinnV9Config=[];
    ErrorStr='Configuration file doesn''t exist!';
end

if isempty(PinnV9Config)   
    MsgboxGuiIFOA(ErrorStr, 'Error', 'warn');
    
    guidata(handles.figure1, handles);
    PushbuttonCancel_Callback(handles.PushbuttonCancel, eventdata, handles);
    return;
end

handles.PinnV9Config=PinnV9Config;

%Set UIControls
set(handles.EditPatFirst, 'String', '');
set(handles.EditPatLast, 'String', '');
set(handles.EditPatMRN, 'String', '');

set(handles.PopupmenuTypeV9, 'String', handles.PinnV9Config.Pinn9DBHostDisplay, 'Value', 1);
set(handles.PopupmenuDBV9, 'String', [{' '}; handles.PinnV9Config.Pinn9DBNameDisplay], 'Value', 1);

EditPatMRN_Callback(handles.EditPatMRN, eventdata, handles);

%Set Position
SetPositionRight(ParentHandles.figure1, handles.figure1);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PlanDatabasePinnIFOA wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function [ConfigInfo, ErrorStr]=ValidateConfigFilePinnV9(ConfigFile)
ConfigInfo=[];
ErrorStr=[];

FID=fopen(ConfigFile, 'r');
TempContent=textscan(FID, '%s', 'delimiter', '\n');
fclose(FID);

cellFileInfo=TempContent{1};
clear('TempContent');

%DB account
TempIndex=strmatch('DBUser', cellFileInfo);
if isempty(TempIndex)
    ConfigInfo=[];
    ErrorStr='No DBUser specified.';
    
    return;
else
    eval(cellFileInfo{TempIndex(1)});
    ConfigInfo.DBUser=DBUser;
end

TempIndex=strmatch('DBPassword', cellFileInfo);
if isempty(TempIndex)
    ConfigInfo=[];
    ErrorStr='No DBPassword specified.';
    
    return;
else
    eval(cellFileInfo{TempIndex(1)});
    ConfigInfo.DBPassword=DBPassword;
end

%FTP account
TempIndex=strmatch('FTPUser', cellFileInfo);
if isempty(TempIndex)
    ConfigInfo=[];
    ErrorStr='No FTPUser specified.';
    
    return;
else
    eval(cellFileInfo{TempIndex(1)});
    ConfigInfo.FTPUser=FTPUser;
end

TempIndex=strmatch('FTPPassword', cellFileInfo);
if isempty(TempIndex)
    ConfigInfo=[];
    ErrorStr='No FTPPassword specified.';
    
    return;
else
    eval(cellFileInfo{TempIndex(1)});
    ConfigInfo.FTPPassword=FTPPassword;
end


%DB Host, DB Mounting Point
TempIndex=strmatch('Pinn9DBHostDBName', cellFileInfo);
if isempty(TempIndex)
    ConfigInfo=[];
    ErrorStr='No Pinn9DBHostDBName specified.';
    
    return;
else
    Pinn9DBName=[];
    Pinn9DBHost=[];
    
    for i=1:length(TempIndex)
        clear('Pinn9DBHostDBName');
        
        eval(cellFileInfo{TempIndex(i)});
        
        if exist('Pinn9DBHostDBName', 'var')
            Pinn9DBHost=[Pinn9DBHost; Pinn9DBHostDBName(1)];
            if length(Pinn9DBHostDBName) >= 2
                Pinn9DBName(length(Pinn9DBHost)).Name=Pinn9DBHostDBName(2:length(Pinn9DBHostDBName));
            else
                Pinn9DBName(length(Pinn9DBHost)).Name='NA';
            end
        end
    end
    
    Pinn9DBHostDisplay=GetHostDisplayStr(Pinn9DBHost);    
    Pinn9DBNameDisplay=GetDBNameDisplayStr(Pinn9DBName(1).Name);    
    
    ConfigInfo.Pinn9DBName=Pinn9DBName;
    ConfigInfo.Pinn9DBHost=Pinn9DBHost;
    
    ConfigInfo.Pinn9DBHostDisplay=Pinn9DBHostDisplay;
    ConfigInfo.Pinn9DBNameDisplay=Pinn9DBNameDisplay;
end



% --- Outputs from this function are returned to the command line.
function varargout = Pinnacle9ImportMain_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

if isfield(handles, 'PinnV9Config')
    varargout{1} = 1;
else
    varargout{1} = 0;
end


% --- Executes on selection change in PopupmenuTypeV9.
function PopupmenuTypeV9_Callback(hObject, eventdata, handles)
% hObject    handle to PopupmenuTypeV9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopupmenuTypeV9 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopupmenuTypeV9
HostID=get(handles.PopupmenuTypeV9, 'Value');

Pinn9DBNameDisplay=GetDBNameDisplayStr(handles.PinnV9Config.Pinn9DBName(HostID).Name);
set(handles.PopupmenuDBV9, 'String', [{' '}; Pinn9DBNameDisplay], 'Value', 1);

EditPatMRN_Callback(handles.EditPatMRN, eventdata, handles);   


% --- Executes during object creation, after setting all properties.
function PopupmenuTypeV9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopupmenuTypeV9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PopupmenuDBV9.
function PopupmenuDBV9_Callback(hObject, eventdata, handles)
% hObject    handle to PopupmenuDBV9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopupmenuDBV9 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopupmenuDBV9

EditPatMRN_Callback(handles.EditPatMRN, eventdata, handles);   


% --- Executes during object creation, after setting all properties.
function PopupmenuDBV9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopupmenuDBV9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditPatMRN_Callback(hObject, eventdata, handles)
% hObject    handle to EditPatMRN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditPatMRN as text
%        str2double(get(hObject,'String')) returns contents of EditPatMRN as a double
DBValue=get(handles.PopupmenuDBV9, 'Value');

if (DBValue > 1) && ...
    (~isempty(get(handles.EditPatMRN, 'String')) || ~isempty(get(handles.EditPatLast, 'String')) || ~isempty(get(handles.EditPatFirst, 'String')))
    set(handles.PushbuttonQuery, 'Enable', 'on');
else
    set(handles.PushbuttonQuery, 'Enable', 'off');
end


% --- Executes during object creation, after setting all properties.
function EditPatMRN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditPatMRN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditPatLast_Callback(hObject, eventdata, handles)
% hObject    handle to EditPatLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditPatLast as text
%        str2double(get(hObject,'String')) returns contents of EditPatLast as a double

EditPatMRN_Callback(handles.EditPatMRN, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function EditPatLast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditPatLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditPatFirst_Callback(hObject, eventdata, handles)
% hObject    handle to EditPatFirst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditPatFirst as text
%        str2double(get(hObject,'String')) returns contents of EditPatFirst as a double

EditPatMRN_Callback(handles.EditPatMRN, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function EditPatFirst_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditPatFirst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushbuttonCancel.
function PushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.figure1);


% --- Executes on button press in PushbuttonQuery.
function PushbuttonQuery_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonQuery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

HostList=get(handles.PopupmenuTypeV9, 'String');
HostID=get(handles.PopupmenuTypeV9, 'Value');

Host=GetHostName(handles.PinnV9Config.Pinn9DBHost{HostID});

DBList=get(handles.PopupmenuDBV9, 'String');
DBID=get(handles.PopupmenuDBV9, 'Value');
DBNameQuery=DBList{DBID};

Pinn9DBName=handles.PinnV9Config.Pinn9DBName(HostID).Name;
DBName=GetDBName(Pinn9DBName{DBID-1});

DBV9User=handles.PinnV9Config.DBUser;
DBV9PW=handles.PinnV9Config.DBPassword;

V9PatMRN=get(handles.EditPatMRN, 'String');
V9PatLast=get(handles.EditPatLast, 'String');
V9PatFirst=get(handles.EditPatFirst, 'String');

%Parameter
ConnInfoStr=['host=', Host, ' dbname=', DBNameQuery, ' user=', DBV9User, ' password=', DBV9PW];

SQLStr=['DECLARE myportal CURSOR FOR SELECT lastname, firstname, middlename, medicalrecordnumber, radiationoncologist, patient.institutionid, name, patientpath FROM patient, institution where ', ...
    'patient.institutionid = institution.institutionid AND '];
    
FlagCondition=0;

if ~isempty(V9PatMRN)    
    V9PatMRN=regexprep(V9PatMRN, '*', '%');
    V9PatMRN=regexprep(V9PatMRN, '?', '_');     
    
    if FlagCondition > 0
        SQLStr=[SQLStr, ' OR medicalrecordnumber ILIKE ''',V9PatMRN, ''''];
    else
        SQLStr=[SQLStr, ' medicalrecordnumber ILIKE ''',V9PatMRN, ''''];
    end
    
    FlagCondition=1;
end

if ~isempty(V9PatLast)  
    V9PatLast=regexprep(V9PatLast, '*', '%');
    V9PatLast=regexprep(V9PatLast, '?', '_');    
    
    if FlagCondition > 0
        SQLStr=[SQLStr, ' OR lastname ILIKE ''',V9PatLast, ''''];
    else
        SQLStr=[SQLStr, ' lastname ILIKE ''',V9PatLast, ''''];
    end
    
     FlagCondition=1;
end

if ~isempty(V9PatFirst)
    V9PatFirst=regexprep(V9PatFirst, '*', '%');
    V9PatFirst=regexprep(V9PatFirst, '?', '_');    
    
    if FlagCondition > 0
        SQLStr=[SQLStr, ' OR firstname ILIKE ''',V9PatFirst, ''''];
    else
        SQLStr=[SQLStr, ' firstname ILIKE ''',V9PatFirst, ''''];
    end
    
     FlagCondition=1;
end

SQLStr=[SQLStr, ' ORDER BY lastname LIMIT 100'];

%Write to file
StatusFile=[handles.ProgramPath, '\Utils\PostGresStatus.txt'];
if exist(StatusFile, 'file')
    delete(StatusFile);
end

SQLParasFile=[handles.ProgramPath, '\Utils\PostGresQuery.txt'];

FID=fopen(SQLParasFile, 'w');
fprintf(FID, '%s\n', ConnInfoStr);
fprintf(FID, '%s\n', SQLStr);
fprintf(FID, '%s\n', StatusFile);
fclose(FID);

%Execute
SQLBatch=[handles.ProgramPath, '\Utils\PostGresQuery.bat'];
FID=fopen(SQLBatch, 'w');
fprintf(FID, '%s\n', [handles.ProgramPath, '\Utils\PostGresQuery\PostGresQuery ', SQLParasFile]);
fprintf(FID, '%s\n', 'exit');
fclose(FID);

%[status,result] = dos([SQLBatch, ' &']);

hFig=findobj(0, 'Type', 'figure');
set(hFig, 'Pointer', 'watch');
drawnow;


system(SQLBatch);

%Wait for the result
for i=1:10
    if exist(StatusFile, 'file')
        break;
    else
        pause(1);
    end
end

set(hFig, 'Pointer', 'arrow');
drawnow;

if exist(StatusFile, 'file')
    QueryResult=textread(StatusFile,'%s','delimiter','\t','whitespace','');

    if length(QueryResult) < 2        
        MsgboxGuiIFOA(QueryResult{1}, 'Warn', 'warn', 'modal', handles.ProgramPath);
    else
        QueryResult=reshape(QueryResult, 9, []);
        
        QueryResult(1, :)=[];
        QueryResult(:, 1)=[];
        
        if ~isempty(QueryResult)
            QueryData.LastName= QueryResult(1, :)';
            QueryData.FirstName=QueryResult(2, :)';
            QueryData.MiddleName=QueryResult(3, :)';
            QueryData.MRN=QueryResult(4, :)';
            QueryData.RadiationOncologist=QueryResult(5, :)';
            QueryData.InstitutionID=QueryResult(6, :)';
            QueryData.Institution=QueryResult(7, :)';
            QueryData.PatPath=QueryResult(8, :)';
                        
            QueryData.RelativePath=GetDataRelPath(DBName);
            QueryData.DataHost=GetDataHost(DBName);
            
            handles.QueryData=QueryData;
        else
            handles.QueryData=[];
        end
        
        guidata(handles.figure1, handles);
        
        hFig=findobj(0, 'Type', 'figure');
        
        for i=1:length(hFig)
            if isequal(get(hFig, 'Name'), 'PlanPatV9IFOA')
                delete(hFig(i));
            end
        end

        PlanPatV9IFOA(1, handles, GetDataHost(DBName), DBNameQuery, handles.PinnV9Config.FTPUser, handles.PinnV9Config.FTPPassword);
    end
else
    MsgboxGuiIFOA('Query failed.', 'Warn', 'warn', 'modal', handles.ProgramPath);
end



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
PushbuttonCancel_Callback(handles.PushbuttonCancel, [], handles);



%--------------------------------------Helper functions----------------------------------%
function Host=GetHostName(HostStr)
TempIndex=strfind(HostStr, ':');

if isempty(TempIndex)
    Host=HostStr;
else
    Host=HostStr(TempIndex(1)+1:end);
end


function DBName=GetDBName(Pinn9DBName)
TempIndex=strfind(Pinn9DBName, ':');

if isempty(TempIndex)
    DBName=Pinn9DBName;
else
    DBName=Pinn9DBName(TempIndex(1)+1:end);
end


function RelPath=GetDataRelPath(DBName)
TempIndex=strfind(DBName, ':');
RelPath=DBName(TempIndex(1)+1:end);

function DataHost=GetDataHost(DBName)
TempIndex=strfind(DBName, ':');
DataHost=DBName(1:TempIndex(1)-1);
