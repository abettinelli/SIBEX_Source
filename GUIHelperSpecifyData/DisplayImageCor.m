function DisplayImageCor(handles)

ImageDataInfoAxial=GetImageDataInfo(handles, 'Axial');
ImageDataInfoCor=GetImageDataInfo(handles, 'Cor');
ImageDataInfoSag=GetImageDataInfo(handles, 'Sag');

%Clean TextStatus, distance line,
set(handles.TextStatus, 'String', '', 'Visible', 'Off');

hTemp=findobj(gcf, 'UserData', 'Length');
delete(hTemp);

%Update Location
YLoc=(handles.SliceNumCor-1)*ImageDataInfoCor.YPixDim+ImageDataInfoCor.YLimMin;
set(handles.TextYLoc, 'String', sprintf('%.3f', YLoc));

%Update Image
%axes(handles.AxesImageCor)

hImage=findobj(handles.AxesImageCor, 'Type', 'Image');
CorImage=(squeeze(ImageDataInfoCor.ImageData(handles.SliceNumCor, :, :)))';

if size(CorImage, 2) < 2
    CorImage=CorImage';
end

if ~isfield(ImageDataInfoCor, 'LayerInfo')
    set(hImage, 'CData', CorImage);
else
    %Update Image
    UserData=get(hImage, 'UserData');
    
    if length(hImage) > 1
        TempIndex=cellfun('isempty', UserData);
        hImage=hImage(TempIndex);
    end
    set(hImage, 'CData', CorImage);
        
    %Update Layer   
    for i=1:length(ImageDataInfoCor.LayerInfo)
        CurrentSliceLoc=YLoc;
        
        [MaskData, ImposeData]=GetLayerMaskData(ImageDataInfoCor, CurrentSliceLoc, i, 'Cor');            
                    
        hImage=findobj(handles.AxesImageCor, 'Type', 'Image', 'UserData', ['Layer', num2str(i)]);
         
        if ishandle(hImage)
            set(hImage, 'CData', ImposeData, 'AlphaData', double(MaskData)*ImageDataInfoCor.LayerInfo(i).Alpha);
        else
            image(ImposeData, 'UserData', ['Layer', num2str(i)], 'Parent', handles.AxesImageCor, ...
                'XData', [ImageDataInfoCor.XLimMin, ImageDataInfoCor.XLimMax], 'YData', [ImageDataInfoCor.ZLimMin, ImageDataInfoCor.ZLimMax],...
                'AlphaData', double(MaskData)*ImageDataInfoCor.LayerInfo(i).Alpha, 'AlphaDataMapping', 'none');           
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
    
    hTemp=findobj(handles.AxesImageSag, 'UserData', 'Cross');
    delete(hTemp);
    
    XLim=[ImageDataInfoSag.YLimMin, ImageDataInfoSag.YLimMax];
    YLim=[min(ImageDataInfoSag.TablePos), max(ImageDataInfoSag.TablePos)];
    
    ZLoc=ImageDataInfoAxial.TablePos(handles.SliceNum);
    XLoc=(handles.SliceNumCor-1)*ImageDataInfoCor.YPixDim+ImageDataInfoCor.YLimMin;
    
    plot(handles.AxesImageSag, XLim, [ZLoc, ZLoc], 'Color', 'w', 'UserData', 'Cross');
    plot(handles.AxesImageSag, [XLoc, XLoc], YLim, 'Color', 'w', 'UserData', 'Cross');
end

%ROIs
ContourOffAll(handles, 'Cor');

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
        
        DisplayContourOn(RowIndex, ColumnIndex, TableData, handles, 'Cor', UserTable);
    end
end

%Update AutoSegBox
if isfield(handles, 'hRectAxial') && isa(handles.hRectAxial, 'imrect') && ...
        isequal(get(handles.TogglebuttonAutoSegBound, 'Value'),  get(handles.TogglebuttonAutoSegBound, 'Max'))
    BoxPos=getPosition(handles.hRectAxial);
    if (YLoc <= (BoxPos(2)+BoxPos(4))) && (YLoc >= BoxPos(2))
        set(handles.hRectCor, 'Visible', 'On');
    else
        set(handles.hRectCor, 'Visible', 'Off');
    end
end

hLine=plot(handles.AxesImageCor, 1,1);
delete(hLine);