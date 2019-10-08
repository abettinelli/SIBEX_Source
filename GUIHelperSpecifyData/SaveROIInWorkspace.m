function SaveROIInWorkspace(handles)

TableData=get(handles.UITableROIUser, 'Data');

%Delete Old UserROI Data
if exist([handles.PatPath, '\User\UserROI.roi'], 'file')
    delete([handles.PatPath, '\User\UserROI.roi']);
end

if exist([handles.PatPath, '\User\UserROI.mat'], 'file')
    delete([handles.PatPath, '\User\UserROI.mat']);
end


%Save UserROI
if ~isempty(TableData)
    hStatus=StatusProgressTextCenterIFOA('IBEX', 'Saving user ROIs ...', handles.figure1);
    set(handles.figure1, 'Pointer', 'watch');
    drawnow;

    structAxialROI=handles.PlansInfo.structAxialROI{end};
    
    if ~exist([handles.PatPath, '\User'])
        mkdir([handles.PatPath, '\User']);        
    end
    
    %Plan.roi format
    structAxialROI=UpdateStructAxialROIColor(structAxialROI, TableData);    

    WriteROIStruct(structAxialROI, [handles.PatPath, '\User\UserROI.roi'],  [0, 0], 'IFOA^ROI^^^');
    
    %Matlab format
    save([handles.PatPath, '\User\UserROI.mat'], '-mat', 'structAxialROI');
    
    delete(hStatus);
    set(handles.figure1, 'Pointer', 'arrow');
    drawnow;
end


