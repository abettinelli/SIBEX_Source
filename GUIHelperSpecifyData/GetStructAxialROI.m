function CDataSetInfo=GetStructAxialROI(CDataSetInfo, RowIndex, ColumnIndex, handles, UserTable)
ROIIndex=RowIndex;

switch UserTable
    case 0
        PlanName=GetPlanNameFromTableHeader(handles.UITableROI, ColumnIndex);
        PlanNameAll=GetPlanNameAll(handles.PlansInfo);
        
        PlanIndex=strmatch(PlanName, PlanNameAll, 'exact');
    case 1
        PlanIndex=length(handles.PlansInfo.PlanNameStr);
end

structViewROI=handles.PlansInfo.structAxialROI{PlanIndex};
CDataSetInfo.structAxialROI=structViewROI(ROIIndex);

