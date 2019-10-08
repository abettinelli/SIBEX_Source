function KeyPressFcn_Callback(hObject, eventdata)
handles = guidata(gcbo);

%------------------------------------------------------------Suferior Navigator------------------------------------------------------
if isequal(get(handles.figure1, 'CurrentCharacter'), 'n') || isequal(get(handles.figure1, 'CurrentCharacter'), 'N') || isequal(get(gcf,'CurrentCharacter'), 31)
    ImageDataInfo=GetImageDataInfo(handles, 'Axial');
    
    SliceNum=handles.SliceNum+1;
    if SliceNum < length(ImageDataInfo.TablePos)
        handles.SliceNum=SliceNum;
        
        guidata(handles.figure1, handles);
        
        DisplayImage(handles);
    end
    
    handles=guidata(handles.figure1);
end


%--------------------------------------------------Inferior Navigator-------------------------------------------------------------

if isequal(get(handles.figure1, 'CurrentCharacter'), 'p') || isequal(get(handles.figure1, 'CurrentCharacter'), 'P') || isequal(get(gcf,'CurrentCharacter'), 30)
    SliceNum=handles.SliceNum-1;
    if SliceNum > 0
        handles.SliceNum=SliceNum;
        
        guidata(handles.figure1, handles);
        
        DisplayImage(handles);
    end   
    
    handles=guidata(handles.figure1);
end

guidata(hObject, handles); 