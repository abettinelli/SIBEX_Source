function [ResultStruct, ResultStructBW]=Resample_VoxelSize(CDataSetInfo, Param)
%%%Doc Starts%%%
%-Note:
%In the test review window, the original image is also resampled accordingly.

%-Description: 
%This method is to resample the pixel size in 3D.  The core code is in C++.

%-Parameters: 
%1.  XPixDim: Pixel size in X dimension. 
%2.  YPixDim: Pixel size in Y dimension.
%3.  ZPixDim: Pixel size in Z dimension.
%4.  NoSampleZPix: 1==Keep the original ZPixSize; 0==Resample the ZPixSize as requested.

%-Formula:
%Trilinear interpolation is used.

%-Revision:
%2014-06-03: The method is implemented.

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
if~isfield(Param, 'XPixDim') && ~isfield(Param, 'YPixDim') && ~isfield(Param, 'ZPixDim') && ~isfield(Param, 'NoSampleZPix')
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
if EqualRelativeX(ROIImageInfo.XPixDim, Param.XPixDim) > 0 && ...
        EqualRelativeX(ROIImageInfo.YPixDim, Param.YPixDim) > 0 && ...
        (EqualRelativeZ(ROIImageInfo.ZPixDim, Param.ZPixDim) > 0 ||   Param.NoSampleZPix > 0)
    
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

ROIImageInfoNew.XPixDim=Param.XPixDim;
ROIImageInfoNew.YPixDim=Param.YPixDim;

if Param.NoSampleZPix < 1
    ROIImageInfoNew.ZPixDim=Param.ZPixDim;
end

XStart=ROIImageInfo.XStart-ROIImageInfo.XPixDim/2;
YStart=ROIImageInfo.YStart-ROIImageInfo.YPixDim/2;
ZStart=ROIImageInfo.ZStart-ROIImageInfo.ZPixDim/2;

XEnd=XStart+ROIImageInfo.XDim*ROIImageInfo.XPixDim;
YEnd=YStart+ROIImageInfo.YDim*ROIImageInfo.YPixDim;
ZEnd=ZStart+ROIImageInfo.ZDim*ROIImageInfo.ZPixDim;

XDim=ceil(round((XEnd-XStart)*100/ROIImageInfoNew.XPixDim)/100);
YDim=ceil(round((YEnd-YStart)*100/ROIImageInfoNew.YPixDim)/100);
ZDim=ceil(round((ZEnd-ZStart)*100/ROIImageInfoNew.ZPixDim)/100);

ROIImageInfoNew.XStart=XStart+ROIImageInfoNew.XPixDim/2;
ROIImageInfoNew.YStart=YStart+ROIImageInfoNew.YPixDim/2;
ROIImageInfoNew.ZStart=ZStart+ROIImageInfoNew.ZPixDim/2;

ROIImageInfoNew.XDim=XDim;
ROIImageInfoNew.YDim=YDim;
ROIImageInfoNew.ZDim=ZDim;