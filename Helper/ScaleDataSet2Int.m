function ROIImageInfo=ScaleDataSet2Int(ROIImageInfo)
TempV=ROIImageInfo.MaskData;

MinV=min(TempV(:));
MaxV=max(TempV(:));

ROIImageInfo.RescaleClass=class(TempV);

if MinV == MaxV
    ROIImageInfo.MaskData=uint16(2000)*ones(size(TempV), 'uint16');
    ROIImageInfo.RescaleMinV=0;
    ROIImageInfo.RescaleMaxV=MaxV;
    ROIImageInfo.RescaleRange=2000;
else
    TempV=double(TempV);
    ROIImageInfo.MaskData=uint16((TempV-MinV)*4096/(MaxV-MinV));
    ROIImageInfo.RescaleMinV=MinV;
    ROIImageInfo.RescaleMaxV=MaxV;
    ROIImageInfo.RescaleRange=4096;
end