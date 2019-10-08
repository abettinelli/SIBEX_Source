function CDataSetInfo= ErodeBWDataSetByVoxel(CDataSetInfo, ShrinkVoxel)
BWData=CDataSetInfo.ROIBWInfo.MaskData;

ErodeNum=ShrinkVoxel;

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







