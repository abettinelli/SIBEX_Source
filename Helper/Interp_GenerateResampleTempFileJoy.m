function [SrcImgFile, DesImgFile]=Interp_GenerateResampleTempFileJoy(ROIImageInfo, ProgramPath, ModeStr)
%Path
UtilsPath=[ProgramPath, '\Utils'];

%Status file
TimeStamp=datestr(now, 30);
SrcImgFile=[UtilsPath, '\Reformate_', TimeStamp, '.src'];
DesImgFile=[UtilsPath, '\Reformate_', TimeStamp, '.des'];

%Pad Image
MaskData=PadImageData(ROIImageInfo.MaskData);

%Write Source Image
if nargin > 2
    MaskData=flipdim(MaskData, 1);
end

TempData=permute(MaskData, [2,1,3]);

FID=fopen(SrcImgFile, 'w');
fwrite(FID, TempData, 'uint16');
fclose(FID);

function MaskData=PadImageData(MaskData)
MaskData=cat(1, MaskData(1, :, :), MaskData);
MaskData=cat(1, MaskData, MaskData(end, :, :));

MaskData=cat(2, MaskData(:, 2, :), MaskData);
MaskData=cat(2, MaskData, MaskData(:,end, :));

MaskData=cat(3, MaskData(:, :, 1), MaskData);
MaskData=cat(3, MaskData, MaskData(:, :, end));





