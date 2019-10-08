function structAxialROI=ROIImportMethod_Pinnacle(FileName, ImageDataInfo)

%Import
try
    hFig=findobj(0, 'Type', 'figure', 'Name', 'Import ROIs');
    
    PHandles=guidata(hFig);
    PinnType=get(PHandles.RadiobuttonPinnV9, 'Value');
    
    [DXStart, DYStart]=GetDiffStartPoint(PinnType, ImageDataInfo);
    
    structAxialROI=LoadROIStructs(FileName, 'Fake.roi', 'Fake.roi', [DXStart, DYStart]);
catch
    structAxialROI=[];
end

