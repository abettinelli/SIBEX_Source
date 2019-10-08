function varargout = ROIEditor(varargin)
% ROIEDITOR MATLAB code for ROIEditor.fig
%      ROIEDITOR, by itself, creates a new ROIEDITOR or raises the existing
%      singleton*.
%
%      H = ROIEDITOR returns the handle to a new ROIEDITOR or the handle to
%      the existing singleton*.
%
%      ROIEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROIEDITOR.M with the given input arguments.
%
%      ROIEDITOR('Property','Value',...) creates a new ROIEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROIEditor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROIEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ROIEditor

% Last Modified by GUIDE v2.5 12-Jul-2019 10:45:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ROIEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @ROIEditor_OutputFcn, ...
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


% --- Executes just before ROIEditor is made visible.
function ROIEditor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ROIEditor (see VARARGIN)

PHandles=varargin{2};

handles.DebugFlag=0;

handles.ParentFig=PHandles.figure1;

handles.ProgramPath=PHandles.ProgramPath;

handles.TableSetValuePause=PHandles.TableSetValuePause;
handles.TableSetValuePauseEdit=0.02;    %Set longer time waiting for java GUI finish

handles.BWMatInfo=PHandles.BWMatInfo;

handles.ImageDataAxialInfo=PHandles.ImageDataAxialInfo;
handles.ImageDataCorInfo=PHandles.ImageDataCorInfo;
handles.ImageDataSagInfo=PHandles.ImageDataSagInfo;

handles.SliceNum=PHandles.SliceNum;
handles.SliceNumCor=PHandles.SliceNumCor;
handles.SliceNumSag=PHandles.SliceNumSag;

%Initiaize GUI UIControl
guidata(handles.figure1, handles);
InitializeROIFig(handles, 1);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

%Window/Level
TempIndex=get(PHandles.PopupmenuWL, 'Value');
set(handles.PopupmenuWL, 'Value', TempIndex);

CLim=get(PHandles.AxesImageAxial, 'CLim');
handles.GrayMin=CLim(1);
handles.GrayMax=CLim(2);

TempIndex=get(PHandles.PopupmenuColorMap, 'Value');
set(handles.PopupmenuColorMap, 'Value', TempIndex);

PopupmenuColorMap_Callback(handles.PopupmenuColorMap, [], handles);

%Display Image
guidata(handles.figure1, handles);
DisplayImageInit(handles);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

%Read Image
hStatus=StatusProgressTextCenterIFOA('IBEX', 'Loading ROI editor ...', handles.ParentFig);
TempName=get(hStatus, 'name');
SetTopWindow(TempName);

set(handles.figure1, 'Pointer', 'Watch');
drawnow;

%Display ROI Table
handles.PlansInfo=PHandles.PlansInfo;
handles.PatPath=PHandles.PatPath;

%Plan ROIs
DisplayROITable(PHandles.PlansInfo, handles.UITableROI);

%User ROIs
DisplayROITableUser(PHandles.PlansInfo, handles.UITableROIUser);

%Initialize contour editing variables
InitializeContourVars(handles);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

%Invisile Parent figure
set(handles.ParentFig, 'Visible', 'off');

%Center figure
CenterFig(handles.figure1);

figure(handles.figure1);

%Get JTable
jScroll = findjobj(handles.UITableROI);
try jScroll = jScroll(1); jScroll = jScroll.getViewport;  catch, end  % may possibly already be the viewport
try jScroll = jScroll.getComponent(0).getViewport;  catch, end  % HG2
jUITableROI = jScroll.getView;

jScroll = findjobj(handles.UITableROIUser);
try jScroll = jScroll(1); jScroll = jScroll.getViewport;  catch, end  % may possibly already be the viewport
try jScroll = jScroll.getComponent(0).getViewport;  catch, end  % HG2
jUITableROIUser = jScroll.getView;

handles.jUITableROI=jUITableROI;
handles.jUITableROIUser=jUITableROIUser;

%Set figure units to normalized for resize
set(handles.figure1, 'Units', 'normalized');
hChild=get(handles.figure1, 'Children');
set(hChild, 'Units', 'normalized');

guidata(handles.figure1, handles);

%Synchonize
PushbuttonOffAllROIs_Callback(handles.PushbuttonOffAllROIs, [], handles);

SyncDisplay(handles, PHandles);
drawnow;

handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

% Choose default command line output for ROIEditor
handles.output = hObject;

%Set Current ROI 
pause(0.5);  %Wait for Jave Table to finish ROI display

SetEditUIOnOff(handles, 'Off');

SetAutoSegStatus(handles);
handles=guidata(handles.figure1);

SetAutoSegPara(handles);



handles.FocusUI=handles.PushbuttonSave;

delete(hStatus);
set(handles.figure1, 'Pointer', 'arrow');
drawnow;

% Update handles structure
guidata(handles.figure1, handles);

% UIWAIT makes ROIEditor wait for user response (see UIRESUME)
if handles.DebugFlag < 1
    uiwait(handles.figure1);
end

function SetAutoSegPara(handles)

AutoSegFlag=0;
if isequal(handles.ImageDataAxialInfo.Modality, 'PT')
    MaxData=max(handles.ImageDataAxialInfo.ImageData);
    
    if MaxData < 300
        %Auto Seg default
        AutoSegFlag=1;
        set(handles.PopupmenuAutoSegPreset, 'Value', 3);
        set(handles.PopupmenuAutoSegUnit, 'Value', 2);
        set(handles.EditAutoSegLower, 'String', '0.2');
        set(handles.EditAutoSegHigher, 'String', '0.6');
    end
end

if AutoSegFlag  < 1
    set(handles.PopupmenuAutoSegPreset, 'Value', 1);
    set(handles.PopupmenuAutoSegUnit, 'Value', 1);
    set(handles.EditAutoSegLower, 'String', '0');
    set(handles.EditAutoSegHigher, 'String', '900');
end


function PlansInfo=ReadPlanInfo(PatPath, DBName)
%Get PlanInfo
PatFileName=[PatPath, '\Patient'];
PatientInfo=ReadPinnTextFile(PatFileName);

PlansInfo=GetPlanInfo(PatientInfo);

if isempty(PlansInfo.PlanIDList)
    PlansInfo.PinnV9=[];
    PlansInfo.structAxialROI=[];
else   
    %Add PinnV9 flag
    PlansInfo=GetPlanImagePinnV9(PlansInfo, PatPath);
    
    %Load ROI
    PlansInfo=GetPlanROIStruct(PlansInfo, PatPath, DBName);
end


function PlansInfo=GetPlanROIStruct(PlansInfo, PatPath, DBName)

for i=1:length(PlansInfo.PlanIDList)
    PinnFile=[PatPath, '\', 'Plan_', num2str(PlansInfo.PlanIDList(i)), '\plan.roi'];
    
    if exist(PinnFile, 'file')
        TextInfo=ReadPinnTextFileOri(PinnFile);
        
        %Find ROIs whose volume name match with image DBName
        TempIndex=strmatch('volume_name', TextInfo);
        if ~isempty(TempIndex)
            ROIName=[];
            VolName=[];
            
            for j=1:length(TempIndex)
                TempStr=TextInfo{TempIndex(j)-1};   
                ROINameT=GetTextStrValue(TempStr); 
                ROIName=[ROIName; {ROINameT}];
                
                TempStr=TextInfo{TempIndex(j)};
                VolNameT=GetTextStrValue(TempStr); 
                VolName=[VolName; {VolNameT}];
            end
            
            TempIndex=strmatch(DBName, VolName, 'exact');
            if ~isempty(TempIndex)
                %no need to resave ROI files
                if length(TempIndex) == length(ROIName)
                    structAxialROI=LoadROIStructs(PinnFile, 'Fake.roi', 'Fake.roi', [0,0]);
                else
                    %ROIFile need to be resave
                    SelectOrgan=ROIName(TempIndex);
                    
                    NewROIFile=[PinnFile, 'Crop'];
                    SaveSelectROI_Outside(TextInfo, NewROIFile , SelectOrgan);
                    
                    structAxialROI=LoadROIStructs(PinnFile, 'Fake.roi', 'Fake.roi', [0,0]);
                    
                    delete(NewROIFile);
                end
                
                structAxialROIT(i)={structAxialROI};
            else
                structAxialROIT(i)={[]};
            end
            
        else
            structAxialROIT(i)={[]};
        end
    else
        structAxialROIT(i)={[]};
    end    
end

PlansInfo.structAxialROI=structAxialROIT;


function PropValueStr=GetTextStrValue(ValueStr)
TempIndex=strfind(ValueStr, ':');
ValueStr=ValueStr(TempIndex(1)+1:end);    
PropValueStr=strtrim(ValueStr);


function PlansInfo=GetPlanImagePinnV9(PlansInfo, PatPath)
for i=1:length(PlansInfo.PlanIDList)
    PinnFile=[PatPath, '\', 'Plan_', num2str(PlansInfo.PlanIDList(i)), '\plan.Pinnacle'];
    
    if exist(PinnFile, 'file')
        TextInfo=ReadPinnTextFileOri(PinnFile);
        
        TempIndex=strmatch('StartWithDICOM', TextInfo);
        if ~isempty(TempIndex)
            eval(TextInfo{TempIndex(1)});
            PinnV9(i)=StartWithDICOM;
        else           
            PinnV9(i)=2; %Unkwon start point type, type will be determined by image start point
        end
    else
        PinnV9(i)=2;
    end    
end

PlansInfo.PinnV9=PinnV9;



function Flag=IsSPUniform(DataFormat)
TempS=conv(DataFormat.TablePos, [1,-1]);
TempS(1)=[]; TempS(size(TempS, 1))=[];
SliceSpacingT=round(abs(TempS*1000))/1000;

VarIndex=conv(SliceSpacingT, [1, -1]);
VarIndex(1)=[]; VarIndex(size(VarIndex, 1))=[];

TempIndex=find(abs(VarIndex) >= 0.05);

if ~isempty(TempIndex)
    Flag=0;
else
    Flag=1;
end


function  InitializeError(hStatus, hFig, ErrorStr)
delete(hStatus);

hMsg=MsgboxGuiIFOA(ErrorStr, 'Error', 'error', 'modal');

TempName=get(hMsg, 'name');
SetTopWindow(TempName);
pause(0.01);
drawnow;

waitfor(hMsg);

delete(hFig);
    

function [CTSizeInfo, CTDimInfo, CTPixInfo]=GetImageSizeInfo(handles)
ImageDataAxialInfoT=GetImageDataInfo(handles, 'Axial');

CTSizeInfo=[num2str(double(size(ImageDataAxialInfoT.ImageData, 2))*ImageDataAxialInfoT.XPixDim), 'cm*',...
    num2str(double(size(ImageDataAxialInfoT.ImageData, 1))*ImageDataAxialInfoT.YPixDim), 'cm*', ...
    num2str(length(ImageDataAxialInfoT.TablePos)*ImageDataAxialInfoT.ZPixDim), 'cm '];
    
if ~isempty(handles.ImageDataCorInfo)
    if ~isequal(ImageDataAxialInfoT, handles.ImageDataCorInfo)
        CTSizeInfo=[CTSizeInfo, num2str(double(size(handles.ImageDataCorInfo.ImageData, 2))*handles.ImageDataCorInfo.XPixDim), 'cm*',...
            num2str(double(size(handles.ImageDataCorInfo.ImageData, 1))*handles.ImageDataCorInfo.YPixDim), 'cm*', ...
            num2str(length(handles.ImageDataCorInfo.TablePos)*handles.ImageDataCorInfo.ZPixDim), 'cm '];
    end
end

if ~isempty(handles.ImageDataSagInfo)
    if ~isequal(ImageDataAxialInfoT, handles.ImageDataSagInfo) && ~isequal(handles.ImageDataCorInfo, handles.ImageDataSagInfo)
        CTSizeInfo=[CTSizeInfo, num2str(double(size(handles.ImageDataSagInfo.ImageData, 2))*handles.ImageDataSagInfo.XPixDim), 'cm*',...
            num2str(double(size(handles.ImageDataSagInfo.ImageData, 1))*handles.ImageDataSagInfo.YPixDim), 'cm*', ...
            num2str(length(handles.ImageDataSagInfo.TablePos)*handles.ImageDataSagInfo.ZPixDim), 'cm '];
    end
end

CTDimInfo=...
    [num2str(size(ImageDataAxialInfoT.ImageData, 2)), '*', num2str(size(ImageDataAxialInfoT.ImageData, 1)), '*', num2str(length(ImageDataAxialInfoT.TablePos)), ' '];

if ~isempty(handles.ImageDataCorInfo)
    if ~isequal(ImageDataAxialInfoT, handles.ImageDataCorInfo)
        CTDimInfo=...
            [CTDimInfo, num2str(size(handles.ImageDataCorInfo.ImageData, 2)), '*', num2str(size(handles.ImageDataCorInfo.ImageData, 1)), '*', num2str(length(handles.ImageDataCorInfo.TablePos)), ' '];
    end
end

if ~isempty(handles.ImageDataSagInfo)
    if ~isequal(ImageDataAxialInfoT, handles.ImageDataSagInfo) && ~isequal(handles.ImageDataCorInfo, handles.ImageDataSagInfo)
        CTDimInfo=...
            [CTDimInfo, num2str(size(handles.ImageDataSagInfo.ImageData, 2)), '*', num2str(size(handles.ImageDataSagInfo.ImageData, 1)), '*', num2str(length(handles.ImageDataSagInfo.TablePos)), ' '];
    end
end

CTPixInfo=...
    [num2str(ImageDataAxialInfoT.XPixDim), 'cm*', num2str(ImageDataAxialInfoT.YPixDim), 'cm*', num2str(ImageDataAxialInfoT.ZPixDim), 'cm '];
 
if ~isempty(handles.ImageDataCorInfo)
    if ~isequal(ImageDataAxialInfoT, handles.ImageDataCorInfo)
        CTPixInfo=...
            [ CTPixInfo, num2str(handles.ImageDataCorInfo.XPixDim), 'cm*', num2str(handles.ImageDataCorInfo.YPixDim), 'cm*', num2str(handles.ImageDataCorInfo.ZPixDim), 'cm '];
    end
end

if ~isempty(handles.ImageDataSagInfo)
    if ~isequal(ImageDataAxialInfoT, handles.ImageDataSagInfo) && ~isequal(handles.ImageDataCorInfo, handles.ImageDataSagInfo)
        CTPixInfo=...
            [ CTPixInfo, num2str(handles.ImageDataSagInfo.XPixDim), 'cm*', num2str(handles.ImageDataSagInfo.YPixDim), 'cm*', num2str(handles.ImageDataSagInfo.ZPixDim), 'cm '];
    end
end

function ImageData=GetImageData(ImgFile, DataFormat)
if DataFormat.ByteOrder < 1
    fid=fopen(ImgFile, 'r', 'ieee-le');
else
    fid=fopen(ImgFile, 'r', 'ieee-be');
end        
        
[TempData, Count]=fread(fid, DataFormat.XDim*DataFormat.YDim*length(DataFormat.TablePos), '*int16');
TempData=uint16(TempData);
fclose(fid);

ImageData=reshape(TempData, [DataFormat.XDim, DataFormat.YDim, length(DataFormat.TablePos)]);
ImageData=permute(ImageData, [2,1, 3]);

ImageData=flipdim(ImageData, 1);


% --- Outputs from this function are returned to the command line.
function varargout = ROIEditor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get default command line output from handles structure
varargout{1} = handles.BWMatInfo;
varargout{2} = handles.PlansInfo;

varargout{3} = handles.SliceNum;
varargout{4} = handles.SliceNumCor;
varargout{5} = handles.SliceNumSag;

varargout{6} = get(handles.UITableROI, 'Data');
varargout{7} = get(handles.UITableROIUser, 'Data');

set(handles.ParentFig, 'Visible', 'on');

if handles.DebugFlag < 1
    delete(handles.figure1);    
end
 

% --- Executes on button press in PushbuttonAntSlow.
function PushbuttonAntSlow_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonAntSlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SliceNum=handles.SliceNumCor-1;
if SliceNum < 1
    SliceNum=1;
end

handles.SliceNumCor=SliceNum;

guidata(handles.figure1, handles);

DisplayImageCor(handles);

% --- Executes on button press in PushbuttonPostSlow.
function PushbuttonPostSlow_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonPostSlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ImageDataInfo=GetImageDataInfo(handles, 'Cor');

SliceNum=handles.SliceNumCor+1;
if SliceNum > ImageDataInfo.YDim
    SliceNum=ImageDataInfo.YDim;
end

handles.SliceNumCor=SliceNum;

guidata(handles.figure1, handles);

DisplayImageCor(handles);


% --- Executes on button press in PushbuttonAntFast.
function PushbuttonAntFast_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonAntFast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SliceNum=handles.SliceNumCor-5;
if SliceNum < 1
    SliceNum=1;
end

handles.SliceNumCor=SliceNum;

guidata(handles.figure1, handles);

DisplayImageCor(handles);


% --- Executes on button press in PushbuttonPostFast.
function PushbuttonPostFast_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonPostFast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ImageDataInfo=GetImageDataInfo(handles, 'Cor');

SliceNum=handles.SliceNumCor+5;
if SliceNum > ImageDataInfo.YDim
    SliceNum=ImageDataInfo.YDim;
end

handles.SliceNumCor=SliceNum;

guidata(handles.figure1, handles);

DisplayImageCor(handles);


% --- Executes on button press in PushbuttonRightSlow.
function PushbuttonRightSlow_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonRightSlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SliceNum=handles.SliceNumSag-1;
if SliceNum < 1
    SliceNum=1;
end

handles.SliceNumSag=SliceNum;

guidata(handles.figure1, handles);

DisplayImageSag(handles);


% --- Executes on button press in PushbuttonLeftSlow.
function PushbuttonLeftSlow_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonLeftSlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ImageDataInfo=GetImageDataInfo(handles, 'Sag');

SliceNum=handles.SliceNumSag+1;
if SliceNum > ImageDataInfo.XDim
    SliceNum=ImageDataInfo.XDim;
end

handles.SliceNumSag=SliceNum;

guidata(handles.figure1, handles);

DisplayImageSag(handles);


% --- Executes on button press in PushbuttonRightFast.
function PushbuttonRightFast_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonRightFast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SliceNum=handles.SliceNumSag-5;
if SliceNum < 1
    SliceNum=1;
end

handles.SliceNumSag=SliceNum;

guidata(handles.figure1, handles);

DisplayImageSag(handles);


% --- Executes on button press in PushbuttonLeftFast.
function PushbuttonLeftFast_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonLeftFast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ImageDataInfo=GetImageDataInfo(handles, 'Sag');

SliceNum=handles.SliceNumSag+5;
if SliceNum > ImageDataInfo.XDim
    SliceNum=ImageDataInfo.XDim;
end

handles.SliceNumSag=SliceNum;

guidata(handles.figure1, handles);

DisplayImageSag(handles);


% --- Executes on button press in PushbuttonInferSlow.
function PushbuttonInferSlow_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonInferSlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SliceNum=handles.SliceNum-1;
if SliceNum > 0
    handles.SliceNum=SliceNum;
   
    guidata(handles.figure1, handles);
    
    DisplayImage(handles);
end


% --- Executes on button press in PushbuttonSupSlow.
function PushbuttonSupSlow_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonSupSlow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ImageDataInfo=GetImageDataInfo(handles, 'Axial');

SliceNum=handles.SliceNum+1;
if SliceNum <= length(ImageDataInfo.TablePos)
    handles.SliceNum=SliceNum;
    
    guidata(handles.figure1, handles);
    
    DisplayImage(handles);
end



% --- Executes on button press in PushbuttonInferFast.
function PushbuttonInferFast_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonInferFast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SliceNum=handles.SliceNum-5;
if SliceNum > 0
    handles.SliceNum=SliceNum;
    
    guidata(handles.figure1, handles);
    
    DisplayImage(handles);
end



% --- Executes on button press in PushbuttonSupFast.
function PushbuttonSupFast_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonSupFast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ImageDataInfo=GetImageDataInfo(handles, 'Axial');

SliceNum=handles.SliceNum+5;
if SliceNum <= length(ImageDataInfo.TablePos)
    handles.SliceNum=SliceNum;
            
    guidata(handles.figure1, handles);
    
    DisplayImage(handles);
end



% --- Executes on button press in TogglebuttonRuler.
function TogglebuttonRuler_Callback(hObject, eventdata, handles)
% hObject    handle to TogglebuttonRuler (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TogglebuttonRuler
if isequal(get(handles.TogglebuttonRuler, 'Value'), get(handles.TogglebuttonRuler, 'Max'))    
    
    set(handles.TextStatus, 'String', ' ', 'Visible', 'Off');
    
    %--Disable Zoom Status
    if isequal(get(handles.TogglebuttonZoom, 'Value'), get(handles.TogglebuttonZoom, 'Max'))        
        set(handles.TogglebuttonZoom, 'Value', get(handles.TogglebuttonZoom, 'Min'));
        zoom off;
        drawnow;
    end
    
    %--Disable TogglebuttonRuler
    if isequal(get(handles.TogglebuttonCTNum, 'Value'), get(handles.TogglebuttonCTNum, 'Max'))    
        set(handles.TogglebuttonCTNum, 'Value', get(handles.TogglebuttonCTNum, 'Min'));
        TogglebuttonCTNum_Callback(handles.TogglebuttonCTNum, eventdata, handles);
    end   
    handles.OldRulerPoint=[];
    guidata(handles.figure1, handles); 
    
     %Disable contour Editing
    SetContourToolStatus(handles, hObject);
    handles=guidata(handles.figure1);
    guidata(handles.figure1, handles);    
    
    set(hObject, 'Value', 1);
else
    set(handles.TextStatus, 'String', ' ', 'Visible', 'Off');    
end

guidata(handles.figure1, handles);


% --- Executes on button press in PushbuttonWL.
function PushbuttonWL_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonWL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.figure1, 'Units', 'pixels');
TempPos=get(handles.figure1, 'Position');
set(handles.figure1, 'Units', 'normalized');

TempH=findobj(0, 'Type', 'figure', 'Name', 'Window/Level Tool');
if isempty(TempH)
    flag_CT = isequal(handles.ImageInfo.Modality, 'CT');
    IBSI_ImcontrastGUIFOA([handles.AxesImageAxial, handles.AxesImageSag, handles.AxesImageCor], [TempPos(1)+(TempPos(3)-300)/2,  TempPos(2)+TempPos(4)-100, 300, 125], flag_CT);
end


% --- Executes on button press in TogglebuttonCTNum.
function TogglebuttonCTNum_Callback(hObject, eventdata, handles)
% hObject    handle to TogglebuttonCTNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TogglebuttonCTNum

if isequal(get(handles.TogglebuttonCTNum, 'Value'), get(handles.TogglebuttonCTNum, 'Max'))          
    
    set(handles.TextStatus, 'String', ' ', 'Visible', 'Off');
     
    %--Disable Zoom Status
    if isequal(get(handles.TogglebuttonZoom, 'Value'), get(handles.TogglebuttonZoom, 'Max'))
        set(handles.TogglebuttonZoom, 'Value', get(handles.TogglebuttonZoom, 'Min'));
        TogglebuttonZoom_Callback(handles.TogglebuttonZoom, eventdata, handles);        
    end    
   
    %--Disable Ruler
    if isequal(get(handles.TogglebuttonRuler, 'Value'), get(handles.TogglebuttonRuler, 'Max'))
        set(handles.TogglebuttonRuler, 'Value', get(handles.TogglebuttonRuler, 'Min'));
        TogglebuttonRuler_Callback(handles.TogglebuttonRuler, eventdata, handles);
    end      
    
    %Disable contour Editing
    SetContourToolStatus(handles, hObject);
    handles=guidata(handles.figure1);
    guidata(handles.figure1, handles);
    
    set(hObject, 'Value', 1);
else
    set(handles.TextStatus, 'String', ' ', 'Visible', 'Off');
    drawnow;
end



% --- Executes on button press in TogglebuttonZoom.
function TogglebuttonZoom_Callback(hObject, eventdata, handles)
% hObject    handle to TogglebuttonZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TogglebuttonZoom
if get(hObject, 'Value') == get(hObject, 'Max')          
    
    set(handles.TextStatus, 'String', ' ', 'Visible', 'Off');    
    
    zoom on;
    drawnow;           
else      
    zoom off;    
    drawnow; 
end

guidata(handles.figure1, handles);


% --- Executes on button press in TogglebuttonCross.
function TogglebuttonCross_Callback(hObject, eventdata, handles)
% hObject    handle to TogglebuttonCross (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TogglebuttonCross
if isequal(get(handles.TogglebuttonCross, 'Value'), get(handles.TogglebuttonCross, 'Max'))    
    
    %Reset Contour Editing tool
    set(handles.TogglebuttonContourDraw, 'Value', get(handles.TogglebuttonContourDraw, 'Min'));
    TogglebuttonContourDraw_Callback(handles.TogglebuttonContourDraw, [], handles);
    handles=guidata(handles.figure1);
    guidata(handles.figure1, handles);
    
    
    set(handles.TogglebuttonContourTrail, 'Value', get(handles.TogglebuttonContourTrail, 'Min'));
    TogglebuttonContourTrail_Callback(handles.TogglebuttonContourTrail, [], handles);
    handles=guidata(handles.figure1);
    guidata(handles.figure1, handles);
    
    
    set(handles.TogglebuttonContourCut, 'Value', get(handles.TogglebuttonContourCut, 'Min'));
    TogglebuttonContourCut_Callback(handles.TogglebuttonContourCut, [], handles);
    handles=guidata(handles.figure1);
    guidata(handles.figure1, handles);
    
    set(handles.TogglebuttonContourNudge, 'Value', get(handles.TogglebuttonContourNudge, 'Min'));
    TogglebuttonContourNudge_Callback(handles.TogglebuttonContourNudge, [], handles);
    handles=guidata(handles.figure1);
    guidata(handles.figure1, handles);
    
    %Display
    DisplayImage(handles);
    
    DisplayImageCor(handles);
    handles=guidata(handles.figure1);
    guidata(handles.figure1, handles);
    
    DisplayImageSag(handles);
    handles=guidata(handles.figure1);
    guidata(handles.figure1, handles);
    
else   
    hLine=findobj(handles.figure1, 'UserData', 'Cross');
    delete(hLine);
    
    set(handles.TextStatus, 'String', ' ', 'Visible', 'Off');
    drawnow;
end
   


% --- Executes on button press in PushbuttonExit.
function PushbuttonExit_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.DebugFlag < 1
    uiresume(handles.figure1);
else
    delete(handles.figure1);
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hint: delete(hObject) closes the figure
PushbuttonExit_Callback(handles.PushbuttonExit, eventdata, handles);


% --- Executes on selection change in PopupmenuWL.
function PopupmenuWL_Callback(hObject, eventdata, handles)
% hObject    handle to PopupmenuWL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopupmenuWL contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopupmenuWL

TempH=findobj(0, 'Type', 'figure', 'Name', 'Window/Level Tool');
if ~isempty(TempH)
    delete(TempH);
end

WLIndex=get(handles.PopupmenuWL, 'Value');
handles.GrayMin=handles.WLRegionMat(WLIndex, 2);
handles.GrayMax=handles.WLRegionMat(WLIndex, 3);

hImage=findobj(0, 'Type', 'Axes');
set(hImage, 'CLim', [handles.GrayMin, handles.GrayMax]);
guidata(handles.figure1, handles);

uicontrol(handles.FocusUI);


% --- Executes during object creation, after setting all properties.
function PopupmenuWL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopupmenuWL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in PushbuttonSave.
function PushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

SaveROIInWorkspace(handles);


% --- Executes on key release with focus on figure1 and none of its controls.
function figure1_KeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
KeyPressFcn_Callback(hObject, eventdata);



function [ColorLUTScale, SUVScale, TablePos]=GetImageScale(InfoFile)
ColorLUTScale=1;
SUVScale=1;

TextInfo=ReadPinnTextFileOri(InfoFile);

TempIndex=strmatch('ColorLUTScale', TextInfo);
if ~isempty(TempIndex)
    TempStr=TextInfo{TempIndex(1)};
    eval(TempStr);    
end

TempIndex=strmatch('SUVScale', TextInfo);
if ~isempty(TempIndex)
    TempStr=TextInfo{TempIndex(1)};
    eval(TempStr);    
end

TableIndex=strmatch('TablePosition', TextInfo);

TablePos=[];
for i=1:length(TableIndex)
    eval(char(TextInfo{TableIndex(i)}));
    TablePos=[TablePos; TablePosition];
end


function ImageInfo=UpdateImageProperty(DataFormat)

if ~isempty(DataFormat.XStartV9)
    ImageInfo.XStart=DataFormat.XStartV9;
    ImageInfo.StartV9=1;
else
    ImageInfo.XStart=DataFormat.XStartV8;
    ImageInfo.StartV9=0;
end

if ~isempty(DataFormat.YStartV9)
    ImageInfo.YStart=DataFormat.YStartV9;
    ImageInfo.StartV9=1;
else
    ImageInfo.YStart=DataFormat.YStartV8;
    ImageInfo.StartV9=0;
end


ImageInfo.XDim=DataFormat.XDim;
ImageInfo.YDim=DataFormat.YDim;
ImageInfo.ZDim=DataFormat.ZDim;

ImageInfo.ZStart=DataFormat.ZStart;

ImageInfo.XPixDim=DataFormat.XPixDim;
ImageInfo.YPixDim=DataFormat.YPixDim;

ImageInfo.TablePos=DataFormat.TablePos;
ImageInfo.ZPixDim=abs(ImageInfo.TablePos(1)-ImageInfo.TablePos(2));

XLimMin=ImageInfo.XStart;
XLimMax=ImageInfo.XDim*ImageInfo.XPixDim+ XLimMin;

ImageInfo.XLimMin=XLimMin;
ImageInfo.XLimMax=XLimMax;

YLimMin=ImageInfo.YStart;
YLimMax=ImageInfo.YDim*ImageInfo.YPixDim+YLimMin;

ImageInfo.YLimMin=YLimMin;
ImageInfo.YLimMax=YLimMax;

ImageInfo.ZLimMin=ImageInfo.TablePos(1);
ImageInfo.ZLimMax=ImageInfo.TablePos(end);

ImageInfo.ScaleValue=DataFormat.ColorLUTScale*DataFormat.SUVScale;


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Axial
CursorPos=get(handles.AxesImageAxial, 'CurrentPoint');

Data=[get(handles.AxesImageAxial, 'XLim'), get(handles.AxesImageAxial, 'YLim')];

CrossFlag=0;
if CursorPos(1)>=Data(1) && CursorPos(1)<=Data(2) && CursorPos(3)>=Data(3) && CursorPos(3)<=Data(4)
    CrossFlag=1;      
end

%Coronal
CursorPosCor=get(handles.AxesImageCor, 'CurrentPoint');
Data=[get(handles.AxesImageCor, 'XLim'), get(handles.AxesImageCor, 'YLim')];

CrossFlagCor=0;
if CursorPosCor(1)>=Data(1) && CursorPosCor(1)<=Data(2) && CursorPosCor(3)>=Data(3) && CursorPosCor(3)<=Data(4)
    CrossFlagCor=1;
end

%Sagittal
CursorPosSag=get(handles.AxesImageSag, 'CurrentPoint');
Data=[get(handles.AxesImageSag, 'XLim'), get(handles.AxesImageSag, 'YLim')];

CrossFlagSag=0;
if CursorPosSag(1)>=Data(1) && CursorPosSag(1)<=Data(2) && CursorPosSag(3)>=Data(3) && CursorPosSag(3)<=Data(4)
    CrossFlagSag=1;    
end


if (CrossFlag < 1) && (CrossFlagCor < 1) && (CrossFlagSag < 1)     
    return;
end

if CrossFlag > 0
    CurrentAxes=handles.AxesImageAxial;
end

if CrossFlagCor > 0
    CurrentAxes=handles.AxesImageCor;
end

if CrossFlagSag > 0
    CurrentAxes=handles.AxesImageSag;
end

ImageDataInfoAxial=GetImageDataInfo(handles, 'Axial');
ImageDataInfoCor=GetImageDataInfo(handles, 'Cor');
ImageDataInfoSag=GetImageDataInfo(handles, 'Sag');             

%Return if hit the imrect components
if isfield(handles, 'hRectAxial') && isa(handles.hRectAxial, 'imrect') && ...
        isequal(get(handles.TogglebuttonAutoSegBound, 'Value'),  get(handles.TogglebuttonAutoSegBound, 'Max'))
    
    CurrentObj=get(handles.figure1, 'CurrentObject');
    
    ObjTag=get(CurrentObj, 'Tag');
    if ~isempty(strmatch('minx', ObjTag)) || ~isempty(strmatch('miny', ObjTag))  || ...
            ~isempty(strmatch('maxx', ObjTag)) || ~isempty(strmatch('maxy', ObjTag))
        return;
    end   
end

%Ruler
if isequal(get(handles.TogglebuttonRuler, 'Value'), get(handles.TogglebuttonRuler, 'Max')) && ...
        isequal(get(handles.TogglebuttonZoom, 'Value'), get(handles.TogglebuttonZoom, 'Min'))
        
    handles.OldRulerPoint=[]; 
    
    handles=guidata(handles.figure1);

    set(0, 'Units', 'normalized');
    set(handles.figure1, 'Units', 'normalized');

    handles.TextDistanceStatus = 'New';
    handles.TextDistanceCycle='on';
    handles.OldRulerPoint=get(CurrentAxes, 'CurrentPoint');     
    
    hLine=findobj(CurrentAxes, 'Type', 'line');
    for i=1:length(hLine)
        if isequal(get(hLine(i), 'UserData'), 'Length')
            delete(hLine(i));
        end
    end    
        
end

%CT Num
if isequal(get(handles.TogglebuttonCTNum, 'Value'), get(handles.TogglebuttonCTNum, 'Max')) && ...
        isequal(get(handles.TogglebuttonZoom, 'Value'), get(handles.TogglebuttonZoom, 'Min'))
    
    %Get current axes image data
    hImage=findobj(CurrentAxes, 'Type', 'image');
    ImageData=get(hImage, 'CData');
            
    %Get image matrix Col or Row
    if CurrentAxes == handles.AxesImageAxial
        ScaleValue=ImageDataInfoAxial.ScaleValue;
        
        %Get current point in axes points
        CTPoint=CursorPos;    
        
        CTCol=(CTPoint(1)-ImageDataInfoAxial.XLimMin)/ImageDataInfoAxial.XPixDim+1; CTRow=(CTPoint(3)-ImageDataInfoAxial.YLimMin)/ImageDataInfoAxial.YPixDim+1;
    end
        
    
    if CurrentAxes == handles.AxesImageCor
        ScaleValue=ImageDataInfoCor.ScaleValue;
        
        CTPoint=CursorPosCor;    
        
        CTCol=(CTPoint(1)-ImageDataInfoCor.XLimMin)/ImageDataInfoCor.XPixDim+1; 
        CTRow=(CTPoint(3)-ImageDataInfoCor.ZLimMin)/ImageDataInfoCor.ZPixDim+1;        
    end
    
    if CurrentAxes == handles.AxesImageSag
        ScaleValue=ImageDataInfoSag.ScaleValue;
        
        CTPoint=CursorPosSag;       
                    
        CTCol=(CTPoint(1)-ImageDataInfoSag.YLimMin)/ImageDataInfoSag.YPixDim+1; 
        CTRow=(CTPoint(3)-ImageDataInfoSag.ZLimMin)/ImageDataInfoSag.ZPixDim+1;        
    end
    
    
    [RowNum, ColNum]=size(ImageData);
    CTRow=floor(CTRow+0.5); CTCol=floor(CTCol+0.5);
         
    if CTRow >= 1 && CTRow <= RowNum && CTCol >= 1 && CTCol <= ColNum
        CTValue=ImageData(CTRow, CTCol);
        
        TempStr=['Value= ',  sprintf('\n'),  num2str(double(CTValue)*ScaleValue)];
        set(handles.TextStatus, 'String', TempStr, 'Visible', 'On');
    else
        set(handles.TextStatus, 'String', 'Value= Invalid', 'Visible', 'On');
    end    
end

%Intersection 
if isequal(get(handles.TogglebuttonCross, 'Value'), get(handles.TogglebuttonCross, 'Max')) && ...
        isequal(get(handles.TogglebuttonZoom, 'Value'), get(handles.TogglebuttonZoom, 'Min')) && ...
        isequal(get(handles.TogglebuttonRuler, 'Value'), get(handles.TogglebuttonRuler, 'Min')) && ...
        isequal(get(handles.TogglebuttonCTNum, 'Value'), get(handles.TogglebuttonCTNum, 'Min'))  && ...
         ~((handles.ContourToolNudge == 1) || (handles.ContourToolCut == 1) || (handles.ContourToolDraw == 1) || (handles.ContourToolTrail == 1))
    
    hImage=findobj(CurrentAxes, 'Type', 'image');
    ImageData=get(hImage, 'CData');
    
    [RowNum, ColNum]=size(ImageData);
    
     %Get image matrix Col or Row
    if CurrentAxes == handles.AxesImageAxial
        %Get current point in axes points
        CTPoint=CursorPos;        
        CTCol=(CTPoint(1)-ImageDataInfoSag.XLimMin)/ImageDataInfoSag.XPixDim+1; 
        CTRow=(CTPoint(3)-ImageDataInfoCor.YLimMin)/ImageDataInfoCor.YPixDim+1;
    end
        
    
    if CurrentAxes == handles.AxesImageCor
        CTPoint=CursorPosCor;           
             
        CTCol=(CTPoint(1)-ImageDataInfoSag.XLimMin)/ImageDataInfoSag.XPixDim+1; 
        CTRow=(CTPoint(3)-ImageDataInfoAxial.ZLimMin)/ImageDataInfoAxial.ZPixDim+1;        
    end
    
    if CurrentAxes == handles.AxesImageSag
        CTPoint=CursorPosSag;      
        
        CTCol=(CTPoint(1)-ImageDataInfoCor.YLimMin)/ImageDataInfoCor.YPixDim+1; 
        CTRow=(CTPoint(3)-ImageDataInfoAxial.ZLimMin)/ImageDataInfoAxial.ZPixDim+1;        
    end
    
    CTCol=round(CTCol); CTRow=round(CTRow);
    
    if CTCol < 1
        CTCol=1;
    end
    
    
    if CTRow < 1
        CTRow=1;
    end
    
    if CurrentAxes == handles.AxesImageAxial
        if CTCol > ImageDataInfoSag.XDim
            CTCol=ImageDataInfoSag.XDim;
        end
        
        if CTRow > ImageDataInfoCor.YDim
            CTRow=ImageDataInfoCor.YDim;
        end
    
         handles.SliceNumSag=CTCol;
         handles.SliceNumCor=CTRow;
     end
     
     if CurrentAxes == handles.AxesImageCor
         if CTCol > ImageDataInfoSag.XDim
            CTCol=ImageDataInfoSag.XDim;
        end
        
        if CTRow > ImageDataInfoAxial.ZDim
            CTRow= ImageDataInfoAxial.ZDim;
        end
         handles.SliceNumSag=CTCol;
         handles.SliceNum=CTRow;
     end
     
     if CurrentAxes == handles.AxesImageSag
         if CTCol > ImageDataInfoCor.YDim
             CTCol=ImageDataInfoCor.YDim;
         end
         
        if CTRow > ImageDataInfoAxial.ZDim
            CTRow= ImageDataInfoAxial.ZDim;
        end
        
         handles.SliceNumCor=CTCol;
         handles.SliceNum=CTRow;
     end
     
     guidata(handles.figure1, handles);     
     
     DisplayImage(handles);
     
     DisplayImageCor(handles);
     handles=guidata(handles.figure1);
     guidata(handles.figure1, handles);
     
     
     DisplayImageSag(handles);
     handles=guidata(handles.figure1);
     guidata(handles.figure1, handles);
     
end

guidata(handles.figure1, handles);

%Contour Editing---Axial Only
if  (CrossFlag>0) && ((handles.ContourToolNudge == 1) || (handles.ContourToolCut == 1) || (handles.ContourToolDraw == 1) ...
        || (handles.ContourToolTrail == 1))...
        && (CurrentAxes == handles.AxesImageAxial) && ...
        isequal(get(handles.TogglebuttonZoom, 'Value'), get(handles.TogglebuttonZoom, 'Min'))
    
    handles.ContourEditFlag=1;
    
    handles.SelectAxis=handles.AxesImageAxial;  
    
    %--Contour Cut
    if handles.ContourToolCut == 1
        handles.CutStartPoint=get(handles.AxesImageAxial, 'CurrentPoint');
        handles.CutEndPoint=handles.CutStartPoint;
        
        guidata(handles.figure1, handles);
    end
    
    %--Contour Nudge
    if handles.ContourToolNudge == 1        
        DrawNudgeContour(handles);
        
        DecideNudgeInsideOutside(handles);
        handles=guidata(handles.figure1);
        guidata(handles.figure1, handles);       
    end
    
    %--Contour trial
    if handles.ContourToolTrail == 1
        Color=get(handles.PushbuttonROIColor, 'BackgroundColor');
        
        handles.ContourFirstPoint=get(handles.SelectAxis, 'CurrentPoint');
        handles.ContourPrevPoint=handles.ContourFirstPoint;     %For Contour drawing
        handles.ContourNextPoint=handles.ContourFirstPoint;
        
        handles.ContourPoint=1;
        
        %Draw line
        plot(handles.SelectAxis, [handles.ContourPrevPoint(1),handles.ContourNextPoint(1)], ...
            [handles.ContourPrevPoint(3),handles.ContourNextPoint(3)], ...
            'Color', Color, 'LineWidth', 1.5, 'UserData', 'ContourNudge');
       
               
          guidata(handles.figure1, handles);     
    end
    
    %--Contour Draw
    if handles.ContourToolDraw == 1
        
        handles.ContourModifyFlag=1;
        
        Color=get(handles.PushbuttonROIColor, 'BackgroundColor');

        if isempty(handles.ContourFirstPoint)
            %Intialize
            handles.ContourFirstPoint=get(handles.SelectAxis, 'CurrentPoint');
            handles.ContourPrevPoint=handles.ContourFirstPoint;     %For Contour drawing
            handles.ContourNextPoint=handles.ContourFirstPoint;
                        
            handles.ContourPoint=1;
            
            %Draw line  
            plot(handles.SelectAxis, [handles.ContourPrevPoint(1),handles.ContourNextPoint(1)], ...
                [handles.ContourPrevPoint(3),handles.ContourNextPoint(3)], ...
                'Color', Color, 'LineWidth', 1.5, 'UserData', 'ContourNudge', 'Marker', 's', 'MarkerSize', 9);
        else
            if gca == handles.SelectAxis
                %Update
                handles.ContourNextPoint=get(handles.SelectAxis, 'CurrentPoint');
                handles.ContourPoint=handles.ContourPoint+1;
                
                XPos1=handles.ContourPrevPoint(1); YPos1=handles.ContourPrevPoint(3);
                XPos2=handles.ContourNextPoint(1); YPos2=handles.ContourNextPoint(3);
                
                %Draw line       
                plot(handles.SelectAxis, [handles.ContourPrevPoint(1),handles.ContourNextPoint(1)], ...
                    [handles.ContourPrevPoint(3),handles.ContourNextPoint(3)], ...
                     'Color', Color, 'LineWidth', 1.5, 'UserData', 'ContourNudge', 'Marker', 's', 'MarkerSize', 9);
                 
                 %Update
                handles.ContourPrevPoint=handles.ContourNextPoint;

                %Close Curve
                if ((handles.ContourPoint >=3) && ...
                        (sqrt((XPos2-handles.ContourFirstPoint(1))^2+(YPos2-handles.ContourFirstPoint(3))^2) < 2*ImageDataInfoAxial.XPixDim)) || ...
                        isequal(get(handles.figure1, 'SelectionType'), 'alt')
                    
                    plot(handles.SelectAxis, handles.ContourNextPoint(1), ...
                        handles.ContourNextPoint(3), ...
                        'Color', Color, 'LineWidth', 1.5, 'UserData', 'ContourNudge', 'Marker', 's', 'MarkerSize', 9);
                    
                    %First: Update strucatAxialROI----Axial                    
                    ContourDrawUpdateStructAxialROI(handles);                    
                    handles=guidata(handles.figure1);
                    guidata(handles.figure1, handles);
                    
                    %Second: Update Binary Mask----Coronal and Sagittal                
                    ContourEditUpdateBinaryMask(handles);
                    handles=guidata(handles.figure1);
                    guidata(handles.figure1, handles);
                
                    
                    %Last: Update display
                    RowIndex=get(handles.PopupmenuROIName, 'Value')-1;
                    OffOnUserROI(handles, RowIndex, 'Off');
                    OffOnUserROI(handles, RowIndex, 'On');
                    
                    handles=guidata(handles.figure1);
                    guidata(handles.figure1, handles);
                end
                
            end  %gca == handles.SelectAxis

        end
            guidata(handles.figure1, handles);    
    end
    
    guidata(handles.figure1, handles);    
end



% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.figure1, 'Pointer', 'arrow');

%Axial
CursorPos=get(handles.AxesImageAxial, 'CurrentPoint');
Data=[get(handles.AxesImageAxial, 'XLim'), get(handles.AxesImageAxial, 'YLim')];

CrossFlag=0;
if CursorPos(1)>=Data(1) && CursorPos(1)<=Data(2) && CursorPos(3)>=Data(3) && CursorPos(3)<=Data(4)
    CrossFlag=1;      
end

%Coronal
CursorPosCor=get(handles.AxesImageCor, 'CurrentPoint');
Data=[get(handles.AxesImageCor, 'XLim'), get(handles.AxesImageCor, 'YLim')];

CrossFlagCor=0;
if CursorPosCor(1)>=Data(1) && CursorPosCor(1)<=Data(2) && CursorPosCor(3)>=Data(3) && CursorPosCor(3)<=Data(4)
    CrossFlagCor=1;
end

%Sagittal
CursorPosSag=get(handles.AxesImageSag, 'CurrentPoint');
Data=[get(handles.AxesImageSag, 'XLim'), get(handles.AxesImageSag, 'YLim')];

CrossFlagSag=0;
if CursorPosSag(1)>=Data(1) && CursorPosSag(1)<=Data(2) && CursorPosSag(3)>=Data(3) && CursorPosSag(3)<=Data(4)
    CrossFlagSag=1;    
end


if (CrossFlag < 1) && (CrossFlagCor < 1) && (CrossFlagSag < 1)      
    set(handles.figure1, 'Pointer', 'arrow');
    return;
else
    if isequal(get(handles.TogglebuttonZoom, 'Value'),  get(handles.TogglebuttonZoom, 'Max'))
        set(handles.figure1, 'Pointer', 'fleur');
    else
        set(handles.figure1, 'Pointer', 'crosshair');
    end
end


if CrossFlag > 0
    CurrentAxes=handles.AxesImageAxial;
    try
        if ((handles.ContourToolNudge==1) || (handles.ContourToolCut== 1) || (handles.ContourToolDraw==1) || (handles.ContourToolTrail==1))
            set(handles.figure1,'Pointer','custom', 'PointerShapeCData', handles.ContourCursor, 'PointerShapeHotSpot', [3 3]);
        end
    catch
    end
end

if CrossFlagCor > 0
    CurrentAxes=handles.AxesImageCor;
end

if CrossFlagSag > 0
    CurrentAxes=handles.AxesImageSag;
end

%Return if hit the imrect components
if isfield(handles, 'hRectAxial') && isa(handles.hRectAxial, 'imrect') && ...
        isequal(get(handles.TogglebuttonAutoSegBound, 'Value'),  get(handles.TogglebuttonAutoSegBound, 'Max'))
   
    if CrossFlag > 0 || isequal(get(handles.hRectAxial, 'Visible'), 'On') || isequal(get(handles.hRectAxial, 'Visible'), 'on')
        return;
    end  
    
    if CrossFlagCor > 0 || isequal(get(handles.hRectCor, 'Visible'), 'On') || isequal(get(handles.hRectCor, 'Visible'), 'on')
        return;
    end  
    
    if CrossFlagSag > 0 || isequal(get(handles.hRectSag, 'Visible'), 'On') || isequal(get(handles.hRectSag, 'Visible'), 'on')
        return;
    end      
end


%Distance
if isequal(get(handles.TogglebuttonRuler, 'Value'), get(handles.TogglebuttonRuler, 'Max')) && ...
        ~isempty(handles.OldRulerPoint) && isequal(handles.TextDistanceCycle, 'on') && ...
        isequal(get(handles.TogglebuttonZoom, 'Value'), get(handles.TogglebuttonZoom, 'Min'))
    
    set(handles.TextStatus, 'Visible', 'on');
    
    handles.NewRulerPoint=get(CurrentAxes, 'CurrentPoint');
    DistX=handles.NewRulerPoint(1)-handles.OldRulerPoint(1);
    DistY=handles.NewRulerPoint(3)-handles.OldRulerPoint(3);
    Dist=sqrt(DistX^2+DistY^2);
    
    if isequal(handles.TextDistanceStatus, 'New')
        handles.TextDistanceStatus='Old';
        
        if isequal(get(handles.TogglebuttonRuler, 'Value'), get(handles.TogglebuttonRuler, 'Max'))
            TempStr=sprintf('%.3f', Dist);
            set(handles.TextStatus, 'String', ['Dist.= ', sprintf('\n'), TempStr, 'cm'], 'Visible', 'on');
        end
        
        plot(CurrentAxes, [handles.OldRulerPoint(1), handles.NewRulerPoint(1)], [handles.OldRulerPoint(3), handles.NewRulerPoint(3)], ...
            'Color', [1,0,0], 'LineWidth', 2, 'UserData', 'Length');
   else
        %Update distance text content
        if isequal(get(handles.TogglebuttonRuler, 'Value'), get(handles.TogglebuttonRuler, 'Max'))
            TempStr=sprintf('%.3f', Dist);
            set(handles.TextStatus, 'String', ['Dist.= ', sprintf('\n'), TempStr, 'cm'], 'Visible', 'on');
        end        
        
        %Update line
        hLine=findobj(CurrentAxes, 'Type', 'line');
        for i=1:length(hLine)
            if isequal(get(hLine(i), 'UserData'), 'Length')
                set(hLine(i), 'XData', [handles.OldRulerPoint(1), handles.NewRulerPoint(1)], ...
                    'YData', [handles.OldRulerPoint(3), handles.NewRulerPoint(3)]);
            end
        end
    end
    
    guidata(handles.figure1, handles);
end

%-----------------------Contour Editting--------------------------------
try
    %Contour Editting---Cut
    if (handles.ContourToolCut == 1)&& (CrossFlag == 1)
        
        %Reset Contour Nudge
        ResetContourNudge(handles);
        handles=guidata(handles.figure1);
        guidata(handles.figure1, handles);
        
        handles.SelectAxis=handles.AxesImageAxial;
        
        %Draw Cut Indication Rectangle
        if (handles.ContourEditFlag == 1)
            %Get  End Point
            if gca == handles.SelectAxis
                handles.CutEndPoint=get(gca, 'CurrentPoint');
                
                hLine=findobj(handles.SelectAxis, 'Type', 'Line', 'UserData', 'ContourNudge');
                delete(hLine);
            end
            
            XPos1=handles.CutStartPoint(1); YPos1=handles.CutStartPoint(3);
            XPos2=handles.CutEndPoint(1); YPos2=handles.CutEndPoint(3);
            
            plot(handles.SelectAxis, [min(XPos1, XPos2), max(XPos1, XPos2), max(XPos1, XPos2), min(XPos1, XPos2), min(XPos1, XPos2)], ...
                [min(YPos1, YPos2), min(YPos1, YPos2), max(YPos1, YPos2), max(YPos1, YPos2), min(YPos1, YPos2)], 'Color', 'r', 'LineWidth', 1, ...
                'UserData', 'ContourNudge');
            
            %Update others
            guidata(handles.figure1, handles);
        end
    end
    
    %Contour Editting---Trail
    if (handles.ContourToolTrail == 1) && (CrossFlag == 1)
        if (handles.ContourEditFlag == 1)
            %Update
            handles.ContourNextPoint=get(handles.SelectAxis, 'CurrentPoint');
            handles.ContourPoint=handles.ContourPoint+1;
            
            XPos1=handles.ContourPrevPoint(1); YPos1=handles.ContourPrevPoint(3);
            XPos2=handles.ContourNextPoint(1); YPos2=handles.ContourNextPoint(3);
            
            %Draw line
            Color=get(handles.PushbuttonROIColor, 'BackgroundColor');
            plot(handles.SelectAxis, [handles.ContourPrevPoint(1),handles.ContourNextPoint(1)], ...
                [handles.ContourPrevPoint(3),handles.ContourNextPoint(3)], ...
                'Color', Color, 'LineWidth', 1.5, 'UserData', 'ContourNudge');
            
            %Update
            handles.ContourPrevPoint=handles.ContourNextPoint;
            
            guidata(handles.figure1, handles);
        end
    end
    
    %Contour Editting---Nudge
    if (handles.ContourToolNudge == 1) && (CrossFlag == 1)
        
        %Reset Contour Nudge
        ResetContourNudge(handles);
        handles=guidata(handles.figure1);
        guidata(handles.figure1, handles);
        
        %Draw New Circle
        CursorPos=get(handles.AxesImageAxial, 'CurrentPoint');
        
        TempX=[handles.NudgeHalfX, fliplr(handles.NudgeHalfX)]+CursorPos(1)-max(handles.NudgeHalfX);
        TempY=[handles.NudgeHalfY, -handles.NudgeHalfY]+CursorPos(3)+max(handles.NudgeHalfY);
        
        %Plot Circle
        plot(handles.AxesImageAxial, TempX, TempY, 'r', 'UserData', 'ContourNudge');
        
        %Update contour curves
        if (handles.ContourEditFlag == 1) && (handles.ContourModifyFlag == 1) && ~isempty(handles.ContourNudgeInside)
            
            UpdateCurrentROIMask(handles);
            handles=guidata(handles.figure1);
            guidata(handles.figure1, handles);
            
            UpdateDisplayFromMask(handles);
        end
        
    end
catch
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%----------------------Distance Meansurement-----------------------------%
if isequal(get(handles.TogglebuttonRuler, 'Value'), get(handles.TogglebuttonRuler, 'Max'))       
    
    handles.TextDistanceStatus ='New';
    handles.TextDistanceCycle='off';
    guidata(hObject, handles);    
    
    hLine=findobj(handles.figure1, 'UserData', 'Length');
    delete(hLine);
    
    set(handles.TextStatus, 'String', '', 'Visible', 'Off');
end

if isequal(get(handles.TogglebuttonCTNum, 'Value'), get(handles.TogglebuttonCTNum, 'Max'))   
    
    set(handles.TextStatus, 'String', '', 'Visible', 'Off');
end

%-----------------------------------------Edit--------------------------------------%
if handles.ContourEditFlag == 1
   
    if handles.ContourToolNudge == 1  
        %For handle no motion mouse release event
        figure1_WindowButtonMotionFcn(handles.figure1, [], handles);
        handles=guidata(handles.figure1);
        guidata(handles.figure1, handles);
        
        handles.ContourNudgeInside=[];

        if handles.ContourModifyFlag == 1    
            
            %Remove hole When nudge draw on empty slice
            Flag=MaskSliceCurrentValid(handles);          
            
            if Flag < 1
                handles.CurrentBinary.MaskData=imfill(handles.CurrentBinary.MaskData, 'holes');
                UpdateDisplayFromMask(handles);
                guidata(handles.figure1, handles);
            end            
                                    
            %Update StructAxialROI
            ContourNudgeUpdateStructAxialROI(handles);
            handles=guidata(handles.figure1);
            guidata(handles.figure1, handles);           
           
             %Update BinaryMask
            ContourEditUpdateBinaryMask(handles);
            handles=guidata(handles.figure1);
            guidata(handles.figure1, handles);
            
            %Update Display
            RowIndex=get(handles.PopupmenuROIName, 'Value')-1;
            OffOnUserROI(handles, RowIndex, 'Off');
            OffOnUserROI(handles, RowIndex, 'On');              
            
            handles=guidata(handles.figure1);
            guidata(handles.figure1, handles);
            
            handles.ContourModifyFlag =0;
        end   
        
        guidata(handles.figure1, handles);     
    end

    
    %-----------Contour Cut-------
    if handles.ContourToolCut ==1
        %Update StructAxialROI
        ContourCutUpdateStructAxialROI(handles);
        handles=guidata(handles.figure1);
        guidata(handles.figure1, handles);

        %Update BinaryMask
        ContourEditUpdateBinaryMask(handles);
        handles=guidata(handles.figure1);
        guidata(handles.figure1, handles);
        
        %Update Display
        RowIndex=get(handles.PopupmenuROIName, 'Value')-1;
        OffOnUserROI(handles, RowIndex, 'Off');
        OffOnUserROI(handles, RowIndex, 'On');
        
        handles=guidata(handles.figure1);
        guidata(handles.figure1, handles);     
    end  %handles.ContourToolCut ==1
    
    
    %-----------Contour Cut-------
    if handles.ContourToolTrail ==1
        Color=get(handles.PushbuttonROIColor, 'BackgroundColor');
        plot(handles.AxesImageAxial, [handles.ContourNextPoint(1), handles.ContourFirstPoint(1)],...
            [handles.ContourNextPoint(3), handles.ContourFirstPoint(3)], ...
            'Color', Color, 'LineWidth', 1.5,  'UserData', 'ContourNudge');       
        
        %First: Update strucatAxialROI----Axial
        ContourDrawUpdateStructAxialROI(handles);
        handles=guidata(handles.figure1);
        guidata(handles.figure1, handles);
        
        %Second: Update Binary Mask----Coronal and Sagittal
        ContourEditUpdateBinaryMask(handles);
        handles=guidata(handles.figure1);
        guidata(handles.figure1, handles);
        
        
        %Last: Update display
        RowIndex=get(handles.PopupmenuROIName, 'Value')-1;
        OffOnUserROI(handles, RowIndex, 'Off');
        OffOnUserROI(handles, RowIndex, 'On');
        
        handles=guidata(handles.figure1);
        guidata(handles.figure1, handles);
    end
   
     handles.ContourEditFlag=0;     
end
                      
guidata(handles.figure1, handles);


% --- Executes when entered data in editable cell(s) in UITableROI.
function UITableROI_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to UITableROI (see GCBO)
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

if isfield(eventdata, 'UserTable')
    TableHandle=handles.UITableROIUser;
    UserTable=1;
else
    TableHandle=handles.UITableROI;
    UserTable=0;
end

%ROI display
if isequal(rem(ColumnIndex, 4), 1)
    
    TableData=get(TableHandle, 'Data');
    
    %Update ROI display
    SelectValue=TableData{RowIndex, ColumnIndex};       
    
    if SelectValue > 0       
        DisplayContourOff(RowIndex, ColumnIndex, TableData, handles, UserTable);  
        
        DisplayContourOn(RowIndex, ColumnIndex, TableData, handles, 'Axial', UserTable);
        
        ROIMode=get(handles.UIButtonGroupPanel, 'SelectedObject');
        if ROIMode == handles.RadiobuttonROIModePoly
            DisplayContourOn(RowIndex, ColumnIndex, TableData, handles, 'Cor', UserTable);
            handles=guidata(handles.figure1);
            guidata(handles.figure1, handles);
            
            DisplayContourOn(RowIndex, ColumnIndex, TableData, handles, 'Sag', UserTable);
            handles=guidata(handles.figure1);
            guidata(handles.figure1, handles);
        end
        
        %Update Current ROI
        UpdateCurrentROIInfo(RowIndex, ColumnIndex, TableData, handles, UserTable);
    else
        DisplayContourOff(RowIndex, ColumnIndex, TableData, handles, UserTable);  
        
        %Update Current ROI
        if UserTable < 1
            PlanName=GetPlanNameFromTableHeader(handles.UITableROI, ColumnIndex);
        else
            PlanName='User';
        end
        
        PlanNameList=get(handles.PopupmenuPlanName, 'String');
        PlanNameValue=get(handles.PopupmenuPlanName, 'Value');
        CurrentPlan=PlanNameList{PlanNameValue};
        
        ROIName=TableData{RowIndex, ColumnIndex+1};
        
        ROINameList=get(handles.PopupmenuROIName, 'String');
        ROINameValue=get(handles.PopupmenuROIName, 'Value');
        CurrentROI=ROINameList{ROINameValue};
                
        if isequal(PlanName, CurrentPlan) && isequal(ROIName, CurrentROI)
            SetEditUIOnOff(handles, 'Off');
        end        
    end
    
    %Set AutoSeg Status   
    SetAutoSegStatus(handles);
    handles=guidata(handles.figure1);
    guidata(handles.figure1, handles);
  
end

%ROI Name
if isequal(rem(ColumnIndex, 4), 0)
    ColumnIndexUpdate=ColumnIndex-3;
    
    TableData=get(TableHandle, 'Data');
    SelectValue=TableData{RowIndex, ColumnIndexUpdate};
    
    if SelectValue > 0
        TableData=get(TableHandle, 'Data');
        
        DisplayContourOff(RowIndex, ColumnIndexUpdate, TableData, handles, UserTable);
        DisplayContourOn(RowIndex, ColumnIndexUpdate, TableData, handles, 'Axial', UserTable);
        
        ROIMode=get(handles.UIButtonGroupPanel, 'SelectedObject');
        if ROIMode == handles.RadiobuttonROIModePoly
            DisplayContourOn(RowIndex, ColumnIndexUpdate, TableData, handles, 'Cor', UserTable);
            handles=guidata(handles.figure1);
            guidata(handles.figure1, handles);
            
            DisplayContourOn(RowIndex, ColumnIndexUpdate, TableData, handles, 'Sag', UserTable);
            handles=guidata(handles.figure1);
            guidata(handles.figure1, handles);
        end
    end       
    
end




% --- Executes when selected cell(s) is changed in UITableROI.
function UITableROI_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to UITableROI (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)


if isempty(eventdata.Indices)
    return;
end

if isfield(eventdata, 'UserTable')
    TableHandle=handles.UITableROIUser;
    UserTable=1;
else
    TableHandle=handles.UITableROI;
    UserTable=0;
end

RowIndex=eventdata.Indices(1);
ColumnIndex=eventdata.Indices(2);

%Change Color
if isequal(rem(ColumnIndex, 4), 3)
    TableData=get(TableHandle, 'Data');
    
    ColorCell=TableData{RowIndex, ColumnIndex};
    
    if isempty(ColorCell)
        return;
    end

    OldColor=GetColorFromHtml(ColorCell)/255;
    
    NewColor=uisetcolor(OldColor);
    
    if ~isequal(NewColor, 0)
        WinColor=round(NewColor*255);
        
        ColorCell=...
            ['<html><body bgcolor="rgb(', num2str(WinColor(1)),',' num2str(WinColor(2)), ',', num2str(WinColor(3)), ...
            ')">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp</body></html>'];
        
        %Table
        switch UserTable
            case 0
                handles.jUITableROI.setValueAt(ColorCell, RowIndex-1, ColumnIndex-1);
            case 1
                handles.jUITableROIUser.setValueAt(ColorCell, RowIndex-1, ColumnIndex-1);
        end
        
        pause(handles.TableSetValuePause);
        
        drawnow;
        
        ColumnIndexUpdate=ColumnIndex-2;
        
        SelectValue=TableData{RowIndex, ColumnIndexUpdate};
        
        if SelectValue > 0
            TableData=get(TableHandle, 'Data');
            
            DisplayContourOff(RowIndex, ColumnIndexUpdate, TableData, handles, UserTable);
            DisplayContourOn(RowIndex, ColumnIndexUpdate, TableData, handles, 'Axial', UserTable);
            
            ROIMode=get(handles.UIButtonGroupPanel, 'SelectedObject');
            if ROIMode == handles.RadiobuttonROIModePoly
                DisplayContourOn(RowIndex, ColumnIndexUpdate, TableData, handles, 'Cor', UserTable);
                handles=guidata(handles.figure1);
                guidata(handles.figure1, handles);
                
                DisplayContourOn(RowIndex, ColumnIndexUpdate, TableData, handles, 'Sag', UserTable);
                handles=guidata(handles.figure1);
                guidata(handles.figure1, handles);
            end
        end
        
        %Update Current ROI
        if UserTable < 1
            PlanName=GetPlanNameFromTableHeader(handles.UITableROI, ColumnIndex-2);
        else
            PlanName='User';
        end
        
        PlanNameList=get(handles.PopupmenuPlanName, 'String');
        PlanNameValue=get(handles.PopupmenuPlanName, 'Value');
        CurrentPlan=PlanNameList{PlanNameValue};
        
        TableData=get(TableHandle, 'Data');
        ROIName=TableData{RowIndex, ColumnIndex-1};
        
        ROINameList=get(handles.PopupmenuROIName, 'String');
        ROINameValue=get(handles.PopupmenuROIName, 'Value');
        CurrentROI=ROINameList{ROINameValue};
                
        if isequal(PlanName, CurrentPlan) && isequal(ROIName, CurrentROI)
            set(handles.PushbuttonROIColor, 'BackgroundColor', NewColor);
        end
    end    
end



% --- Executes on button press in PushbuttonDeleteROI.
function PushbuttonDeleteROI_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonDeleteROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Answer = QuestdlgIFOA('The current user ROIs will be deleted! Continue?', 'Confirm','Continue','Cancel', 'Continue');
if ~isequal(Answer, 'Continue')
    return;
end

TableData=get(handles.UITableROIUser, 'Data');
if isempty(TableData)
    return;
end

SelectIndex=get(handles.PopupmenuROIName, 'Value')-1;

%Delete selected ROIs
ROINameT=TableData(SelectIndex, 2);
TableData(SelectIndex, :)=[];

PlanIndex=find(handles.PlansInfo.PlanIDList==99999);

structAxialROI=handles.PlansInfo.structAxialROI{PlanIndex};
structAxialROI(SelectIndex)=[];
handles.PlansInfo.structAxialROI{PlanIndex}=structAxialROI;

guidata(handles.figure1,handles);

set(handles.UITableROIUser, 'Data', TableData);

%Delete Binary Mask
for i=1:length(ROINameT)
    ROIPlanStr={handles.BWMatInfo.ROINamePlanIndex}';
    BWMatIndex=strmatch([deblank(ROINameT{i}), num2str(PlanIndex)], ROIPlanStr, 'exact');
    
    if ~isempty(BWMatIndex)
        handles.BWMatInfo(BWMatIndex)=[];
        guidata(handles.figure1,handles);
    end
end

%Update display
PushbuttonOffAllROIs_Callback(handles.PushbuttonOffAllROIs, [], handles);
pause(handles.TableSetValuePauseEdit);

SelectMat=cell2mat(TableData(:, 1));

SelectIndex=find(SelectMat > 0);
if ~isempty(SelectIndex)
    for i=1:length(SelectIndex)
        handles.jUITableROIUser.setValueAt(true, SelectIndex(i)-1, 0);
        pause(handles.TableSetValuePause);  
                
        handles=guidata(handles.figure1);
        guidata(handles.figure1, handles);
    end
end

%Reset Edit tools
pause(handles.TableSetValuePauseEdit);
SetEditUIOnOff(handles, 'Off');




% --- Executes when entered data in editable cell(s) in UITableROIUser.
function UITableROIUser_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to UITableROIUser (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


RowIndex=eventdata.Indices(1);
ColumnIndex=eventdata.Indices(2);

if ColumnIndex ~= 2         
    eventdataNew.Indices=eventdata.Indices;
    eventdataNew.UserTable=1;
    UITableROI_CellEditCallback(hObject, eventdataNew, handles);        
    return;
end

%Modify ROI Name
structAxialROI=handles.PlansInfo.structAxialROI{end};
ROIName=structAxialROI(RowIndex).name;

TableData=get(handles.UITableROIUser, 'Data');
if TableData{RowIndex, 1} > 0
    UserTable=1;
    
    %Old Table Data
    TableData{RowIndex, ColumnIndex}=ROIName;
    DisplayContourOff(RowIndex, ColumnIndex-1, TableData, handles, UserTable);        
    
    %Updated Table Data
    TableData=get(handles.UITableROIUser, 'Data');
    
    %Update structAxialROI name
    NewROIName=TableData{RowIndex, ColumnIndex};
    structAxialROI(RowIndex).name=NewROIName;
    handles.PlansInfo.structAxialROI{end}=structAxialROI;
    
    %Update BWMat
    if ~isempty(handles.BWMatInfo)
        PlanIndex=length(handles.PlansInfo.PlanNameStr);
        
        ROIPlanStr={handles.BWMatInfo.ROINamePlanIndex}';
        
        BWMatIndex=strmatch([deblank(ROIName), num2str(PlanIndex)], ROIPlanStr, 'exact');
        
        if ~isempty(BWMatIndex)
            handles.BWMatInfo(BWMatIndex).ROINamePlanIndex=[deblank(NewROIName), num2str(PlanIndex)];
        end
    end
    
    guidata(handles.figure1, handles);
    
    %Update contour display
    DisplayContourOn(RowIndex, ColumnIndex-1, TableData, handles, 'Axial', UserTable);
    
    ROIMode=get(handles.UIButtonGroupPanel, 'SelectedObject');
    if ROIMode == handles.RadiobuttonROIModePoly
        DisplayContourOn(RowIndex, ColumnIndex-1, TableData, handles, 'Cor', UserTable);
        handles=guidata(handles.figure1);
        guidata(handles.figure1, handles);
        
        DisplayContourOn(RowIndex, ColumnIndex-1, TableData, handles, 'Sag', UserTable);
        handles=guidata(handles.figure1);
        guidata(handles.figure1, handles);
    end
end


%Update Current ROI Info
PlanNameValue=get(handles.PopupmenuPlanName, 'Value');
ROINameValue=get(handles.PopupmenuROIName, 'Value');

if PlanNameValue >1
    %Update ROI List
    PopupmenuPlanName_Callback(handles.PopupmenuPlanName, [], handles);
    
    set(handles.PopupmenuPlanName, 'Value', PlanNameValue);
    set(handles.PopupmenuROIName, 'Value', ROINameValue);
    PopupmenuROIName_Callback(handles.PopupmenuROIName, [], handles);
end



% --- Executes when selected cell(s) is changed in UITableROIUser.
function UITableROIUser_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to UITableROIUser (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
eventdataNew.Indices=eventdata.Indices;
eventdataNew.UserTable=1;

UITableROI_CellSelectionCallback(hObject, eventdataNew, handles)


% --- Executes on button press in PushbuttonOffAllROIs.
function PushbuttonOffAllROIs_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonOffAllROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Off ROI display
ContourOffAll(handles, 'Axial');
ContourOffAll(handles, 'Cor');
ContourOffAll(handles, 'Sag');

%Off ROI table display
for i=1:2
    switch i
        case 1
            TableHandle=handles.UITableROI;
        case 2
            TableHandle=handles.UITableROIUser;
    end
    
    TableData=get(TableHandle, 'Data');
    
    if isempty(TableData)
        continue;
    end
    
    TableDataIndex=cellfun(@IsTrueCell, TableData);
    
    TempIndex=find(TableDataIndex);
    if ~isempty(TempIndex)
        TableData(TempIndex)={false};
        
        set(TableHandle, 'Data', TableData);
    end
end

%Update Current ROI
SetEditUIOnOff(handles, 'Off');


% --- Executes when selected object is changed in UIButtonGroupPanel.
function UIButtonGroupPanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in UIButtonGroupPanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

%Off ROI table display
for i=1:2
    
    if i< 2
        TableHandle=handles.UITableROI;
        UserTable=0;
    else
        TableHandle=handles.UITableROIUser;
        UserTable=1;
    end
    
    TableData=get(TableHandle, 'Data');
    
    if isempty(TableData)
        continue;
    end
    
    TableDataIndex=cellfun(@IsTrueCell, TableData);
    
    [RowIndexT, ColumnIndexT]=find(TableDataIndex);
    if ~isempty(RowIndexT)
        for j=1:length(RowIndexT)
            RowIndex=RowIndexT(j);
            ColumnIndex=ColumnIndexT(j);
            
            DisplayContourOff(RowIndex, ColumnIndex, TableData, handles, UserTable);
            
            DisplayContourOn(RowIndex, ColumnIndex, TableData, handles, 'Axial', UserTable);
            
            ROIMode=get(handles.UIButtonGroupPanel, 'SelectedObject');
            if ROIMode == handles.RadiobuttonROIModePoly
                DisplayContourOn(RowIndex, ColumnIndex, TableData, handles, 'Cor', UserTable);
                handles=guidata(handles.figure1);
                guidata(handles.figure1, handles);
                
                DisplayContourOn(RowIndex, ColumnIndex, TableData, handles, 'Sag', UserTable);
                handles=guidata(handles.figure1);
                guidata(handles.figure1, handles);
            end
        end
    end
end


function OnFlag=PrepareContourTool(hObject, handles)
if isequal(get(hObject, 'Value'), get(hObject, 'Max'))    
    PlanList=get(handles.PopupmenuPlanName, 'String');
    PlanValue=get(handles.PopupmenuPlanName, 'Value');
    
    if PlanValue < length(PlanList)
        Answer = QuestdlgIFOA('To edit, the current ROI will be copied to User plan first. Continue?', 'Confirm','Continue','Cancel', 'Continue');
        if ~isequal(Answer, 'Continue')
            OnFlag=-1;
            set(hObject, 'Value', get(hObject, 'Min'));
            return;
        end      
        
        PushbuttonContourCopy_Callback(handles.PushbuttonContourCopy, [], handles);  
        handles=guidata(handles.figure1);
        guidata(handles.figure1, handles);
    end

    OnFlag=1;
else
    OnFlag=0;
end
    
% --- Executes on button press in TogglebuttonContourNudge.
function TogglebuttonContourNudge_Callback(hObject, eventdata, handles)
% hObject    handle to TogglebuttonContourNudge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TogglebuttonContourNudge

OnFlag=PrepareContourTool(hObject, handles);
if OnFlag < 0
    return;
end
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);


SetContourToolStatus(handles, hObject);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

if OnFlag > 0
    set(hObject, 'Value', get(hObject, 'Max'));
end

% --- Executes on button press in TogglebuttonContourCut.
function TogglebuttonContourCut_Callback(hObject, eventdata, handles)
% hObject    handle to TogglebuttonContourCut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TogglebuttonContourCut
OnFlag=PrepareContourTool(hObject, handles);
if OnFlag < 0
    return;
end
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

SetContourToolStatus(handles, hObject);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

if OnFlag > 0
    set(hObject, 'Value', get(hObject, 'Max'));
end

% --- Executes on button press in TogglebuttonContourDraw.
function TogglebuttonContourDraw_Callback(hObject, eventdata, handles)
% hObject    handle to TogglebuttonContourDraw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TogglebuttonContourDraw

OnFlag=PrepareContourTool(hObject, handles);
if OnFlag < 0
    return;
end
    
if OnFlag > 0
    set(hObject, 'Value', get(hObject, 'Max'));
end
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

SetContourToolStatus(handles, hObject);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

if OnFlag > 0
    set(hObject, 'Value', get(hObject, 'Max'));
end


function SetContourToolStatus(handles, hObject)
%Reset Contour Nudge
ResetContourNudge(handles);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

%Set Status
if isequal(get(hObject,'Value'), get(hObject,'Max'))
    handles.ContourEditFlag=0;
    
    handles.ContourToolNudge=0;
    set(handles.TogglebuttonContourNudge, 'Value', get(handles.TogglebuttonContourNudge, 'Min'));
    
    handles.ContourToolCut=0;    
    set(handles.TogglebuttonContourCut, 'Value', get(handles.TogglebuttonContourCut, 'Min'));
    
    handles.ContourToolDraw=0;
    set(handles.TogglebuttonContourDraw, 'Value', get(handles.TogglebuttonContourDraw, 'Min'));
    
    handles.ContourToolTrail=0;
    set(handles.TogglebuttonContourTrail, 'Value', get(handles.TogglebuttonContourTrail, 'Min'));
    
     
    switch hObject
        case handles.TogglebuttonContourNudge
            handles.ContourToolNudge=1;
            
        case handles.TogglebuttonContourCut
            handles.ContourToolCut=1;    
            
        case handles.TogglebuttonContourDraw
            handles.ContourToolDraw=1;   
            
        case handles.TogglebuttonContourTrail
            handles.ContourToolTrail=1;               
    end      
    %--Clear View Status   
    set(handles.TogglebuttonZoom, 'Value', get(handles.TogglebuttonZoom, 'Min'));   
    zoom off;   
    
    set(handles.TogglebuttonRuler, 'Value', get(handles.TogglebuttonRuler, 'Min'));
    TogglebuttonRuler_Callback(handles.TogglebuttonRuler, [], handles);
    
    set(handles.TogglebuttonCTNum, 'Value', get(handles.TogglebuttonCTNum, 'Min'));
    TogglebuttonCTNum_Callback(handles.TogglebuttonCTNum, [], handles);    
    
    set(handles.TogglebuttonCross, 'Value', get(handles.TogglebuttonCross, 'Min'));
    TogglebuttonCross_Callback(handles.TogglebuttonCross, [], handles);        
else
    switch hObject
        case handles.TogglebuttonContourNudge
            handles.ContourToolNudge=0;
            
        case handles.TogglebuttonContourCut
            handles.ContourToolCut=0;    
            
        case handles.TogglebuttonContourDraw
            handles.ContourToolDraw=0;        
            
        case handles.TogglebuttonContourTrail
            handles.ContourToolTrail=0;
    end      
end

%Save back
guidata(handles.figure1, handles);


function EditDiameter_Callback(hObject, eventdata, handles)
% hObject    handle to EditDiameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditDiameter as text
%        str2double(get(hObject,'String')) returns contents of EditDiameter as a double

%Reset contour nudge
ResetContourNudge(handles);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

%Set Status
TempValue=str2num(get(hObject,'String'));

if ~isempty(TempValue)
    handles.ContourNudgeSize=TempValue;
    
    Temp=handles.ContourNudgeSize/20;
    FirstHalfX=-handles.ContourNudgeSize/20:0.005:-handles.ContourNudgeSize/40;
    SecondHalfX=-handles.ContourNudgeSize/40:0.005:handles.ContourNudgeSize/40;
    ThirdHalfX=handles.ContourNudgeSize/40:0.005:handles.ContourNudgeSize/20;
        
    handles.NudgeHalfX=[FirstHalfX, SecondHalfX,ThirdHalfX];

    handles.NudgeHalfY=sqrt(Temp*Temp-handles.NudgeHalfX.*handles.NudgeHalfX);
    
    %Save back
    guidata(handles.figure1, handles);
    
    if isequal(get(handles.TogglebuttonContourNudge, 'Value'), get(handles.TogglebuttonContourNudge, 'Max'))
        set(handles.TogglebuttonContourNudge, 'Value', get(handles.TogglebuttonContourNudge, 'Min'));
        TogglebuttonContourNudge_Callback(handles.TogglebuttonContourNudge, [], handles);
        handles=guidata(handles.figure1);
        guidata(handles.figure1, handles);
        
        set(handles.TogglebuttonContourNudge, 'Value', get(handles.TogglebuttonContourNudge, 'Max'));
        TogglebuttonContourNudge_Callback(handles.TogglebuttonContourNudge, [], handles);
        handles=guidata(handles.figure1);
        guidata(handles.figure1, handles);
    end    
    
end




% --- Executes during object creation, after setting all properties.
function EditDiameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditDiameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushbuttonContourNew.
function PushbuttonContourNew_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonContourNew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Reset contour status
for i=1:3
    switch i
        case 1
            set(handles.TogglebuttonContourDraw, 'Value', get(handles.TogglebuttonContourDraw, 'Min'));
            hObject=handles.TogglebuttonContourDraw;
        case 2
            set(handles.TogglebuttonContourCut, 'Value', get(handles.TogglebuttonContourCut, 'Min'));
            hObject=handles.TogglebuttonContourCut;
        case 3
            set(handles.TogglebuttonContourNudge, 'Value', get(handles.TogglebuttonContourNudge, 'Min'));
            hObject=handles.TogglebuttonContourNudge;
    end
    
    SetContourToolStatus(handles, hObject);
    handles=guidata(handles.figure1);
    guidata(handles.figure1, handles);
end              

handles.ContourModifyFlag =0;

guidata(handles.figure1, handles);


%Get New/Copy ROI name
TableData=get(handles.UITableROIUser, 'Data');

if isempty(TableData)
    ROINameList={''};
else
    ROINameList=TableData(:, 2);
end

if ~isequal(eventdata, 'Copy')
    TempName=InputTextIFOA(1, 'New ROI Name: ',  'ROI', ROINameList, handles.figure1);

    if isempty(TempName)
        return;
    end
else
    %Copy
    ROIList=get(handles.PopupmenuROIName, 'String');
    ROIIndex=get(handles.PopupmenuROIName, 'Value');
    CurrentROI=ROIList{ROIIndex};
    
    TempName=['CP ', CurrentROI];
    
    if ~isempty(strmatch(TempName, ROINameList, 'exact'))
        TempName=['CP ', CurrentROI, datestr(now, 30)];
    end
end

ROIName=TempName;

%Update structAxialROI
PlanIndex=find(handles.PlansInfo.PlanIDList==99999);    %User Plan Index
if ~isempty(PlanIndex)
    structAxialROI=handles.PlansInfo.structAxialROI{PlanIndex};
else
    handles.PlansInfo=InitUserPlanInfo(handles.PlansInfo, 1);
    PlanIndex=find(handles.PlansInfo.PlanIDList==99999);
    structAxialROI=[];
end

if ~isequal(eventdata, 'Copy')
    %New
    structAxialROIT.name=ROIName;
    
    structAxialROIT.OrganCurveNum=0;
    structAxialROIT.ZLocation=[];
    structAxialROIT.CurvesCor=[];
    structAxialROIT.Color=GetPinnColor(handles.PinnColorList, length(structAxialROI)+1);
else
    %Copy from the current ROI
    PlanNameList=get(handles.PopupmenuPlanName, 'String');
    PlanNameValue=get(handles.PopupmenuPlanName, 'Value');
    CurrentPlan=PlanNameList{PlanNameValue};
    
    if isequal(CurrentPlan, 'User')
        CurrentPlanIndex=PlanIndex;        
    else        
        AllPlanName=GetPlanNameAll(handles.PlansInfo);
        CurrentPlanIndex=strmatch(CurrentPlan, AllPlanName, 'exact');             
    end
    
    CurrentROIIndex=get(handles.PopupmenuROIName, 'Value')-1;
    
    CstructAxialROI=handles.PlansInfo.structAxialROI{CurrentPlanIndex};    
    structAxialROIT=CstructAxialROI(CurrentROIIndex);
    
    CROIName=structAxialROIT.name;
    
    structAxialROIT.name=ROIName;
end

structAxialROI=[structAxialROI;  structAxialROIT];

handles.PlansInfo.structAxialROI{PlanIndex}=structAxialROI;

%Update BWMask
if isequal(eventdata, 'Copy')    
    if ~isempty(handles.BWMatInfo)
        ROIPlanStr={handles.BWMatInfo.ROINamePlanIndex}';
        BWMatIndex=strmatch([deblank(CROIName), num2str(CurrentPlanIndex)], ROIPlanStr, 'exact');
                        
        BWMatInfoT=handles.BWMatInfo(BWMatIndex);
        BWMatInfoT.ROINamePlanIndex=[deblank(ROIName), num2str(PlanIndex)];
        
        handles.BWMatInfo=[handles.BWMatInfo, BWMatInfoT];        
    end
end

guidata(handles.figure1,handles);

%Udpate display
OldTableData=get(handles.UITableROIUser, 'Data');

DisplayROITableUser(handles.PlansInfo, handles.UITableROIUser);

TableData=get(handles.UITableROIUser, 'Data');
if ~isempty(OldTableData)
    TableData(1:end-1, 1)=OldTableData(:, 1);
    TableData(1:end-1, 3)=OldTableData(:, 3);
    set(handles.UITableROIUser, 'Data', TableData);
end

handles=guidata(handles.figure1);
guidata(handles.figure1, handles);
 

%Update CurrentROI Info
PlanNameList=get(handles.PopupmenuPlanName, 'String');
set(handles.PopupmenuPlanName, 'Value', length(PlanNameList));
PopupmenuPlanName_Callback(handles.PopupmenuPlanName, [], handles);

ROINameList=get(handles.PopupmenuROIName, 'String');
set(handles.PopupmenuROIName, 'Value', length(ROINameList));
PopupmenuROIName_Callback(handles.PopupmenuROIName, [], handles);


% --- Executes on button press in PushbuttonContourCopy.
function PushbuttonContourCopy_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonContourCopy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.PopupmenuROIName, 'Value') > 1
    PushbuttonContourNew_Callback(handles.PushbuttonContourNew, 'Copy', handles);
end


% --- Executes on button press in PushbuttonROIColor.
function PushbuttonROIColor_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonROIColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PushbuttonDelete.
function PushbuttonDelete_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

PushbuttonDeleteROI_Callback(hObject, [], handles);

% --- Executes on selection change in PopupmenuPlanName.
function PopupmenuPlanName_Callback(hObject, eventdata, handles)
% hObject    handle to PopupmenuPlanName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopupmenuPlanName contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopupmenuPlanName

PlanNameList=get(handles.PopupmenuPlanName, 'String');
PlanNameValue=get(handles.PopupmenuPlanName, 'Value');
CurrentPlan=PlanNameList{PlanNameValue};

if isequal(CurrentPlan, ' ')
    SetEditUIOnOff(handles, 'Off');
    return;
end

SetEditUIOnOff(handles, 'Off');
set(handles.PopupmenuPlanName, 'Value', PlanNameValue);

if isequal(CurrentPlan, 'User')
    TableHandle=handles.UITableROIUser;
     ColumnIndex=1;
else
    TableHandle=handles.UITableROI;
    
    AllPlanName=GetAllValidPlanName(handles);
    TempIndex=strmatch(CurrentPlan, AllPlanName, 'exact');
    TempIndex=TempIndex-1;
    
    ColumnIndex=(TempIndex-1)*4+1;
end

%Update PopupmenuROIName
TableData=get(TableHandle, 'Data');
ROIName=TableData(:, ColumnIndex+1);
set(handles.PopupmenuROIName, 'String', [{' '}; ROIName], 'Value', 1);


% --- Executes during object creation, after setting all properties.
function PopupmenuPlanName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopupmenuPlanName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PopupmenuROIName.
function PopupmenuROIName_Callback(hObject, eventdata, handles)
% hObject    handle to PopupmenuROIName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopupmenuROIName contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopupmenuROIName

%Set Current ROI Info
ROINameList=get(handles.PopupmenuROIName, 'String');
ROINameValue=get(handles.PopupmenuROIName, 'Value');

PlanNameList=get(handles.PopupmenuPlanName, 'String');
PlanNameValue=get(handles.PopupmenuPlanName, 'Value');
CurrentPlan=PlanNameList{PlanNameValue};

if ROINameValue < 2
    PopupmenuPlanName_Callback(handles.PopupmenuPlanName, [], handles);
    return;
end

RowIndex=ROINameValue-1;

if isequal(CurrentPlan, 'User')    
    TableHandle=handles.UITableROIUser;
    jTableHandle=handles.jUITableROIUser;
    
     ColumnIndex=1;
     
     UserTable=1;
else       
    TableHandle=handles.UITableROI;
    jTableHandle=handles.jUITableROI;
    
    AllPlanName=GetAllValidPlanName(handles);
    TempIndex=strmatch(CurrentPlan, AllPlanName, 'exact');
    TempIndex=TempIndex-1;
    
    ColumnIndex=(TempIndex-1)*4+1;
    
    UserTable=0;
end

TableData=get(TableHandle, 'Data');

UpdateCurrentROIInfo(RowIndex, ColumnIndex, TableData, handles, UserTable);

%Update Table and display
jTableHandle.setValueAt(true, RowIndex-1, ColumnIndex-1);
pause(handles.TableSetValuePause);


% --- Executes during object creation, after setting all properties.
function PopupmenuROIName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopupmenuROIName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TogglebuttonContourTrail.
function TogglebuttonContourTrail_Callback(hObject, eventdata, handles)
% hObject    handle to TogglebuttonContourTrail (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TogglebuttonContourTrail

OnFlag=PrepareContourTool(hObject, handles);
if OnFlag < 0
    return;
end
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

SetContourToolStatus(handles, hObject);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

if OnFlag > 0
    set(hObject, 'Value', get(hObject, 'Max'));
end


% --- Executes on selection change in PopupmenuColorMap.
function PopupmenuColorMap_Callback(hObject, eventdata, handles)
% hObject    handle to PopupmenuColorMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopupmenuColorMap contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopupmenuColorMap
SetColormap(' ', handles, ' ');

% --- Executes during object creation, after setting all properties.
function PopupmenuColorMap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopupmenuColorMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushbuttonColorMap.
function PushbuttonColorMap_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonColorMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PushbuttonInterpolate.
function PushbuttonInterpolate_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonInterpolate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Reset contour status
for i=1:3
    switch i
        case 1
            set(handles.TogglebuttonContourDraw, 'Value', get(handles.TogglebuttonContourDraw, 'Min'));
            hObject=handles.TogglebuttonContourDraw;
        case 2
            set(handles.TogglebuttonContourCut, 'Value', get(handles.TogglebuttonContourCut, 'Min'));
            hObject=handles.TogglebuttonContourCut;
        case 3
            set(handles.TogglebuttonContourNudge, 'Value', get(handles.TogglebuttonContourNudge, 'Min'));
            hObject=handles.TogglebuttonContourNudge;
    end
    
    SetContourToolStatus(handles, hObject);
    handles=guidata(handles.figure1);
    guidata(handles.figure1, handles);
end              

handles.ContourModifyFlag =0;

guidata(handles.figure1, handles);

%First: Update strucatAxialROI----Axial
UpdateMaskFlag=ContourInterpolateUpdateStructAxialROI(handles);
if UpdateMaskFlag < 1
    return;
end

handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

%Second: Update Binary Mask----Coronal and Sagittal
hStatus=StatusProgressTextCenterIFOA('IBEX', 'Interpolating contours...', handles.figure1);
set(handles.figure1, 'Pointer', 'Watch');
drawnow;

ContourInterpolateUpdateBinaryMask(handles);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);


%Last: Update display
RowIndex=get(handles.PopupmenuROIName, 'Value')-1;
OffOnUserROI(handles, RowIndex, 'Off');
OffOnUserROI(handles, RowIndex, 'On');

handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

delete(hStatus);
set(handles.figure1, 'Pointer', 'arrow');
drawnow;


% --- Executes on button press in TogglebuttonAutoSegBound.
function TogglebuttonAutoSegBound_Callback(hObject, eventdata, handles)
% hObject    handle to TogglebuttonAutoSegBound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TogglebuttonAutoSegBound

TogglebuttonAutoSegBoundOutside_Callback(handles.TogglebuttonAutoSegBound, [], handles);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);


function  IntializeAutoSegBox(handles)
ImageDataInfoAxial=GetImageDataInfo(handles, 'Axial');
ImageDataInfoCor=GetImageDataInfo(handles, 'Cor');
ImageDataInfoSag=GetImageDataInfo(handles, 'Sag');  

XCenter=ImageDataInfoAxial.XStart+(ImageDataInfoAxial.XDim/2-1)*ImageDataInfoAxial.XPixDim;
YCenter=ImageDataInfoAxial.YStart+(ImageDataInfoAxial.YDim/2-1)*ImageDataInfoAxial.YPixDim;
ZCenter=ImageDataInfoAxial.TablePos(handles.SliceNum);

XDimLen=ImageDataInfoAxial.XDim*ImageDataInfoAxial.XPixDim;
YDimLen=ImageDataInfoAxial.YDim*ImageDataInfoAxial.YPixDim;
ZDimLen=2*min(abs(ZCenter-ImageDataInfoAxial.TablePos(1)), abs(ZCenter-ImageDataInfoAxial.TablePos(end)));

%Initialize
if ~isfield(handles, 'RectPosAxial')
    handles.hRectAxial=imrect(handles.AxesImageAxial, [XCenter-XDimLen/8, YCenter-YDimLen/8, XDimLen/4, YDimLen/4]);
    handles.hRectCor=imrect(handles.AxesImageCor, [XCenter-XDimLen/8, ZCenter-ZDimLen/8, XDimLen/4, ZDimLen/4]);
    handles.hRectSag=imrect(handles.AxesImageSag, [YCenter-YDimLen/8, ZCenter-ZDimLen/8, YDimLen/4, ZDimLen/4]);     
else
    handles.hRectAxial=imrect(handles.AxesImageAxial,  handles.RectPosAxial);
    handles.hRectCor=imrect(handles.AxesImageCor, handles.RectPosCor);
    handles.hRectSag=imrect(handles.AxesImageSag, handles.RectPosSag);
end

%New Position Call back
TFunc=@(RectPos)UpdateAutoSegBox(RectPos, handles.figure1, 'Axial');
addNewPositionCallback(handles.hRectAxial, TFunc);

TFunc=@(RectPos)UpdateAutoSegBox(RectPos, handles.figure1, 'Cor');
addNewPositionCallback(handles.hRectCor, TFunc);

TFunc=@(RectPos)UpdateAutoSegBox(RectPos, handles.figure1, 'Sag');
addNewPositionCallback(handles.hRectSag, TFunc);

%Constrain Fcn
TFunc=makeConstrainToRectFcn('imrect', [ImageDataInfoAxial.XStart+ImageDataInfoAxial.XPixDim, ImageDataInfoAxial.XStart+XDimLen-ImageDataInfoAxial.XPixDim], ...
    [ImageDataInfoAxial.YStart+ImageDataInfoAxial.YPixDim, ImageDataInfoAxial.YStart+YDimLen-ImageDataInfoAxial.YPixDim]);
setPositionConstraintFcn(handles.hRectAxial, TFunc);

TFunc=makeConstrainToRectFcn('imrect', [ImageDataInfoAxial.XStart+ImageDataInfoAxial.XPixDim, ImageDataInfoAxial.XStart+XDimLen-ImageDataInfoAxial.XPixDim], ...
    [ImageDataInfoAxial.ZStart+ImageDataInfoAxial.ZPixDim, ImageDataInfoAxial.ZStart+ZDimLen-ImageDataInfoAxial.ZPixDim]);
setPositionConstraintFcn(handles.hRectCor, TFunc);

TFunc=makeConstrainToRectFcn('imrect', [ImageDataInfoAxial.YStart+ImageDataInfoAxial.YPixDim, ImageDataInfoAxial.YStart+YDimLen-ImageDataInfoAxial.YPixDim], ...
   [ImageDataInfoAxial.ZStart+ImageDataInfoAxial.ZPixDim, ImageDataInfoAxial.ZStart+ZDimLen-ImageDataInfoAxial.ZPixDim]);
setPositionConstraintFcn(handles.hRectSag, TFunc);

guidata(handles.figure1, handles);

% DisplayImage(handles);
% DisplayImageCor(handles);
% DisplayImageSag(handles);


function UpdateAutoSegBox(RectPos, hFig, Mode)
handles=guidata(hFig);

AxialRectPos=getPosition(handles.hRectAxial);
CorRectPos=getPosition(handles.hRectCor);
SagRectPos=getPosition(handles.hRectSag);

switch Mode
    case 'Axial'
        XPos=AxialRectPos(1);
        YPos=AxialRectPos(2);
        XLen=AxialRectPos(3);
        YLen=AxialRectPos(4);
        
        CorRectPos=[XPos, CorRectPos(2), XLen, CorRectPos(4)];
        setPosition(handles.hRectCor, CorRectPos);
        
        SagRectPos=[YPos, SagRectPos(2), YLen, SagRectPos(4)];
        setPosition(handles.hRectSag, SagRectPos);        
    case 'Cor'
        XPos=CorRectPos(1);
        ZPos=CorRectPos(2);
        XLen=CorRectPos(3);
        ZLen=CorRectPos(4);
        
        AxialRectPos=[XPos, AxialRectPos(2), XLen, AxialRectPos(4)];
        setPosition(handles.hRectAxial, AxialRectPos);
        
        SagRectPos=[SagRectPos(1), ZPos, SagRectPos(3), ZLen];
        setPosition(handles.hRectSag, SagRectPos);     
        
    case 'Sag'
        YPos=SagRectPos(1);
        ZPos=SagRectPos(2);
        YLen=SagRectPos(3);
        ZLen=SagRectPos(4);
        
        AxialRectPos=[AxialRectPos(1), YPos, AxialRectPos(3), YLen];
        setPosition(handles.hRectAxial, AxialRectPos);
        
        CorRectPos=[CorRectPos(1), ZPos, CorRectPos(3), ZLen];
        setPosition(handles.hRectCor, CorRectPos);     
end

DisplayImage(handles);
DisplayImageCor(handles);
DisplayImageSag(handles);



% --- Executes on button press in PushbuttonAutoSeg.
function PushbuttonAutoSeg_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonAutoSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Sanity Check
if ~isfield(handles, 'hRectAxial') ||  ~isa(handles.hRectAxial, 'imrect') 
    set(handles.TogglebuttonAutoSegBound, 'Value',  get(handles.TogglebuttonAutoSegBound, 'Max'));
    
    TogglebuttonAutoSegBoundOutside_Callback(handles.TogglebuttonAutoSegBound, [], handles);
    handles=guidata(handles.figure1);
    guidata(handles.figure1, handles);
    
    hMsg=MsgboxGuiIFOA('Please specify the segmentation box first!', 'Warn', 'warn', 'modal');
    waitfor(hMsg);
else
    if isequal(get(handles.TogglebuttonAutoSegBound, 'Value'), get(handles.TogglebuttonAutoSegBound, 'Min'))
        set(handles.TogglebuttonAutoSegBound, 'Value', 1);
        
        TogglebuttonAutoSegBoundOutside_Callback(handles.TogglebuttonAutoSegBound, [], handles);
        handles=guidata(handles.figure1);
        guidata(handles.figure1, handles);
    end
end

EmptyFlag=IsEmptyUserROI(handles);
if EmptyFlag == 0
    Answer = QuestdlgIFOA('All the existing curves will be lost. Continue?', 'Confirm','Continue','Cancel', 'Continue');
    if ~isequal(Answer, 'Continue')
        return;
    end
end

if EmptyFlag == 2
    hMsg=MsgboxGuiIFOA(['Please create or select one user ROI.' sprintf('\n'), 'Auto segmentation can only be done in the user ROI.'],...
        'Error', 'error', 'modal');
    waitfor(hMsg);
    return;
end


%Status
hStatus=StatusProgressTextCenterIFOA('IBEX', 'Segmenting images ...', handles.figure1);
drawnow;

%Parameters
Para.LowerThres=str2num(get(handles.EditAutoSegLower, 'String'));
Para.HigherThres=str2num(get(handles.EditAutoSegHigher, 'String'));

%Get Image Data and Mask
CorPos=getPosition(handles.hRectCor);

ZLocStart=CorPos(2);
ZLocEnd=CorPos(2)+CorPos(4);

[MinV, MinIndex1]=min(abs(ZLocStart-handles.ImageDataAxialInfo.TablePos));
[MinV, MinIndex2]=min(abs(ZLocEnd-handles.ImageDataAxialInfo.TablePos));

PageStartIndex=MinIndex1(1);
PageEndIndex=MinIndex2(1);

%Segment
UpsampleRate=4;

ImageDataAxialInfo=handles.ImageDataAxialInfo;
ImageDataAxialInfo=UpdateDataAxialInfo(ImageDataAxialInfo, PageStartIndex, PageEndIndex);

if UpsampleRate ~= 1
    ImageDataAxialInfo=UpsampleImage(ImageDataAxialInfo, UpsampleRate);
end
SubImageData=ImageDataAxialInfo.ImageData;

BoxMask=GetBoxMask(handles.hRectAxial, ImageDataAxialInfo);

SubSegMask=AutoSegPET2(SubImageData, BoxMask, Para);

SubSegMask=flipdim(SubSegMask, 1);

%Generate curves
structAxialROIT=GenerateStructAxialROI(SubSegMask, ImageDataAxialInfo);

UpdateUserROIStructDeleteMask(handles, structAxialROIT);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

delete(hStatus);
drawnow;

%Update image
DisplayImage(handles);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

DisplayImageCor(handles);
DisplayImageSag(handles);

function BoxMask=GetBoxMask(hRectAxial, ImageDataAxialInfo)
MaskPos=getPosition(hRectAxial);

XI=[MaskPos(1), MaskPos(1)+MaskPos(3), MaskPos(1)+MaskPos(3), MaskPos(1)];
YI=[MaskPos(2), MaskPos(2), MaskPos(2)+MaskPos(4), MaskPos(2)+MaskPos(4)];

C=(XI-ImageDataAxialInfo.XStart)/ImageDataAxialInfo.XPixDim+1;
R=(YI-ImageDataAxialInfo.YStart)/ImageDataAxialInfo.YPixDim+1;

BoxMask = roipoly( ImageDataAxialInfo.ImageData(:, :, 1), C, R);


function ImageDataAxialInfo=UpdateDataAxialInfo(ImageDataAxialInfo, PageStartIndex, PageEndIndex)
ImageDataAxialInfo.ZDim=PageEndIndex-PageStartIndex+1;
ImageDataAxialInfo.ZStart=ImageDataAxialInfo.TablePos(PageStartIndex);
ImageDataAxialInfo.TablePos=ImageDataAxialInfo.TablePos(PageStartIndex:PageEndIndex);
ImageDataAxialInfo.ImageData=ImageDataAxialInfo.ImageData(:, :, PageStartIndex:PageEndIndex);

function NewImageDataAxialInfo=UpsampleImage(ImageDataAxialInfo, UpsampleRate)
NewImageDataAxialInfo=ImageDataAxialInfo;
NewImageDataAxialInfo.XPixDim=ImageDataAxialInfo.XPixDim/UpsampleRate;
NewImageDataAxialInfo.YPixDim=ImageDataAxialInfo.YPixDim/UpsampleRate;

NewImageDataAxialInfo.XDim=ImageDataAxialInfo.XDim*UpsampleRate;
NewImageDataAxialInfo.YDim=ImageDataAxialInfo.YDim*UpsampleRate;

NewImageDataAxialInfo.XStart=ImageDataAxialInfo.XStart-ImageDataAxialInfo.XPixDim/2+NewImageDataAxialInfo.XPixDim/2;
NewImageDataAxialInfo.YStart=ImageDataAxialInfo.YStart-ImageDataAxialInfo.YPixDim/2+NewImageDataAxialInfo.YPixDim/2;

RescaleFlag=0;
ImageDataAxialInfo.MaskData=ImageDataAxialInfo.ImageData;
ImageDataAxialInfo=rmfield(ImageDataAxialInfo, 'ImageData');

if isa(ImageDataAxialInfo.MaskData, 'single') && max(ImageDataAxialInfo.MaskData(:)) < 300
    
    ImageDataAxialInfo.MaskData=uint16(ImageDataAxialInfo.MaskData*1000);
    RescaleFlag=1;
end

ProgramPath=fileparts(mfilename('fullpath'));
NewImageDataAxialInfo=Interp_ROIImage(ImageDataAxialInfo, ProgramPath, NewImageDataAxialInfo, 0);
NewImageDataAxialInfo.ImageData=NewImageDataAxialInfo.MaskData;

if RescaleFlag > 0
    NewImageDataAxialInfo.ImageData=single(NewImageDataAxialInfo.ImageData)/1000;
end
NewImageDataAxialInfo=rmfield(NewImageDataAxialInfo, 'MaskData');



function EmptyFlag=IsEmptyUserROI(handles)
[ROIName, PlanIndex]=GetCurrentROIInfo(handles);

if PlanIndex < length(handles.PlansInfo.PlanNameStr)
    EmptyFlag=2;
    return;
end

structAxialROI=handles.PlansInfo.structAxialROI{PlanIndex};
if isempty(structAxialROI)
    EmptyFlag=1;
    return;
end

ROIIndex=strmatch(ROIName, {structAxialROI.name}, 'exact');
if isempty(structAxialROI(ROIIndex).ZLocation)
     EmptyFlag=1;
else
     EmptyFlag=0;
end

function UpdateUserROIStructDeleteMask(handles, structAxialROIT)
%Update structAxialROI
[ROIName, PlanIndex]=GetCurrentROIInfo(handles);

structAxialROI=handles.PlansInfo.structAxialROI{PlanIndex};

ROIIndex=strmatch(ROIName, {structAxialROI.name}, 'exact');

structAxialROI(ROIIndex).ZLocation=structAxialROIT.ZLocation;
structAxialROI(ROIIndex).CurvesCor=structAxialROIT.CurvesCor;
structAxialROI(ROIIndex).OrganCurveNum=structAxialROIT.OrganCurveNum;

handles.PlansInfo.structAxialROI{PlanIndex}=structAxialROI;

%Dlelete Mask
ROIPlanStr={handles.BWMatInfo.ROINamePlanIndex}';

BWMatIndex=strmatch([deblank(ROIName), num2str(PlanIndex)], ROIPlanStr, 'exact');
if ~isempty(BWMatIndex) 
    handles.BWMatInfo(BWMatIndex)=[];
end

%Save
guidata(handles.figure1, handles);


function   structAxialROI=GenerateStructAxialROI(MaskMat, ImageDataInfo)

TempIndex=find(MaskMat);
[RowIndex, ColIndex, PageIndex]=ind2sub(size(MaskMat), TempIndex);

MinPage=min(PageIndex);
MaxPage=max(PageIndex);

ZLocation=[]; CurvesCor={[]};
for i=MinPage:MaxPage
    BWSlice=MaskMat(:, :, i);
    BWSlice=flipud(BWSlice);
    
    CurveContour = bwboundaries(BWSlice);
    
    if ~isempty(CurveContour)        
        
        for kk=1:length(CurveContour)
            SubSliceContour=CurveContour{kk};
            
            if length(SubSliceContour) >=5              
                
                YCor=floor(SubSliceContour(:, 1)); XCor=floor(SubSliceContour(:, 2));
                
                XCor2=ImageDataInfo.XStart+(XCor-1)*ImageDataInfo.XPixDim;
                YCor2=ImageDataInfo.YStart+(YCor-1)*ImageDataInfo.YPixDim;
                
                CurvesCor=[CurvesCor; {[XCor2, YCor2]}];
                ZLocation=[ZLocation; ImageDataInfo.ZStart+(i-1)*ImageDataInfo.ZPixDim];
            end
        end        
    end
end
CurvesCor(1)=[];

structAxialROI(1).name='ROIMat';
structAxialROI(1).OrganCurveNum=length(ZLocation);
structAxialROI(1).ZLocation=ZLocation;
structAxialROI(1).CurvesCor=CurvesCor;
structAxialROI(1).Color='red';


function EditAutoSegLower_Callback(hObject, eventdata, handles)
% hObject    handle to EditAutoSegLower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditAutoSegLower as text
%        str2double(get(hObject,'String')) returns contents of EditAutoSegLower as a double


% --- Executes during object creation, after setting all properties.
function EditAutoSegLower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditAutoSegLower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditAutoSegHigher_Callback(hObject, eventdata, handles)
% hObject    handle to EditAutoSegHigher (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditAutoSegHigher as text
%        str2double(get(hObject,'String')) returns contents of EditAutoSegHigher as a double


% --- Executes during object creation, after setting all properties.
function EditAutoSegHigher_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditAutoSegHigher (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PopupmenuAutoSegPreset.
function PopupmenuAutoSegPreset_Callback(hObject, eventdata, handles)
% hObject    handle to PopupmenuAutoSegPreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopupmenuAutoSegPreset contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopupmenuAutoSegPreset


% --- Executes during object creation, after setting all properties.
function PopupmenuAutoSegPreset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopupmenuAutoSegPreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PopupmenuAutoSegUnit.
function PopupmenuAutoSegUnit_Callback(hObject, eventdata, handles)
% hObject    handle to PopupmenuAutoSegUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopupmenuAutoSegUnit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopupmenuAutoSegUnit


% --- Executes during object creation, after setting all properties.
function PopupmenuAutoSegUnit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopupmenuAutoSegUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TogglebuttonAutoSegBoundOutside_Callback(hObject, eventdata, handles)
if isequal(get(handles.TogglebuttonAutoSegBound, 'Value'), get(handles.TogglebuttonAutoSegBound, 'Max'))
    SetContourToolStatus(handles, handles.TogglebuttonAutoSegBound);  
    
    IntializeAutoSegBox(handles);
    handles=guidata(handles.figure1);
    
else
    if isfield(handles, 'hRectAxial') && isa(handles.hRectAxial, 'imrect')   && isvalid(handles.hRectAxial)
        handles.RectPosAxial=getPosition(handles.hRectAxial);
        handles.RectPosCor=getPosition(handles.hRectCor);
        handles.RectPosSag=getPosition(handles.hRectSag);
        
        delete(handles.hRectAxial);
        delete(handles.hRectSag);
        delete(handles.hRectCor);
    end
end

guidata(handles.figure1, handles);


function SetAutoSegStatus(handles)
PlanValue=get(handles.PopupmenuPlanName, 'Value');
ROIValue=get(handles.PopupmenuROIName, 'Value');

if PlanValue < 2 || ROIValue <2
    set(handles.TogglebuttonAutoSegBound, 'Enable', 'Off', 'Value', 0);    
    
    set(handles.PushbuttonAutoSeg, 'Enable', 'Off', 'BackgroundColor', [170, 170, 170]/255);    
    
    set(handles.TextAutoSegLower, 'Enable', 'Off');
    set(handles.TextAutoSegHigher, 'Enable', 'Off');
    set(handles.EditAutoSegLower, 'Enable', 'Off');
    set(handles.EditAutoSegHigher, 'Enable', 'Off');
    set(handles.PopupmenuAutoSegPreset, 'Enable', 'Off');
    set(handles.PopupmenuAutoSegUnit, 'Enable', 'Off');    
else
    set(handles.TogglebuttonAutoSegBound, 'Enable', 'On');
    set(handles.PushbuttonAutoSeg, 'Enable', 'On', 'BackgroundColor', [1, 1, 1]);       
    
    set(handles.TextAutoSegLower, 'Enable', 'On');
    set(handles.TextAutoSegHigher, 'Enable', 'On');
    set(handles.EditAutoSegLower, 'Enable', 'On');
    set(handles.EditAutoSegHigher, 'Enable', 'On');
    set(handles.PopupmenuAutoSegPreset, 'Enable', 'On');
    set(handles.PopupmenuAutoSegUnit, 'Enable', 'On');    
end

if isequal(get(handles.TogglebuttonAutoSegBound, 'Value'), get(handles.TogglebuttonAutoSegBound, 'Max'))
    set(handles.TogglebuttonAutoSegBound, 'Value', get(handles.TogglebuttonAutoSegBound, 'Min'));
    TogglebuttonAutoSegBoundOutside_Callback(handles.TogglebuttonAutoSegBound, [], handles);
    handles=guidata(handles.figure1);
    guidata(handles.figure1, handles);    
    
    set(handles.TogglebuttonAutoSegBound, 'Value', get(handles.TogglebuttonAutoSegBound, 'Max'));
    TogglebuttonAutoSegBoundOutside_Callback(handles.TogglebuttonAutoSegBound, [], handles);
    handles=guidata(handles.figure1);
    guidata(handles.figure1, handles);    
else
    TogglebuttonAutoSegBoundOutside_Callback(handles.TogglebuttonAutoSegBound, [], handles);
    handles=guidata(handles.figure1);
    guidata(handles.figure1, handles);    
end
