function [ImageInfo_InROIBox, BinaryMaskInfo_InROIBox]=IBSI_Resample_VoxelSize(DataItemInfo, Param)
%%%Doc Starts%%%
% 1. Interpolation algorithms translate image intensities from the original image grid to an interpolation grid.
% 
% -Parameters:
% 1. XPixDim: Pixel size in X dimension. 
% 2. YPixDim: Pixel size in Y dimension.
% 3. ZPixDim: Pixel size in Z dimension.
% 4. Method:
%       'linear':, Bilinear/trilinear interpolation.
%       'nearest': Nearest neighborhood interpolation.
%       'cubic': Bicubic/tricubic interpolation.
%       'spline': Spline interpolation using not-a-knot end conditions. 
%       'makima': Modified Akima cubic Hermite interpolation.
% 5. NoZDim:
%       0: Resample the ZPixSize as requested (3D interpolation).
%       1: Keep the original ZPixSize (slice by slice interpolation). 
% 6. GridAlignment:
%       0: align grid centers
%       1: align grid origins
%       2: fit to original grid
% 7. Alpha: Threshold to binarise intesnity fractions of the ROI mask.
% 
% -References:
% 1. Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
%    December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%
% -Revision:
% 2019-07-10: The method is implemented.
% 
% -Authors:
% Andrea Bettinelli
%%%Doc Ends%%%

%///////////////////////////////////////////////////////////////////////////%
%----------------------------DO_NOT_CHANGE_STARTS---------------------------%
%----Wavelet.INI------------------------------------------------------------%
%Load the default parameters from INI
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

if nargin < 2
    ConfigFile=[MFilePath, '\', MFileName, '.INI'];
    Param=GetParamFromINI(ConfigFile);
end
%-----------------------------DO_NOT_CHANGE_ENDS----------------------------%
%///////////////////////////////////////////////////////////////////////////%

%----Parameter Check
if~isfield(Param, 'XPixDim') && ~isfield(Param, 'YPixDim') && ~isfield(Param, 'ZPixDim')
    ImageInfo_InROIBox=[];
    BinaryMaskInfo_InROIBox=[];
    return;
end

if ~isfield(Param, 'Method')
    Param.Method = 'linear';
end
if ~isfield(Param, 'GridAlignment')
    Param.GridAlignment = 0;
end
if ~isfield(Param, 'NoZDim')
    Param.NoZDim = false;
end
if ~isfield(Param, 'Alpha')
    Param.Alpha = 0.5;
end

%----Initialisation
ROIImageInfo=DataItemInfo.ROIImageInfo;
ROIBWInfo=DataItemInfo.ROIBWInfo;

%----To see if there is need to resample
if EqualRelativeX(ROIImageInfo.XPixDim, Param.XPixDim) > 0 && ...
        EqualRelativeX(ROIImageInfo.YPixDim, Param.YPixDim) > 0 && ...
        (EqualRelativeZ(ROIImageInfo.ZPixDim, Param.ZPixDim) > 0 || Param.NoZDim )
    
    ImageInfo_InROIBox=ROIImageInfo;
    BinaryMaskInfo_InROIBox=ROIBWInfo;    
    return;
end

%----New Coordinate Format
ROIImageInfoNew=GetDestinationFormat(DataItemInfo, Param);

%----Resampling
[ROIImageInfoNew, ROIBWInfoNew, CDataSetInfoNew]=IBSI_Resample_Wrapper(ROIImageInfo, ROIImageInfoNew, DataItemInfo, ROIBWInfo, Param.Method, Param.Alpha);

%----Update fields MASK
fields = fieldnames(ROIBWInfo);
fields_new = fieldnames(ROIBWInfoNew);
missing_fields = setdiff(fields,fields_new);
for i = 1:length(missing_fields)
   ROIBWInfoNew.(missing_fields{i}) = ROIBWInfo.(missing_fields{i});
end

%----Update fields IMAGE IBSIv2
ROIImageInfoNew.CDataSetInfo=CDataSetInfoNew;
fields = fieldnames(ROIImageInfo);
fields_new = fieldnames(ROIImageInfoNew);
missing_fields = setdiff(fields,fields_new);
for i = 1:length(missing_fields)
   ROIImageInfoNew.(missing_fields{i}) = ROIImageInfo.(missing_fields{i});
end

ROIImageInfo = ROIImageInfoNew;
ROIBWInfo = ROIBWInfoNew;

%---Summary
Summary.Type = 'ResampleVoxelSize';
Summary.Parameters = Param;
Summary.BreakIntensity = false;

%///////////////////////////////////////////////////////////////////////////%
%----------------------------DO_NOT_CHANGE_STARTS---------------------------%
%----Return Value
ROIImageInfo.Summary = Summary;
ROIImageInfo.Description=MFileName;
ImageInfo_InROIBox=ROIImageInfo;
BinaryMaskInfo_InROIBox=ROIBWInfo;
%-----------------------------DO_NOT_CHANGE_ENDS----------------------------%
%///////////////////////////////////////////////////////////////////////////%

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
if Param.GridAlignment == 0 || Param.GridAlignment == 1
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
    
elseif Param.GridAlignment == 2
    FULL_ImageInfoNew.XDim=ceil((FULL_ImageInfo.XDim*FULL_ImageInfo.XPixDim)/Param.XPixDim);
    FULL_ImageInfoNew.YDim=ceil((FULL_ImageInfo.YDim*FULL_ImageInfo.YPixDim)/Param.YPixDim);
    FULL_ImageInfoNew.ZDim=ceil((FULL_ImageInfo.ZDim*FULL_ImageInfo.ZPixDim)/Param.ZPixDim);
    
    XDim_temp=ceil((FULL_ImageInfo.XDim-1)*FULL_ImageInfo.XPixDim)/Param.XPixDim;
    YDim_temp=ceil((FULL_ImageInfo.YDim-1)*FULL_ImageInfo.YPixDim)/Param.YPixDim;
    ZDim_temp=ceil((FULL_ImageInfo.ZDim-1)*FULL_ImageInfo.ZPixDim)/Param.ZPixDim;
    
    FULL_ImageInfoNew.XPixDim = (FULL_ImageInfo.XDim-1)*FULL_ImageInfo.XPixDim/(XDim_temp-1);
    FULL_ImageInfoNew.YPixDim = (FULL_ImageInfo.YDim-1)*FULL_ImageInfo.YPixDim/(YDim_temp-1);
    FULL_ImageInfoNew.ZPixDim = (FULL_ImageInfo.ZDim-1)*FULL_ImageInfo.ZPixDim/(ZDim_temp-1);
    FULL_ImageInfoNew.XStart = FULL_ImageInfo.XStart;
    FULL_ImageInfoNew.YStart = FULL_ImageInfo.YStart;
    FULL_ImageInfoNew.ZStart = FULL_ImageInfo.ZStart;
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
    ROI_ImageInfoNew.XPixDim=FULL_ImageInfoNew.XPixDim;
    ROI_ImageInfoNew.YPixDim=FULL_ImageInfoNew.YPixDim;
    ROI_ImageInfoNew.ZPixDim=FULL_ImageInfoNew.ZPixDim;
end

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


if Param.GridAlignment == 1 % Align grid origins
    ROI_ImageInfoNew.XStart = ROI_ImageInfo.XStart;
    ROI_ImageInfoNew.YStart = ROI_ImageInfo.YStart;
    ROI_ImageInfoNew.ZStart = ROI_ImageInfo.ZStart;
end

if Param.NoZDim
    ROI_ImageInfoNew.ZDim = ROI_ImageInfo.ZDim;
    ROI_ImageInfoNew.ZPixDim = ROI_ImageInfo.ZPixDim;
    ROI_ImageInfoNew.ZStart = ROI_ImageInfo.ZStart;
end