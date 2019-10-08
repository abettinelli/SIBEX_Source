function ROIImageInfoNew=Interp_UpdateROIImageInfo(ROIImageInfoNew, DesImgFile)
FID=fopen(DesImgFile, 'r');
TempData=fread(FID, ROIImageInfoNew.XDim*ROIImageInfoNew.YDim*ROIImageInfoNew.ZDim, '*uint16');
fclose(FID);

TempData=reshape(TempData, [ROIImageInfoNew.YDim, ROIImageInfoNew.XDim, ROIImageInfoNew.ZDim]);

ROIImageInfoNew.MaskData=TempData;
