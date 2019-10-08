function structAxialROI=UpdateStructAxialROIColor(structAxialROI, TableData)

for i=1:length(structAxialROI)
    RowIndex=i;
    ColumnIndex=3;
    
    ColorCell=TableData{RowIndex, ColumnIndex};
    
    WinColor=GetColorFromHtml(ColorCell)/255;
    
    PinnColor=GetPinnOrganColor({WinColor});
    
    PinnColor=PinnColor{1};
    
    structAxialROI(i).Color=PinnColor;
    
    if isempty(structAxialROI(i).CurvesCor)
        structAxialROI(i).CurvesCor={};
    end
end