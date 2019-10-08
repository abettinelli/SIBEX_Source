function [ImageInfo_InROIBox, BinaryMaskInfo_InROIBox]=IBSI_ReSegmentation_range(DataItemInfo, Param)
%%%Doc Starts%%%
%%%Doc Starts%%%
% -Description: 
% 1. ROI voxels whose values fall outside the user-defined range of intensities are excluded from the mask.
% 
% -Parameters:
% 1. GrayLimits: may be specified both as a closed interval [a,b] (size 1x2) or a half-open interval [a,?)(size 1x1).

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

%----Initialization
ROIImageInfo=DataItemInfo.ROIImageInfo;
ROIBWInfo=DataItemInfo.ROIBWInfo;
CurrentImg = double(ROIImageInfo.MaskData);

%----Traslate Image intensieties for CT
if isequal(DataItemInfo.Modality, 'CT')
    CurrentImg = CurrentImg-1000;
end

%----Intensity Mask - Morphological Mask
MorphologicalMask = logical(ROIBWInfo.MorphologicalMaskData);
IntensityMask = logical(ROIBWInfo.MaskData);

%----Sanity Check
if ~isfield(Param, 'GrayLimits')
    gl = [min(CurrentImg(MorphologicalMask == 1)) max(CurrentImg(MorphologicalMask == 1))];
else
    gl = double(Param.GrayLimits);
end

%----Threshold in Hounsfield Unit but Data in PinnacleFormat

if numel(gl) == 1
    gl = [gl(1) max(CurrentImg(MorphologicalMask == 1))];
elseif numel(gl) ~= 2 && numel(gl) ~= 1
    eid = sprintf('Images:%s:invalidGrayLimitsSize',mfilename);
    error(eid, 'GL must be a one-element or two-element vector.');
end

%----Update current mask
idx_min_range = CurrentImg >= gl(1);
idx_max_range = CurrentImg <= gl(2);
UpdatedMask = (idx_min_range & idx_max_range) & IntensityMask;

%----Convert data type back
ClassName=class(ROIBWInfo.MaskData);
ClassFunc=str2func(ClassName);
ROIBWInfo.MaskData=ClassFunc(UpdatedMask);

%---Summary-old
ROIBWInfo.ReSegmented = true;
ROIImageInfo.GrayLimits = gl;

%---Summary
Param.GrayLimits = gl;
Summary.Type = 'ReSegmentationRange';
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
