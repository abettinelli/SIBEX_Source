function UpdateCurrentROIInfo(RowIndex, ColumnIndex, TableData, handles, UserTable)

%Plan Name
if UserTable > 0
    PlanStr='User';
    TableHandle=handles.UITableROIUser;
else
    TableHeader=get(handles.UITableROI, 'ColumnName');
    PlanStr=TableHeader{ColumnIndex};
    PlanStr=GetHtmlValue(PlanStr);
    
    TableHandle=handles.UITableROI;
end

PlanIndex=strmatch(PlanStr, get(handles.PopupmenuPlanName, 'String'), 'exact');
set(handles.PopupmenuPlanName, 'Value', PlanIndex);

%ROI Name
ROIName=TableData(:, ColumnIndex+1);
set(handles.PopupmenuROIName, 'String', [{' '}; ROIName], 'Value', RowIndex+1);

%ROI Color
TableData=get(TableHandle, 'Data');
ColorCell=TableData{RowIndex, ColumnIndex+2};
OldColor=GetColorFromHtml(ColorCell)/255;

set(handles.PushbuttonROIColor, 'BackgroundColor', OldColor);

%Enable Edit UI
SetEditUIOnOff(handles, 'On');




