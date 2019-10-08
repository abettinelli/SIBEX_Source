function [ResultStruct, ResultStructBW]=Clean_MaskEdge(CDataSetInfo, Param)

%%%Doc Starts%%%
%-Description: 
%This method is to remove edge voxels of binary mask based on the fraction of edge voxel.
%To get the fraction, binary mask is first generated into the finer resolution, cacluate the fraction,  then go back to the original resolution.

%-Parameters: 
%1. EdgeVoxFraction: The Threshold to remove or keep edge voxels
%2. XPix_ScaleFactor: Scale Factor of pixel size in X dimension. 
%3. YPix_ScaleFactor: Scale Factor of pixel size in Y dimension.
%4. ZPix_ScaleFactor: Scale Factor of pixel size in Z dimension.

%-Formula:
%1.  Down-Sample: Pix_ScaleFactor > 1; Up-Sample: Pix_ScaleFactor < 1. 
%     PixSizeAfter=PixSizeCurrent*Pix_ScaleFactor.
%2.  Trilinear interpolation is used.

%-Revision:
%2014-09-09: The method is implemented.

%-Author:
%Joy Zhang, lifzhang@mdanderson.org
%David Fried, DVFried@mdanderson.org
%%%Doc Ends%%%

%--Parameters
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

if nargin < 2    
    ConfigFile=[MFilePath, '\', MFileName, '.INI'];
    
    Param=GetParamFromINI(ConfigFile);   
end

%Parameter Check
if~isfield(Param, 'XPix_ScaleFactor') || ~isfield(Param, 'YPix_ScaleFactor') || ~isfield(Param, 'ZPix_ScaleFactor') || ~isfield(Param, 'EdgeVoxelFraction')
    ResultStruct=[];
    ResultStructBW=[];
    return;
end


%Initialize
ROIImageInfo=CDataSetInfo.ROIImageInfo;
ROIBWInfo=CDataSetInfo.ROIBWInfo;

TempIndex=strfind(MFilePath, '\');
ProgramPath=MFilePath(1:TempIndex(end-1));

%To see if there is need to resample
if EqualRelativeX(Param.XPix_ScaleFactor, 1) > 0 && ...
        EqualRelativeX(Param.YPix_ScaleFactor, 1) > 0 && ...
        EqualRelativeZ(Param.ZPix_ScaleFactor, 1) > 0
    
    ResultStruct=ROIImageInfo;
    ResultStructBW=ROIBWInfo;    
    return;
end

%Finer Format for BWMask only----Upsample
ROIImageInfoNew=GetDestFormat(ROIImageInfo, Param);

ResampleImageFlag=0; ResampleROIFlag=1; 
[ROIImageInfoNew, ROIBWInfoNew, CDataSetInfoNew]=Resample_Wrapper(ROIImageInfo, ProgramPath, ROIImageInfoNew, CDataSetInfo, ROIBWInfo, ResampleImageFlag, ResampleROIFlag);


%BWMask format goes back to old
MaskVauleScale=1000;
ROIImageInfoNew.MaskData=uint16(ROIBWInfoNew.MaskData)*MaskVauleScale;

ResampleImageFlag=1; ResampleROIFlag=0; BoxKernelFlag=1;
[ROIImageInfoBack, ROIBWInfoNull, CDataSetInfoNull]=Resample_Wrapper(ROIImageInfoNew, ProgramPath, ROIImageInfo, CDataSetInfoNew, ROIBWInfoNew, ResampleImageFlag, ResampleROIFlag, BoxKernelFlag);

MaskDataBack=ROIImageInfoBack.MaskData;
MaskDataBack=double(MaskDataBack)/MaskVauleScale;
MaskDataBack=MaskDataBack>=Param.EdgeVoxelFraction;

ROIBWInfo.MaskData=MaskDataBack;

%Return Value
ROIImageInfo.Description=MFileName;

ResultStruct=ROIImageInfo;
ResultStructBW=ROIBWInfo;

function ROIImageInfoNew=GetDestFormat(ROIImageInfo, Param)
ROIImageInfoNew=ROIImageInfo;

ROIImageInfoNew.XPixDim=ROIImageInfoNew.XPixDim*Param.XPix_ScaleFactor;
ROIImageInfoNew.YPixDim=ROIImageInfoNew.YPixDim*Param.YPix_ScaleFactor;
ROIImageInfoNew.ZPixDim=ROIImageInfoNew.ZPixDim*Param.ZPix_ScaleFactor;

XStart=ROIImageInfo.XStart-ROIImageInfo.XPixDim/2;
YStart=ROIImageInfo.YStart-ROIImageInfo.YPixDim/2;
ZStart=ROIImageInfo.ZStart-ROIImageInfo.ZPixDim/2;

XEnd=XStart+ROIImageInfo.XDim*ROIImageInfo.XPixDim;
YEnd=YStart+ROIImageInfo.YDim*ROIImageInfo.YPixDim;
ZEnd=ZStart+ROIImageInfo.ZDim*ROIImageInfo.ZPixDim;

XDim=ceil((XEnd-XStart)/ROIImageInfoNew.XPixDim);
YDim=ceil((YEnd-YStart)/ROIImageInfoNew.YPixDim);
ZDim=ceil((ZEnd-ZStart)/ROIImageInfoNew.ZPixDim);

ROIImageInfoNew.XStart=XStart+ROIImageInfoNew.XPixDim/2;
ROIImageInfoNew.YStart=YStart+ROIImageInfoNew.YPixDim/2;
ROIImageInfoNew.ZStart=ZStart+ROIImageInfoNew.ZPixDim/2;

ROIImageInfoNew.XDim=XDim;
ROIImageInfoNew.YDim=YDim;
ROIImageInfoNew.ZDim=ZDim;

