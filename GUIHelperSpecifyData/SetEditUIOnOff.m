function SetEditUIOnOff(handles, ModeStr)

set(handles.TogglebuttonContourNudge, 'Enable', ModeStr);
set(handles.TogglebuttonContourCut, 'Enable', ModeStr);
set(handles.TogglebuttonContourDraw, 'Enable', ModeStr);
set(handles.TogglebuttonContourTrail, 'Enable', ModeStr);
set(handles.PushbuttonContourCopy, 'Enable', ModeStr);
set(handles.PushbuttonInterpolate, 'Enable', ModeStr);
set(handles.PushbuttonDelete, 'Enable', ModeStr);


if isequal(ModeStr, 'Off')    
    AllPlanName=GetAllValidPlanName(handles);
    set(handles.PopupmenuPlanName, 'String', AllPlanName, 'Value', 1);
    
    set(handles.PopupmenuROIName, 'String', {' '}, 'Value', 1);
    
    set(handles.PushbuttonROIColor, 'BackgroundColor', [212, 208, 200]/255);
else
    PlanList=get(handles.PopupmenuPlanName, 'String');
    PlanValue=get(handles.PopupmenuPlanName, 'Value');
    
    if PlanValue < length(PlanList)
        set(handles.PushbuttonDelete, 'Enable', 'off');
    end
end

