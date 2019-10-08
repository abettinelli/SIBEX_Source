function [ImageInfo_InROIBox, BinaryMaskInfo_InROIBox]=IBSI_ReSegmentation_outliers(DataItemInfo, Param)
%%%Doc Starts%%%
% -Description: 
% 1. ROI voxels whose values fall outside the user-defined range of intensities are excluded from the mask.
% 
% -Parameters:
% 1. SigmaMultiplier: multiplying factor ? so that the range is defined as [?-??,?+??], 
%       where ? and ? are respectively the mean and standard deviation of ROI intensity values.
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
%----DO_NOT_CHANGE_STARTS---------------------------------------------------%
%----Wavelet.INI------------------------------------------------------------%
%Load the default parameters from INI
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

if nargin < 2
    ConfigFile=[MFilePath, '\', MFileName, '.INI'];
    Param=GetParamFromINI(ConfigFile);
end
%----DO_NOT_CHANGE_ENDS-----------------------------------------------------%
%///////////////////////////////////////////////////////////////////////////%

%----Sanity Check
if ~isfield(Param, 'SigmaMultiplier')
    sigma_multiplier = 3;
else
    sigma_multiplier = double(Param.SigmaMultiplier);
end
if numel(sigma_multiplier) ~= 1
    eid = sprintf('Images:%s:invalidOutliersSigma',mfilename);
    error(eid, 'GL must be a one-element vector.');
end

%----Initialization
ROIImageInfo=DataItemInfo.ROIImageInfo;
ROIBWInfo=DataItemInfo.ROIBWInfo;
CurrentImg = double(ROIImageInfo.MaskData);

%----Traslate Image intensieties for CT
if isequal(DataItemInfo.Modality, 'CT')
    CurrentImg = CurrentImg-1000;
end

%----Morphological Mask - Intensity Mask
MorphologicalMask = logical(ROIBWInfo.MorphologicalMaskData);
IntensityMask = logical(ROIBWInfo.MaskData);

ROIImageVector = CurrentImg(IntensityMask == 1); % which to use? IntensityMask MorphologicalMask
mu = mean(ROIImageVector);
sigma = std(ROIImageVector);
gl = [mu-sigma_multiplier*sigma mu+sigma_multiplier*sigma];

%----Update current mask
idx_min_outliers = CurrentImg >= gl(1);
idx_max_outliers = CurrentImg <= gl(2);
UpdatedMask = (idx_min_outliers & idx_max_outliers) & IntensityMask;

%----Convert data type back
ClassName=class(ROIBWInfo.MaskData);
ClassFunc=str2func(ClassName);
ROIBWInfo.MaskData=ClassFunc(UpdatedMask);

%---Summary-old
ROIBWInfo.ReSegmented = true;
% ROIImageInfo.GrayLimits = gl; no -> cat D

%----Summary
Param.GrayLimits = gl;
Summary.Type = 'ReSegmentationOutliers';
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
