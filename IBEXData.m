function varargout = IBEXData(varargin)
% IBEXDATA MATLAB code for IBEXData.fig
%      IBEXDATA, by itself, creates a new IBEXDATA or raises the existing
%      singleton*.
%
%      H = IBEXDATA returns the handle to a new IBEXDATA or the handle to
%      the existing singleton*.
%
%      IBEXDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IBEXDATA.M with the given input arguments.
%
%      IBEXDATA('Property','Value',...) creates a new IBEXDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IBEXData_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IBEXData_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IBEXData

% Last Modified by GUIDE v2.5 16-Feb-2021 10:31:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IBEXData_OpeningFcn, ...
                   'gui_OutputFcn',  @IBEXData_OutputFcn, ...
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


% --- Executes just before IBEXData is made visible.
function IBEXData_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IBEXData (see VARARGIN)

PHandles=varargin{2};

handles.PatsParentDir=[PHandles.INIConfigInfo.DataDir, '\', PHandles.CurrentUser, '\', PHandles.CurrentSite];

handles.PadROI = PHandles.INIConfigInfo.PadROI;

%Bettinelli
handles.DataFormat='Pinnacle';

handles.HightColor=[0, 120, 215];
% handles.TableSetValuePause=1E-90;
handles.TableSetValuePause=1E-1000;

handles.ROICurrentImageOnly=PHandles.INIConfigInfo.ROICurrentImageOnly;
handles.ThresholdNonUniformSP=PHandles.INIConfigInfo.ThresholdNonUniformSP;

%Create common folder
CreateSiteFolder(handles.PatsParentDir);

%Display Patient information
PatsInfo=ReadPatsInfo(handles);
if isempty(PatsInfo)
    set(handles.UITablePatient, 'Data', '');
    set(handles.UITableImage, 'Data', '');
else
    DisplayUITablePatient(PatsInfo, handles.UITablePatient);
    set(handles.UITableImage, 'Data', '');    
end
handles.PatsInfo=PatsInfo;

set(handles.PushbuttonOpen, 'Enable', 'Off');
set(handles.TextLocation, 'String', ['User: ', PHandles.CurrentUser, '; ', 'Site: ', PHandles.CurrentSite]);

handles.ParentFig=PHandles.figure1;
% set(handles.ParentFig, 'Visible', 'off');
pause(0.1);

CenterFigCenterLeft(handles.figure1,handles.ParentFig);

figure(handles.figure1);


%Set figure units to normalized for resize
set(handles.figure1, 'Units', 'normalized');
hChild=get(handles.figure1, 'Children');
set(hChild, 'Units', 'normalized');

%Get JTable
handles.jUITablePatient=GetJTable(handles.UITablePatient);
handles.jUITableImage=GetJTable(handles.UITableImage);


% Choose default command line output for IBEXData
handles.output = hObject;

% Update handles structure
guidata(handles.figure1, handles);

% UIWAIT makes IBEXData wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = IBEXData_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in PushbuttonOpen.
function PushbuttonOpen_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
HighlightStr=['<html><body bgcolor="' 'rgb(', num2str(handles.HightColor(1)), ', ', ...
                    num2str(handles.HightColor(2)), ', ', num2str(handles.HightColor(3)), ')', '">'];

%Patient Index
TableData=get(handles.UITablePatient, 'Data');
A=TableData(:, 1);
PatIndex=strmatch(HighlightStr, A);
 
%Image Index
TableData=get(handles.UITableImage, 'Data');
A=TableData(:, 1);
ImageIndex=strmatch(HighlightStr, A);

PatInfo=handles.PatsInfo(PatIndex);
ImageInfo=handles.ImagesInfo(ImageIndex);
ImageID=handles.ImagesInfoID{ImageIndex};

set(handles.figure1, 'Pointer', 'watch');
drawnow;

LocationStr=get(handles.TextLocation, 'String');

SpecifyData(1, handles.figure1, handles.PatsParentDir,...
    LocationStr, PatInfo, ImageInfo, ImageID, handles.ImagesInfo, handles.ImagesInfoID, handles.ROICurrentImageOnly, handles.ThresholdNonUniformSP, handles.PadROI);

set(handles.figure1, 'Pointer', 'arrow');
drawnow;





% --- Executes when entered data in editable cell(s) in UITablePatient.
function UITablePatient_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to UITablePatient (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

UITableEditComment(handles, eventdata, handles.UITablePatient);



function UITableEditComment(handles, eventdata, TableHandle)
RowIndex=eventdata.Indices(1);
ColumnIndex=eventdata.Indices(2);

%Comment
if ColumnIndex == 5     
        
    switch TableHandle
        case handles.UITablePatient
            TableData=get(handles.UITablePatient, 'Data');
        case handles.UITableImage
            TableData=get(handles.UITableImage, 'Data');
    end
    
    CurrentValue=TableData{RowIndex, ColumnIndex};       
    
    TempIndex=strfind(CurrentValue, '>'); 
    if ~isempty(TempIndex)
        CurrentValue=CurrentValue(TempIndex(end)+1:end);
    end
    
    
    switch TableHandle
        case handles.UITablePatient
            OriValue=handles.PatsInfo(RowIndex).Comment;
        case handles.UITableImage
            OriValue=handles.ImagesInfo(RowIndex).Comment;
    end
    
    if isempty(CurrentValue)
        if isempty(OriValue)
            return;
        end
    else
        if isequal(CurrentValue,OriValue)
            return;
        end
    end    
            
    %Update display   
    ShiftHtml=[CurrentValue];
        
     switch TableHandle
        case handles.UITablePatient
            %Update PatsInfo structure
            handles.PatsInfo(RowIndex).Comment=CurrentValue;
            guidata(handles.figure1, handles);
            
            %Update table
            handles.jUITablePatient.setValueAt(ShiftHtml, RowIndex-1, ColumnIndex-1);
            pause(handles.TableSetValuePause);
            
            %Update Patient file
            UpdatePatientFileComment(handles.PatsInfo(RowIndex).Directory, handles, CurrentValue);
        case handles.UITableImage
            %Update PatsInfo structure
            handles.ImagesInfo(RowIndex).Comment=CurrentValue;
            guidata(handles.figure1, handles);
            
            %Update table
            handles.jUITableImage.setValueAt(ShiftHtml, RowIndex-1, ColumnIndex-1);
            pause(handles.TableSetValuePause);
            
            %Update Patient file
            TableData=get(handles.UITablePatient, 'Data');
            
            HighlightStr=['<html><body bgcolor="' 'rgb(', num2str(handles.HightColor(1)), ', ', ...
                    num2str(handles.HightColor(2)), ', ', num2str(handles.HightColor(3)), ')', '">'];
                
            PatRowIndex=strmatch(HighlightStr, TableData(:, 1));            
            
            UpdateHeaderFileComment(handles.PatsInfo(PatRowIndex).Directory, handles, CurrentValue, handles.ImagesInfoID{RowIndex});
    end
    
end


% --- Executes when selected cell(s) is changed in UITablePatient.
function UITablePatient_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to UITablePatient (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

UITableSelectionMutexHighlight(handles, handles.UITablePatient, eventdata);


% --- Executes when entered data in editable cell(s) in UITableImage.
function UITableImage_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to UITableImage (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(eventdata.Indices)
    UITableEditComment(handles, eventdata, handles.UITableImage);
end


% --- Executes when selected cell(s) is changed in UITableImage.
function UITableImage_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to UITableImage (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(eventdata.Indices)
    UITableSelectionMutexHighlight(handles, handles.UITableImage, eventdata);
    
    EnableButtonOpen(handles);
end


%-----------------------------------------Helpers------------------------------%
function EnableButtonOpen(handles)
TableData=get(handles.UITableImage, 'Data');
if isempty(TableData)
    return;
end

A=TableData(:, 1);

HighlightStr=['<html><body bgcolor="' 'rgb(', num2str(handles.HightColor(1)), ', ', ...
                    num2str(handles.HightColor(2)), ', ', num2str(handles.HightColor(3)), ')', '">'];
                
TempIndex=strmatch(HighlightStr, A);
if isempty(TempIndex)
    set(handles.PushbuttonOpen, 'Enable', 'off');
else
    set(handles.PushbuttonOpen, 'Enable', 'on');
end


function DisplayUITablePatient(RawData, UITableData)

TableData=struct2cell(RawData);
TableData=reshape(TableData, [size(TableData, 1), size(TableData, 3)]);
TableData=TableData';

TableHeader=fieldnames(RawData);
TableEdit=repmat(false, 1,  size(TableData, 2));
TableFormat=repmat({'char'}, 1,  size(TableData, 2));

TempIndex=strmatch('Comment', TableHeader, 'exact');
TableEdit(TempIndex)=true;

TableFieldWidth=repmat({100}, 1, size(TableData, 2));

TempIndex=strmatch('LastName', TableHeader, 'exact');
TableFieldWidth{TempIndex}=120;

TempIndex=strmatch('Comment', TableHeader, 'exact');
TableFieldWidth{TempIndex}=150;

TempIndex=strmatch('Directory', TableHeader, 'exact');
TableFieldWidth{TempIndex}=200;

TableColWidth=TableFieldWidth;

TableHeader=FormatTableHeader(TableHeader);
TableHeader(1)=[];

set(UITableData, 'Visible', 'on', 'Enable', 'on', 'Data', TableData, ...
        'ColumnName', TableHeader, 'ColumnFormat', TableFormat, ...
        'ColumnEditable', TableEdit, 'ColumnWidth', TableColWidth); 
    
    


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
set(handles.ParentFig, 'Visible', 'on');
delete(handles.figure1);


function UpdatePatientFileComment(PatDir, handles, CurrentValue)
if isequal(handles.DataFormat, 'Pinnacle')
    if ~exist([handles.PatsParentDir, '\', PatDir, '\Plan'], 'dir')
        PatPath=PatDir;
    else
        PatPath=[PatDir, '\Plan'];
    end
    
    PatientFile=[handles.PatsParentDir, '\', PatPath, '\Patient'];
    
    PatientInfo=ReadPinnTextFileOri(PatientFile);
    
    TempIndex=strmatch('Comment', PatientInfo);
    PatientInfo(TempIndex(1))={['Comment = "', CurrentValue, '";']};
    
    FID=fopen(PatientFile, 'w');
    for i=1:length(PatientInfo)
        fprintf(FID, '%s\n', PatientInfo{i});
    end
    fclose(FID);    
end

function UpdateHeaderFileComment(PatDir, handles, CurrentValue, ImageSetID)
if isequal(handles.DataFormat, 'Pinnacle')
    if ~exist([handles.PatsParentDir, '\', PatDir, '\Plan'], 'dir')
        PatPath=[handles.PatsParentDir, '\', PatDir];
    else
        PatPath=[handles.PatsParentDir, '\', PatDir, '\Plan'];        
    end
    
    PatientFile=[PatPath, '\ImageSet_', ImageSetID, '.header'];
    
    PatientInfo=ReadPinnTextFileOri(PatientFile);
    
    TempIndex=strmatch('comment', PatientInfo);
    PatientInfo(TempIndex(1))={['comment : ', CurrentValue]};
    
    FID=fopen(PatientFile, 'w');
    for i=1:length(PatientInfo)
        fprintf(FID, '%s\n', PatientInfo{i});
    end
    fclose(FID);    
end


function UpdateTableImageSet(handles)

TableData=get(handles.UITablePatient, 'Data');
A=TableData(:, 1);

HighlightStr=['<html><body bgcolor="' 'rgb(', num2str(handles.HightColor(1)), ', ', ...
                    num2str(handles.HightColor(2)), ', ', num2str(handles.HightColor(3)), ')', '">'];
                
TempIndex=strmatch(HighlightStr, A);
if isempty(TempIndex)
    set(handles.UITableImage, 'Data', '');
    return;
end

TempIndex=TempIndex(1);

%Yes Patient Selection
if isequal(handles.DataFormat, 'Pinnacle')
    PatDir=handles.PatsInfo(TempIndex).Directory;
    
    if ~exist([handles.PatsParentDir, '\', PatDir, '\Plan'], 'dir')
        PatPath=[handles.PatsParentDir, '\', PatDir];
    else
        PatPath=[handles.PatsParentDir, '\', PatDir, '\Plan'];
    end
       
    HeaderInfo=GetHeaderInfo(PatPath, 1);
    if isempty(HeaderInfo)
        set(handles.UITableImage, 'Data', '');
        return;
    end
    
    ImagesInfoID=[];
    for i=1:length(HeaderInfo)
        ImagesInfoID=[ImagesInfoID; cellstr(HeaderInfo(i).ID)];
    end
        
    RawData=rmfield(HeaderInfo, 'ID');
    RawData=rmfield(RawData, 'MRN');
    
    TableHeader=fieldnames(RawData);
    TableData=struct2cell(RawData);
    TableData=reshape(TableData, [size(TableData, 1), size(TableData, 3)]);
    TableData=TableData';
        
    TableEdit= repmat(false, 1,  size(TableData, 2));
    TempIndex=strmatch('Comment', TableHeader, 'exact');
    TableEdit(TempIndex)=true;
    
    TableHeader=FormatTableHeader(TableHeader);
    TableHeader(1)=[];
    
    TableFormat=repmat({'char'}, 1,  size(TableData, 2));
        
    TableColWidth=[{60}, {180}, {160}, {50}, {90}, {210}];
        
    set(handles.UITableImage, 'Visible', 'on', 'Enable', 'on', 'Data', TableData, ...
        'ColumnName', TableHeader, 'ColumnFormat', TableFormat, ...
        'ColumnEditable', TableEdit, 'ColumnWidth', TableColWidth);
    
    handles.ImagesInfo=RawData;
    handles.ImagesInfoID=ImagesInfoID;
    guidata(handles.figure1, handles);
end




function UITableSelectionMutexHighlight(handles, TableHandle, eventdata)

RowIndex=eventdata.Indices(1);
ColumnIndex=eventdata.Indices(2);

%Current Selection
TableData=get(TableHandle, 'Data');
TableCol=size(TableData, 2);

switch TableHandle
    case handles.UITablePatient
        FieldName=fieldnames(handles.PatsInfo);
    case handles.UITableImage
        FieldName=fieldnames(handles.ImagesInfo);
end

HighlightStr=['<html><body bgcolor="' 'rgb(', num2str(handles.HightColor(1)), ', ', ...
                    num2str(handles.HightColor(2)), ', ', num2str(handles.HightColor(3)), ')', '">'];
   
%Dehightlight old selection                
A=TableData(:, 1);                
                
TempIndex=strmatch(HighlightStr, A);

if ~isempty(TempIndex)   
    for i=1:length(TempIndex)
        for j=1:TableCol
            CTempIndex=TempIndex(i);
            
            switch TableHandle
                case handles.UITablePatient
                    TempStr=getfield(handles.PatsInfo(CTempIndex), FieldName{j});
                case handles.UITableImage
                   TempStr=getfield(handles.ImagesInfo(CTempIndex), FieldName{j});
            end            
                       
            if rem(TempIndex, 2) == 0
                ShiftHtml=['<html><body bgcolor="' 'rgb(204, 204, 204)', '">', TempStr];
            else
                ShiftHtml=['<html><body bgcolor="' 'rgb(255, 255, 255)', '">', TempStr];
            end
            
            switch TableHandle
                case handles.UITablePatient
                    handles.jUITablePatient.setValueAt(ShiftHtml, CTempIndex-1, j-1);
                case handles.UITableImage
                  handles.jUITableImage.setValueAt(ShiftHtml, CTempIndex-1, j-1);
            end                  
            pause(handles.TableSetValuePause);            
        end
      
    end
end


%highlight new selection
if ~isequal(TempIndex, RowIndex)
    for j=1:TableCol
         switch TableHandle
             case handles.UITablePatient
                 TempStr=getfield(handles.PatsInfo(RowIndex), FieldName{j});
                 ShiftHtml=[HighlightStr, TempStr];
                 handles.jUITablePatient.setValueAt(ShiftHtml, RowIndex-1, j-1);
                 
             case handles.UITableImage
                 TempStr=getfield(handles.ImagesInfo(RowIndex), FieldName{j});
                 ShiftHtml=[HighlightStr, TempStr];
                 handles.jUITableImage.setValueAt(ShiftHtml, RowIndex-1, j-1);
         end
        pause(handles.TableSetValuePause);
        
    end
end

drawnow;
pause(handles.TableSetValuePause);

%Update Table Image
if isequal(TableHandle, handles.UITablePatient)
    UpdateTableImageSet(handles);
    EnableButtonOpen(handles)
end


    


% --- Executes on button press in PushbuttonAnonymize.
function PushbuttonAnonymize_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonAnonymize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Answer = QuestdlgIFOA('All patients under this site will be anonymized! Continue?', 'Confirm','Continue','Cancel', 'Continue');
if ~isequal(Answer, 'Continue')
    return;
end
    
%Status
hFigAll=findobj(0, 'Type', 'figure');
set(hFigAll, 'Pointer', 'watch');
drawnow;

hFig=findobj(0, 'Type', 'figure', 'Name', 'Open patient');
hStatus=StatusProgressTextCenterIFOA('IBEX', 'Anonymizing patients ...', hFig);
hText=findobj(hStatus, 'Style', 'Text');
drawnow;


%Anonymize patient
for i=1:size(handles.PatsInfo, 2)
    
    set(hText, 'String', ['Anonymizing patients (', num2str(i), '/', num2str(size(handles.PatsInfo, 2)), ') ...']);
    drawnow;
    
    CurrentDir=[handles.PatsParentDir, '\', handles.PatsInfo(i).Directory];    
    
    PatInfo=AnonymizePatient(CurrentDir, num2str(i));
    
    handles.PatsInfo(i).LastName=PatInfo.LastName;
    handles.PatsInfo(i).FirstName=PatInfo.FirstName;
    handles.PatsInfo(i).MiddleName=PatInfo.MiddleName;
    handles.PatsInfo(i).MRN=PatInfo.MRN;    
    handles.PatsInfo(i).Directory=PatInfo.Directory;
end

guidata(handles.figure1, handles);
    
%Update display
if isempty(handles.PatsInfo)
    set(handles.UITablePatient, 'Data', '');
    set(handles.UITableImage, 'Data', '');
else
    DisplayUITablePatient(handles.PatsInfo, handles.UITablePatient);
    set(handles.UITableImage, 'Data', '');
end

set(handles.PushbuttonOpen, 'Enable', 'Off');

%Status
delete(hStatus);

hFigAll=findobj(0, 'Type', 'figure');
set(hFigAll, 'Pointer', 'arrow');
drawnow;

% --- Executes on button press in PushbuttonCancel.
function PushbuttonCancel_Callback(hObject, eventdata, handles)
set(handles.ParentFig, 'Visible', 'on');
delete(handles.figure1);
