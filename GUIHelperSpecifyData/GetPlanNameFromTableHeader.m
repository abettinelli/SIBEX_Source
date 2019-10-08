function PlanName=GetPlanNameFromTableHeader(UITableROI, ColumnIndex)
TableHeader=get(UITableROI, 'ColumnName');
PlanName=TableHeader{ColumnIndex};
PlanName=GetHtmlValue(PlanName);