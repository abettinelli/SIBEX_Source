function ContourOffAll(handles, AxesName)

switch AxesName
    case 'Axial'
        handlesAxes=handles.AxesImageAxial;
        
    case 'Cor'
        handlesAxes=handles.AxesImageCor;
        
    case 'Sag'
        handlesAxes=handles.AxesImageSag;
end

hLine=findobj(handlesAxes, 'Type', 'line');

%Off ROI display
for i=1:length(hLine)
    UserData=get(hLine(i), 'UserData');
    if ~isempty(UserData) && iscell(UserData)
        delete(hLine(i));
    end
end

    