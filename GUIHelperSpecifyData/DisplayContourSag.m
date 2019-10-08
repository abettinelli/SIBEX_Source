function DisplayContourSag(BWMatIndex, PlanIndex, ROIName, ROIColor, ROILineStyle, ModeStr, handles)

%Off contour editing leftover
ResetContourNudge(handles)

%Off ROI
if isequal(ModeStr, 'Off')
    UserData{1}='Contour';
    UserData{2}=deblank([ROIName, num2str(PlanIndex)]);
    
    hLine=findobj(handles.AxesImageSag, 'Type', 'line', 'UserData', UserData);
    
    if ~isempty(hLine)
        delete(hLine);
    end
    
    return;
end


%On ROI
ImageDataInfo=GetImageDataInfo(handles, 'Sag');

CurrentLoc=str2num(get(handles.TextXLoc, 'String'));

BWMatInfo=handles.BWMatInfo(BWMatIndex);

structCurveCor=GetCurveCor(CurrentLoc, BWMatInfo);

if ~isempty(structCurveCor)
    [RowNum, ColNum]=size(structCurveCor);
    for mm=1:ColNum
        UserData={};
        UserData{1}='Contour'; UserData{2}=deblank([ROIName, num2str(PlanIndex)]);
        
        LineData=structCurveCor(mm).LineData;
        
        plot(handles.AxesImageSag, LineData(:,1), LineData(:,2), ...,
            'Color', ROIColor, 'UserData', UserData, 'LineStyle',  ROILineStyle, 'LineWidth',  1.5);
    end
end



function CurvesCor=GetCurveCor(CurrentLoc, BWMatInfo)
CurvesCor=[];

if isempty(BWMatInfo.MaskData)
    return;
end

if (CurrentLoc < BWMatInfo.XStart) || (CurrentLoc >BWMatInfo.XStart+(BWMatInfo.XDim-1)* BWMatInfo.XPixDim)
    return;
end

SliceNum=round((CurrentLoc-BWMatInfo.XStart)/BWMatInfo.XPixDim+1);
% SliceNum=BWMatInfo.XDim-SliceNum+1;

BWSlice=squeeze(BWMatInfo.MaskData(:, SliceNum,  :));
BWSlice=BWSlice';

CurveContour = bwboundaries(BWSlice);

if ~isempty(CurveContour)
    TempCurveNum=0;
    
    for kk=1:length(CurveContour)
        SubSliceContour=CurveContour{kk};
        
        if length(SubSliceContour) >=5
            %Update curve number
            TempCurveNum=TempCurveNum+1;
            
            ZCor=floor(SubSliceContour(:, 1)); YCor=floor(SubSliceContour(:, 2));
            YCor=BWMatInfo.YDim-YCor+1;
            
            YCor2=BWMatInfo.YStart+(YCor-1)*BWMatInfo.YPixDim;
            ZCor2=BWMatInfo.ZStart+(ZCor-1)*BWMatInfo.ZPixDim;
            
            CurvesCor(TempCurveNum).LineData=[YCor2,ZCor2];
        end
        
    end
end






