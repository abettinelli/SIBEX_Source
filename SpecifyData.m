function varargout = SpecifyData(varargin)
% SPECIFYDATA MATLAB code for SpecifyData.fig
%      SPECIFYDATA, by itself, creates a new SPECIFYDATA or raises the existing
%      singleton*.
%
%      H = SPECIFYDATA returns the handle to a new SPECIFYDATA or the handle to
%      the existing singleton*.
%
%      SPECIFYDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPECIFYDATA.M with the given input arguments.
%
%      SPECIFYDATA('Property','Value',...) creates a new SPECIFYDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SpecifyData_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SpecifyData_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SpecifyData

% Last Modified by GUIDE v2.5 19-Sep-2014 15:19:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SpecifyData_OpeningFcn, ...
                   'gui_OutputFcn',  @SpecifyData_OutputFcn, ...
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


% --- Executes just before SpecifyData is made visible.
function SpecifyData_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SpecifyData (see VARARGIN)

handles.ParentFig=varargin{2};
handles.PatsParentDir=varargin{3};
LocationStr=varargin{4};
PatInfo=varargin{5};
ImageInfo=varargin{6};
ImageID=varargin{7};
handles.ImagesInfo=varargin{8};
handles.ImagesInfoID=varargin{9};
handles.ROICurrentImageOnly=varargin{10};
handles.ThresholdNonUniformSP=varargin{11};
handles.PadROI=varargin{12};

ImageInfo.ImageID=ImageID;

handles.PatInfo=PatInfo;
handles.ImageInfo=ImageInfo;
handles.PatInfo=catstruct(PatInfo, ImageInfo);

ProgramPath=fileparts(mfilename('fullpath'));
handles.ProgramPath=ProgramPath;

handles.TableSetValuePause=1E-1000;

handles.BWMatInfo=[];

%Center figure
CenterFig(handles.figure1);

%Set Information Str
set(handles.TextSiteInfo, 'String', ['Location: ', LocationStr, '. ' ...
    ['Patient: ', PatInfo.FirstName, ' ', PatInfo.MiddleName, ' ', PatInfo.LastName, ', ', PatInfo.MRN, ', ', PatInfo.Directory, ', ', PatInfo.Comment, '.']]);
set(handles.TextPatInfo, 'String', ...
    ['Image: ', ImageInfo.Modality, ', ', ImageInfo.DBName, ', ', ImageInfo.ScanTime, ', Slices=', ImageInfo.Slices, ', ',...
    'ID=', ImageID, ', ', ImageInfo.SeriesInfo, ', ', ImageInfo.Comment, '.']);


%Clean up Review figures
hFig=findobj(0, 'Type', 'figure', 'Name', 'Review');
if ~isempty(hFig) 
    delete(hFig);
end

%Initilaize GUI UIControl
guidata(handles.figure1, handles);
InitializeROIFig(handles, 0);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

%Read Image
hStatus=StatusProgressTextCenterIFOA('IBEX', 'Loading images ...', handles.ParentFig);
drawnow;

hText=findobj(hStatus, 'Style', 'Text');

PatPath=[handles.PatsParentDir, '\', PatInfo.Directory];

if exist([PatPath, '\Plan'], 'dir')
    PatPath=[PatPath, '\Plan'];
end
handles.PatPath=PatPath;

handles.PatInfo.PatDir=PatPath;

HeaderFile=[PatPath, '\ImageSet_', ImageID, '.header'];

[Flag,  DataFormat]=GetImageHeader(HeaderFile);
if Flag < 1
    ErrorStr='Image header/info. file is incomplete.';
    InitializeError(hStatus, handles.figure1, ErrorStr);
    
    return;
end

Flag=IsSPUniform(DataFormat, handles.ThresholdNonUniformSP);
if Flag < 1
    ErrorStr='Image slice spacing is non-uniform.';
    InitializeError(hStatus, handles.figure1, ErrorStr);
        
    return;
end

ImgFile=[HeaderFile(1:end-6), 'img'];
if ~exist(ImgFile, 'file')
    ErrorStr='Image data file doesn''t exist.';
    InitializeError(hStatus, handles.figure1, ErrorStr);
    
    return;
end

ImageData=GetImageData(ImgFile, DataFormat);

handles.ImageDataAxialInfo=UpdateImageProperty(DataFormat);
handles.ImageDataAxialInfo.ImageData=ImageData;

handles.ImageDataCorInfo=[];
handles.ImageDataSagInfo=[];

[SizeInfo, DimInfo, PixInfo]=GetImageSizeInfo(handles);

%Check XPixDim == YPixDim
if EqualRelativeX(handles.ImageDataAxialInfo.XPixDim, handles.ImageDataAxialInfo.YPixDim) < 1
     ErrorStr='Voxel XPixSize is not equal to YPixSize.';
    InitializeError(hStatus, handles.figure1, ErrorStr);
    
    return;
end


%Update Image Info
ImageInfoStr=['Format: ', SizeInfo(1:end-1), ', ', DimInfo(1:end-1), ', ', PixInfo(1:end-1), '.'];
set(handles.TextImageInfo, 'String', ImageInfoStr);

guidata(handles.figure1, handles);

%Read ROI
set(hText, 'String', 'Loading ROIs ...');
drawnow;

PlansInfo=ReadPlanInfo(handles.PatPath, ImageInfo.DBName, handles.ImageDataAxialInfo, handles.ROICurrentImageOnly);
handles.PlansInfo=PlansInfo;

%W/L and colormap
if ~isfield(DataFormat, 'Modality')
    DataFormat.Modality='CT';
end

handles.ImageDataAxialInfo.Modality=DataFormat.Modality;

handles=SetDefaultWL(DataFormat.Modality, handles);

SetColormap(DataFormat.Modality, handles, 'Init');

%Display Image
set(hText, 'String', 'Displaying images ...');
drawnow;

guidata(handles.figure1, handles);
DisplayImageInit(handles);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

%Non-CT Non-PT
if ~isequal(DataFormat.Modality, 'CT') && ~isequal(DataFormat.Modality, 'PT') && ~isequal(DataFormat.Modality, 'CS')
    [handles.GrayMin, handles.GrayMax]=SetAdaptiveWL(handles);
    
    set([handles.AxesImageAxial, handles.AxesImageSag, handles.AxesImageCor], 'CLim', [handles.GrayMin, handles.GrayMax]);
    
    guidata(handles.figure1, handles);
end

if isequal(DataFormat.Modality, 'CS')
    [handles.GrayMin, handles.GrayMax]=SetAdaptiveWL_CS(handles);
    set([handles.AxesImageAxial, handles.AxesImageSag, handles.AxesImageCor], 'CLim', [handles.GrayMin, handles.GrayMax]);
    guidata(handles.figure1, handles);
end

TogglebuttonCross_Callback([], [], handles)

%Display ROI Table
set(hText, 'String', 'Displaying ROI table ...');
drawnow;

%Plan ROIs
DisplayROITable(PlansInfo, handles.UITableROI);

%User ROIs
DisplayROITableUser(PlansInfo, handles.UITableROIUser);

%Delete status
 delete(hStatus);

%Invisile Parent figure
set(handles.ParentFig, 'Visible', 'off');


figure(handles.figure1);

%Get JTable
jScroll = findjobj(handles.UITableROI);
try jScroll = jScroll(1); jScroll = jScroll.getViewport;  catch, end  % may possibly already be the viewport
try jScroll = jScroll.getComponent(0).getViewport;  catch, end  % HG2
jUITableROI = jScroll.getView;

%Set Table resize
% jUITableROI.setAutoResizeMode(jUITableROI.AUTO_RESIZE_SUBSEQUENT_COLUMNS);
% jUITableROI.setColumnResizable(true);
% jUITableROI.setRowHeight(22);

% jUITableROI.setRowSelectionAllowed(0);
% jUITableROI.setColumnSelectionAllowed(0);
% jUITableROI.setCellSelectionEnabled(0);

jScroll = findjobj(handles.UITableROIUser);
try jScroll = jScroll(1); jScroll = jScroll.getViewport;  catch, end  % may possibly already be the viewport
try jScroll = jScroll.getComponent(0).getViewport;  catch, end  % HG2
jUITableROIUser = jScroll.getView;

%Set Table resize
% jUITableROIUser.setAutoResizeMode(jUITableROIUser.AUTO_RESIZE_SUBSEQUENT_COLUMNS);
% jUITableROIUser.setColumnResizable(true);
% % jUITablePatient.setRowResizable(true);
% jUITableROIUser.setRowHeight(22);

handles.jUITableROI=jUITableROI;
handles.jUITableROIUser=jUITableROIUser;

%Set figure units to normalized for resize
set(handles.figure1, 'Units', 'normalized');
hChild=get(handles.figure1, 'Children');
set(hChild, 'Units', 'normalized');

% Choose default command line output for SpecifyData
handles.output = hObject;

% Update handles structure
guidata(handles.figure1, handles);

% UIWAIT makes SpecifyData wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function PlansInfo=ReadPlanInfo(PatPath, DBName, ImageInfo, ROICurrentImageOnly)

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
    PlansInfo=GetPlanROIStruct(PlansInfo, PatPath, DBName, ImageInfo, ROICurrentImageOnly);
end


if exist([PatPath, '\User\UserROI.mat'], 'file')
    load([PatPath, '\User\UserROI.mat']);
    
    PlansInfo=InitUserPlanInfo(PlansInfo, 'Pinn9');
    PlansInfo.structAxialROI=[PlansInfo.structAxialROI, {structAxialROI}];    
end

function PlansInfo=GetPlanROIStruct(PlansInfo, PatPath, DBName, ImageInfo, ROICurrentImageOnly)

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
            
            if ROICurrentImageOnly < 1
                TempIndex=ones(1, length(ROIName));
            else
                %Remove char .
                DBName=regexprep(DBName, '\.', '');
                TempIndex=strmatch(DBName, VolName, 'exact');
            end           
           
            
            if ~isempty(TempIndex)
                %Version 8/Version 9
                [DXStart, DYStart]=GetDiffStartPoint(PlansInfo.PinnV9(i), ImageInfo);                
                
                %no need to resave ROI files
                if length(TempIndex) == length(ROIName)
                    
                    structAxialROI=LoadROIStructs(PinnFile, 'Fake.roi', 'Fake.roi', [DXStart, DYStart]);                    
                else
                    %ROIFile need to be resave
                    SelectOrgan=ROIName(TempIndex);
                    
                    NewROIFile=[PinnFile, 'Crop'];
                    SaveSelectROI_Outside(TextInfo, NewROIFile , SelectOrgan);
                    
                    structAxialROI=LoadROIStructs(PinnFile, 'Fake.roi', 'Fake.roi', [DXStart, DYStart]);                  
                    
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
            PinnV9(i)=0; %Unkwon start point type, type will be determined by image start point
        end
    else
        PinnV9(i)=2;
    end    
end

PlansInfo.PinnV9=PinnV9;

function Flag=IsSPUniform(DataFormat, ThresholdNonUniformSP)
TempS=conv(DataFormat.TablePos, [1,-1]);
TempS(1)=[]; TempS(size(TempS, 1))=[];
SliceSpacingT=round(abs(TempS*1000))/1000;

VarIndex=conv(SliceSpacingT, [1, -1]);
VarIndex(1)=[]; VarIndex(size(VarIndex, 1))=[];

TempIndex=find(abs(VarIndex) >= ThresholdNonUniformSP);

if ~isempty(TempIndex)
    Flag=0;
else
    Flag=1;
end

function  InitializeError(hStatus, hFig, ErrorStr)
hMsg=MsgboxGuiIFOA(ErrorStr, 'Error', 'error', 'modal');
waitfor(hMsg);

delete(hStatus);
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
        
if isequal(DataFormat.Modality, 'CT') || isequal(DataFormat.Modality, 'MR')
    [TempData, Count]=fread(fid, DataFormat.XDim*DataFormat.YDim*length(DataFormat.TablePos), '*int16');
    TempData=uint16(TempData);
end

if  isequal(DataFormat.Modality, 'PT')
    [TempData, Count]=fread(fid, DataFormat.XDim*DataFormat.YDim*length(DataFormat.TablePos), '*single');
    TempData=single(TempData);
    
    TempData=TempData*DataFormat.ColorLUTScale*DataFormat.SUVScale;
    
    %Only for CT treated as PT
    %TempData=uint16(TempData);
end

if  isequal(DataFormat.Modality, 'CS')
    [TempData, Count]=fread(fid, DataFormat.XDim*DataFormat.YDim*length(DataFormat.TablePos), '*single');
    TempData=single(TempData);
end

if ~isequal(DataFormat.Modality, 'CT') && ~isequal(DataFormat.Modality, 'MR') && ~isequal(DataFormat.Modality, 'PT') && ~isequal(DataFormat.Modality, 'CS')
    [TempData, Count]=fread(fid, DataFormat.XDim*DataFormat.YDim*length(DataFormat.TablePos), '*int16');
    TempData=uint16(TempData);
end

fclose(fid);

ImageData=reshape(TempData, [DataFormat.XDim, DataFormat.YDim, length(DataFormat.TablePos)]);
ImageData=permute(ImageData, [2,1,3]);
ImageData=flip(ImageData, 1);


% --- Outputs from this function are returned to the command line.
function varargout = SpecifyData_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = 0;

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
SliceNum=handles.SliceNumCor-10;
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

SliceNum=handles.SliceNumCor+10;
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
SliceNum=handles.SliceNumSag-10;
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

SliceNum=handles.SliceNumSag+10;
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
else
    handles.SliceNum=length(ImageDataInfo.TablePos);
end
            
guidata(handles.figure1, handles);
DisplayImage(handles);

% --- Executes on button press in PushbuttonInferFast.
function PushbuttonInferFast_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonInferFast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SliceNum=handles.SliceNum-10;
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

SliceNum=handles.SliceNum+10;
if SliceNum <= length(ImageDataInfo.TablePos)
    handles.SliceNum=SliceNum;
else
    handles.SliceNum=length(ImageDataInfo.TablePos);
end
            
guidata(handles.figure1, handles);
DisplayImage(handles);

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
   
% % --- Executes on button press in PushbuttonShowDataSet.
% function PushbuttonShowDataSet_Callback(hObject, eventdata, handles)
% % hObject    handle to PushbuttonShowDataSet (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% %Show Data Set
% hFig=findobj(0, 'Type', 'figure', 'Name', 'Current Data Set');
% if ~isempty(hFig)    
%     figure(hFig);
%     return;
% else
%     DataSetList(1, handles.PatsParentDir, handles.figure1);
% end

% --- Executes on button press in PushbuttonShowFeatureSet.
function PushbuttonShowFeatureSet_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonShowFeatureSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in PushbuttonAddToDataSet.
function PushbuttonAddToDataSet_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonAddToDataSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hFig=findobj(0, 'Type', 'figure', 'Name', 'Review');
if ~isempty(hFig)
    WindowAPI(handles.figure1, 'minimize');
    hFig2=MsgboxGuiIFOA('Data set is being reviewed. Action can''t be performed!', 'Warn', 'warn');    
    waitfor(hFig2);
    
    WindowAPI(handles.figure1, 'restore');
        
    figure(hFig);
    
    return;    
end

%Close Data Set 
hFig=findobj(0, 'Type', 'figure', 'Name', 'Current Data Set');
if isempty(hFig)        
    DataSetName=[];
else
    hDataSetName=findobj(hFig, 'Tag', 'TextDataSetName');
    DataSetName=get(hDataSetName, 'String');
    
    delete(hFig);
end

%Sanity Check
[SelectFlag, SelectNum]=ROISelectStatus(handles);

if SelectFlag < 1
    hFig=MsgboxGuiIFOA('NO ROIs are selected.', 'Warn', 'warn');       
    return;
end

if SelectNum> 1
    Answer = QuestdlgIFOA('Multiple ROIs will be added to Data Set! Continue?', 'Confirm','Continue','Cancel', 'Continue');
    if ~isequal(Answer, 'Continue')
        return;
    end
end

%Show Data Set
if ~isempty(DataSetName)
    hFig=DataSetCurrent(1, [handles.PatsParentDir, '\1FeatureDataSet_ImageROI'], DataSetName);
    
    TempName=get(hFig, 'name');
    SetTopWindow(TempName);
    pause(0.01);
    drawnow;
else
    hFig=DataSetList(1, handles.PatsParentDir, handles.figure1);  
    waitfor(hFig);    
end

%Add to file
Flag=AddToDataSet(handles);

function Flag=AddToDataSet(handles)
Flag=1;

hFig=findobj(0, 'Type', 'figure', 'Name', 'Current Data Set');
if isempty(hFig)
    Flag=0;
    return;
end

hDataSetName=findobj(hFig, 'Tag', 'TextDataSetName');
DataSetName=get(hDataSetName, 'String');

DataSetFile=[handles.PatsParentDir, '\1FeatureDataSet_ImageROI\', DataSetName];

CDataSethandles=guidata(hFig);

DataSetsInfo=CDataSethandles.DataSetsInfo;

if size(DataSetsInfo, 1) < 1
    DataSetsInfo=[];    
end

%Image Info
%Format information
ImageDataInfo=GetImageDataInfo(handles, 'Axial');
ImageDataInfo=rmfield(ImageDataInfo, {'ImageData', 'TablePos'});
CDataSetInfo=ImageDataInfo;

%Basic information
CDataSetInfo.Modality=handles.ImageInfo.Modality;
CDataSetInfo.MRN=handles.PatInfo.MRN;
CDataSetInfo.DBName=handles.ImageInfo.DBName;
CDataSetInfo.Comment=handles.ImageInfo.Comment;
CDataSetInfo.ScanTime=handles.ImageInfo.ScanTime;
CDataSetInfo.Slices=handles.ImageInfo.Slices;
CDataSetInfo.SeriesInfo=handles.ImageInfo.SeriesInfo;
CDataSetInfo.ImageID=handles.ImageInfo.ImageID;

%Path information
CDataSetInfo.SrcPath=handles.PatPath;

%ROI Info
ADDItemNum=0;
for i=1:2
    switch i 
        case 1
            TableData=get(handles.UITableROI, 'Data');      
            UserTable=0;
        case 2
            TableData=get(handles.UITableROIUser, 'Data');            
            UserTable=1;
    end
              
    PlanLen=size(TableData, 2)/4;
    
    for k=1:PlanLen
        SelectMat=TableData(:, 4*(k-1)+1);
        
        SelectIndex=cellfun(@IsTrueCell, SelectMat);
        SelectIndex=find(SelectIndex > 0);
        
        if ~isempty(SelectIndex)
            for j=1:length(SelectIndex)
                RowIndex=SelectIndex(j);
                ColIndex=4*(k-1)+1;
                
                %Fill ROI if not binary mask
                BWMatIndex=GenerateROIBinaryMask(RowIndex, ColIndex, handles, UserTable);
                handles=guidata(handles.figure1);
                guidata(handles.figure1, handles);
                                
                % IBSI_mod
                CDataSetInfo_ROI=IBSI_GetDateSetROIInfo(CDataSetInfo, handles, BWMatIndex);  
                CDataSetInfo_ROI=GetStructAxialROI(CDataSetInfo_ROI, RowIndex, ColIndex, handles, UserTable);
                
                DataSetsInfo=[DataSetsInfo; CDataSetInfo_ROI];
                
                ADDItemNum=ADDItemNum+1;
            end
            
        end
        
    end        
end

%Save to file
save(DataSetFile, 'DataSetsInfo');

%Update display
[Flag, TableDataItemID]=UpdateTableDataSetDisplay(DataSetsInfo, CDataSethandles, ADDItemNum);

CDataSethandles.TableDataItemID=TableDataItemID;
CDataSethandles.DataSetsInfo=DataSetsInfo;

guidata(CDataSethandles.figure1, CDataSethandles);

function [SelectFlag, SelectNum]=ROISelectStatus(handles)
SelectFlag=0; SelectNum=0;
for i=1:2
    switch i 
        case 1
            TableData=get(handles.UITableROI, 'Data');            
        case 2
            TableData=get(handles.UITableROIUser, 'Data');            
    end
              
    PlanLen=size(TableData, 2)/4;
    
    for k=1:PlanLen
        SelectMat=TableData(:, 4*(k-1)+1);
        
        SelectIndex=cellfun(@IsTrueCell, SelectMat);
        SelectIndex=find(SelectIndex > 0);
        
        if ~isempty(SelectIndex)
            SelectFlag=1;
            SelectNum=SelectNum+length(SelectIndex);
        end
    end        
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
set(handles.ParentFig, 'Visible', 'on');
delete(handles.figure1);

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

ImageDataInfo=GetImageDataInfo(handles, 'Axial');

hImage=findobj(0, 'Type', 'Axes');
set(hImage, 'CLim', [handles.GrayMin, handles.GrayMax]);
% set(hImage, 'CLim', [handles.GrayMin/ImageDataInfo.ScaleValue, handles.GrayMax/ImageDataInfo.ScaleValue]);
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

% --- Executes on button press in PushbuttonEditROI.
function PushbuttonEditROI_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonEditROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[BWMatInfo, PlansInfo, SliceNum, SliceNumCor, SliceNumSag, TableData, TableDataUser]=ROIEditor(1, handles);

if isequal(handles.PlansInfo, PlansInfo) &&...
        isequal(handles.BWMatInfo, BWMatInfo) &&...
        isequal(handles.SliceNum, SliceNum) &&...
        isequal(handles.SliceNumCor, SliceNumCor) &&...
        isequal(handles.SliceNumSag, SliceNumSag) 
    return;    
end


hStatus=StatusProgressTextCenterIFOA('IBEX', 'Updating display ...', handles.ParentFig);
set(handles.figure1, 'Pointer', 'watch');
drawnow;

PushbuttonOffAllROIs_Callback(handles.PushbuttonOffAllROIs, [], handles);
pause(handles.TableSetValuePause);

handles.BWMatInfo=BWMatInfo;
handles.PlansInfo=PlansInfo;
handles.SliceNum=SliceNum;
handles.SliceNumCor=SliceNumCor;
handles.SliceNumSag=SliceNumSag;

guidata(handles.figure1, handles);

set(handles.UITableROI, 'Data', TableData);
set(handles.UITableROIUser, 'Data', TableDataUser);

DisplayImage(handles);

DisplayImageCor(handles);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);


DisplayImageSag(handles);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

set(handles.figure1, 'Pointer', 'arrow');
delete(hStatus);
drawnow;

% --- Executes on button press in PushbuttonSave.
function PushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

SaveROIInWorkspace(handles);

% --- Executes on button press in PushbuttonShowDataSet.
function PushbuttonShowDataSet_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonShowDataSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Show Data Set
hFig=findobj(0, 'Type', 'figure', 'Name', 'Current Data Set');
if ~isempty(hFig)    
    figure(hFig);
    return;
else
    DataSetList(1, handles.PatsParentDir, handles.figure1);
end

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
    CTRow=floor(CTRow); CTCol=floor(CTCol);
         
    if CTRow >= 1 && CTRow <= RowNum && CTCol >= 1 && CTCol <= ColNum
        CTValue=ImageData(CTRow, CTCol);
        
        % IBSI_mod
        % TempStr=['Value= ',  sprintf('\n'),  num2str(double(CTValue)*ScaleValue)];
        if (handles.ImageInfo.Modality == 'CT')
            TempStr=['Value= ',  sprintf('\n'),  num2str(double(CTValue)*ScaleValue-1000)];
        else
            TempStr=['Value= ',  sprintf('\n'),  num2str(double(CTValue)*ScaleValue)];
        end
        % IBSI_mod
        
        set(handles.TextStatus, 'String', TempStr, 'Visible', 'On');
    else
        set(handles.TextStatus, 'String', 'Value= Invalid', 'Visible', 'On');
    end    
end

%Intersection 
if isequal(get(handles.TogglebuttonCross, 'Value'), get(handles.TogglebuttonCross, 'Max')) && ...
        isequal(get(handles.TogglebuttonZoom, 'Value'), get(handles.TogglebuttonZoom, 'Min')) && ...
        isequal(get(handles.TogglebuttonRuler, 'Value'), get(handles.TogglebuttonRuler, 'Min')) && ...
        isequal(get(handles.TogglebuttonCTNum, 'Value'), get(handles.TogglebuttonCTNum, 'Min')) 
    
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
    hLine=findobj(handles.figure1, 'UserData', 'Isocircle');
    delete(hLine);
    
    set(handles.figure1, 'Pointer', 'arrow');
    return;
else
    if isequal(get(handles.TogglebuttonZoom, 'Value'),  get(handles.TogglebuttonZoom, 'Max'))
        set(handles.figure1, 'Pointer', 'fleur');
    else
        set(handles.figure1, 'Pointer', 'crosshair');
    end
end

if isequal(get(handles.TogglebuttonRuler, 'Value'),  get(handles.TogglebuttonRuler, 'Min')) 
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

% --- Executes on button press in PushbuttonImportROI.
function PushbuttonImportROI_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonImportROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Import ROI
ImageDataInfo=GetImageDataInfo(handles, 'Axial');

structAxialROI=ROIImportMain(ImageDataInfo, handles.figure1, handles.PatPath);
if isempty(structAxialROI)
    return;
end

%Add the fake plan info for the user ROIs
PlanLen=length(handles.PlansInfo.PlanNameStr);

PlanIndex=find(handles.PlansInfo.PlanIDList==99999);
if isempty(PlanIndex)
    PrePlanLen=PlanLen;
else
    PrePlanLen=PlanLen-1;
end

if PrePlanLen == PlanLen
    handles.PlansInfo=InitUserPlanInfo(handles.PlansInfo, 1);
end

if PlanLen == PrePlanLen
    handles.PlansInfo.structAxialROI=[ handles.PlansInfo.structAxialROI, {structAxialROI}];
else
    OldstructROI=handles.PlansInfo.structAxialROI{PrePlanLen+1};
    
    %Rename if duplicated
    OldROIName={OldstructROI.name};
    NewROIName={structAxialROI.name};
        
    for i=1:length(NewROIName)
        TempIndex=strmatch(NewROIName{i}, OldROIName, 'exact');
        
        if ~isempty(TempIndex)
            structAxialROI(i).name=[structAxialROI(i).name, datestr(now, 30)];
        end        
    end
    
    TempstructAxialROI=[handles.PlansInfo.structAxialROI{PrePlanLen+1}; structAxialROI];
    handles.PlansInfo.structAxialROI(PrePlanLen+1)={TempstructAxialROI};
end

guidata(handles.figure1, handles);


%Update display
TableData=get(handles.UITableROIUser, 'Data');
if ~isempty(TableData)
    SelectMat=TableData(:, 1);
else
    SelectMat=[];
end

DisplayROITableUser(handles.PlansInfo, handles.UITableROIUser);

TableData=get(handles.UITableROIUser, 'Data');
if ~isempty(SelectMat)
    Len=length(SelectMat);
    TableData(1:Len, 1)=SelectMat;
    set(handles.UITableROIUser, 'Data', TableData);
end

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
    else
        DisplayContourOff(RowIndex, ColumnIndex, TableData, handles, UserTable);        
    end
end

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
    end    
end

% --- Executes on button press in PushbuttonDeleteROI.
function PushbuttonDeleteROI_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonDeleteROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

TableData=get(handles.UITableROIUser, 'Data');
if isempty(TableData)
    return;
end

SelectMat=cell2mat(TableData(:, 1));
SelectIndex=find(SelectMat > 0);

%No ROI selected
if isempty(SelectIndex)
    hMsg=MsgboxGuiIFOA('No user ROIs are selected.', 'warn', 'warn');
    waitfor(hMsg);
    
    return;
end

Answer = QuestdlgIFOA('All the selected user ROIs will be deleted! Continue?', 'Confirm','Continue','Cancel', 'Continue');
if ~isequal(Answer, 'Continue')
    return;
end

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
pause(handles.TableSetValuePause);

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

% --- Executes on button press in PushbuttonExportROI.
function PushbuttonExportROI_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonExportROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Any ROIs checked
ROICheckedFlag=0;
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
       ROICheckedFlag=1;
       break;
    end
end

if ROICheckedFlag < 1
    hMsg=MsgboxGuiIFOA('No ROIs are selected!', 'Warn', 'warn', 'modal');
    waitfor(hMsg);
    return;
end


%Export INI Configuration
if ~isfield(handles, 'ExportPath')
    ConfigFile=[handles.ProgramPath, '\', 'ImportExport\ExportModule\ExportConfig.INI'];
    if exist(ConfigFile, 'file')
        ConfigStruct=GetParamFromINI(ConfigFile);
    end
    
    DirFlag=0;
    if isfield(ConfigStruct, 'ExportPath')
        if ~exist(ConfigStruct.ExportPath, 'dir')
            DirFlag=mkdir(ConfigStruct.ExportPath);
        else
            DirFlag=1;
        end
    end
    
    if DirFlag < 1
        ConfigStruct.ExportPath='C:';
    end
    
    ExportPath=ConfigStruct.ExportPath;
else
    ExportPath=handles.ExportPath;
end
     
%Export
[structAxialROIT, BWMatInfoT]=GetSelectROIInfo(handles);

handles.PatInfo.YStart=handles.ImageDataAxialInfo.YStart;
handles.PatInfo.YPixDim=handles.ImageDataAxialInfo.YPixDim;
handles.PatInfo.YDim=handles.ImageDataAxialInfo.YDim;
handles.PatInfo.StartV9=handles.ImageDataAxialInfo.StartV9;

handles.PatInfo.ZStart=handles.ImageDataAxialInfo.ZStart;
handles.PatInfo.ZPixDim=handles.ImageDataAxialInfo.ZPixDim;
 
ExportPath=ROIExportMain(1, ExportPath, structAxialROIT, BWMatInfoT, handles.PatInfo, handles.figure1);

if ~isempty(ExportPath)
    %Save exportPath
    handles.ExportPath=ExportPath;
    guidata(handles.figure1, handles);
end

function  [structAxialROIT, BWMatInfoT]=GetSelectROIInfo(handles)
structAxialROIT=[];
BWMatInfoT=[];

for i=1:2
    switch i
        case 1
            TableHandle=handles.UITableROI;
            UserTable=0;
        case 2
            TableHandle=handles.UITableROIUser;
            UserTable=1;
    end
    
    TableData=get(TableHandle, 'Data');
    
    if isempty(TableData)
        continue;
    end
    
    TableDataIndex=cellfun(@IsTrueCell, TableData);
    
    [RowIndex, ColumnIndex]=find(TableDataIndex);
    if length(RowIndex) > 0
       for j=1:length(RowIndex)
           ROIIndex=RowIndex(j);
           
           switch UserTable
               case 0
                   PlanName=GetPlanNameFromTableHeader(handles.UITableROI, ColumnIndex(j));
                   PlanNameAll=GetPlanNameAll(handles.PlansInfo);
                   
                   PlanIndex=strmatch(PlanName, PlanNameAll, 'exact');
               case 1
                   PlanIndex=length(handles.PlansInfo.PlanNameStr);
           end
                     
           %ROI Curves
           structViewROI=handles.PlansInfo.structAxialROI{PlanIndex};
           
           CstructAxialROI=structViewROI(ROIIndex);  
           structAxialROIT=[structAxialROIT, CstructAxialROI];
           
           %ROI BWMask
           BWMatIndex=GenerateROIBinaryMask(RowIndex(j), ColumnIndex(j), handles, UserTable);
           
           CBWMatInfo=handles.BWMatInfo(BWMatIndex);
           BWMatInfoT=[BWMatInfoT, CBWMatInfo];
       end
    end
end

% --- Executes on button press in PushbuttonOnAllROIs.
function PushbuttonOnAllROIs_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonOnAllROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%On ROI table display
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
    
    TableDataIndex=cellfun(@IsFalseCell, TableData);
    
    TempIndex=find(TableDataIndex);
    [RowIndex, ColIndex]=find(TableDataIndex);
    if ~isempty(TempIndex)
        TableData(TempIndex)={true};
        
        set(TableHandle, 'Data', TableData);
    end
    
    for j=1:length(RowIndex)
        
        if i>1
            eventdataNew.UserTable=1;
        end        
        eventdataNew.Indices(1)=RowIndex(j);
        eventdataNew.Indices(2)=ColIndex(j);
        
        UITableROI_CellEditCallback(handles.UITableROI, eventdataNew, handles);
        handles=guidata(handles.figure1);
        guidata(handles.figure1, handles);
    end
end
