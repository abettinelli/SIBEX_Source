function CDataSetInfo= ComputeHistogram(CDataSetInfo, Param, Mode)

ImageInfo=CDataSetInfo.ROIImageInfo;
BWInfo= CDataSetInfo.ROIBWInfo;

%Data
%Max Area Slice only
if isfield(Param, 'OnlyUseMaxSlice') && Param.OnlyUseMaxSlice > 0
    
    AreaSlice=sum(double(BWInfo.MaskData), 1);
    AreaSlice=sum(AreaSlice, 2);
    AreaSlice=squeeze(AreaSlice);
    
    [MaxV, MaxIndex]=max(AreaSlice);
    MaxIndex=MaxIndex(1);
    
    MaskImageMat=ImageInfo.MaskData(:, :, MaxIndex);
    MaskBWMat=BWInfo.MaskData(:, :, MaxIndex);
    
    MaskImageMat=double(MaskImageMat(logical(MaskBWMat)));    
else
    MaskImageMat=ImageInfo.MaskData(logical(BWInfo.MaskData));
    MaskImageMat=double(MaskImageMat(:));
end

MaxV=max(MaskImageMat);
MinV=min(MaskImageMat);

%Dynamic Range
if isfield(Param, 'RangeFix') && Param.RangeFix < 1
    Param.RangeMin=MinV;
    Param.RangeMax=MaxV;    
end

% Bin Location
if isfield(Param, 'BinFix') && Param.BinFix < 1
    Param.NBins=round((Param.RangeMax-Param.RangeMin)/4);
end

InterVal=(Param.RangeMax-Param.RangeMin)/Param.NBins;
BinLoc=double(Param.RangeMin:InterVal:Param.RangeMax);

if isempty(MaskImageMat)
    p = zeros(1,length(BinLoc));
    BinCenter=BinLoc;
else
    [p, BinCenter] = hist(MaskImageMat, BinLoc);
end

%Remove the bondary bin to remove the extrapolation from Matlab hist
if BinCenter(1) > MinV
    BinCenter(1)=[];
    p(1)=[];
end

if BinCenter(end) < MaxV
    BinCenter(end)=[];
    p(end)=[];
end

p = p ./ numel(MaskImageMat);

CDataSetInfo.ROIImageInfo.MaskDataOri=CDataSetInfo.ROIImageInfo.MaskData;

CDataSetInfo.ROIImageInfo.MaskData=[BinCenter', p'];

CDataSetInfo.ROIImageInfo.Description='Histogram (Probability VS Value)';