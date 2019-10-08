function BWMatIndex=GenerateROIBinaryMask(RowIndex, ColumnIndex, handles, UserTable)

ROIIndex=RowIndex;

switch UserTable
    case 0
        PlanName=GetPlanNameFromTableHeader(handles.UITableROI, ColumnIndex);
        PlanNameAll=GetPlanNameAll(handles.PlansInfo);
        
        PlanIndex=strmatch(PlanName, PlanNameAll, 'exact');
        
        TableData=get(handles.UITableROI, 'Data');
    case 1
        PlanIndex=length(handles.PlansInfo.PlanNameStr);
        TableData=get(handles.UITableROIUser, 'Data');
end

ROIName=TableData{RowIndex, ColumnIndex+1};

%BWMat exist
MaskExistFlag=0;        
if ~isempty(handles.BWMatInfo)
    ROIPlanStr={handles.BWMatInfo.ROINamePlanIndex}';
    
    BWMatIndex=strmatch([deblank(ROIName), num2str(PlanIndex)], ROIPlanStr, 'exact');
    
    if ~isempty(BWMatIndex)
        MaskExistFlag=1;
    end
end

%Get BWMat
if MaskExistFlag < 1
    set(handles.figure1, 'Pointer', 'watch');
    
    hStatus=StatusProgressTextCenterIFOA('IFOA', 'Computing ROI mask ...', handles.figure1);
    drawnow;
    %tic
    BWMatInfoT=BWFillROI(ROIIndex, PlanIndex, handles); % Bettinelli
    
    BWMatInfoT.ROINamePlanIndex=[deblank(ROIName), num2str(PlanIndex)];
    %toc
    
    handles.BWMatInfo=[ handles.BWMatInfo, BWMatInfoT];
    
    guidata(handles.figure1, handles);
    
    BWMatIndex=length(handles.BWMatInfo);
    
    delete(hStatus);
    
    set(handles.figure1, 'Pointer', 'arrow');
    drawnow;
end
