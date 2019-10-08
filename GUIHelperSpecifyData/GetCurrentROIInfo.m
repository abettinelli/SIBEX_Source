function [ROIName, PlanIndex]=GetCurrentROIInfo(handles)

ROINameList=get(handles.PopupmenuROIName, 'String');
ROIValue=get(handles.PopupmenuROIName, 'Value');

ROIName=ROINameList{ROIValue};

PlanIndex=get(handles.PopupmenuPlanName, 'Value')-1;


