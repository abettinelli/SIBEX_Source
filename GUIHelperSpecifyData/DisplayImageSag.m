function DisplayImageSag(handles)

ImageDataInfoAxial=GetImageDataInfo(handles, 'Axial');
ImageDataInfoCor=GetImageDataInfo(handles, 'Cor');
ImageDataInfoSag=GetImageDataInfo(handles, 'Sag');

%Clean TextStatus, distance line,
set(handles.TextStatus, 'String', '', 'Visible', 'Off');

hTemp=findobj(gcf, 'UserData', 'Length');
delete(hTemp);

%Update Location
XLoc=(handles.SliceNumSag-1)*ImageDataInfoSag.XPixDim+ImageDataInfoSag.XLimMin;
set(handles.TextXLoc, 'String', sprintf('%.3f', XLoc));

%Update Image
%axes(handles.AxesImageSag)

hImage=findobj(handles.AxesImageSag, 'Type', 'Image');
SagImage=(squeeze(ImageDataInfoSag.ImageData(:, handles.SliceNumSag, :)))';

if ~isfield(ImageDataInfoSag, 'LayerInfo')
    set(hImage, 'CData', SagImage);
else
    %Update Image
    UserData=get(hImage, 'UserData');
    
    if length(hImage) > 1
        TempIndex=cellfun('isempty', UserData);
        hImage=hImage(TempIndex);
    end
    set(hImage, 'CData', SagImage);
    
    %Update Layer
    for i=1:length(ImageDataInfoSag.LayerInfo)
        CurrentSliceLoc=XLoc;
        
        [MaskData, ImposeData]=GetLayerMaskData(ImageDataInfoSag, CurrentSliceLoc, i, 'Sag');            
                    
        hImage=findobj(handles.AxesImageSag, 'Type', 'Image', 'UserData', ['Layer', num2str(i)]);
         
        if ishandle(hImage)
            set(hImage, 'CData', ImposeData, 'AlphaData', double(MaskData)*ImageDataInfoSag.LayerInfo(i).Alpha);
        else
            image(ImposeData, 'UserData', ['Layer', num2str(i)],'Parent', handles.AxesImageSag, ...
                'XData', [ImageDataInfoSag.YLimMin, ImageDataInfoSag.YLimMax], 'YData', [ImageDataInfoSag.ZLimMin, ImageDataInfoSag.ZLimMax],...
                'AlphaData', double(MaskData)*ImageDataInfoSag.LayerInfo(i).Alpha, 'AlphaDataMapping', 'none');           
        end
    end
end

%Cross Line
if isequal(get(handles.TogglebuttonCross, 'Value'), get(handles.TogglebuttonCross, 'Max'))
    hTemp=findobj(handles.AxesImageAxial, 'UserData', 'Cross');
    delete(hTemp);
    
    XLim=[ImageDataInfoAxial.XLimMin, ImageDataInfoAxial.XLimMax];
    YLim=[ImageDataInfoAxial.YLimMin, ImageDataInfoAxial.YLimMax];
    
    XLoc=(handles.SliceNumSag-1)*ImageDataInfoSag.XPixDim+ImageDataInfoSag.XLimMin;
    YLoc=(handles.SliceNumCor-1)*ImageDataInfoCor.YPixDim+ImageDataInfoCor.YLimMin;
    
    plot(handles.AxesImageAxial, XLim, [YLoc, YLoc], 'Color', 'w', 'UserData', 'Cross');
    plot(handles.AxesImageAxial, [XLoc, XLoc], YLim, 'Color', 'w', 'UserData', 'Cross');
    
    hTemp=findobj(handles.AxesImageCor, 'UserData', 'Cross');
    delete(hTemp);
    
    XLim=[ImageDataInfoCor.XLimMin, ImageDataInfoCor.XLimMax];
    YLim=[min(ImageDataInfoCor.TablePos), max(ImageDataInfoCor.TablePos)];
    
    ZLoc=ImageDataInfoAxial.TablePos(handles.SliceNum);
    XLoc=(handles.SliceNumSag-1)*ImageDataInfoSag.XPixDim+ImageDataInfoSag.XLimMin;
    
    plot(handles.AxesImageCor, XLim, [ZLoc, ZLoc], 'Color', 'w', 'UserData', 'Cross');
    plot(handles.AxesImageCor, [XLoc, XLoc], YLim, 'Color', 'w', 'UserData', 'Cross');   
end

%ROIs
ContourOffAll(handles, 'Sag');

for i=1:2
    switch i
        case 1
            TableHandle=handles.UITableROI;
            UserTable=0;
        case 2
            TableHandle=handles.UITableROIUser;
            UserTable=1;
    end
    
    TableData=get(TableHandle, 'Data');
    
     if isempty(TableData)
        continue;
     end
    
    TableDataIndex=cellfun(@IsTrueCell, TableData);
    
    [RowIndexT, ColumnIndexT]=find(TableDataIndex);
    
    TableData=get(TableHandle, 'Data');
    
    for i=1:length(RowIndexT)
        RowIndex=RowIndexT(i);
        ColumnIndex=ColumnIndexT(i);
        
        DisplayContourOn(RowIndex, ColumnIndex, TableData, handles, 'Sag', UserTable);
    end
end

%Update AutoSegBox
if isfield(handles, 'hRectAxial') && isa(handles.hRectAxial, 'imrect') && ...
        isequal(get(handles.TogglebuttonAutoSegBound, 'Value'),  get(handles.TogglebuttonAutoSegBound, 'Max'))
    
    BoxPos=getPosition(handles.hRectAxial);
    if (XLoc <= (BoxPos(1)+BoxPos(3))) && (XLoc >= BoxPos(1))
        set(handles.hRectSag, 'Visible', 'On');
    else
        set(handles.hRectSag, 'Visible', 'Off');
    end
end


hLine=plot(handles.AxesImageSag, 1,1);
delete(hLine);
