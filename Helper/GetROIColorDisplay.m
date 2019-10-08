
function ROIColor=GetROIColorDisplay(structAxialROI)
ROIColor=[];

for i=1:length(structAxialROI)
    WinColor=GetWinOrganColor({structAxialROI(i).Color});
    WinColor=round(cell2mat(WinColor)*255);
    
    ColorCell=...
        ['<html><body bgcolor="rgb(', num2str(WinColor(1)),',' num2str(WinColor(2)), ',', num2str(WinColor(3)), ...
        ')">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp</body></html>'];
    ROIColor=[ROIColor; {ColorCell}];
end
