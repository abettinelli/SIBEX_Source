function Flag=MaskSliceCurrentValid(handles)

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
       
       Flag=0;
       
       return;
   else
       BWMatIndex=length(handles.BWMatInfo);
   end
end

if isempty(handles.BWMatInfo(BWMatIndex).XStart)
    Flag=0;
else
    
    PageIndex=round((CurrentZLoc-handles.BWMatInfo(BWMatIndex).ZStart)/handles.BWMatInfo(BWMatIndex).ZPixDim+1);
    
    if PageIndex < 1 || PageIndex > handles.BWMatInfo(BWMatIndex).ZDim
        Flag=0;
    else
        TempIndex=find(handles.BWMatInfo(BWMatIndex).MaskData(:,:, PageIndex));
        if ~isempty(TempIndex)
            Flag=1;
        else
            Flag=0;
        end
    end
end


