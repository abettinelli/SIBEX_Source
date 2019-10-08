function DisplayImage(handles)

ImageDataInfoAxial=GetImageDataInfo(handles, 'Axial');

ImageDataInfoCor=GetImageDataInfo(handles, 'Cor');
ImageDataInfoSag=GetImageDataInfo(handles, 'Sag');

%Clean TextStatus, distance line,
set(handles.TextStatus, 'String', '', 'Visible', 'Off');

hTemp=findobj(handles.figure1, 'UserData', 'Length');
delete(hTemp);

%Update Location
ZLoc=ImageDataInfoAxial.TablePos(handles.SliceNum);
set(handles.TextZLoc, 'String', sprintf('%.3f', ZLoc));

%Update Image
%axes(handles.AxesImageAxial)

hImage=findobj(handles.AxesImageAxial, 'Type', 'Image');

if ~isfield(ImageDataInfoAxial, 'LayerInfo')    
    set(hImage, 'CData', ImageDataInfoAxial.ImageData(:, :, handles.SliceNum)); 
else
    %Update Image
    UserData=get(hImage, 'UserData');
    
    if length(hImage) > 1
        TempIndex=cellfun('isempty', UserData);
        hImage=hImage(TempIndex);
    end
    set(hImage, 'CData', ImageDataInfoAxial.ImageData(:, :, handles.SliceNum));   
    
    %Update Layer   
    for i=1:length(ImageDataInfoAxial.LayerInfo)        
        CurrentSliceLoc=ZLoc;
        
        [MaskData, ImposeData]=GetLayerMaskData(ImageDataInfoAxial, CurrentSliceLoc, i, 'Axial');
            
        hImage=findobj(handles.AxesImageAxial, 'Type', 'Image', 'UserData', ['Layer', num2str(i)]);
        if ishandle(hImage)
            set(hImage, 'CData', ImposeData, 'AlphaData', double(MaskData)*ImageDataInfoAxial.LayerInfo(i).Alpha);
        else
%             axes( handles.AxesImageAxial);
%             set(handles.figure1, 'CurrentAxes', handles.AxesImageAxial);
%             hold on, 
            image(ImposeData, 'UserData', ['Layer', num2str(i)], 'Parent', handles.AxesImageAxial, ...
                'XData', [ImageDataInfoAxial.XLimMin, ImageDataInfoAxial.XLimMax], 'YData', [ImageDataInfoAxial.YLimMin, ImageDataInfoAxial.YLimMax],...
                'AlphaData', double(MaskData)*ImageDataInfoAxial.LayerInfo(i).Alpha, 'AlphaDataMapping', 'none');            
        
        end
    end
    
end

%Cross Line
if isequal(get(handles.TogglebuttonCross, 'Value'), get(handles.TogglebuttonCross, 'Max')) 
    hTemp=findobj(handles.AxesImageCor, 'UserData', 'Cross');
    delete(hTemp);    
          
    XLim=[ImageDataInfoCor.XLimMin, ImageDataInfoCor.XLimMax];
    YLim=[min(ImageDataInfoCor.TablePos), max(ImageDataInfoCor.TablePos)];
    
    ZLoc=ImageDataInfoAxial.TablePos(handles.SliceNum);
    XLoc=(handles.SliceNumSag-1)*ImageDataInfoSag.XPixDim+ImageDataInfoSag.XLimMin;
    
    plot(handles.AxesImageCor, XLim, [ZLoc, ZLoc], 'Color', 'w', 'UserData', 'Cross');
    plot(handles.AxesImageCor, [XLoc, XLoc], YLim, 'Color', 'w', 'UserData', 'Cross');
    
    hTemp=findobj(handles.AxesImageSag, 'UserData', 'Cross');
    delete(hTemp);
    
    XLim=[ImageDataInfoSag.YLimMin, ImageDataInfoSag.YLimMax];
    YLim=[min(ImageDataInfoSag.TablePos), max(ImageDataInfoSag.TablePos)];
    
    ZLoc=ImageDataInfoAxial.TablePos(handles.SliceNum);
    YLoc=(handles.SliceNumCor-1)*ImageDataInfoCor.YPixDim+ImageDataInfoCor.YLimMin;
    
    plot(handles.AxesImageSag, XLim, [ZLoc, ZLoc], 'Color', 'w', 'UserData', 'Cross');
    plot(handles.AxesImageSag, [YLoc, YLoc], YLim, 'Color', 'w', 'UserData', 'Cross');
end

%ROIs
ContourOffAll(handles, 'Axial');

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
        
        DisplayContourOn(RowIndex, ColumnIndex, TableData, handles, 'Axial', UserTable);
    end
end

%Update AutoSegBox
if isfield(handles, 'hRectAxial') && isa(handles.hRectAxial, 'imrect') && ...
        isequal(get(handles.TogglebuttonAutoSegBound, 'Value'),  get(handles.TogglebuttonAutoSegBound, 'Max'))
    
    BoxPos=getPosition(handles.hRectCor);
    if (ZLoc <= (BoxPos(2)+BoxPos(4))) && (ZLoc >= BoxPos(2))
        set(handles.hRectAxial, 'Visible', 'On');
    else
        set(handles.hRectAxial, 'Visible', 'Off');
    end
end

hLine=plot(handles.AxesImageAxial, 1,1);
delete(hLine);

drawnow;

