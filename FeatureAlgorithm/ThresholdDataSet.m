function CDataSetInfo= ThresholdDataSet(CDataSetInfo, Param, Mode)
ImageData=CDataSetInfo.ROIImageInfo.MaskData;
BWData=CDataSetInfo.ROIBWInfo.MaskData;

TempBW=zeros(size(BWData), 'uint8');

TempIndex=[];

%For compatibility
if isfield(Param, 'Threshold')
    TempIndex=find(ImageData < Param.Threshold);
end

if isfield(Param, 'ThresholdLow')
    TempIndex=find(ImageData < Param.ThresholdLow |  ImageData > Param.ThresholdHigh);
end

if isempty(TempIndex)
    return;
end

%BW    
TempBW(TempIndex)=1;
TempBW=TempBW+BWData;

TempIndex=find(TempBW > 1);
if ~isempty(TempIndex)
    BWData(TempIndex)=uint8(0);
    CDataSetInfo.ROIBWInfo.MaskData=BWData;
end

%Image
if isequal(Mode, 'Review')
    TempImageData=zeros(size(BWData), class(CDataSetInfo.ROIImageInfo.MaskData));
    
    TempIndex=find(BWData);
    
    TempImageData(TempIndex)=ImageData(TempIndex);
    CDataSetInfo.ROIImageInfo.MaskData=TempImageData;
end


