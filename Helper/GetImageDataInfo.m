function ImageDataInfo=GetImageDataInfo(handles, Mode)

switch Mode
    case 'Axial'
        if ~isempty(handles.ImageDataAxialInfo)
            ImageDataInfo=handles.ImageDataAxialInfo;
        else
            if ~isempty(handles.ImageDataSagInfo)
                ImageDataInfo=handles.ImageDataSagInfo;
            else
                ImageDataInfo=handles.ImageDataCorInfo;
            end
        end
        
    case 'Cor'
        if ~isempty(handles.ImageDataCorInfo)
            ImageDataInfo=handles.ImageDataCorInfo;
        else
            if ~isempty(handles.ImageDataAxialInfo)
                ImageDataInfo=handles.ImageDataAxialInfo;
            else
                ImageDataInfo=handles.ImageDataSagInfo;
            end
        end        
        
    case 'Sag'
        if ~isempty(handles.ImageDataSagInfo)
            ImageDataInfo=handles.ImageDataSagInfo;
        else
            if ~isempty(handles.ImageDataAxialInfo)
                ImageDataInfo=handles.ImageDataAxialInfo;
            else
                ImageDataInfo=handles.ImageDataCorInfo;
            end
        end
end