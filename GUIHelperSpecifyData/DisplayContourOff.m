function DisplayContourOff(RowIndex, ColumnIndex, TableData, handles, UserTable)

ROIIndex=RowIndex;

switch UserTable
    case 0
        TableHeader=get(handles.UITableROI, 'ColumnName');
        PlanName=TableHeader{ColumnIndex};
        PlanName=GetHtmlValue(PlanName);
        
        PlanNameAll=...
            strcat(strtrim(cellstr(num2str(handles.PlansInfo.PlanIDList))), {' '}, handles.PlansInfo.PlanNameStr);
        
        PlanIndex=strmatch(PlanName, PlanNameAll, 'exact');
    case 1
        PlanIndex=length(handles.PlansInfo.PlanNameStr);
end

ROIName=TableData{RowIndex, ColumnIndex+1};

DisplayContourAxial(ROIIndex, PlanIndex, ROIName, [], [], 'Off', handles);
DisplayContourCor([], PlanIndex, ROIName, [], [], 'Off', handles);
DisplayContourSag([], PlanIndex, ROIName, [], [], 'Off', handles);

