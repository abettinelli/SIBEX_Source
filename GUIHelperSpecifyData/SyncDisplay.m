function SyncDisplay(handles, PHandles)
for i=1:2
    switch i 
        case 1
            TableData=get(PHandles.UITableROI, 'Data');
            set(handles.UITableROI, 'Data', TableData);
            jUITable=handles.jUITableROI;
        case 2
            TableData=get(PHandles.UITableROIUser, 'Data');
            set(handles.UITableROIUser, 'Data', TableData);            
            jUITable=handles.jUITableROIUser;
    end
              
    PlanLen=size(TableData, 2)/4;
    
    for k=1:PlanLen
        SelectMat=TableData(:, 4*(k-1)+1);
        
        SelectIndex=cellfun(@IsTrueCell, SelectMat);
        SelectIndex=find(SelectIndex > 0);
        
        if ~isempty(SelectIndex)
            for j=1:length(SelectIndex)
                jUITable.setValueAt(true, SelectIndex(j)-1, 4*(k-1));
                pause(handles.TableSetValuePause);
                
                handles=guidata(handles.figure1);
                guidata(handles.figure1, handles);
            end
        end
    end        
end