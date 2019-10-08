function [ResultStruct, ResultStructBW]=IBSI_Resample_Gaussian_VoxelSize(CDataSetInfo, Param)
%%%Doc Starts%%%
%-Note:
%In the test review window, the original image is also resampled accordingly.

%-Description: 

%-Parameters: 
%1.  XPixDim: Pixel size in X dimension. 
%2.  YPixDim: Pixel size in Y dimension.
%3.  ZPixDim: Pixel size in Z dimension.

%-Revision:
%2019-02-21: The method is implemented.

%-Author:
%Andrea Bettinelli
%%%Doc Ends%%%

%--Parameters
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

if nargin < 2    
    ConfigFile=[MFilePath, '\', MFileName, '.INI'];
    Param=GetParamFromINI(ConfigFile);   
end

%Parameter Check
if~isfield(Param, 'XPixDim') && ~isfield(Param, 'YPixDim') && ~isfield(Param, 'ZPixDim')
    ResultStruct=[];
    ResultStructBW=[];
    return;
end

if ~isfield(Param, 'Method')
    Param.Method = 'linear';
end
if ~isfield(Param, 'AlignCornerCentre')
    Param.AlignCornerCentre = false;
end
if ~isfield(Param, 'NoZDim')
    Param.NoZDim = false;
end
if ~isfield(Param, 'Alpha')
    Param.Alpha = 0.5;
end

%Initialize
ROIImageInfo=CDataSetInfo.ROIImageInfo;
ROIBWInfo=CDataSetInfo.ROIBWInfo;

%Preprocess
% SIGMA ACCORDING TO RESCALE
dims_before = [ROIImageInfo.XPixDim, ROIImageInfo.YPixDim, ROIImageInfo.ZPixDim];
dims_after = [Param.XPixDim Param.YPixDim Param.ZPixDim];

val = dims_after;
FWHM = val./dims_before; % FWHM in voxel units
FWHM(FWHM <= 1) = 10^-15;
sigma = FWHM./(2*sqrt(2*log(2)));

disp(['before: [' num2str(dims_before) ']'])
disp(['after: [' num2str(dims_after) ']'])
disp(['sigma: [' num2str(sigma) ']'])
disp([' '])

ClassName=class(ROIImageInfo.MaskData);
ClassFunc=str2func(ClassName);
% implay(double(ROIImageInfo.MaskData))
ROIImageInfo.MaskData = ClassFunc(imgaussfilt3(ROIImageInfo.MaskData,sigma));
% implay(double(ROIImageInfo.MaskData))

%To see if there is need to resample
if EqualRelativeX(ROIImageInfo.XPixDim, Param.XPixDim) > 0 && ...
        EqualRelativeX(ROIImageInfo.YPixDim, Param.YPixDim) > 0 && ...
        (EqualRelativeZ(ROIImageInfo.ZPixDim, Param.ZPixDim) > 0 || Param.NoZDim )
    
    ResultStruct=ROIImageInfo;
    ResultStructBW=ROIBWInfo;    
    return;
end

% New Coordinate Format
ROIImageInfoNew=GetDestinationFormat(CDataSetInfo, Param);

% Resampling
[ROIImageInfoNew, ROIBWInfoNew, CDataSetInfoNew]=IBSI_Resample_Wrapper(ROIImageInfo, ROIImageInfoNew, CDataSetInfo, ROIBWInfo, Param.Method, Param.Alpha);

ROIImageInfoNew.Description=MFileName;
ROIImageInfoNew.CDataSetInfo=CDataSetInfoNew;

fields = fieldnames(ROIBWInfo);
fields_new = fieldnames(ROIBWInfoNew);
missing_fields = setdiff(fields,fields_new);
for i = 1:length(missing_fields)
   ROIBWInfoNew.(missing_fields{i}) = ROIBWInfo.(missing_fields{i});
end

% Return Value
ResultStruct=ROIImageInfoNew;
ResultStructBW=ROIBWInfoNew;


function ROI_ImageInfoNew=GetDestinationFormat(CDataSetInfo, Param)

% Full Image
FULL_ImageInfo=CDataSetInfo.IBSI_info.Original;
FULL_ImageInfo.XPixDim=CDataSetInfo.XPixDim;
FULL_ImageInfo.YPixDim=CDataSetInfo.YPixDim;
FULL_ImageInfo.ZPixDim=CDataSetInfo.ZPixDim;
% Grid Old Full
FULL_ImageInfo.XGrid = FULL_ImageInfo.XStart+(0:FULL_ImageInfo.XDim-1)*FULL_ImageInfo.XPixDim;
FULL_ImageInfo.YGrid = FULL_ImageInfo.YStart+(0:FULL_ImageInfo.YDim-1)*FULL_ImageInfo.YPixDim;
FULL_ImageInfo.ZGrid = FULL_ImageInfo.ZStart+(0:FULL_ImageInfo.ZDim-1)*FULL_ImageInfo.ZPixDim;

% Full Image New
FULL_ImageInfoNew.XPixDim=Param.XPixDim;
FULL_ImageInfoNew.YPixDim=Param.YPixDim;
FULL_ImageInfoNew.ZPixDim=Param.ZPixDim;
FULL_ImageInfoNew.XDim=ceil((FULL_ImageInfo.XDim*FULL_ImageInfo.XPixDim)/Param.XPixDim);
FULL_ImageInfoNew.YDim=ceil((FULL_ImageInfo.YDim*FULL_ImageInfo.YPixDim)/Param.YPixDim);
FULL_ImageInfoNew.ZDim=ceil((FULL_ImageInfo.ZDim*FULL_ImageInfo.ZPixDim)/Param.ZPixDim);
FULL_ImageInfoNew.XStart = FULL_ImageInfo.XStart + 0.5*FULL_ImageInfo.XPixDim*(FULL_ImageInfo.XDim-1)-0.5*Param.XPixDim*(FULL_ImageInfoNew.XDim-1);
FULL_ImageInfoNew.YStart = FULL_ImageInfo.YStart + 0.5*FULL_ImageInfo.YPixDim*(FULL_ImageInfo.YDim-1)-0.5*Param.YPixDim*(FULL_ImageInfoNew.YDim-1);
FULL_ImageInfoNew.ZStart = FULL_ImageInfo.ZStart + 0.5*FULL_ImageInfo.ZPixDim*(FULL_ImageInfo.ZDim-1)-0.5*Param.ZPixDim*(FULL_ImageInfoNew.ZDim-1);
% Grid New Full
FULL_ImageInfoNew.XGrid = FULL_ImageInfoNew.XStart+(0:FULL_ImageInfoNew.XDim-1)*FULL_ImageInfoNew.XPixDim;
FULL_ImageInfoNew.YGrid = FULL_ImageInfoNew.YStart+(0:FULL_ImageInfoNew.YDim-1)*FULL_ImageInfoNew.YPixDim;
FULL_ImageInfoNew.ZGrid = FULL_ImageInfoNew.ZStart+(0:FULL_ImageInfoNew.ZDim-1)*FULL_ImageInfoNew.ZPixDim;

% ROI old
ROI_ImageInfo=CDataSetInfo.IBSI_info.BoundingBox;
ROI_ImageInfo.XPixDim=CDataSetInfo.XPixDim;
ROI_ImageInfo.YPixDim=CDataSetInfo.YPixDim;
ROI_ImageInfo.ZPixDim=CDataSetInfo.ZPixDim;

% ROI new
ROI_ImageInfoNew.XPixDim=Param.XPixDim;
ROI_ImageInfoNew.YPixDim=Param.YPixDim;
ROI_ImageInfoNew.ZPixDim=Param.ZPixDim;

% Find start and end indeces of the ROI in the new Grid
% idx_old = findStartEndIdx(FULL_ImageInfo, ROI_ImageInfo);
idx_new = findStartEndIdx(FULL_ImageInfoNew, ROI_ImageInfo);

% Update Info
ROI_ImageInfoNew.XStart = FULL_ImageInfoNew.XGrid(idx_new.X_Start);
ROI_ImageInfoNew.YStart = FULL_ImageInfoNew.YGrid(idx_new.Y_Start);
ROI_ImageInfoNew.ZStart = FULL_ImageInfoNew.ZGrid(idx_new.Z_Start);

ROI_ImageInfoNew.XDim = (idx_new.X_End-idx_new.X_Start)+1;
ROI_ImageInfoNew.YDim = (idx_new.Y_End-idx_new.Y_Start)+1;
ROI_ImageInfoNew.ZDim = (idx_new.Z_End-idx_new.Z_Start)+1;

if Param.NoZDim
    ROI_ImageInfoNew.ZDim = ROI_ImageInfo.ZDim;
    ROI_ImageInfoNew.ZPixDim = ROI_ImageInfo.ZPixDim;
    ROI_ImageInfoNew.ZStart = ROI_ImageInfo.ZStart;
end

if Param.AlignCornerCentre
    ROI_ImageInfoNew.XStart = ROI_ImageInfo.XStart;
    ROI_ImageInfoNew.YStart = ROI_ImageInfo.YStart;
    ROI_ImageInfoNew.ZStart = ROI_ImageInfo.ZStart;
end