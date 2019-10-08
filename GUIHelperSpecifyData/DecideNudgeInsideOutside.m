function DecideNudgeInsideOutside(handles)

%Initialization
[ROIName, PlanIndex]=GetCurrentROIInfo(handles);

ImageDataInfo=GetImageDataInfo(handles, 'Axial');
CurrentZLoc=ImageDataInfo.TablePos(handles.SliceNum);

structAxialROI=handles.PlansInfo.structAxialROI{PlanIndex};
ROIIndex=strmatch(ROIName, {structAxialROI.name}, 'exact');


%Nudge LIne
hLine=findobj(handles.AxesImageAxial, 'Type', 'Line', 'UserData', 'ContourNudge');
NudgeLineX=get(hLine, 'XData'); NudgeLineY=get(hLine, 'YData');

delete(hLine);

%Nudge Mask
NudgeBinary=BWFillROI([], [], handles, CurrentZLoc, NudgeLineX, NudgeLineY);

%ROI Line
hLine=findobj(handles.AxesImageAxial, 'Type', 'line', 'UserData', [{'Contour'}, {[ROIName, num2str(PlanIndex)]}]);

if ~isempty(hLine)
    CurrentBinary=GetCurrentROIMask(handles, CurrentZLoc, ROIName, PlanIndex);
    
    TempIndex=find(CurrentBinary.MaskData);
    
    if ~isempty(TempIndex)
        handles.CurrentBinary=CurrentBinary;
    else
        delete(hLine);
        
        handles.ContourNudgeInside=[];
        
        guidata(handles.figure1, handles);
        return;
    end       
    
    BinaryAnd=ExtendBWMatDim(CurrentBinary, NudgeBinary, 'And');
    
    TempIndex2=find(BinaryAnd.MaskData>1);
    TempIndexNudge=find(NudgeBinary.MaskData);
    
    if ~isempty(TempIndex2)
        if length(TempIndex2)/length(TempIndexNudge) > 0.5
            handles.ContourModifyFlag=1;
            handles.ContourNudgeInside=1;
        else
            handles.ContourModifyFlag=1;
            handles.ContourNudgeInside=0;
        end
    else
        handles.ContourModifyFlag=1;
        handles.ContourNudgeInside=0;
    end
else    
    handles.CurrentBinary=NudgeBinary;
    
    handles.ContourModifyFlag=1;
    handles.ContourNudgeInside=1;           
end

guidata(handles.figure1, handles);