%Update bitmap and view after contour is drawn

function UpdateMaskFlag=ContourInterpolateUpdateStructAxialROI(handles)
%Initialization
[ROIName, PlanIndex]=GetCurrentROIInfo(handles);

ImageDataInfo=GetImageDataInfo(handles, 'Axial');

structAxialROI=handles.PlansInfo.structAxialROI{PlanIndex};
ROIIndex=strmatch(ROIName, {structAxialROI.name}, 'exact');

ContourZLoc=structAxialROI(ROIIndex).ZLocation;

UpdateMaskFlag=0;

if length(ContourZLoc) < 2    
    return;
end

%Reset
handles.ContourFirstPoint=[];
handles.ContourPrevPoint=[];
handles.ContourNextPoint=[];
handles.ContourPoint=0;

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

BWMatInfo=handles.BWMatInfo(BWMatIndex);


%Interpolate
MinZLoc=min(ContourZLoc);
MaxZLoc=max(ContourZLoc);

for i=1:BWMatInfo.ZDim
    TempIndex=find(BWMatInfo.MaskData(:, :, i));       
    
    %NO ROI
    if isempty(TempIndex)                
        CurrentZLoc=BWMatInfo.ZStart+(i-1)*BWMatInfo.ZPixDim;            
        
        if (CurrentZLoc > MinZLoc) && (CurrentZLoc < MaxZLoc)
            ResultCurve=InterpolateROI(BWMatInfo, CurrentZLoc, ContourZLoc);
            
            %update structAxialROI
            for j=1:length(ResultCurve)
                structAxialROI(ROIIndex).ZLocation=[structAxialROI(ROIIndex).ZLocation; CurrentZLoc];
                structAxialROI(ROIIndex).CurvesCor=[structAxialROI(ROIIndex).CurvesCor; ResultCurve(j)];
                structAxialROI(ROIIndex).OrganCurveNum=structAxialROI(ROIIndex).OrganCurveNum+1;
            end
        end
        
        UpdateMaskFlag=1;
    end
    
end

if UpdateMaskFlag > 0
    handles.PlansInfo.structAxialROI{PlanIndex}=structAxialROI;
    guidata(handles.figure1, handles);
end










