%Update bitmap and view after contour is drawn

function ContourNudgeUpdateStructAxialROI(handles)
%Initialization
[ROIName, PlanIndex]=GetCurrentROIInfo(handles);

ImageDataInfo=GetImageDataInfo(handles, 'Axial');
CurrentZLoc=ImageDataInfo.TablePos(handles.SliceNum);

structAxialROI=handles.PlansInfo.structAxialROI{PlanIndex};
ROIIndex=strmatch(ROIName, {structAxialROI.name}, 'exact');

%Reset
handles.ContourFirstPoint=[];
handles.ContourPrevPoint=[];
handles.ContourNextPoint=[];
handles.ContourPoint=0;

%update structAxialROI---Clean
TempIndex=find(abs(structAxialROI(ROIIndex).ZLocation-CurrentZLoc) < ImageDataInfo.ZPixDim/3);
if ~isempty(TempIndex)
    structAxialROI(ROIIndex).ZLocation(TempIndex)=[];
    structAxialROI(ROIIndex).CurvesCor(TempIndex)=[];
    structAxialROI(ROIIndex).OrganCurveNum=length(structAxialROI(ROIIndex).CurvesCor);    
end


%%update structAxialROI---Store new
hLine=findobj(handles.AxesImageAxial, 'Type', 'Line', 'UserData', [{'Contour'}, {[ROIName, num2str(PlanIndex)]}]);

if ~isempty(hLine)
    for i=1:length(hLine)
        TempX=(get(hLine(i), 'XData'))'; TempY=(get(hLine(i), 'YData'))';
        
        structAxialROI(ROIIndex).ZLocation=[structAxialROI(ROIIndex).ZLocation; CurrentZLoc];
        structAxialROI(ROIIndex).CurvesCor=[structAxialROI(ROIIndex).CurvesCor; {[TempX, TempY]}];
        structAxialROI(ROIIndex).OrganCurveNum=structAxialROI(ROIIndex).OrganCurveNum+1; 
    end
end

handles.PlansInfo.structAxialROI{PlanIndex}=structAxialROI;

guidata(handles.figure1, handles);







