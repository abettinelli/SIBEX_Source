function SetColormap(Modality, handles, ModeStr)
if isequal(ModeStr, 'Init')
    if isequal(Modality, 'CT')
        set(handles.PopupmenuColorMap, 'Value', 1);
    end
    
    if isequal(Modality, 'PT')
        set(handles.PopupmenuColorMap, 'Value', 2);
    end
end

ColormapStr=get(handles.PopupmenuColorMap, 'String');
CIndex=get(handles.PopupmenuColorMap, 'Value');

TempColor=imread(['CM', ColormapStr{CIndex}, '.jpg']);

set(handles.PushbuttonColorMap, 'String', '', 'CData', TempColor, 'Enable', 'inactive');

colormap(handles.AxesImageAxial, ColormapStr{CIndex});
colormap(handles.AxesImageCor, ColormapStr{CIndex});
colormap(handles.AxesImageSag, ColormapStr{CIndex});