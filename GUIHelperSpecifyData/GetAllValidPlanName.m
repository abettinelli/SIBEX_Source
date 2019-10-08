function AllPlanName=GetAllValidPlanName(handles)
AllPlanName={' '};

TableData=get(handles.UITableROI, 'Data');
if ~isempty(TableData)
    TableHeader=get(handles.UITableROI, 'ColumnName');
    
    for ColumnIndex=1:size(TableData, 2)/4
        PlanName=TableHeader{(ColumnIndex-1)*4+1};
        PlanName=GetHtmlValue(PlanName);
        
        AllPlanName=[AllPlanName; {PlanName}];
    end
end
         
AllPlanName=[AllPlanName; {'User'}];
