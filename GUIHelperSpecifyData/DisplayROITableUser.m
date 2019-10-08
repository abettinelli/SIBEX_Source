
function DisplayROITableUser(PlansInfo, UITableROIUser)
%From Users
TableHeader=FormatROITableHeader;
TableHeader(1)=...
    {['<html><b><center><font size="4" face="Calibri" color="rgb(0,0,255)">', 'User']};

TableFormat={'logical', 'char', 'char', {'-', ':', '--', '-.'}};
TableEdit=[true, true, false, true];
TableWidth={60, 135, 60, 60};

%Display
PlanIndex=find(PlansInfo.PlanIDList==99999);

%No User Data
if isempty(PlanIndex)
    set(UITableROIUser, 'Visible', 'on', 'Enable', 'on', 'Data', '', ...
        'ColumnName', TableHeader, 'ColumnFormat', TableFormat, ...
        'ColumnEditable', logical(TableEdit), 'ColumnWidth', TableWidth);
    
    return;
end

%Yes User Data   
structAxialROI=PlansInfo.structAxialROI{PlanIndex};

%Table Data
TableData=repmat({''}, length(structAxialROI), length(TableHeader));
    
ROILen=length(structAxialROI);

if ROILen > 0
    %Check box
    TableData(1:ROILen, 1)=repmat({false}, ROILen, 1);
    
    %ROI Name
    ROIName=GetROIName(structAxialROI);
    TableData(1:ROILen, 2)=ROIName;
    
    %ROI Color
    ROIColor=GetROIColorDisplay(structAxialROI);
    TableData(1:ROILen, 3)=ROIColor;
    
    %Line Style
    TableData(1:ROILen, 4)=repmat({'-'}, ROILen, 1);
    
    set(UITableROIUser, 'Visible', 'on', 'Enable', 'on', 'Data', TableData, ...
        'ColumnName', TableHeader, 'ColumnFormat', TableFormat, ...
        'ColumnEditable', logical(TableEdit), 'ColumnWidth', TableWidth);
end
    
       

