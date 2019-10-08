function handles=SetDefaultWL(Modality, handles)
if isequal(Modality, 'CT')
    set(handles.PopupmenuWL, 'Value', 1);
end

if isequal(Modality, 'PT')
    set(handles.PopupmenuWL, 'Value', 9);
end

WLIndex=get(handles.PopupmenuWL, 'Value');
handles.GrayMin=handles.WLRegionMat(WLIndex, 2);
handles.GrayMax=handles.WLRegionMat(WLIndex, 3);


