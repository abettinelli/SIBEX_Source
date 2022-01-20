function varargout = ROIEditorDataSet(varargin)
% ROIEDITORDATASET MATLAB code for ROIEditorDataSet.fig
%      ROIEDITORDATASET, by itself, creates a new ROIEDITORDATASET or raises the existing
%      singleton*.
%
%      H = ROIEDITORDATASET returns the handle to a new ROIEDITORDATASET or the handle to
%      the existing singleton*.
%
%      ROIEDITORDATASET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROIEDITORDATASET.M with the given input arguments.
%
%      ROIEDITORDATASET('Property','Value',...) creates a new ROIEDITORDATASET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROIEditorDataSet_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROIEditorDataSet_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ROIEditorDataSet

% Last Modified by GUIDE v2.5 20-May-2014 15:41:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ROIEditorDataSet_OpeningFcn, ...
                   'gui_OutputFcn',  @ROIEditorDataSet_OutputFcn, ...
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


% --- Executes just before ROIEditorDataSet is made visible.
function ROIEditorDataSet_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ROIEditorDataSet (see VARARGIN)

CDataSetInfo=varargin{2};
PFig=varargin{3};
handles.TableDataItemID=varargin{4};

handles.DataSetsInfo=varargin{5};
handles.DataSetFile=varargin{6};

%Test/Review UI Components
guidata(handles.figure1, handles);
SetTestUIStatus(varargin, handles);
handles=guidata(handles.figure1);

handles.ParentFig=PFig;
handles.CDataSetInfo=CDataSetInfo;

%Relative Image Src path
handles.CDataSetInfo=UpdateDateSetSrcPath(handles.DataSetFile, handles.CDataSetInfo);

ProgramPath=fileparts(mfilename('fullpath'));
handles.ProgramPath=ProgramPath;

handles.TableSetValuePause=1E-1000;
handles.TableSetValuePauseEdit=0.02;    %Set longer time waiting for java GUI finish

handles.BWMatInfo=[];

TableHeader={'Modality', 'MRN', 'DBName', 'SeriesInfo', 'Comment', 'ROIName', 'CreationDate'};

%Set Information Str
InfoStr=GetInfoStr(handles.CDataSetInfo, TableHeader);

set(handles.TextInfo, 'String', InfoStr);


%Initilaize GUI UIControl
guidata(handles.figure1, handles);
InitializeROIFig(handles, 1);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);


%Read Image
hStatus=StatusProgressTextCenterIFOA('IBEX', 'Loading images ...', PFig);

TempName=get(hStatus, 'name');
SetTopWindow(TempName);
pause(0.01);
drawnow;

drawnow;

hText=findobj(hStatus, 'Style', 'Text');

PatPath=handles.CDataSetInfo.SrcPath;
handles.PatPath=PatPath;

ReadImageFlag=1;

HeaderFile=[PatPath, '\ImageSet_', handles.CDataSetInfo.ImageID, '.header'];

[Flag,  DataFormat]=GetImageHeader(HeaderFile);
if Flag < 1
    ErrorStr='Image header/info. file is incomplete.';   
    
    if ~isfield(handles, 'TestType')
        InitializeError(hStatus, handles.figure1, ErrorStr);              
        return;
    else
        DataFormat=RecoverDataFormat(handles.CDataSetInfo);
        ReadImageFlag=0;
    end
end

Flag=IsSPUniform(DataFormat);
if Flag < 1
    ErrorStr='Image slice spacing is non-uniform.';
    
    if ~isfield(handles, 'TestType')
        InitializeError(hStatus, handles.figure1, ErrorStr);
        return;
    else
        ReadImageFlag=0;
    end
end

ImgFile=[HeaderFile(1:end-6), 'img'];
if ~exist(ImgFile, 'file')
    ErrorStr='Image data file doesn''t exist.';   
    
    if ~isfield(handles, 'TestType')
        InitializeError(hStatus, handles.figure1, ErrorStr);
        return;
    else
        ReadImageFlag=0;
    end
end

% ReadImageFlag=0;
if ReadImageFlag > 0
    ImageData=GetImageData(ImgFile, DataFormat);   
    
    handles.ImageDataAxialInfo=UpdateImageProperty(DataFormat);
    handles.ImageDataAxialInfo.ImageData=ImageData;
else
    handles.ImageDataAxialInfo=handles.CDataSetInfo;    
    handles.ImageDataAxialInfo.TablePos=handles.CDataSetInfo.ZStart+((1:handles.CDataSetInfo.ZDim)'-1)*handles.CDataSetInfo.ZPixDim;    
    
    [handles.ImageDataAxialInfo.ImageData, handles.ImageDataAxialInfo.LayerInfo]...
        =UpdateImageDataWithROIImage(handles.CDataSetInfo, []);
end

handles.ImageDataCorInfo=[];
handles.ImageDataSagInfo=[];

[SizeInfo, DimInfo, PixInfo]=GetImageSizeInfo(handles);


guidata(handles.figure1, handles);

%Read ROI
set(hText, 'String', 'Loading ROIs ...');
drawnow;

%Fake Plan Info
PlansInfo=GenerateFakePlanInfo;

PlansInfo=InitUserPlanInfo(PlansInfo, 'Pinn9');
PlansInfo.structAxialROI=[PlansInfo.structAxialROI, {handles.CDataSetInfo.structAxialROI}];
handles.PlansInfo=PlansInfo;

%Center figure
CenterFigUpCenter(handles.figure1);

%Preprocess Image
if length(varargin) > 6
    set(hText, 'String', 'Preprocessing the ROI-box image ...');
    drawnow;

    if ~isempty(handles.TestStruct{1})
        CDataSetInfo=PreprocessImage(handles.TestStruct{1}, handles.CDataSetInfo);    
        
       %Execute CallBackFunc for the customized purpose
       if isfield(CDataSetInfo.ROIImageInfo, 'CallBackFunc')
           HelperPath=[handles.ProgramPath, '\FeatureAlgorithm\Preprocess\helper'];
           if exist(HelperPath, 'dir')
               CurrentPath=pwd;
               cd(HelperPath);
               
               ReviewFuncH=str2func(CDataSetInfo.ROIImageInfo.CallBackFunc);
               CDataSetInfo=ReviewFuncH(CDataSetInfo);
               
               cd(CurrentPath);
           end
       end
                
        handles.CDataSetInfo.ROIImageInfoFilter=CDataSetInfo.ROIImageInfo;
        
        %Reample the entire image
        if EqualRelativeX(DataFormat.XPixDim, CDataSetInfo.XPixDim) < 1 || ...
                EqualRelativeX(DataFormat.YPixDim, CDataSetInfo.YPixDim) < 1 || ...
                EqualRelativeZ(DataFormat.ZPixDim, CDataSetInfo.ZPixDim) < 1  
            
            BackData=CDataSetInfo.ROIImageInfo;
                       
            set(hText, 'String', 'Resampling the entire image ...');
            drawnow;
             
            try
                [DataFormat, ImageData]=Resample_EntireImage(DataFormat, handles.ImageDataAxialInfo.ImageData,CDataSetInfo);
                
                %Update CDataSetInfo image property
                handles.ImageDataAxialInfo=UpdateImageProperty(DataFormat);
                handles.ImageDataAxialInfo.ImageData=ImageData;
                
                handles.ImageDataAxialInfo.TablePos=CDataSetInfo.ZStart+((1:CDataSetInfo.ZDim)'-1)*CDataSetInfo.ZPixDim;
            catch ErrObj
                hFig=findobj(0, 'Type', 'figure', 'Name', 'Current Data Set');
                delete(hFig);
                
                ErrorStr='Resampling data failed.';
                InitializeError(hStatus, handles.figure1, ErrorStr);
                
                 rethrow(ErrObj);
                 
                return;                
            end
                        
            %Update ROI
            handles.PlansInfo.structAxialROI(end)={CDataSetInfo.structAxialROI};
                                         
            %Replace ROI box withe the box from the resample entire image
            CDataSetInfo=UpdateROIImageInfoData(ImageData, CDataSetInfo);
            
            handles.CDataSetInfo=CDataSetInfo;
            
            handles.CDataSetInfo.ROIImageInfoFilter=BackData;
        end      
                
    else
        %No Preprocess
        handles.CDataSetInfo.ROIImageInfoFilter=handles.CDataSetInfo.ROIImageInfo;
    end
    
    try
        [handles.ImageDataAxialInfo.ImageData, handles.ImageDataAxialInfo.LayerInfo]=...
            UpdateImageDataWithROIImage(handles.CDataSetInfo, handles.ImageDataAxialInfo.ImageData);
    catch
        hFig=findobj(0, 'Type', 'figure', 'Name', 'Current Data Set');
        delete(hFig);
        
        ErrorStr='Update image data failed.';
        InitializeError(hStatus, handles.figure1, ErrorStr);
        
        rethrow(ErrObj);
        
        return;
    end
end

%Category review data
 if isfield(handles, 'TestType') && isequal(handles.TestType, 'Category')
     set(hText, 'String', 'Computing category review info. ...');
     drawnow;
    
     CategoryFuncH=str2func([handles.TestStruct{2}.Name, '_Category']);
     
     if length(varargin) > 6
         if~isempty(handles.TestStruct{1})
             ReviewInfo=CategoryFuncH(CDataSetInfo, 'Review', handles.TestStruct{2}.Value);
         else
             ReviewInfo=CategoryFuncH(handles.CDataSetInfo, 'Review', handles.TestStruct{2}.Value);
         end
     end
     
     handles.CDataSetInfo.ROIImageInfoFeature=ReviewInfo;    
 end
 
 %Feature review data
 if isfield(handles, 'TestType') && isequal(handles.TestType, 'Feature')
      set(hText, 'String', 'Computing feature review info. ...');
     drawnow;    
     
     CategoryFuncH=str2func([handles.TestStruct{2}.Name, '_Category']);     
     if length(varargin) > 6
         if ~isempty(handles.TestStruct{1})
             ParentInfo=CategoryFuncH(CDataSetInfo, 'Child', handles.TestStruct{2}.Value);
         else
             ParentInfo=CategoryFuncH(handles.CDataSetInfo, 'Child', handles.TestStruct{2}.Value);
         end
     end
     
     FeatureFuncH=str2func([handles.TestStruct{2}.Name, '_Feature']);     
     FeatureInfo=FeatureFuncH(ParentInfo, handles.TestStruct{3}, 'Review');
     
     handles.CDataSetInfo.ROIImageInfoFeature=FeatureInfo.FeatureReviewInfo;
 end
 
 
 if isfield(handles, 'TestType') && isfield(handles.CDataSetInfo, 'ROIImageInfoFeature')
     ReviewInfo=handles.CDataSetInfo.ROIImageInfoFeature;
     
     %Execute CallBackFunc for the customized purpose
     if isfield(ReviewInfo, 'CallBackFunc')         
         HelperPath=[handles.ProgramPath, '\FeatureAlgorithm\Category\', handles.TestStruct{2}.Name, '\helper'];
         if exist(HelperPath, 'dir')
             CurrentPath=pwd;
             cd(HelperPath);
             
             ReviewFuncH=str2func(ReviewInfo.CallBackFunc);
             ReviewInfo=ReviewFuncH(ReviewInfo);
             
             cd(CurrentPath);
         end
     end
     
     %Feature value
     if isfield(ReviewInfo, 'Value')
         if isnumeric(ReviewInfo.Value)
             set(handles.TextFeatureValue, 'Visible', 'on', 'String', [handles.TestStruct{length(handles.TestStruct)}.Name, ' = ', num2str(ReviewInfo.Value)]);
         else
             set(handles.TextFeatureValue, 'Visible', 'on', 'String', [handles.TestStruct{length(handles.TestStruct)}.Name, ' = ', ReviewInfo.Value]);
         end
     end
     
     %Feature: Curves
     if isfield(ReviewInfo, 'CurvesInfo')         
         PlotCurvesInfo(ReviewInfo, handles.figure1);
     end
     
     %Feature: NIDTable     
     if isfield(ReviewInfo,'NIDTable')
          NID = figure('Position',[1500 500 320 420], 'menubar', 'none', 'toolbar', 'none', 'Color', [212, 208, 200]/255, 'Name', 'NID', 'NumberTitle', 'off');
          NIDStruct = ReviewInfo.NIDTable;
          ColumnName={'Values','Difference','Probability'};
          ColumnName=FormatTableHeader(ColumnName);
          ColumnName(1)=[];
          
          uitable('Parent', NID, 'Data', [NIDStruct.HistBinLoc,NIDStruct.HistDiffSum,NIDStruct.HistOccurPropability], ...
              'ColumnName', ColumnName , 'ColumnWidth',{80}, ...
              'Position',[10 10 300 400], 'FontSize', 12, 'FontName', 'Calibri', 'FontWeight', 'bold');
          
          set(NID, 'Units', 'normalized');
          hChild=get(NID, 'Children');
          set(hChild, 'Units', 'normalized');
          
          CenterFigBottom(NID, handles.figure1);
     end

     %Feature: Mesh
     if isfield(ReviewInfo, 'MeshInfo')
         for i=1:length(ReviewInfo.MeshInfo)
             TriRep=ReviewInfo.MeshInfo(i).TriRep;
             TriXCor=ReviewInfo.MeshInfo(i).XCor;
             TriYCor=ReviewInfo.MeshInfo(i).YCor;
             TriZCor=ReviewInfo.MeshInfo(i).ZCor;             
             
             ReviewFig=figure;
             trimesh(TriRep, TriXCor, TriYCor, TriZCor, 'FaceAlpha', 1);
%              hold on, plot3(TriXCor, TriYCor, TriZCor,  'Marker', '+', 'LineStyle', 'none');    %Too many points
                                      
             ReviewAx=findobj(ReviewFig, 'Type', 'axes');
             
             if isfield(ReviewInfo.MeshInfo(i), 'Description')
                 title(ReviewAx, ReviewInfo.MeshInfo(i).Description);
             end
             
             SetFigBottomNum(ReviewFig, handles.figure1, (i-1)/length(ReviewInfo.MeshInfo));
             
         end
     end
     
     
     if isfield(ReviewInfo, 'MaskData')
         %Feature: 1 number
         if (ndims(ReviewInfo.MaskData) ==2) ...
                 && (numel(ReviewInfo.MaskData) == 1)
             set(handles.TextFeatureValue, 'Visible', 'on', 'String', [handles.TestStruct{length(handles.TestStruct)}.Name, ' = ', num2str(ReviewInfo.MaskData)]);
         end
         
         %Feature: 3D or 2D one slice
         if (ndims(handles.CDataSetInfo.ROIImageInfoFeature.MaskData) ==3)  || ...
                 ((ndims(handles.CDataSetInfo.ROIImageInfoFeature.MaskData) ==2) && size(handles.CDataSetInfo.ROIImageInfoFeature.MaskData, 2) > 2)
             
             if isequal(handles.TestType, 'Category')
                 set(handles.PopupmenuImageType, 'Value',  2, 'String', [{'Original'}; {'Preprocess'}; {'Category'}]);
             end
             
             if isequal(handles.TestType, 'Feature')
                 set(handles.PopupmenuImageType, 'Value',  2, 'String', [{'Original'}; {'Preprocess'}; {'Feature'}]);
             end
         end
         
         if isfield(handles.CDataSetInfo.ROIImageInfoFeature, 'GLCMStruct')
             set(handles.PopupmenuImageType, 'Value',  2, 'String', [{'Original'}; {'Preprocess'}; {'GLCM'}]);
         end
         
         if isfield(handles.CDataSetInfo.ROIImageInfoFeature, 'GLCMStruct25')
             set(handles.PopupmenuImageType, 'Value',  2, 'String', [{'Original'}; {'Preprocess'}; {'GLCM25'}]);
         end
         
         if isfield(handles.CDataSetInfo.ROIImageInfoFeature, 'GLCMStruct3')
             set(handles.PopupmenuImageType, 'Value',  2, 'String', [{'Original'}; {'Preprocess'}; {'GLCM3'}]);
             handles.CDataSetInfo.ROIImageInfoFeature.GLCMStruct25=handles.CDataSetInfo.ROIImageInfoFeature.GLCMStruct3;
         end
         
         %&& isequal(handles.TestType, 'Category')
         if isfield(handles.CDataSetInfo.ROIImageInfoFeature, 'GLRLMStruct25') 
             set(handles.PopupmenuImageType, 'Value',  2, 'String', [{'Original'}; {'Preprocess'}; {'GLRLM25'}]);
             handles.CDataSetInfo.ROIImageInfoFeature.GLCMStruct25=handles.CDataSetInfo.ROIImageInfoFeature.GLRLMStruct25;
%              handles.CDataSetInfo.ROIImageInfoFeature.MaskData=handles.CDataSetInfo.ROIImageInfoFeature.GLRLMStruct25(1).ScaleImage;
         end
         
         
         %Feature: [X, Y]
          if (ndims(ReviewInfo.MaskData) ==2) && size(ReviewInfo.MaskData, 2) == 2
              ReviewFig=figure; 
              if isfield(ReviewInfo, 'LineStyle')
                  plot(ReviewInfo.MaskData(:, 1), ReviewInfo.MaskData(:, 2), ReviewInfo.LineStyle);
              else
                  plot(ReviewInfo.MaskData(:, 1), ReviewInfo.MaskData(:, 2));
              end
              
              ReviewAx=findobj(ReviewFig, 'Type', 'axes');
              
              if isfield(ReviewInfo, 'Description')
                  title(ReviewAx, ReviewInfo.Description);
              end
                            
              CenterFigBottom(ReviewFig, handles.figure1);
          end
     end
     
 end
 
 %WL 
 if ~isfield(handles.CDataSetInfo, 'Modality')
    handles.CDataSetInfo.Modality='CT';
 end

 handles=SetDefaultWL(handles.CDataSetInfo.Modality, handles);
 
 SetColormap(handles.CDataSetInfo.Modality, handles, 'Init');
 
%Check XPixDim == YPixDim
if EqualRelativeX(handles.ImageDataAxialInfo.XPixDim, handles.ImageDataAxialInfo.YPixDim) < 1
    hFig=findobj(0, 'Type', 'figure', 'Name', 'Current Data Set');
    delete(hFig);
    
    ErrorStr='Voxel XPixSize is not equal to YPixSize.';
    InitializeError(hStatus, handles.figure1, ErrorStr);
    
    return;
end

%Display Image
set(hText, 'String', 'Displaying images ...');
drawnow;

guidata(handles.figure1, handles);
DisplayImageInit(handles);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

%Non-CT Non-PT
if ~isequal(handles.CDataSetInfo.Modality, 'CT') && ~isequal(handles.CDataSetInfo.Modality, 'PT')
    [handles.GrayMin, handles.GrayMax]=SetAdaptiveWL(handles);
    
    if handles.GrayMax <= handles.GrayMin
        handles.GrayMax=handles.GrayMin+1;
    end
    
    set([handles.AxesImageAxial, handles.AxesImageSag, handles.AxesImageCor], 'CLim', [handles.GrayMin, handles.GrayMax]);
    
    guidata(handles.figure1, handles);
end


%Display ROI Table
set(hText, 'String', 'Displaying ROI table ...');
drawnow;

%Plan ROIs
DisplayROITable(PlansInfo, handles.UITableROI);

%User ROIs
DisplayROITableUser(PlansInfo, handles.UITableROIUser);

%Initialize contour editing variables
guidata(handles.figure1, handles);
InitializeContourVars(handles);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

%JTable
figure(handles.figure1);

jScroll = findjobj(handles.UITableROIUser);
try jScroll = jScroll(1); jScroll = jScroll.getViewport;  catch, end  % may possibly already be the viewport
try jScroll = jScroll.getComponent(0).getViewport;  catch, end  % HG2
jUITableROIUser = jScroll.getView;

%Set Table resize
% jUITableROIUser.setAutoResizeMode(jUITableROIUser.AUTO_RESIZE_SUBSEQUENT_COLUMNS);
% jUITableROIUser.setColumnResizable(true);
% % jUITablePatient.setRowResizable(true);
% jUITableROIUser.setRowHeight(22);

handles.jUITableROI=[];
handles.jUITableROIUser=jUITableROIUser;

%Set figure units to normalized for resize
set(handles.figure1, 'Units', 'normalized');
hChild=get(handles.figure1, 'Children');
set(hChild, 'Units', 'normalized');

%Set Editt
SetEditUIOnOff(handles, 'Off');

%Display ROI
TableData=get(handles.UITableROIUser, 'Data');
TableData(:, 1)={true};
set(handles.UITableROIUser, 'Data', TableData);

PlanList=get(handles.PopupmenuPlanName, 'String');
set(handles.PopupmenuPlanName, 'Value', length(PlanList));

PopupmenuPlanName_Callback(handles.PopupmenuPlanName, [], handles);

ROIList=get(handles.PopupmenuROIName, 'String');
set(handles.PopupmenuROIName, 'Value', length(ROIList));

guidata(handles.figure1, handles);
PopupmenuROIName_Callback(handles.PopupmenuROIName, [], handles);

pause(handles.TableSetValuePauseEdit);

handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

%Display Images to bring layers
DisplayImage(handles);

DisplayImageCor(handles);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

DisplayImageSag(handles);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

% Choose default command line output for SpecifyData
handles.output = hObject;

% Update handles structure
guidata(handles.figure1, handles);

%Delete status
if ishandle(hStatus)
    delete(hStatus);
end

set(handles.figure1, 'Pointer', 'arrow');
drawnow;


% UIWAIT makes SpecifyData wait for user response (see UIRESUME)
% uiwait(handles.figure1);

    
function CDataSetInfo=UpdateROIImageInfoData(ImageData, CDataSetInfo)
BWMatInfo=CDataSetInfo.ROIBWInfo;

ROIImageInfo=BWMatInfo;

if ~isempty(BWMatInfo.XStart)        
    
    ROIYEnd=ROIImageInfo.YStart+(ROIImageInfo.YDim-1)*ROIImageInfo.YPixDim;
    ImageYEnd=CDataSetInfo.YStart+(CDataSetInfo.YDim-1)*CDataSetInfo.YPixDim;
        
    StartDist=ImageYEnd-ROIYEnd;
    YStart=CDataSetInfo.YStart+StartDist;
    
    XDimStart=round((ROIImageInfo.XStart-CDataSetInfo.XStart)/CDataSetInfo.XPixDim+1);
    XDimEnd=XDimStart+ROIImageInfo.XDim-1;
    
    YDimStart=round((YStart-CDataSetInfo.YStart)/CDataSetInfo.YPixDim+1+ROIImageInfo.YDim-1);
    YDimStart=CDataSetInfo.YDim-YDimStart+1;
    
    YDimEnd=YDimStart+ROIImageInfo.YDim-1;
    
    ZDimStart=round((ROIImageInfo.ZStart-CDataSetInfo.ZStart)/CDataSetInfo.ZPixDim+1);
    ZDimEnd=ZDimStart+ROIImageInfo.ZDim-1;
    
    ROIImageInfo.MaskData=...
        flipdim(ImageData(YDimStart:YDimEnd, XDimStart:XDimEnd, ZDimStart:ZDimEnd), 1);
else
    ROIImageInfo.MaskData=[];
end

CDataSetInfo.ROIImageInfo=ROIImageInfo;



function DataFormat=RecoverDataFormat(CDataSetInfo)
DataFormat.XDim=CDataSetInfo.XDim;
DataFormat.YDim=CDataSetInfo.YDim;
DataFormat.ZDim=CDataSetInfo.ZDim;
DataFormat.XPixDim=CDataSetInfo.XPixDim;
DataFormat.YPixDim=CDataSetInfo.YPixDim;
DataFormat.ZPixDim=CDataSetInfo.ZPixDim;
DataFormat.XStartV9=CDataSetInfo.XStartV9;
DataFormat.XStartV8=CDataSetInfo.XStartV8;
DataFormat.YStartV9=CDataSetInfo.YStartV9;
DataFormat.YStartV8=CDataSetInfo.YStartV8;
DataFormat.ZStart=CDataSetInfo.ZStart;
DataFormat.ColorLUTScale=1;
DataFormat.SUVScale=CDataSetInfo.ScaleValue;
DataFormat.TablePos=CDataSetInfo.ZStart+((1:CDataSetInfo.ZDim)'-1)*CDataSetInfo.ZPixDim;
DataFormat.ByteOrder=0;


function SetTestUIStatus(varargin, handles)

handles.WL1=[];
handles.WL2=[];
handles.WL3=[];

if length(varargin) > 6    
    handles.TestType=varargin{7};
    handles.TestStruct=varargin{8};
      
    InfoStr=GetTestInfoStr(handles);
    set(handles.TextTestInfo, 'String', InfoStr);
          
    set(handles.PopupmenuImageType, 'Visible', 'on');   
    set(handles.TextImageType, 'Visible', 'on');               
        
    [ImgIcon, map]=imread('Export.png');
    set(handles.PushbuttonExport, 'CData', ImgIcon, 'Visible', 'on');       
        
    set(handles.PopupmenuImageType, 'Value', 2, 'String', [{'Original'}; {'Preprocess'}]);
    
    set(handles.TextReview, 'String', handles.TestType);
    
    %Invisible Contour Editing Control
    set(handles.TogglebuttonContourNudge, 'Visible', 'Off');
    set(handles.TogglebuttonContourCut, 'Visible', 'Off');
    set(handles.TogglebuttonContourDraw, 'Visible', 'Off');
    set(handles.TogglebuttonContourTrail, 'Visible', 'Off');
    set(handles.PushbuttonContourCopy, 'Visible', 'Off');
    set(handles.PushbuttonInterpolate, 'Visible', 'Off');
    set(handles.PushbuttonDelete, 'Visible', 'Off');
    set(handles.PushbuttonSave, 'Visible', 'Off');
    set(handles.PushbuttonUpdate, 'Visible', 'Off');
    set(handles.PushbuttonContourNew, 'Visible', 'Off');
    
    set(handles.TextDiameter, 'Visible', 'Off');
    set(handles.EditDiameter, 'Visible', 'Off');
       
    
    guidata(handles.figure1, handles);
 
else    
    set(handles.TextTestInfo, 'Visible', 'off');
    set(handles.PushbuttonExport, 'Visible', 'off');
    
    set(handles.PopupmenuImageType, 'Visible', 'off');
    set(handles.TextImageType, 'Visible', 'off');
end


function [ImageData, LayerInfo]=UpdateImageDataWithROIImage(CDataSetInfo, ImageDataIn)

 if isempty(ImageDataIn)
     %No original image available     
     ROIImageInfo=CDataSetInfo.ROIImageInfo;
 else
     %Original image available  
     ROIImageInfo=CDataSetInfo.ROIImageInfoFilter;
 end
 
 if isfield(ROIImageInfo, 'LayerInfo')
     LayerInfo=ROIImageInfo.LayerInfo;     
 else
     LayerInfo=[];
 end

 ROIYEnd=ROIImageInfo.YStart+(ROIImageInfo.YDim-1)*ROIImageInfo.YPixDim;
 ImageYEnd=CDataSetInfo.YStart+(CDataSetInfo.YDim-1)*CDataSetInfo.YPixDim;
 
 StartDist=ImageYEnd-ROIYEnd;
 ROIImageInfo.YStart=CDataSetInfo.YStart+StartDist;
 
 XDimStart=round((ROIImageInfo.XStart-CDataSetInfo.XStart)/CDataSetInfo.XPixDim+1);
 XDimEnd=XDimStart+ROIImageInfo.XDim-1;
 
 YDimStart=round((ROIImageInfo.YStart-CDataSetInfo.YStart)/CDataSetInfo.YPixDim+1+ROIImageInfo.YDim-1);
 YDimStart=CDataSetInfo.YDim-YDimStart+1;
 
 YDimEnd=YDimStart+ROIImageInfo.YDim-1;
 
 ZDimStart=round((ROIImageInfo.ZStart-CDataSetInfo.ZStart)/CDataSetInfo.ZPixDim+1);
 ZDimEnd=ZDimStart+ROIImageInfo.ZDim-1;
 
 if isempty(ImageDataIn)
    ImageDataIn=zeros(CDataSetInfo.YDim, CDataSetInfo.XDim, CDataSetInfo.ZDim, class(CDataSetInfo.ROIImageInfo.MaskData));
 end   
 
 ImageDataIn(YDimStart:YDimEnd, XDimStart:XDimEnd, ZDimStart:ZDimEnd)=...
     flipdim(ROIImageInfo.MaskData, 1);

 ImageData=ImageDataIn;


function PlansInfo=GenerateFakePlanInfo
PlansInfo.PlanNameStr=[];
PlansInfo.PlanIDList=[];
PlansInfo.PlanComment=[];
PlansInfo.PlanDosimetrist=[];
PlansInfo.PlanFusionIDList=[];
PlansInfo.PlanPrimayImageID=[];
PlansInfo.PinnV9=[];
PlansInfo.structAxialROI=[];


function InfoStr=GetInfoStr(CDateSetInfo, TableHeader)
InfoStr=[];

for i=1:length(TableHeader)
    if ~isequal(TableHeader{i}, 'CreationDate')
        InfoStr=[InfoStr, CDateSetInfo.(TableHeader{i}), ', '];
    else
        InfoStr=[InfoStr, 'CreationDate: ', CDateSetInfo.(TableHeader{i}), '.'];
    end
end


function PropValueStr=GetTextStrValue(ValueStr)


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

if isequal(DataFormat.Modality, 'CT') || isequal(DataFormat.Modality, 'MR')
    [TempData, Count]=fread(fid, DataFormat.XDim*DataFormat.YDim*length(DataFormat.TablePos), '*int16');
    TempData=uint16(TempData);
end

if  isequal(DataFormat.Modality, 'PT') 
    [TempData, Count]=fread(fid, DataFormat.XDim*DataFormat.YDim*length(DataFormat.TablePos), '*single');
    TempData=single(TempData);
    
    TempData=TempData*DataFormat.ColorLUTScale*DataFormat.SUVScale;
end

if  isequal(DataFormat.Modality, 'CS') 
    [TempData, Count]=fread(fid, DataFormat.XDim*DataFormat.YDim*length(DataFormat.TablePos), '*single');
    TempData=single(TempData);
end

if ~isequal(DataFormat.Modality, 'CT') && ~isequal(DataFormat.Modality, 'MR') && ~isequal(DataFormat.Modality, 'PT') && ~isequal(DataFormat.Modality, 'CS')
    [TempData, Count]=fread(fid, DataFormat.XDim*DataFormat.YDim*length(DataFormat.TablePos), '*int16');
    TempData=uint16(TempData);
end

ImageData=reshape(TempData, [DataFormat.XDim, DataFormat.YDim, length(DataFormat.TablePos)]);
ImageData=permute(ImageData, [2,1, 3]);

ImageData=flipdim(ImageData, 1);


% --- Outputs from this function are returned to the command line.
function varargout = ROIEditorDataSet_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
try
    varargout{1} = handles.figure1;
catch
    varargout{1} = 0;
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

if isequal(get(handles.PushbuttonSave, 'Visible'), 'On') || isequal(get(handles.PushbuttonSave, 'Visible'), 'on')
    
    Answer = QuestdlgIFOA('Update the data set?', 'Confirm','Yes','No', 'Yes');
    if isequal(Answer, 'Yes')
        PushbuttonUpdate_Callback(handles.PushbuttonUpdate, [], handles);
    end
end

delete(handles.figure1);


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

hImage=findobj(handles.figure1, 'Type', 'Axes');
set(hImage, 'CLim', [handles.GrayMin, handles.GrayMax]);
guidata(handles.figure1, handles);


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
            
    %Get image matrix Col or Row
    if CurrentAxes == handles.AxesImageAxial        
        if ~isfield(ImageDataInfoAxial, 'LayerInfo') || length(hImage) < 2
            ImageData=get(hImage, 'CData');
        else            
             UserData=get(hImage, 'UserData');    
             TempIndex=cellfun('isempty', UserData);
             
             ImageData=get(hImage(TempIndex), 'CData');             
        end        
        
        ScaleValue=ImageDataInfoAxial.ScaleValue;
        
        %Get current point in axes points
        CTPoint=CursorPos;    
        
        CTCol=(CTPoint(1)-ImageDataInfoAxial.XLimMin)/ImageDataInfoAxial.XPixDim+1; CTRow=(CTPoint(3)-ImageDataInfoAxial.YLimMin)/ImageDataInfoAxial.YPixDim+1;
    end
        
    
    if CurrentAxes == handles.AxesImageCor
        if ~isfield(ImageDataInfoCor, 'LayerInfo') || length(hImage) < 2
            ImageData=get(hImage, 'CData');
        else            
             UserData=get(hImage, 'UserData');    
             TempIndex=cellfun('isempty', UserData);
             
             ImageData=get(hImage(TempIndex), 'CData');             
        end        
        
        ScaleValue=ImageDataInfoCor.ScaleValue;
        
        CTPoint=CursorPosCor;    
        
        CTCol=(CTPoint(1)-ImageDataInfoCor.XLimMin)/ImageDataInfoCor.XPixDim+1; 
        CTRow=(CTPoint(3)-ImageDataInfoCor.ZLimMin)/ImageDataInfoCor.ZPixDim+1;        
    end
    
    if CurrentAxes == handles.AxesImageSag
        if ~isfield(ImageDataInfoSag, 'LayerInfo') || length(hImage) < 2
            ImageData=get(hImage, 'CData');
        else            
             UserData=get(hImage, 'UserData');    
             TempIndex=cellfun('isempty', UserData);
             
             ImageData=get(hImage(TempIndex), 'CData');             
        end       
        
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
    
    
    %-----------Contour Trial-------
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

%     handles.NudgeHalfX=[-TempValue/20:0.05:TempValue/20];
    handles.NudgeHalfY=sqrt(Temp*Temp-handles.NudgeHalfX.*handles.NudgeHalfX);
    
    %Save back
    guidata(handles.figure1, handles);
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


% --- Executes on button press in PushbuttonUpdate.
function PushbuttonUpdate_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonUpdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

OldROIName=handles.CDataSetInfo.ROIName;

% IBSI_mod
handles.CDataSetInfo=IBSI_GetDateSetROIInfo(handles.CDataSetInfo, handles, 1);
handles.CDataSetInfo=GetStructAxialROI(handles.CDataSetInfo, 1, 1, handles, 1);

handles.CDataSetInfo.ROIName=OldROIName;

%Update display
hFig=findobj(0, 'Type', 'figure', 'Name', 'Current Data Set');
if ~isempty(hFig)
    
    DateSetHandle=guidata(hFig);    
    DateSetHandle.DataSetsInfo(handles.TableDataItemID)=handles.CDataSetInfo;    
    
    [Flag, TableDataItemID]=UpdateTableDataSetDisplay(DateSetHandle.DataSetsInfo, DateSetHandle);    
    
    DateSetHandle.TableDataItemID=TableDataItemID;
    
    guidata(DateSetHandle.figure1, DateSetHandle);
end

%Update file
handles.DataSetsInfo(handles.TableDataItemID)=handles.CDataSetInfo;  
guidata(handles.figure1, handles);

save(handles.DataSetFile, '-struct', 'handles', 'DataSetsInfo');


% --- Executes on selection change in PopupmenuImageType.
function PopupmenuImageType_Callback(hObject, eventdata, handles)
% hObject    handle to PopupmenuImageType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopupmenuImageType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopupmenuImageType

CurrentValue=get(hObject, 'Value');

CDataSetInfo=handles.CDataSetInfo;

switch CurrentValue
    case 1
        CDataSetInfo.ROIImageInfoFilter=handles.CDataSetInfo.ROIImageInfo;        
        OffUIScaleGLCM(handles);                       
    case 2
        CDataSetInfo.ROIImageInfoFilter=handles.CDataSetInfo.ROIImageInfoFilter;
        OffUIScaleGLCM(handles);           
    case 3
        OffUIScaleGLCM(handles);   
        
        CDataSetInfo.ROIImageInfoFilter=handles.CDataSetInfo.ROIImageInfoFeature;
        
        if isfield(handles.CDataSetInfo.ROIImageInfoFeature, 'ScaleRatio')            
            set(handles.TextScale, 'Visible', 'on', 'String', ...
                ['Ratio=', num2str(handles.CDataSetInfo.ROIImageInfoFeature.ScaleRatio), ', Min=',  num2str(handles.CDataSetInfo.ROIImageInfoFeature.ScaleMin)]);        
        end
        
        if (isfield(handles.CDataSetInfo.ROIImageInfoFeature, 'GLCMStruct') || isfield(handles.CDataSetInfo.ROIImageInfoFeature, 'GLCMStruct25')) 
            SetUIGLCM(handles);
            CDataSetInfo.ROIImageInfoFilter=GetGLCMInfo(handles, 1);
        end              
        
        if  isfield(handles.CDataSetInfo.ROIImageInfoFeature, 'GLCMStruct')
            CLim=GetWL(CDataSetInfo.ROIImageInfoFilter.MaskData(:,:, round(end/2)));
            
            hAxes=findobj(handles.figure1, 'Type', 'Axes');
            set(hAxes, 'CLim', CLim);
        end
end

%Update Data
[handles.ImageDataAxialInfo.ImageData, handles.ImageDataAxialInfo.LayerInfo]=...
    UpdateImageDataWithROIImage(CDataSetInfo, handles.ImageDataAxialInfo.ImageData);
guidata(handles.figure1);

%Remove Layers
hImage=findobj(0, 'Type', 'Image');
UserData=get(hImage, 'UserData');
TempIndex=cellfun('isempty', UserData);
TempIndex=~TempIndex;
delete(hImage(TempIndex));

%Update display
DisplayImage(handles);

DisplayImageCor(handles);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

DisplayImageSag(handles);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

function CLim=GetWL(DRRFilm)
MinDRRFilm=min(DRRFilm(:));
MaxDRRFilm=max(DRRFilm(:));

CLim=[MinDRRFilm-(MaxDRRFilm-MinDRRFilm)*1/200, MinDRRFilm+(MaxDRRFilm-MinDRRFilm)*1/50];

if ~(CLim(2) > CLim(1))
    CLim(2)=CLim(1)+1;
end

% Range=1000;
% DRRFilm=(DRRFilm-min(DRRFilm(:)))*Range/(max(DRRFilm(:))-min(DRRFilm(:)));
% 
% %Get Intestity tol_low tol_high
% nbins = 0:Range;
% [RowNum, ColNum]=size(DRRFilm);
% [N, xLoc]=hist(double(reshape(DRRFilm, [RowNum*ColNum,1])), nbins);
% 
% tol_low = 0;
% tol_high = 0.99;
% 
% cdf = cumsum(N)/sum(N);
% 
% IndexLow = find(cdf>=tol_low, 1, 'first');
% if ~isempty(IndexLow)
%     TGrayMin=xLoc(IndexLow);
% else
%     TGrayMin=min(DRRFilm(:));
% end
% 
% IndexHigh = find(cdf>=tol_high, 1, 'first');
% if ~isempty(IndexHigh)
%     TGrayMax=xLoc(IndexHigh);
% else
%     TGrayMax=max(DRRFilm(:));
% end
% 
% GrayMin=TGrayMin*(MaxDRRFilm-MinDRRFilm)/Range+MinDRRFilm;
% GrayMax=TGrayMax*(MaxDRRFilm-MinDRRFilm)/Range+MinDRRFilm;
% 
% CLim=[GrayMin, GrayMax];


function OffUIScaleGLCM(handles)
set(handles.TextScale, 'Visible', 'off');

set(handles.TextGLCM, 'Visible', 'off');
set(handles.TextGLCMDegree, 'Visible', 'off');
set(handles.TextGLCMOffset, 'Visible', 'off');
set(handles.PopupmenuGLCMDegree, 'Visible', 'off');
set(handles.PopupmenuGLCMOffset, 'Visible', 'off');

function OnUIGLCM(handles)
set(handles.TextGLCM, 'Visible', 'on');
set(handles.TextGLCMDegree, 'Visible', 'on');

set(handles.PopupmenuGLCMDegree, 'Visible', 'on');

if ~isfield(handles.CDataSetInfo.ROIImageInfoFeature, 'GLRLMStruct25')
    set(handles.TextGLCMOffset, 'Visible', 'on');
    set(handles.PopupmenuGLCMOffset, 'Visible', 'on');
end

function SetUIGLCM(handles)
OnUIGLCM(handles);

Degree=[];

if isfield(handles.CDataSetInfo.ROIImageInfoFeature, 'GLCMStruct')
    GLCMStruct=handles.CDataSetInfo.ROIImageInfoFeature.GLCMStruct;
end

if isfield(handles.CDataSetInfo.ROIImageInfoFeature, 'GLCMStruct25')
    GLCMStruct=handles.CDataSetInfo.ROIImageInfoFeature.GLCMStruct25;
end


for i=1:length(GLCMStruct)
    Degree=[Degree; GLCMStruct(i).Direction];
end

Degree=cellstr(num2str(Degree));
set(handles.PopupmenuGLCMDegree, 'String', Degree);

if isfield(GLCMStruct, 'Offset')
    Offset=GLCMStruct(1).Offset;
    Offset=cellstr(num2str(Offset));
    set(handles.PopupmenuGLCMOffset, 'String', Offset);
end



function ROIImageInfoFilter=GetGLCMInfo(handles, PlotFlag)
ROIImageInfoFilter=handles.CDataSetInfo.ROIImageInfoFeature;

DegreeIndex=get(handles.PopupmenuGLCMDegree, 'Value');
OffsetIndex=get(handles.PopupmenuGLCMOffset, 'Value');

%Plot
if isequal(handles.TestType, 'Feature') && PlotFlag > 0
         
    if isfield(handles.CDataSetInfo.ROIImageInfoFeature, 'GLCMStruct')
        ReviewFig=figure; plot(ROIImageInfoFilter.MaskData(:, 1), ROIImageInfoFilter.MaskData(:, DegreeIndex+1));
        ReviewAx=findobj(ReviewFig, 'Type', 'axes');
        
        title(ReviewAx, [ROIImageInfoFilter.Description, ' Degree: ', num2str(handles.CDataSetInfo.ROIImageInfoFeature.GLCMStruct(DegreeIndex).Direction)]);
    end
    
    if isfield(handles.CDataSetInfo.ROIImageInfoFeature, 'GLCMStruct25') && isfield(handles.CDataSetInfo.ROIImageInfoFeature.GLCMStruct25, 'Offset')
        ReviewFig=figure; plot(ROIImageInfoFilter.MaskData(:, 1), ROIImageInfoFilter.MaskData(:, DegreeIndex+1));
        ReviewAx=findobj(ReviewFig, 'Type', 'axes');
        
        title(ReviewAx, [ROIImageInfoFilter.Description, ' Degree: ', num2str(handles.CDataSetInfo.ROIImageInfoFeature.GLCMStruct25(DegreeIndex).Direction)]);
    end
    
    if exist('ReviewFig', 'var')
        CenterFigBottom(ReviewFig, handles.figure1);
    end
    
    %GLCM image
    if isfield(handles.CDataSetInfo.ROIImageInfoFeature, 'GLCMStruct25')       
        
        ReviewFig=figure;
        
        if isfield(handles.CDataSetInfo.ROIImageInfoFeature.GLCMStruct25, 'Offset')
            OffsetNum=length(handles.CDataSetInfo.ROIImageInfoFeature.GLCMStruct25(DegreeIndex).Offset);
            n=4; m=ceil(OffsetNum/n);
            
            TAx=[];
            for i=1:OffsetNum
                hAx=subplot(m, n, i); imagesc(handles.CDataSetInfo.ROIImageInfoFeature.GLCMStruct25(DegreeIndex).GLCM(:, :, i)); colormap(gray);
                title(['GLCM Offset ', num2str(handles.CDataSetInfo.ROIImageInfoFeature.GLCMStruct25(DegreeIndex).Offset(i))]);
                
                TAx=[TAx; hAx];
            end
        
            CLim=GetWL(handles.CDataSetInfo.ROIImageInfoFeature.GLCMStruct25(DegreeIndex).GLCM(:, :, 1));            
            set(TAx, 'CLim', CLim);
             
            %Seperate window for summation
            TempFig=figure;
            subplot(1, 1, 1); 
            imagesc(handles.CDataSetInfo.ROIImageInfoFeature.GLCMStruct25(DegreeIndex).GLCM(:, :, 1));
            title(['GLCM Offset ', num2str(handles.CDataSetInfo.ROIImageInfoFeature.GLCMStruct25(DegreeIndex).Offset(1))]);  
            
            SetPosGLCMFig(TempFig, 'Left');
        else
           TAx=subplot(1, 1, 1);  imagesc(handles.CDataSetInfo.ROIImageInfoFeature.GLCMStruct25(DegreeIndex).GLRLM); colormap(gray);
            title(['GLRLM']);
        end        
              
        
        SetPosGLCMFig(ReviewFig, 'Right');
    end
  
end


%Data
if isfield(handles.CDataSetInfo.ROIImageInfoFeature, 'GLCMStruct')
    GLCMMat=handles.CDataSetInfo.ROIImageInfoFeature.GLCMStruct(DegreeIndex).GLCM(:, :, OffsetIndex, :);
    GLCMMat=squeeze(GLCMMat);
    
    ROIImageInfoFilter.MaskData=GLCMMat;
    ROIImageInfoFilter.XDim=size(GLCMMat, 2);
    ROIImageInfoFilter.YDim=size(GLCMMat, 1);
end

if isfield(handles.CDataSetInfo.ROIImageInfoFeature, 'GLCMStruct25')
    
    SI=uint16(handles.CDataSetInfo.ROIImageInfoFeature.GLCMStruct25(DegreeIndex).ScaleImage);
    ROIImageInfoFilter.MaskData=SI;
    ROIImageInfoFilter.XDim=size(SI, 2);
    ROIImageInfoFilter.YDim=size(SI, 1);    
end

function SetPosGLCMFig(ReviewFig, ModeStr)
PFig=findobj(0, 'Type', 'figure', 'Name', 'Review');

if isempty(PFig)
    return;
else
    PFig=PFig(1);
end

switch ModeStr
    case 'Right'
        CenterFigBottomRight(ReviewFig, PFig);
        
    case 'Left'
        CenterFigBottomLeft(ReviewFig, PFig);
end


% --- Executes during object creation, after setting all properties.
function PopupmenuImageType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopupmenuImageType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushbuttonExport.
function PushbuttonExport_Callback(hObject, eventdata, handles)
% hObject    handle to PushbuttonExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
end

ExportPath=uigetdir(ExportPath, 'Select Export directory:');
if ExportPath== 0
    return;
end

%Export All in Matlab format
CDataSetInfo=handles.CDataSetInfo;
for i=1:2 
    switch i
        case 1
            save([ExportPath, '\ROIImageInfo.mat'], '-struct', 'CDataSetInfo', 'ROIImageInfo');  
            SaveROIImageInfoRaw(CDataSetInfo.ROIImageInfo.MaskData, [ExportPath, '\Raw_ROIImage']);
         
        case 2
            save([ExportPath, '\ROIImageInfoFilter.mat'], '-struct', 'CDataSetInfo', 'ROIImageInfoFilter');       
            SaveROIImageInfoRaw(CDataSetInfo.ROIImageInfoFilter.MaskData, [ExportPath, '\Raw_ROIImageFilter']);
    end
end

if isfield(CDataSetInfo, 'ROIImageInfoFeature')
    save([ExportPath, '\ROIImageInfoFeature.mat'], '-struct', 'CDataSetInfo', 'ROIImageInfoFeature');   
    if isfield(CDataSetInfo.ROIImageInfoFeature, 'MaskData')
        SaveROIImageInfoRaw(CDataSetInfo.ROIImageInfoFeature.MaskData, [ExportPath, '\Raw_ROIImageFeature']);
    end
end

hMsg=MsgboxGuiIFOA('Review-related data is exported.', 'help', 'modal');
waitfor(hMsg);


function SaveROIImageInfoRaw(MaskData, FileName)
HeaderFile=[FileName, '.header'];
DataFile=[FileName, '.data'];
DataTxtFile=[FileName, '.txt'];

%Write Header file
FID=fopen(HeaderFile, 'w');
fprintf(FID, '%s\n', ['X_Dim=', num2str(size(MaskData, 2)), ';']);
fprintf(FID, '%s\n', ['Y_Dim=', num2str(size(MaskData, 1)), ';']);
fprintf(FID, '%s\n', ['Z_Dim=', num2str(size(MaskData, 3)), ';']);
fprintf(FID, '%s\n', ['Data_Type=', class(MaskData), ';']);
fclose(FID);

%Write ASCII file
if size(MaskData, 3) < 2
    FID=fopen(DataTxtFile, 'w');
    FormatStr=repmat('%15.10f ', 1, size(MaskData, 2));
    FormatStr=[FormatStr, '\n'];
    
    fprintf(FID, FormatStr, MaskData');
    fclose(FID);
end

%Write binary data file
FID=fopen(DataFile, 'w');
MaskData=permute(MaskData, [2,1,3]);
fwrite(FID, MaskData, class(MaskData));
fclose(FID);



% --- Executes on selection change in PopupmenuGLCMDegree.
function PopupmenuGLCMDegree_Callback(hObject, eventdata, handles)
% hObject    handle to PopupmenuGLCMDegree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopupmenuGLCMDegree contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopupmenuGLCMDegree

PopupmenuGLCMOffset_Callback(handles.PopupmenuGLCMOffset, 'Degree', handles);


% --- Executes during object creation, after setting all properties.
function PopupmenuGLCMDegree_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopupmenuGLCMDegree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PopupmenuGLCMOffset.
function PopupmenuGLCMOffset_Callback(hObject, eventdata, handles)
% hObject    handle to PopupmenuGLCMOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopupmenuGLCMOffset contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopupmenuGLCMOffset

            
CDataSetInfo=handles.CDataSetInfo;

if isempty(eventdata)
    CDataSetInfo.ROIImageInfoFilter=GetGLCMInfo(handles, 0);
else
    CDataSetInfo.ROIImageInfoFilter=GetGLCMInfo(handles, 1);
end

if isfield(CDataSetInfo.ROIImageInfoFilter, 'GLCMStruct')
    CLim=GetWL(CDataSetInfo.ROIImageInfoFilter.MaskData(:,:, round(end/2)));
    
    hAxes=findobj(handles.figure1, 'Type', 'Axes');
    set(hAxes, 'CLim', CLim);
end

%Update Data
[handles.ImageDataAxialInfo.ImageData, handles.ImageDataAxialInfo.LayerInfo]=...
    UpdateImageDataWithROIImage(CDataSetInfo, handles.ImageDataAxialInfo.ImageData);
guidata(handles.figure1);

%Update display
DisplayImage(handles);

DisplayImageCor(handles);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);

DisplayImageSag(handles);
handles=guidata(handles.figure1);
guidata(handles.figure1, handles);


% --- Executes during object creation, after setting all properties.
function PopupmenuGLCMOffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopupmenuGLCMOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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
