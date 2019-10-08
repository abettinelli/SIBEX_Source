function CDataSetInfo=IBSI_GetDateSetROIInfo(CDataSetInfo, handles, BWMatIndex)

ImageDataInfo=GetImageDataInfo(handles, 'Axial');

BWMatInfo=handles.BWMatInfo(BWMatIndex);

CDataSetInfo.XDim;
CDataSetInfo.YDim;
CDataSetInfo.ZDim;
CDataSetInfo.XStart;
CDataSetInfo.YStart;
CDataSetInfo.ZStart;

BWMatInfo_expanded=IBSI_boundingbox(ImageDataInfo, BWMatInfo, handles);

% Original grid - Reference point
CDataSetInfo.IBSI_info.Original.XDim = CDataSetInfo.XDim;
CDataSetInfo.IBSI_info.Original.YDim = CDataSetInfo.YDim;
CDataSetInfo.IBSI_info.Original.ZDim = CDataSetInfo.ZDim;
CDataSetInfo.IBSI_info.Original.XStart = CDataSetInfo.XStart;
CDataSetInfo.IBSI_info.Original.YStart = CDataSetInfo.YStart;
CDataSetInfo.IBSI_info.Original.ZStart = CDataSetInfo.ZStart;

% Minimal Bounding-box
CDataSetInfo.IBSI_info.minBoundingBox.XDim = BWMatInfo.XDim;
CDataSetInfo.IBSI_info.minBoundingBox.YDim = BWMatInfo.YDim;
CDataSetInfo.IBSI_info.minBoundingBox.ZDim = BWMatInfo.ZDim;
CDataSetInfo.IBSI_info.minBoundingBox.XStart = BWMatInfo.XStart;
CDataSetInfo.IBSI_info.minBoundingBox.YStart = BWMatInfo.YStart;
CDataSetInfo.IBSI_info.minBoundingBox.ZStart = BWMatInfo.ZStart;

% Expanded Bounding-box
CDataSetInfo.IBSI_info.BoundingBox.XDim = BWMatInfo_expanded.XDim;
CDataSetInfo.IBSI_info.BoundingBox.YDim = BWMatInfo_expanded.YDim;
CDataSetInfo.IBSI_info.BoundingBox.ZDim = BWMatInfo_expanded.ZDim;
CDataSetInfo.IBSI_info.BoundingBox.XStart = BWMatInfo_expanded.XStart;
CDataSetInfo.IBSI_info.BoundingBox.YStart = BWMatInfo_expanded.YStart;
CDataSetInfo.IBSI_info.BoundingBox.ZStart = BWMatInfo_expanded.ZStart;

CDataSetInfo.ROIBWInfo=BWMatInfo_expanded;
CDataSetInfo.ROIImageInfo=GetROIImageInfo(BWMatInfo_expanded, ImageDataInfo);

% ROI INFO
CDataSetInfo.ROIXDim=BWMatInfo_expanded.XDim;
CDataSetInfo.ROIYDim=BWMatInfo_expanded.YDim;
CDataSetInfo.ROIZDim=BWMatInfo_expanded.ZDim;
CDataSetInfo.ROIXStart=BWMatInfo_expanded.XStart;
CDataSetInfo.ROIYStart=BWMatInfo_expanded.YStart;
CDataSetInfo.ROIZStart=BWMatInfo_expanded.ZStart;

ROIMask=BWMatInfo_expanded.MaskData;
ROIMaskImage=CDataSetInfo.ROIImageInfo.MaskData;

TempIndex=find(ROIMask);

CDataSetInfo.ROIName=BWMatInfo_expanded.ROINamePlanIndex;

if ~isempty(TempIndex)
    
    NumVox=IBSI_MCGetNumVoxBWMask(ROIMask);
    ROIVol=NumVox*BWMatInfo_expanded.XPixDim*BWMatInfo_expanded.YPixDim*BWMatInfo_expanded.ZPixDim;

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
                
function [ROIImageInfo]=GetROIImageInfo(BWMatInfo, ImageDataInfo)
ROIImageInfo=BWMatInfo;

if ~isempty(BWMatInfo.XStart)    
    XDimStart=round((BWMatInfo.XStart-ImageDataInfo.XStart)/BWMatInfo.XPixDim+1);
    XDimEnd=XDimStart+BWMatInfo.XDim-1;
    
    YDimStart=round((BWMatInfo.YStart-ImageDataInfo.YStart)/BWMatInfo.YPixDim+1);
    YDimEnd=YDimStart+BWMatInfo.YDim-1;
    
    ZDimStart=round((BWMatInfo.ZStart-ImageDataInfo.ZStart)/BWMatInfo.ZPixDim+1);
    ZDimEnd=ZDimStart+BWMatInfo.ZDim-1;
    
    ROIImageInfo.MaskData=ImageDataInfo.ImageData(YDimStart:YDimEnd, XDimStart:XDimEnd, ZDimStart:ZDimEnd);

    ROIImageInfo.MaskData=flipdim(ROIImageInfo.MaskData, 1);
else
    ROIImageInfo.MaskData=[];
end

