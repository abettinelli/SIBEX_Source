function varargout = IBEXLocation(varargin)
% IBEXLOCATION MATLAB code for IBEXLocation.fig
%      IBEXLOCATION, by itself, creates a new IBEXLOCATION or raises the existing
%      singleton*.
%
%      H = IBEXLOCATION returns the handle to a new IBEXLOCATION or the handle to
%      the existing singleton*.
%
%      IBEXLOCATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IBEXLOCATION.M with the given input arguments.
%
%      IBEXLOCATION('Property','Value',...) creates a new IBEXLOCATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IBEXLocation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IBEXLocation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IBEXLocation

% Last Modified by GUIDE v2.5 07-Oct-2014 11:58:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IBEXLocation_OpeningFcn, ...
                   'gui_OutputFcn',  @IBEXLocation_OutputFcn, ...
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


% --- Executes just before IBEXLocation is made visible.
function IBEXLocation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IBEXLocation (see VARARGIN)

handles.ParentHandle=varargin{2};

set(handles.CheckboxDefault, 'Value', get(handles.CheckboxDefault, 'Min'), 'Enable', 'Off');   

PrefUser=handles.ParentHandle.CurrentUser;
PrefSite=handles.ParentHandle.CurrentSite;


DirName=GetDirList(handles.ParentHandle.INIConfigInfo.DataDir);
UserInfo=[DirName'; {'<New User>'}];

%Set preference User
TempIndex=strmatch(PrefUser, UserInfo, 'exact');
if ~isempty(TempIndex)
    UserIndex=TempIndex(1);
else
    UserIndex=1;
end

set(handles.ListboxUser, 'String', UserInfo, 'Value', UserIndex, 'Min', 0, 'Max', 1, ...
    'Enable', 'on', 'SelectionHighlight', 'on', 'ListboxTop', 1);

set(handles.TextLocation, 'String', ['Current location: .\' PrefUser '\' PrefSite])

%Set preference site
guidata(handles.figure1, handles);
ListboxUser_Callback(hObject, PrefSite, handles);
handles=guidata(handles.figure1);

% %Set position
% set(handles.ParentHandle.figure1, 'Units', 'pixels');
% ParentPos=get(handles.ParentHandle.figure1, 'Position');
% set(handles.figure1, 'Units', 'pixels');
% GcfPos=get(handles.figure1, 'Position');
% set(handles.figure1, 'Position', [ParentPos(1)+(ParentPos(3)-GcfPos(3)), ParentPos(2)+(ParentPos(4)-GcfPos(4)), GcfPos(3), GcfPos(4)]);
% set(handles.figure1, 'Units', 'characters');

%Change application Icon
figure(handles.figure1);
CenterFig(handles.figure1,handles.ParentHandle.figure1);
drawnow;

uicontrol(handles.ListboxSite);

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes IBEXLocation wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = IBEXLocation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.figure1;


% --- Executes on selection change in ListboxSite.
function ListboxSite_Callback(hObject, eventdata, handles)
% hObject    handle to ListboxSite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListboxSite contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListboxSite

%Rename or create site
UserInfo=get(handles.ListboxUser,'String');
UserIndex=get(handles.ListboxUser,'Value');   

if (UserIndex < length(UserInfo))
    if isequal(get(handles.figure1, 'SelectionType'), 'Open') || isequal(get(handles.figure1, 'SelectionType'), 'open')
        RenameCreateSite(handles);
    end
end

%Enable or disable OK button
UserInfo=get(handles.ListboxUser,'String');
UserIndex=get(handles.ListboxUser,'Value');   

SiteInfo=get(handles.ListboxSite,'String');
SiteIndex=get(handles.ListboxSite,'Value');   

if (UserIndex < length(UserInfo)) && (SiteIndex < length(SiteInfo))
    set(handles.PushbuttonOK, 'Enable', 'On');
else
    set(handles.PushbuttonOK, 'Enable', 'Off');
end



% --- Executes during object creation, after setting all properties.
function ListboxSite_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListboxSite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushbuttonOK.
function PushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%---Save default User&site setting
if isequal(get(handles.CheckboxDefault, 'Value'), get(handles.CheckboxDefault, 'Max'))
    UserInfo=get(handles.ListboxUser,'String');
    UserIndex=get(handles.ListboxUser,'Value');
    
    CurrentUser=UserInfo{UserIndex};
    
    SiteInfo=get(handles.ListboxSite,'String');
    if ~isempty(SiteInfo)
        SiteIndex=get(handles.ListboxSite,'Value');
        
        if SiteIndex < length(SiteInfo)
            CurrentSite=SiteInfo{SiteIndex};
        else
            CurrentSite='';
        end
    else
        CurrentSite='';
    end
    
    try
        FID=fopen(handles.ParentHandle.PrefFile, 'w');        
        fprintf(FID, '%s\n', ['User=''', CurrentUser,''';']);
        fprintf(FID, '%s\n', ['Site=''', CurrentSite, ''';']);
        fclose(FID);
    catch ErrObj
        rethrow(ErrObj);
    end
end


%Adapt the variable to network drive
UserInfo=get(handles.ListboxUser,'String');
UserIndex=get(handles.ListboxUser,'Value');   

SiteInfo=get(handles.ListboxSite,'String');
SiteIndex=get(handles.ListboxSite,'Value');   

handles.ParentHandle.CurrentUser=UserInfo{UserIndex};
handles.ParentHandle.CurrentSite=SiteInfo{SiteIndex};

guidata(handles.ParentHandle.figure1, handles.ParentHandle);

guidata(handles.figure1, handles);

delete(handles.figure1);



% --- Executes on button press in PushbuttonCancel.
function PushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);

% --- Executes on selection change in ListboxUser.
function ListboxUser_Callback(hObject, eventdata, handles)
% hObject    handle to ListboxUser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListboxUser contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListboxUser


if isequal(get(handles.figure1, 'SelectionType'), 'Normal') || isequal(get(handles.figure1, 'SelectionType'), 'normal')

    UserInfo=get(handles.ListboxUser,'String');
    UserIndex=get(handles.ListboxUser,'Value');
    
    OldSiteName=get(handles.TextSite, 'String');
    NewSiteName=['Site (', UserInfo{UserIndex}, '):'];
    
    if isequal(OldSiteName, NewSiteName)
        return;
    end
    
    set(handles.TextSite, 'String', NewSiteName);

    if UserIndex < length(UserInfo)
        CurrentUser=UserInfo{UserIndex};
      
        DirName=GetDirList([handles.ParentHandle.INIConfigInfo.DataDir, '\', CurrentUser]);
        SiteInfo=DirName;
        
        SiteInfo=[SiteInfo'; {'<New Site>'}];

        if ~isempty(SiteInfo)
            if ~isempty(eventdata)
                % IBSI_mod
                try
                    TempIndex=strmatch(eventdata, SiteInfo, 'exact');
                catch
                    TempIndex = [];
                end
                
                if ~isempty(TempIndex)
                    SiteIndex=TempIndex(1);
                else
                    SiteIndex=1;
                end
            else
                SiteIndex=1;
            end

            set(handles.ListboxSite, 'String', SiteInfo, 'Value', SiteIndex, 'Min', 0, 'Max', 1, ...
                'Enable', 'on', 'SelectionHighlight', 'on', 'ListboxTop', 1);
        end
    else
        %SiteInfo=handles.ParentHandle.DefaultSiteStringBack;
        
        SiteInfo=[];
        SiteInfo=[SiteInfo; {'<New Site>'}];

        SiteIndex=1;
        
        set(handles.ListboxSite, 'String', SiteInfo, 'Value', SiteIndex, 'Min', 0, 'Max', 1, ...
            'Enable', 'on', 'SelectionHighlight', 'on', 'ListboxTop', 1);
    end

    if UserIndex < length(UserInfo)
        set(handles.CheckboxDefault, 'Value', 1, 'Enable', 'on');
    else
        set(handles.CheckboxDefault, 'Value', 0, 'Enable', 'off');
    end
    
    if (UserIndex < length(UserInfo)) && (SiteIndex < length(SiteInfo))
        set(handles.PushbuttonOK, 'Enable', 'On');
    else
        set(handles.PushbuttonOK, 'Enable', 'Off');
    end
end


if isequal(get(handles.figure1, 'SelectionType'), 'Open') || isequal(get(handles.figure1, 'SelectionType'), 'open')
    RenameCreateUser(handles);
end



% --- Executes during object creation, after setting all properties.
function ListboxUser_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListboxUser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CheckboxDefault.
function CheckboxDefault_Callback(hObject, eventdata, handles)
% hObject    handle to CheckboxDefault (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CheckboxDefault


%Change User name for double-click
function RenameCreateUser(handles)
% hObject    handle to ListboxUser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%User is not allowed to change
if handles.ParentHandle.INIConfigInfo.UserType < 1
    hMsg=MsgboxGuiIFOA('New User on network drive has to be created by administrators.', 'warn', 'help');
    waitfor(hMsg);
    return;
end

handles = guidata(handles.figure1);

UserInfo=get(handles.ListboxUser,'String');
UserIndex=get(handles.ListboxUser,'Value');

    
%No change for local
if UserIndex == length(UserInfo)-1
    return;
end

UserName=UserInfo{UserIndex};

if length(UserInfo) > 2
    UserInfoCandidate=UserInfo(1:length(UserInfo)-2);
else
    UserInfoCandidate='';
end


TempName=InputTextUser(1, 'User name: ', UserName, UserInfoCandidate, handles.ParentHandle.ProgramPath);

if ~isempty(TempName)
    %Create new network User
    if UserIndex < length(UserInfo)-1
        Flag=movefile([handles.ParentHandle.INIConfigInfo.DataDir, '\', UserName], [handles.ParentHandle.INIConfigInfo.DataDir, '\', TempName], 'f');
    else
        Flag=mkdir([handles.ParentHandle.INIConfigInfo.DataDir, '\', TempName]);
    end

    if Flag < 1
        MsgboxGuiIFOA('Failed to create/rename the User folder.', 'Warning', 'help');
        return;
    else
        %New User list
        UserInfo=[];
        DirName=GetDirList(handles.ParentHandle.INIConfigInfo.DataDir);
        UserInfo=[UserInfo; DirName'];

        UserInfo=[UserInfo; {'<New User>'}];

        %Set preference User
        TempIndexUser=strmatch(TempName, UserInfo, 'exact');
        if ~isempty(TempIndexUser)
            UserIndex=TempIndexUser(1);
        else
            UserIndex=1;
        end

        set(handles.ListboxUser, 'String', UserInfo, 'Value', UserIndex, 'Min', 0, 'Max', 1, ...
            'Enable', 'on', 'SelectionHighlight', 'on', 'ListboxTop', 1);        

        %Set preference site
        SiteInfo=get(handles.ListboxSite, 'String');
        SiteIndex=get(handles.ListboxSite, 'Value');

        SiteName=SiteInfo{SiteIndex};
        
        set(handles.figure1, 'SelectionType', 'normal');

        guidata(handles.figure1, handles);
        ListboxUser_Callback(handles.ListboxUser, SiteName, handles);
        handles=guidata(handles.figure1);

        guidata(handles.figure1, handles);
    end

end


%Change User name for double-click
function RenameCreateSite(handles)
% hObject    handle to ListboxUser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(handles.figure1);

UserInfo=get(handles.ListboxUser,'String');
UserIndex=get(handles.ListboxUser,'Value');   

UserName=UserInfo{UserIndex};

%Only allow change for local folder
if handles.ParentHandle.INIConfigInfo.UserType < 1
    hMsg=MsgboxGui('New Site on network drive has to be created by administrators.', 'warn', 'help', 'modal', handles.ParentHandle.ProgramPath);
    waitfor(hMsg);
    return;
end


SiteInfo=get(handles.ListboxSite,'String');
SiteIndex=get(handles.ListboxSite,'Value');   

SiteName=SiteInfo{SiteIndex};

if length(SiteInfo) > 1
    SiteInfoCandidate=SiteInfo(1:length(SiteInfo)-1);
else
    SiteInfoCandidate='';
end


TempName=InputTextUser(1, 'Site name: ', SiteName, SiteInfoCandidate, handles.ParentHandle.ProgramPath);

if ~isempty(TempName)
    %Create new site
    if SiteIndex < length(SiteInfo)
        Flag=movefile([handles.ParentHandle.INIConfigInfo.DataDir, '\', UserName, '\', SiteName], ...
            [handles.ParentHandle.INIConfigInfo.DataDir, '\', UserName, '\', TempName], 'f');
    else
        Flag=mkdir([handles.ParentHandle.INIConfigInfo.DataDir, '\',  UserName, '\', TempName]);
    end
    
    if Flag < 1
        MsgboxGuiIFOA('Failed to create/rename the site folder.', 'Warning', 'help', 'modal');
        return;
    else
                
        %New User list
        SiteInfo=[];
        DirName=GetDirList([handles.ParentHandle.INIConfigInfo.DataDir, '\', UserName]);
        SiteInfo=[SiteInfo; DirName'];
     
        SiteInfo=[SiteInfo; {'<New Site>'}];

        %Set preference User
        TempIndex=strmatch(TempName, SiteInfo, 'exact');
        if ~isempty(TempIndex)
            SiteIndex=TempIndex(1);
        else
            SiteIndex=1;
        end

        set(handles.ListboxSite, 'String', SiteInfo, 'Value', SiteIndex, 'Min', 0, 'Max', 1, ...
            'Enable', 'on', 'SelectionHighlight', 'on', 'ListboxTop', 1);        
                
        set(handles.figure1, 'SelectionType', 'normal');
    end

end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(handles.figure1);
