function UpdateDisplayFromMask(handles)
%Initialization
[ROIName, PlanIndex]=GetCurrentROIInfo(handles);

ImageDataInfo=GetImageDataInfo(handles, 'Axial');
CurrentZLoc=ImageDataInfo.TablePos(handles.SliceNum);

structAxialROI=handles.PlansInfo.structAxialROI{PlanIndex};
ROIIndex=strmatch(ROIName, {structAxialROI.name}, 'exact');

%delete Old lines
hLine=findobj(handles.AxesImageAxial, 'Type', 'Line', 'UserData', [{'Contour'}, {[ROIName, num2str(PlanIndex)]}]);
delete(hLine);

%put new lines
Color=get(handles.PushbuttonROIColor, 'BackgroundColor');

TempCurves=bwboundaries(handles.CurrentBinary.MaskData);
for kk=1:length(TempCurves)
    
    TempData=TempCurves{kk};
    
    if length(TempData) > handles.ContourNoArea
        LineX=TempData(1:2:end, 2); LineY=TempData(1:2:end,1);
        
        LineX=(LineX-1)*handles.CurrentBinary.XPixDim+handles.CurrentBinary.XStart;
        LineY=(handles.CurrentBinary.YDim-LineY)*handles.CurrentBinary.YPixDim+handles.CurrentBinary.YStart;
        
        plot(handles.AxesImageAxial, LineX, LineY, 'UserData', [{'Contour'}, {[ROIName, num2str(PlanIndex)]}], ...
            'Color', Color, 'LineWidth', 1.5);
    end
end