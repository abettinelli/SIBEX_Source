function ROIName=GetROIName(structAxialROI)
ROIName=[];

for i=1:length(structAxialROI)
    ROIName=[ROIName; {structAxialROI(i).name}];
end
