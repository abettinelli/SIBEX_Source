function CDataSetInfo=GetDateSetROIInfo(CDataSetInfo, handles, BWMatIndex)

ImageDataInfo=GetImageDataInfo(handles, 'Axial');

BWMatInfo=handles.BWMatInfo(BWMatIndex);

CDataSetInfo.ROIBWInfo=BWMatInfo;
CDataSetInfo.ROIImageInfo=GetROIImageInfo(BWMatInfo, ImageDataInfo);

CDataSetInfo.ImageXDim=ImageDataInfo.XDim;
CDataSetInfo.ImageYDim=ImageDataInfo.YDim;
CDataSetInfo.ImageZDim=ImageDataInfo.ZDim;

CDataSetInfo.ROIXDim=CDataSetInfo.ROIBWInfo.XDim;
CDataSetInfo.ROIYDim=CDataSetInfo.ROIBWInfo.YDim;
CDataSetInfo.ROIZDim=CDataSetInfo.ROIBWInfo.ZDim;


ROIMask=BWMatInfo.MaskData;
ROIMaskImage=CDataSetInfo.ROIImageInfo.MaskData;

TempIndex=find(ROIMask);

CDataSetInfo.ROIName=BWMatInfo.ROINamePlanIndex;

if ~isempty(TempIndex)
    NumVox=MKGetNumVoxBWMask(ROIMask);
    
    ROIVol=NumVox*BWMatInfo.XPixDim*BWMatInfo.YPixDim*BWMatInfo.ZPixDim;

    ROIMaskImage=ROIMaskImage(TempIndex);
    
    CDataSetInfo.ROIVol=ROIVol;
    CDataSetInfo.ROIMinV=min(ROIMaskImage(:));
    CDataSetInfo.ROIMaxV=max(ROIMaskImage(:));
else
    CDataSetInfo.ROIVol=0;
    CDataSetInfo.ROIMinV=[];
    CDataSetInfo.ROIMaxV=[];
end

CDataSetInfo.CreationDate=datestr(now, 30);
                
function ROIImageInfo=GetROIImageInfo(BWMatInfo, ImageDataInfo)
ROIImageInfo=BWMatInfo;

if ~isempty(BWMatInfo.XStart)    
    XDimStart=round((BWMatInfo.XStart-ImageDataInfo.XStart)/BWMatInfo.XPixDim+1);
    XDimEnd=XDimStart+BWMatInfo.XDim-1;
    
    YDimStart=round((BWMatInfo.YStart-ImageDataInfo.YStart)/BWMatInfo.YPixDim+1);
    YDimEnd=YDimStart+BWMatInfo.YDim-1;
        
%     YDimStart=round((BWMatInfo.YStart-ImageDataInfo.YStart)/BWMatInfo.YPixDim+1)+BWMatInfo.YDim-1;
%     YDimStart=ImageDataInfo.YDim-YDimStart+1;
%     YDimEnd=YDimStart+BWMatInfo.YDim-1;
    
    ZDimStart=round((BWMatInfo.ZStart-ImageDataInfo.ZStart)/BWMatInfo.ZPixDim+1);
    ZDimEnd=ZDimStart+BWMatInfo.ZDim-1;
    
    
    ROIImageInfo.MaskData=ImageDataInfo.ImageData(YDimStart:YDimEnd, XDimStart:XDimEnd, ZDimStart:ZDimEnd);
    
    ROIImageInfo.MaskData=flipdim(ROIImageInfo.MaskData, 1);
else
    ROIImageInfo.MaskData=[];
end
