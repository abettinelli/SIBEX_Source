function DisplayContourOn(RowIndex, ColumnIndex, TableData, handles, Mode, UserTable)

ROIIndex=RowIndex;

switch UserTable
    case 0
        PlanName=GetPlanNameFromTableHeader(handles.UITableROI, ColumnIndex);
        PlanNameAll=GetPlanNameAll(handles.PlansInfo);
        
        PlanIndex=strmatch(PlanName, PlanNameAll, 'exact');
    case 1
        PlanIndex=length(handles.PlansInfo.PlanNameStr);
end

ROIName=TableData{RowIndex, ColumnIndex+1};

ColorCell=TableData{RowIndex, ColumnIndex+2};
ROIColor=GetColorFromHtml(ColorCell)/255;

ROILineStyle=TableData{RowIndex, ColumnIndex+3};

%-----Conour on Axial view always
if isequal(Mode, 'Axial')
    DisplayContourAxial(ROIIndex, PlanIndex, ROIName, ROIColor, ROILineStyle, 'On', handles);
end


%----Contour on Sagittal and Coronal views
if isequal(Mode, 'Sag') || isequal(Mode, 'Cor')
    
    ROIMode=get(handles.UIButtonGroupPanel, 'SelectedObject');
    if ROIMode == handles.RadiobuttonROIModePoly
        
        %Generate ROI binary mask if not available
        BWMatIndex=GenerateROIBinaryMask(RowIndex, ColumnIndex, handles, UserTable);
        handles=guidata(handles.figure1);
        guidata(handles.figure1, handles);
        
        if isequal(Mode, 'Cor')
            DisplayContourCor(BWMatIndex, PlanIndex, ROIName, ROIColor, ROILineStyle, 'On', handles);
        end
        
        if isequal(Mode, 'Sag')
            DisplayContourSag(BWMatIndex, PlanIndex, ROIName, ROIColor, ROILineStyle, 'On', handles);
        end
    end
end







