function DisplayContourCor(BWMatIndex, PlanIndex, ROIName, ROIColor, ROILineStyle, ModeStr, handles)

%Off contour editing leftover
ResetContourNudge(handles)

%Off ROI
if isequal(ModeStr, 'Off')
    UserData{1}='Contour';
    UserData{2}=deblank([ROIName, num2str(PlanIndex)]);
    
    hLine=findobj(handles.AxesImageCor, 'Type', 'line', 'UserData', UserData);
    
    if ~isempty(hLine)
        delete(hLine);
    end
    
    return;
end


%On ROI
ImageDataInfo=GetImageDataInfo(handles, 'Cor');

CurrentLoc=str2num(get(handles.TextYLoc, 'String'));

BWMatInfo=handles.BWMatInfo(BWMatIndex);

structCurveCor=GetCurveCor(CurrentLoc, BWMatInfo);

if ~isempty(structCurveCor)
    [RowNum, ColNum]=size(structCurveCor);
    for mm=1:ColNum
        UserData={};
        UserData{1}='Contour'; UserData{2}=deblank([ROIName, num2str(PlanIndex)]);
        
        LineData=structCurveCor(mm).LineData;
        
        plot(handles.AxesImageCor, LineData(:,1), LineData(:,2), ...,
            'Color', ROIColor, 'UserData', UserData, 'LineStyle',  ROILineStyle, 'LineWidth',  1.5);
    end
end


function CurvesCor=GetCurveCor(CurrentLoc, BWMatInfo)
CurvesCor=[];

if isempty(BWMatInfo.MaskData)
    return;
end

if (CurrentLoc < BWMatInfo.YStart) || (CurrentLoc >BWMatInfo.YStart+(BWMatInfo.YDim-1)* BWMatInfo.YPixDim)
    return;
end

SliceNum=round((CurrentLoc-BWMatInfo.YStart)/BWMatInfo.YPixDim+1);
SliceNum=BWMatInfo.YDim-SliceNum+1;

BWSlice=squeeze(BWMatInfo.MaskData(SliceNum, :, :));

if size(BWMatInfo.MaskData, 3) > 1
    BWSlice=BWSlice';
end

CurveContour = bwboundaries(BWSlice);

if ~isempty(CurveContour)
    TempCurveNum=0;
    
    for kk=1:length(CurveContour)
        SubSliceContour=CurveContour{kk};
        
        if length(SubSliceContour) >=5
            %Update curve number
            TempCurveNum=TempCurveNum+1;
            
            ZCor=floor(SubSliceContour(:, 1)); XCor=floor(SubSliceContour(:, 2));
            
            XCor2=BWMatInfo.XStart+(XCor-1)*BWMatInfo.XPixDim;
            ZCor2=BWMatInfo.ZStart+(ZCor-1)*BWMatInfo.ZPixDim;
            
            CurvesCor(TempCurveNum).LineData=[XCor2, ZCor2];
        end
        
    end
end





