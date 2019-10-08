function OffOnUserROI(handles, RowIndex, Mode)
TableData=get(handles.UITableROIUser, 'Data');
    
ColumnIndex=1;
UserTable=1;

if isequal(Mode, 'On')
    DisplayContourOff(RowIndex, ColumnIndex, TableData, handles, UserTable);
    
    DisplayContourOn(RowIndex, ColumnIndex, TableData, handles, 'Axial', UserTable);
    
    ROIMode=get(handles.UIButtonGroupPanel, 'SelectedObject');
    if ROIMode == handles.RadiobuttonROIModePoly
        DisplayContourOn(RowIndex, ColumnIndex, TableData, handles, 'Cor', UserTable);
        handles=guidata(handles.figure1);
        guidata(handles.figure1, handles);
        
        DisplayContourOn(RowIndex, ColumnIndex, TableData, handles, 'Sag', UserTable);
        handles=guidata(handles.figure1);
        guidata(handles.figure1, handles);
    end
    
    %Update Current ROI
    UpdateCurrentROIInfo(RowIndex, ColumnIndex, TableData, handles, UserTable);
else
    DisplayContourOff(RowIndex, ColumnIndex, TableData, handles, UserTable);
    
    %Update Current ROI
    if UserTable < 1
        PlanName=GetPlanNameFromTableHeader(handles.UITableROI, ColumnIndex);
    else
        PlanName='User';
    end
    
    PlanNameList=get(handles.PopupmenuPlanName, 'String');
    PlanNameValue=get(handles.PopupmenuPlanName, 'Value');
    CurrentPlan=PlanNameList{PlanNameValue};
    
    ROIName=TableData{RowIndex, ColumnIndex+1};
    
    ROINameList=get(handles.PopupmenuROIName, 'String');
    ROINameValue=get(handles.PopupmenuROIName, 'Value');
    CurrentROI=ROINameList{ROINameValue};
    
    if isequal(PlanName, CurrentPlan) && isequal(ROIName, CurrentROI)
        SetEditUIOnOff(handles, 'Off');
    end
end