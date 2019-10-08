function [ResultStruct, ResultStructBW]=Resample_UpDownSample(CDataSetInfo, Param)

%%%Doc Starts%%%
%-Note:
%In the test review window, the original image is also resampled accordingly.

%-Description: 
%This method is to up-sample or down-sample image in 3D.  The core code is in C++.

%-Parameters: 
%1. XPix_ScaleFactor: Scale Factor of pixel size in X dimension. 
%2. YPix_ScaleFactor: Scale Factor of pixel size in Y dimension.
%3. ZPix_ScaleFactor: Scale Factor of pixel size in Z dimension.

%-Formula:
%1.  Down-Sample: Pix_ScaleFactor > 1; Up-Sample: Pix_ScaleFactor < 1. 
%     PixSizeAfter=PixSizeCurrent*Pix_ScaleFactor.
%2.  Trilinear interpolation is used.

%-Revision:
%2014-06-04: The method is implemented.

%-Author:
%Joy Zhang, lifzhang@mdanderson.org
%%%Doc Ends%%%

%--Parameters
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

if nargin < 2    
    ConfigFile=[MFilePath, '\', MFileName, '.INI'];
    
    Param=GetParamFromINI(ConfigFile);   
end

%Parameter Check
if~isfield(Param, 'XPix_ScaleFactor') && ~isfield(Param, 'YPix_ScaleFactor') && ~isfield(Param, 'ZPix_ScaleFactor')
    ResultStruct=[];
    ResultStructBW=[];
    return;
end


%Initialize
%Force data type ==Uint16 if not
if ~isinteger(CDataSetInfo.ROIImageInfo.MaskData)
    ROIImageInfo=ScaleDataSet2Int(CDataSetInfo.ROIImageInfo);
else
    ROIImageInfo=CDataSetInfo.ROIImageInfo;
end

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

%New Format
ROIImageInfoNew=GetDestFormat(ROIImageInfo, Param);

[ROIImageInfoNew, ROIBWInfoNew, CDataSetInfoNew]=Resample_Wrapper(ROIImageInfo, ProgramPath, ROIImageInfoNew, CDataSetInfo, ROIBWInfo);

%Force data type back to original data type
if isfield(ROIImageInfoNew, 'RescaleMinV')
    ROIImageInfoNew=ScaleDataSet2Ori(ROIImageInfoNew);
end

%Return Value
ROIImageInfo.Description=MFileName;

ROIImageInfoNew.CDataSetInfo=CDataSetInfoNew;

ResultStruct=ROIImageInfoNew;
ResultStructBW=ROIBWInfoNew;

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





