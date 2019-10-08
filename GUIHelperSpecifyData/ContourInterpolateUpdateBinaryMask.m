function ContourInterpolateUpdateBinaryMask(handles)

%Initialization
[ROIName, PlanIndex]=GetCurrentROIInfo(handles);

ImageDataInfo=GetImageDataInfo(handles, 'Axial');
CurrentZLoc=ImageDataInfo.TablePos(handles.SliceNum);

structAxialROI=handles.PlansInfo.structAxialROI{PlanIndex};
ROIIndex=strmatch(ROIName, {structAxialROI.name}, 'exact');
       
%BWMat existence    
if ~isempty(handles.BWMatInfo)
    ROIPlanStr={handles.BWMatInfo.ROINamePlanIndex}';
    
    BWMatIndex=strmatch([deblank(ROIName), num2str(PlanIndex)], ROIPlanStr, 'exact');    
    if ~isempty(BWMatIndex)    
        handles.BWMatInfo(BWMatIndex)=[];
    end
end

%Brand new BWMat
BWMatInfoT=BWFillROI(ROIIndex, PlanIndex, handles);
BWMatInfoT.ROINamePlanIndex=[deblank(ROIName), num2str(PlanIndex)];

handles.BWMatInfo=[ handles.BWMatInfo, BWMatInfoT];   
guidata(handles.figure1, handles);