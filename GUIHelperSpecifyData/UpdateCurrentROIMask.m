function UpdateCurrentROIMask(handles)

%Initialization
[ROIName, PlanIndex]=GetCurrentROIInfo(handles);

ImageDataInfo=GetImageDataInfo(handles, 'Axial');
CurrentZLoc=ImageDataInfo.TablePos(handles.SliceNum);

structAxialROI=handles.PlansInfo.structAxialROI{PlanIndex};
ROIIndex=strmatch(ROIName, {structAxialROI.name}, 'exact');

hLine=findobj(handles.AxesImageAxial, 'Type', 'Line', 'UserData', 'ContourNudge');
NudgeLineX=get(hLine, 'XData'); NudgeLineY=get(hLine, 'YData');

%Axial
hLine=findobj(handles.AxesImageAxial, 'Type', 'Line', 'UserData', [{'Contour'}, {[ROIName, num2str(PlanIndex)]}]);

%Current view in the bitmap
NudgeBinary=BWFillROI([], [], handles, CurrentZLoc, NudgeLineX, NudgeLineY);

if isfield(handles, 'CurrentBinary')
    CurrentBinary=handles.CurrentBinary;
    
    if handles.ContourNudgeInside == 1
        BinaryAnd=ExtendBWMatDim(CurrentBinary, NudgeBinary, 'Xor');
        TempIndex=find(BinaryAnd.MaskData > 0);
    else
        BinaryAnd=ExtendBWMatDim(CurrentBinary, NudgeBinary, 'And');
        TempIndex=find(BinaryAnd.MaskData > 1);
    end
    
    if isempty(TempIndex)
        return;
    end
    
    TempBinary=BinaryAnd;
    TempBinary.MaskData=zeros([TempBinary.YDim, TempBinary.XDim, TempBinary.ZDim], 'uint8');
    
    CurrentBinary=ExtendBWMatDim(TempBinary, CurrentBinary, 'And');
    
    if handles.ContourNudgeInside == 1
        CurrentBinary.MaskData(TempIndex)=uint8(1);
    end
    
    if handles.ContourNudgeInside == 0
        CurrentBinary.MaskData(TempIndex)=uint8(0);
    end
    
    handles.CurrentBinary=CurrentBinary;
else    
    handles.CurrentBinary=NudgeBinary;
end

guidata(handles.figure1, handles);

