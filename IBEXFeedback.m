function varargout = IBEXFeedback(varargin)
% IBEXFEEDBACK MATLAB code for IBEXFeedback.fig
%      IBEXFEEDBACK, by itself, creates a new IBEXFEEDBACK or raises the existing
%      singleton*.
%
%      H = IBEXFEEDBACK returns the handle to a new IBEXFEEDBACK or the handle to
%      the existing singleton*.
%
%      IBEXFEEDBACK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IBEXFEEDBACK.M with the given input arguments.
%
%      IBEXFEEDBACK('Property','Value',...) creates a new IBEXFEEDBACK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IBEXFeedback_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IBEXFeedback_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IBEXFeedback

% Last Modified by GUIDE v2.5 26-Nov-2014 16:42:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IBEXFeedback_OpeningFcn, ...
                   'gui_OutputFcn',  @IBEXFeedback_OutputFcn, ...
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


% --- Executes just before IBEXFeedback is made visible.
function IBEXFeedback_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IBEXFeedback (see VARARGIN)


PFig=varargin{2};

%Set Position
CenterFigBottomCenter(handles.figure1, PFig);


% Choose default command line output for IBEXFeedback
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes IBEXFeedback wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = IBEXFeedback_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in PushbuttonCopy.
function PushbuttonCopy_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonCopy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[ProgramPath, FName]=fileparts(mfilename('fullpath'));

%Get Command History
DiaryFileName=get(0, 'DiaryFile');
diary(DiaryFileName);


DairyInfo=ReadPinnTextFileOri(DiaryFileName);

DiaryInfo=[{'%----Matlab Output Starts----%'}; DairyInfo; {'%----Matlab Output Ends----%'}];

%Remove old text
StringInfo=RemoveBodyText(handles, 'Matlab');

%Insert new text
 StringInfo=[DiaryInfo; {' '}; StringInfo];
set(handles.EditBody, 'String', StringInfo);


function EditSubject_Callback(hObject, eventdata, handles)
% hObject    handle to EditSubject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditSubject as text
%        str2double(get(hObject,'String')) returns contents of EditSubject as a double


% --- Executes during object creation, after setting all properties.
function EditSubject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSubject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushbuttonAttachFiles.
function PushbuttonAttachFiles_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonAttachFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CurrentDir=pwd;
cd('C:\');

[FileName, PathName]=uigetfile('*.*', 'Select a file to attch');
if FileName == 0
    return;
end

FileName=[PathName, '\', FileName];
set(handles.EditAttachment, 'String', FileName);


function EditBody_Callback(hObject, eventdata, handles)
% hObject    handle to EditBody (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditBody as text
%        str2double(get(hObject,'String')) returns contents of EditBody as a double


% --- Executes during object creation, after setting all properties.
function EditBody_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditBody (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushbuttonSendMail.
function PushbuttonSendMail_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonSendMail (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Check Email Address 
if isequal(get(handles.CheckboxShareData, 'Value'), get(handles.CheckboxShareData, 'Max')) &&...
        isempty(get(handles.EditSender, 'String'))
    hMsg=MsgboxGuiIFOA(['Please make sure your email address is correct. ', sprintf('\n'), 'Information on the Box collaboration folder will be sent to that email.'], 'Help', 'help', 'modal');
    waitfor(hMsg);    
    return;
end

MailInfo.SenderEmail=get(handles.EditSender, 'String');
MailInfo.Subject=get(handles.EditSubject, 'String');
MailInfo.Body=get(handles.EditBody, 'String');
MailInfo.Attachment=get(handles.EditAttachment, 'String');

if isempty(MailInfo.Body) && ~exist(MailInfo.Attachment, 'file')
    Answer = QuestdlgIFOA('No body content or No attachment! Continue to send?', 'Confirm','Continue','Cancel', 'Continue');
    if ~isequal(Answer, 'Continue')
        return;
    end
end


hFig=findobj(0, 'Type', 'figure');
set(hFig, 'Pointer', 'watch');
drawnow;

try
    try
        SendMailForFeedback(MailInfo);
        ReturnFlag=1;
    catch
        ReturnFlag=0;
    end
%     ReturnFlag=SendMailNet(MailInfo);
    
    hFig=findobj(0, 'Type', 'figure');
    set(hFig, 'Pointer', 'arrow');
    drawnow;
    
    if ReturnFlag >0
        hMsg=MsgboxGuiIFOA(['Email is successfully sent to IBEX administrator. ', sprintf('\n'), 'You will be contacted soon. Thanks for your feedback!'], 'Help', 'Help', 'modal');        
    else
        hMsg=MsgboxGuiIFOA(['There is a failure in email sending. ', sprintf('\n'), 'Please copy content and send it through your email software.'], 'Error', 'Error', 'modal');
    end
    
    waitfor(hMsg);
    
    PushbuttonExit_Callback(handles.PushbuttonExit, eventdata, handles);
catch
    hFig=findobj(0, 'Type', 'figure');
    set(hFig, 'Pointer', 'arrow');
    drawnow;
    
    hMsg=MsgboxGuiIFOA(['There is a failure in email sending. ', sprintf('\n'), 'Please copy content and send it through your email software.'], 'Error', 'Error', 'modal');
    waitfor(hMsg); 
end

% --- Executes on button press in PushbuttonExit.
function PushbuttonExit_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);

% --- Executes on button press in CheckboxShareData.
function CheckboxShareData_Callback(hObject, eventdata, handles)
% hObject    handle to CheckboxShareData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CheckboxShareData

if isequal(get(handles.CheckboxShareData, 'Value'), get(handles.CheckboxShareData, 'Max'))
    
    %Check Email Address 
    hMsg=MsgboxGuiIFOA(['Please make sure your email address is correct. ', sprintf('\n'), 'Information on the Box collaboration folder will be sent to that email.'], 'Help', 'help', 'modal');
    waitfor(hMsg);    

    %Remove old text
    StringInfo=RemoveBodyText(handles, 'Folder');
       
    %Insert new text
    DiaryInfo=[{'I want to send data for the purpose of debugging and/or feedback.'};...
        {'Please create me a Box collaboration folder and send me the folder information.'};...
        ];
    DiaryInfo=[{'%----Data Share Folder Starts----%'}; DiaryInfo; {'%----Data Share Folder Ends----%'}];
    StringInfo=[DiaryInfo; {' '}; StringInfo];
else
    %Remove old text
    StringInfo=RemoveBodyText(handles, 'Folder');
end

set(handles.EditBody, 'String', StringInfo);


function StringInfo=RemoveBodyText(handles, Mode)
StringInfo=get(handles.EditBody, 'String');

switch Mode
    case 'Folder'
        TIndexStart=strmatch('%----Data Share Folder Starts----%', StringInfo);
        TIndexEnd=strmatch('%----Data Share Folder Ends----%', StringInfo);
    case 'Matlab'
        TIndexStart=strmatch('%----Matlab Output Starts----%', StringInfo);
        TIndexEnd=strmatch('%----Matlab Output Ends----%', StringInfo);
end

if ~isempty(TIndexStart) && ~isempty(TIndexEnd) && abs(length(TIndexEnd)-length(TIndexStart) < 1)
    if TIndexEnd(end)+1 <= length(StringInfo) && isequal(StringInfo{TIndexEnd(end)+1}, ' ')
        StringInfo(TIndexStart(1):TIndexEnd(end)+1)=[];
    else
        StringInfo(TIndexStart(1):TIndexEnd(end))=[];
    end
end



function EditAttachment_Callback(hObject, eventdata, handles)
% hObject    handle to EditAttachment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditAttachment as text
%        str2double(get(hObject,'String')) returns contents of EditAttachment as a double


% --- Executes during object creation, after setting all properties.
function EditAttachment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditAttachment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditSender_Callback(hObject, eventdata, handles)
% hObject    handle to EditSender (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditSender as text
%        str2double(get(hObject,'String')) returns contents of EditSender as a double


% --- Executes during object creation, after setting all properties.
function EditSender_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSender (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

PushbuttonExit_Callback(handles.PushbuttonExit, eventdata, handles);
