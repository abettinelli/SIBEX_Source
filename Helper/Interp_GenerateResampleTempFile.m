function [SrcImgFile, DesImgFile, ConfigFile]=Interp_GenerateResampleTempFile(ROIImageInfo, ROIImageInfoNew, ProgramPath)
%Path
UtilsPath=[ProgramPath, 'Utils'];

%Status file
TimeStamp=datestr(now, 30);
SrcImgFile=[UtilsPath, '\Reformate_', TimeStamp, '.src'];
DesImgFile=[UtilsPath, '\Reformate_', TimeStamp, '.des'];

%Write Source Image
TempData=permute(ROIImageInfo.MaskData, [2,1,3]);

FID=fopen(SrcImgFile, 'w');
fwrite(FID, TempData, 'uint16');
fclose(FID);

%Write config info
ConfigFile=[UtilsPath, '\Reformate_', TimeStamp, '.INI'];

ConfigInfo=Interp_GetConfigInfoStr(SrcImgFile, DesImgFile, ROIImageInfo, ROIImageInfoNew);

FID=fopen(ConfigFile, 'w');
for i = 1:length(ConfigInfo)
    fprintf(FID, '%s\n', ConfigInfo{i});
end
fclose(FID);