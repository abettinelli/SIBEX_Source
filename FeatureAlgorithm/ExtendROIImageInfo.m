function [ExtendFlag, ROIImageInfo]=ExtendROIImageInfo(CDataSetInfo, MarginSize)
MarginXStart=CDataSetInfo.ROIImageInfo.XStart-MarginSize*CDataSetInfo.ROIImageInfo.XPixDim;
MarginXEnd=CDataSetInfo.ROIImageInfo.XStart+(CDataSetInfo.ROIImageInfo.XDim-1)*CDataSetInfo.ROIImageInfo.XPixDim+...
    MarginSize*CDataSetInfo.ROIImageInfo.XPixDim;

MarginYStart=CDataSetInfo.ROIImageInfo.YStart-MarginSize*CDataSetInfo.ROIImageInfo.YPixDim;
MarginYEnd=CDataSetInfo.ROIImageInfo.YStart+(CDataSetInfo.ROIImageInfo.YDim-1)*CDataSetInfo.ROIImageInfo.YPixDim+...
    MarginSize*CDataSetInfo.ROIImageInfo.YPixDim;

ImageXEnd=CDataSetInfo.XStart+(CDataSetInfo.XDim-1)*CDataSetInfo.XPixDim;
ImageYEnd=CDataSetInfo.YStart+(CDataSetInfo.YDim-1)*CDataSetInfo.YPixDim;

try
    if (MarginXStart >= CDataSetInfo.XStart) && (MarginYStart >= CDataSetInfo.YStart) ...
            &&  (MarginXEnd <= ImageXEnd) && (MarginYEnd <= ImageYEnd)
        
        FID=fopen([CDataSetInfo.SrcPath, '\', CDataSetInfo.ImageSetID, '.img'], 'r');
        Data=fread(FID, CDataSetInfo.XDim*CDataSetInfo.YDim*CDataSetInfo.ZDim, '*int16');
        Data=uint16(Data);
        fclose(FID);
        
        Data=reshape(Data, [CDataSetInfo.XDim, CDataSetInfo.YDim, CDataSetInfo.ZDim]);
        Data=permute(Data, [2, 1, 3]);
        
        XDimStart=round((MarginXStart-CDataSetInfo.XStart)/XPixDim+1);
        YDimStart=round(CDataSetInfo.YDim-(MarginYEnd-CDataSetInfo.YStart)/YPixDim);
        
        XDim=round((MarginXEnd-MarginXStart)/XPixDim+1);
        YDim=round((MarginYEnd-MarginYStart)/YPixDim+1);
        
        ExtendFlag=1;
        
        ROIImageInfo=CDataSetInfo.ROIImageInfo;
        ROIImageInfo.XDim=XDim;
        ROIImageInfo.YDim=YDim;
        ROIImageInfo.XStart=MarginXStart;
        ROIImageInfo.YStart=MarginYStart;
        
        ROIImageInfo.MaskData=Data(YDimStart:YDimStart+YDim-1, XDimStart:XDimStart+XDim-1);
    end
catch
    ExtendFlag=0;
    ROIImageInfo=[];
end