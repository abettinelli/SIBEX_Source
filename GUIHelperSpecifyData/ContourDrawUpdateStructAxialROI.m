%Update bitmap and view after contour is drawn

function ContourDrawUpdateStructAxialROI(handles)
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

%Axial View
hLine=findobj(handles.AxesImageAxial, 'Type', 'line', 'UserData', 'ContourNudge');

if ~isempty(hLine)
    TempX=(get(hLine(1), 'XData'))'; TempY=(get(hLine(1), 'YData'))';

    if length(hLine) >=2
        for i=2:length(hLine)
            XData=get(hLine(i), 'XData'); YData=get(hLine(i), 'YData');
            TempX=[TempX; XData(end)];  TempY=[TempY; YData(end)];
        end
    end
    
    %Close
    XData=get(hLine(1), 'XData'); YData=get(hLine(1), 'YData');
    TempX=[TempX; XData(1)];  TempY=[TempY; YData(1)];    
else
    return;
end

delete(hLine);

%update structAxialROI
structAxialROI(ROIIndex).ZLocation=[structAxialROI(ROIIndex).ZLocation; CurrentZLoc];
structAxialROI(ROIIndex).CurvesCor=[structAxialROI(ROIIndex).CurvesCor; {[TempX, TempY]}];
structAxialROI(ROIIndex).OrganCurveNum=structAxialROI(ROIIndex).OrganCurveNum+1;

handles.PlansInfo.structAxialROI{PlanIndex}=structAxialROI;

guidata(handles.figure1, handles);







