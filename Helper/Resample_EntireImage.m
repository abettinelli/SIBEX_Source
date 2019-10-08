function  [DataFormat, ImageData]=Resample_EntireImage(DataFormat, ImageData, CDataSetInfo)
%Entire image needs to resample after preprocess-Reample_VoxelSize

[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

TempIndex=strfind(MFilePath, '\');
ProgramPath=MFilePath(1:TempIndex(end));

%UpdateData DataFormat
if ~isempty(DataFormat.XStartV9)
    DataFormat.XStart=DataFormat.XStartV9;
    DataFormat.StartV9=1;
else
    DataFormat.XStart=DataFormat.XStartV8;
    DataFormat.StartV9=0;
end

if ~isempty(DataFormat.YStartV9)
    DataFormat.YStart=DataFormat.YStartV9;
    DataFormat.StartV9=1;
else
    DataFormat.YStart=DataFormat.YStartV8;
    DataFormat.StartV9=0;
end

DataFormat.XStartV9=DataFormat.XStart;
DataFormat.XStartV8=DataFormat.XStart;

DataFormat.YStartV9=DataFormat.YStart;
DataFormat.YStartV8=DataFormat.YStart;

DataFormat.MaskData=ImageData;

if ~isinteger(DataFormat.MaskData)
    DataFormat=ScaleDataSet2Int(DataFormat);
end

[SrcImgFile, DesImgFile]=Interp_GenerateResampleTempFileJoy(DataFormat, ProgramPath, 'Flip');

DataFormat=rmfield(DataFormat, 'MaskData');

%Reformat
FlipRowFlag=1;
BoxKernelFlag=0;
Interpolation3D_Uint16(SrcImgFile, DesImgFile, ...
    single(DataFormat.XPixDim), single(DataFormat.YPixDim), single(DataFormat.ZPixDim), ...
    uint16(DataFormat.XDim+2), uint16(DataFormat.YDim+2), uint16(DataFormat.ZDim+2), ...
    single(DataFormat.XStart-DataFormat.XPixDim), ...
    single(DataFormat.YStart-DataFormat.YPixDim), ...
    single(DataFormat.ZStart-DataFormat.ZPixDim), single(0), ...
   single(CDataSetInfo.XPixDim), single(CDataSetInfo.YPixDim), single(CDataSetInfo.ZPixDim), ...
    uint16(CDataSetInfo.XDim), uint16(CDataSetInfo.YDim), uint16(CDataSetInfo.ZDim), ...
    single(CDataSetInfo.XStart), single(CDataSetInfo.YStart), single(CDataSetInfo.ZStart), FlipRowFlag, uint16(BoxKernelFlag));


%Update ImageDada
ROIImageInfo=DataFormat;
ROIImageInfo.XDim=CDataSetInfo.XDim;
ROIImageInfo.YDim=CDataSetInfo.YDim;
ROIImageInfo.ZDim=CDataSetInfo.ZDim;

ROIImageInfo=Interp_UpdateROIImageInfo(ROIImageInfo, DesImgFile);
delete(DesImgFile);
delete(SrcImgFile);

if isfield(ROIImageInfo, 'RescaleMinV')
    ROIImageInfo=ScaleDataSet2Ori(ROIImageInfo);
end

ImageData=ROIImageInfo.MaskData;

%Update Data Format
DataFormat.XDim=CDataSetInfo.XDim;
DataFormat.YDim=CDataSetInfo.YDim;
DataFormat.ZDim=CDataSetInfo.ZDim;
DataFormat.XPixDim=CDataSetInfo.XPixDim;
DataFormat.YPixDim=CDataSetInfo.YPixDim;
DataFormat.ZPixDim=CDataSetInfo.ZPixDim;
DataFormat.XStartV9=CDataSetInfo.XStart;
DataFormat.XStartV8=CDataSetInfo.XStart;
DataFormat.YStartV9=CDataSetInfo.YStart;
DataFormat.YStartV8=CDataSetInfo.YStart;
DataFormat.ZStart=CDataSetInfo.ZStart;
DataFormat.TablePos=CDataSetInfo.ZStart+((1:CDataSetInfo.ZDim)'-1)*CDataSetInfo.ZPixDim;






