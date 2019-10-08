function CDataSetInfo= ErodeDataSet(CDataSetInfo, Param, Mode)
ImageData=CDataSetInfo.ROIImageInfo.MaskData;
BWData=CDataSetInfo.ROIBWInfo.MaskData;

%For compatibility
if ~isfield(Param, 'ErosionDist')
    return;
end

ErodeNum=round(Param.ErosionDist/10/CDataSetInfo.ROIImageInfo.XPixDim);

if ErodeNum < 1
    return;
end

%BW
for i=1:size(BWData, 3)
    CurrentSlice=BWData(:, :, i);
    
    TempIndex=find(CurrentSlice);
    if ~isempty(TempIndex)
        CurrentSlice = bwmorph(CurrentSlice,'erode',ErodeNum);
        BWData(:, :, i)=CurrentSlice;
    end      
end
CDataSetInfo.ROIBWInfo.MaskData=BWData;

%Image
if isequal(Mode, 'Review')
    TempImageData=zeros(size(BWData), 'uint16');
    
    TempIndex=find(BWData);
    
    TempImageData(TempIndex)=ImageData(TempIndex);
    CDataSetInfo.ROIImageInfo.MaskData=TempImageData;
end







