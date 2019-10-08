function DrawNudgeContour(handles)
hLine=findobj(handles.AxesImageAxial, 'Type', 'Line', 'UserData', 'ContourNudge');

if isempty(hLine)
    %Draw New Circle
    CursorPos=get(handles.AxesImageAxial, 'CurrentPoint');
    
    TempX=[handles.NudgeHalfX, fliplr(handles.NudgeHalfX)]+CursorPos(1)-max(handles.NudgeHalfX);
    TempY=[handles.NudgeHalfY, -handles.NudgeHalfY]+CursorPos(3)+max(handles.NudgeHalfY);
    
    %Plot Circle
    plot(handles.AxesImageAxial, TempX, TempY, 'r', 'UserData', 'ContourNudge');
end
