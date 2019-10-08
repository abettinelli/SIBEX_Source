function ContourEditUpdateBinaryMask(handles)

%Initialization
[ROIName, PlanIndex]=GetCurrentROIInfo(handles);

ImageDataInfo=GetImageDataInfo(handles, 'Axial');
CurrentZLoc=ImageDataInfo.TablePos(handles.SliceNum);

structAxialROI=handles.PlansInfo.structAxialROI{PlanIndex};
ROIIndex=strmatch(ROIName, {structAxialROI.name}, 'exact');
       
%BWMat existence
MaskExistFlag=0;
if ~isempty(handles.BWMatInfo)
    ROIPlanStr={handles.BWMatInfo.ROINamePlanIndex}';
    
    BWMatIndex=strmatch([deblank(ROIName), num2str(PlanIndex)], ROIPlanStr, 'exact');    
    if ~isempty(BWMatIndex) && ~isempty(handles.BWMatInfo(BWMatIndex).XStart)
        MaskExistFlag=1;
    end
end

%Brand new BWMat
if MaskExistFlag < 1       
    BWMatInfoT=BWFillROI(ROIIndex, PlanIndex, handles);
    BWMatInfoT.ROINamePlanIndex=[deblank(ROIName), num2str(PlanIndex)];
        
   if isempty(handles.BWMatInfo(BWMatIndex).XStart)
       handles.BWMatInfo(BWMatIndex)=[];
       
       handles.BWMatInfo=[ handles.BWMatInfo, BWMatInfoT];
       guidata(handles.figure1, handles);
       return;
   else
       BWMatIndex=length(handles.BWMatInfo);
   end
end

%Update current slice Mask only
BWMatInfoSlice=BWFillROI(ROIIndex, PlanIndex, handles, CurrentZLoc);

if isempty(BWMatInfoSlice.XStart)
%     BWMatInfoSlice=handles.BWMatInfo;
    BWMatInfoSlice=handles.BWMatInfo(BWMatIndex);
    BWMatInfoSlice.ZStart=CurrentZLoc;
    BWMatInfoSlice.ZDim=1;
    
    BWMatInfoSlice.MaskData=zeros([BWMatInfoSlice.YDim, BWMatInfoSlice.XDim], 'uint8');
end

handles.BWMatInfo(BWMatIndex)=ExtendBWMatDim(handles.BWMatInfo(BWMatIndex), BWMatInfoSlice);
guidata(handles.figure1, handles);




















