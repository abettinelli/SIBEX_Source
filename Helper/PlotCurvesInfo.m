function PlotCurvesInfo(ReviewInfo, hFigure)
if~isfield(ReviewInfo, 'CurvesPlot')
    ReviewInfo.CurvesPlot=ones(1, length(ReviewInfo.CurvesInfo));
end

LineT=[]; LineD=[]; FigNum=0;
for i=1:length(ReviewInfo.CurvesInfo)
    CurveData=ReviewInfo.CurvesInfo(i).CurveData;
    
    if ReviewInfo.CurvesPlot(i) > 0
        ReviewFig=figure;
        FigNum=FigNum+1;
    end
    
    
    hold on,
    if isfield(ReviewInfo.CurvesInfo(i), 'LineStyle')
        hLine=plot(CurveData(:, 1), CurveData(:, 2), ReviewInfo.CurvesInfo(i).LineStyle);
    else
        hLine=plot(CurveData(:, 1), CurveData(:, 2));
    end
    
    if isfield(ReviewInfo.CurvesInfo(i), 'LineWidth')
        set(hLine, 'LineWidth', ReviewInfo.CurvesInfo(i).LineWidth);
    end
    
    if isfield(ReviewInfo.CurvesInfo(i), 'Description')
        LineT=[LineT; hLine];
        LineD=[LineD; {ReviewInfo.CurvesInfo(i).Description}];
    end
    
    if ReviewInfo.CurvesPlot(i) > 0
        SetFigBottomNum(ReviewFig, hFigure, (FigNum-1)/sum(ReviewInfo.CurvesPlot));
    end
    
    DrawLegend=0;
    %Last curve in the group
    if ReviewInfo.CurvesPlot(i) < 1 && (i  > length(ReviewInfo.CurvesInfo)-1)
        DrawLegend=1;
    end
    
    if ReviewInfo.CurvesPlot(i) < 1 && (i  < length(ReviewInfo.CurvesInfo)) && ReviewInfo.CurvesPlot(i+1) > 0
        DrawLegend=1;
    end
    
    if ReviewInfo.CurvesPlot(i) > 0 && (i  > length(ReviewInfo.CurvesInfo)-1)
        DrawLegend=1;
    end
    
    if ReviewInfo.CurvesPlot(i) > 0 && (i  < length(ReviewInfo.CurvesInfo)) && ReviewInfo.CurvesPlot(i+1) > 0
        DrawLegend=1;
    end
    
    if DrawLegend > 0  && ~isempty(LineT) && ~isempty(LineD)
        ReviewAx=findobj(ReviewFig, 'Type', 'axes');
        h_ = legend(ReviewAx, LineT, LineD);
        set(h_,'Interpreter','none');
        
        LineT=[]; LineD=[];
    end
end