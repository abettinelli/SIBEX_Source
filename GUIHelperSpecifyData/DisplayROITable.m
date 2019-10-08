function DisplayROITable(PlansInfo, UITableROI)
TableHeaderTemplate=FormatROITableHeader;

%No ROIs from plan
if  isempty(PlansInfo.PlanIDList)    
    set(UITableROI, 'Data', '', 'ColumnName', TableHeaderTemplate);   
    return;
end

%Yes ROIs from plan
ValidPlanIndex=[];
for i=1:length(PlansInfo.PlanIDList)
    if isequal(PlansInfo.PlanIDList(i), 99999)
        continue;
    end
    
    if ~isempty(PlansInfo.structAxialROI{i})
        ValidPlanIndex=[ValidPlanIndex; i];
    end
end

%No ROIs from plan
if  isempty(ValidPlanIndex)
    set(UITableROI, 'Data', '', 'ColumnName', TableHeaderTemplate);   
    return;
end

%Yes ROIs from Plans
TableFormatTemplate={[], 'char', 'char', {'-', ':',  '--', '-.'}};
TableEditTemplate=[true, false, false, true];
TableWidthTemplate={60, 100, 50, 40};

TableHeader=[]; TableFormat=[]; TableEdit=[]; TableWidth=[]; ROILenMax=0;
for i=1:length(ValidPlanIndex)
    PlanIndex=ValidPlanIndex(i);
    
    TableHeaderTemplate(1)=...
        {['<html><b><center><font size="4" face="Calibri" color="rgb(0,0,255)">', ...
        num2str( PlansInfo.PlanIDList(PlanIndex)), ' ' PlansInfo.PlanNameStr{PlanIndex}]};
    
    TableHeader=[TableHeader, TableHeaderTemplate];
    
    TableFormat=[TableFormat, TableFormatTemplate];
    TableEdit=[TableEdit, TableEditTemplate];
    TableWidth=[TableWidth, TableWidthTemplate];
    
    ROILenMax=max(ROILenMax, length(PlansInfo.structAxialROI{PlanIndex}));
end

%Table Data
TableData=repmat({''}, ROILenMax, length(TableHeader));
for i=1:length(ValidPlanIndex)
    PlanIndex=ValidPlanIndex(i);
    
    ROILen=length(PlansInfo.structAxialROI{PlanIndex});
    
    %Check box
    TableData(1:ROILen, (i-1)*4+1)=repmat({false}, ROILen, 1);
    
    %ROI Name
    ROIName=GetROIName(PlansInfo.structAxialROI{PlanIndex});
    TableData(1:ROILen, (i-1)*4+2)=ROIName;
    
    %ROI Color
    ROIColor=GetROIColorDisplay(PlansInfo.structAxialROI{PlanIndex});
    TableData(1:ROILen, (i-1)*4+3)=ROIColor;
    
    %Line Style
    if rem(i, 2) == 1
        TableData(1:ROILen, (i-1)*4+4)=repmat({'-'}, ROILen, 1);
    else
        TableData(1:ROILen, (i-1)*4+4)=repmat({':'}, ROILen, 1);
    end
end

set(UITableROI, 'Visible', 'on', 'Enable', 'on', 'Data', TableData, ...
        'ColumnName', TableHeader, 'ColumnFormat', TableFormat, ...
        'ColumnEditable', logical(TableEdit), 'ColumnWidth', TableWidth); 