
function ROIColor=GetROIColor(structAxialROI)
ROIColor=[];

for i=1:length(structAxialROI)
    ROIColor=[ROIColor; {structAxialROI(i).Color}];
end