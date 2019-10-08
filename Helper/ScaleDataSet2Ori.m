function ROIImageInfo=ScaleDataSet2Ori(ROIImageInfo)
fhandle=str2func(ROIImageInfo.RescaleClass);
ROIImageInfo.MaskData=fhandle(double(ROIImageInfo.MaskData)*(ROIImageInfo.RescaleMaxV-ROIImageInfo.RescaleMinV)/...
    ROIImageInfo.RescaleRange+ROIImageInfo.RescaleMinV);

FieldNames={'RescaleMinV'; 'RescaleMaxV'; 'RescaleRange'; 'RescaleClass'};
ROIImageInfo=rmfield(ROIImageInfo, FieldNames);