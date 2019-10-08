function [MaskData, ImposeData]=GetLayerMaskData(ImageDataInfo, CurrentSliceLoc, CurrentLayerNum, ModeStr)

switch ModeStr
    case 'Axial'
        StartPos=ImageDataInfo.LayerInfo(CurrentLayerNum).ZStart;
        PixDim=ImageDataInfo.LayerInfo(CurrentLayerNum).ZPixDim;
        Dim=ImageDataInfo.LayerInfo(CurrentLayerNum).ZDim;
    case 'Cor'
        StartPos=ImageDataInfo.LayerInfo(CurrentLayerNum).YStart;
        PixDim=ImageDataInfo.LayerInfo(CurrentLayerNum).YPixDim;
        Dim=ImageDataInfo.LayerInfo(CurrentLayerNum).YDim;
    case 'Sag'
        StartPos=ImageDataInfo.LayerInfo(CurrentLayerNum).XStart;
        PixDim=ImageDataInfo.LayerInfo(CurrentLayerNum).XPixDim;
        Dim=ImageDataInfo.LayerInfo(CurrentLayerNum).XDim;
end

LayLimMin=StartPos;
LayLimMax=StartPos+(Dim-1)*PixDim;

if (CurrentSliceLoc-LayLimMin) < -0.0001 || (CurrentSliceLoc -LayLimMax) > 0.0001
    switch ModeStr
        case 'Axial'
            MaskData=zeros(size(ImageDataInfo.ImageData, 1), size(ImageDataInfo.ImageData, 2), class(ImageDataInfo.LayerInfo(CurrentLayerNum).MaskData));
        case 'Cor'
            MaskData=zeros(size(ImageDataInfo.ImageData, 3), size(ImageDataInfo.ImageData, 2), class(ImageDataInfo.LayerInfo(CurrentLayerNum).MaskData));
        case 'Sag'
            MaskData=zeros(size(ImageDataInfo.ImageData, 2), size(ImageDataInfo.ImageData, 1), class(ImageDataInfo.LayerInfo(CurrentLayerNum).MaskData));
    end    
else    
    MaskData=GetLayerMaskDataSub(ImageDataInfo, CurrentLayerNum, CurrentSliceLoc, ModeStr);           
end

Color=ImageDataInfo.LayerInfo(CurrentLayerNum).Color;
ImposeData=cat(3, Color(1)*double(MaskData), Color(2)*double(MaskData), Color(3)*double(MaskData));


function TMaskData=GetLayerMaskDataSub(ImageDataInfo, CurrentNum, CurrentSliceLoc, ModeStr)
LayerInfo=ImageDataInfo.LayerInfo(CurrentNum);

%Region MaskData
switch ModeStr
    case 'Axial'
        TMaskData=zeros(size(ImageDataInfo.ImageData, 1), size(ImageDataInfo.ImageData, 2), class(LayerInfo.MaskData));
        TempIndex=round((CurrentSliceLoc-LayerInfo.ZStart)/LayerInfo.ZPixDim+1);
    case 'Cor'
        TMaskData=zeros(size(ImageDataInfo.ImageData, 3), size(ImageDataInfo.ImageData, 2), class(LayerInfo.MaskData));
        TempIndex=round((CurrentSliceLoc-LayerInfo.YStart)/LayerInfo.YPixDim+1);
        TempIndex=LayerInfo.YDim-TempIndex+1;
    case 'Sag'
        TMaskData=zeros(size(ImageDataInfo.ImageData, 3), size(ImageDataInfo.ImageData, 1), class(LayerInfo.MaskData));
        TempIndex=round((CurrentSliceLoc-LayerInfo.XStart)/LayerInfo.XPixDim+1);
end

%Extend to image domain
XDimStart=round((LayerInfo.XStart-ImageDataInfo.XStart)/ImageDataInfo.XPixDim+1);
XDimEnd=XDimStart+LayerInfo.XDim-1;

YDimStart=round((LayerInfo.YStart-ImageDataInfo.YStart)/ImageDataInfo.YPixDim+1+...
LayerInfo.YDim-1);
YDimStart=ImageDataInfo.YDim-YDimStart+1;

YDimEnd=YDimStart+LayerInfo.YDim-1;

ZDimStart=round((LayerInfo.ZStart-ImageDataInfo.ZStart)/ImageDataInfo.ZPixDim+1);
ZDimEnd=ZDimStart+LayerInfo.ZDim-1;

switch ModeStr
    case 'Axial'
        RegionMask=LayerInfo.MaskData(:, :, TempIndex);
        TMaskData(YDimStart:YDimEnd, XDimStart:XDimEnd)=RegionMask;        
        TMaskData=flipdim(TMaskData, 1);
    case 'Cor'
        RegionMask=(squeeze(LayerInfo.MaskData(TempIndex, :, :)))';
        TMaskData(ZDimStart:ZDimEnd, XDimStart:XDimEnd)=RegionMask;  
    case 'Sag'
        RegionMask=(squeeze(LayerInfo.MaskData(:, TempIndex, :)))';
        TMaskData(ZDimStart:ZDimEnd, YDimStart:YDimEnd)=RegionMask;          
         TMaskData=fliplr(TMaskData);
end











