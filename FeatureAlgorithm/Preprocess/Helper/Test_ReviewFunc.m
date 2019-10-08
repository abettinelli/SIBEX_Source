function CDataSetInfo=Test_ReviewFunc(CDataSetInfo)

MaskData=CDataSetInfo.ROIImageInfo.MaskData;
figure, imagesc(MaskData(:,:,1)); colormap(gray)

CDataSetInfo.Test=1;