function [ImageInfo_InROIBox, BinaryMaskInfo_InROIBox]=IBSI_FixedBinSize(DataItemInfo, Param)
%%%Doc Starts%%%
% -Description: 
% 1. To apply fixed bin size discretisation to image intensity values as a separate preprocessing step.
% 
% -Parameters:
% 1. BinSize: Integer specifying the bin size to use when scaling the grayscale values.
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
%-----------------------------DO_NOT_CHANGE_STARTS--------------------------%
%%-----------IBSI_FixedBinNumber.INI------%
%Load the default parameters from INI
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

if nargin < 2    
ConfigFile=[MFilePath, '\', MFileName, '.INI'];    
Param=GetParamFromINI(ConfigFile);    
end
%-----------------------------DO_NOT_CHANGE_ENDS----------------------------%
%///////////////////////////////////////////////////////////////////////////%

%----Initialization
ROIImageInfo = DataItemInfo.ROIImageInfo;
ROIBWInfo = DataItemInfo.ROIBWInfo;
CurrentImg = double(ROIImageInfo.MaskData);
CurrentMask = ROIBWInfo.MaskData;

%----Traslate Image intensieties for CT
if isequal(DataItemInfo.Modality, 'CT')
    CurrentImg = CurrentImg-1000;
end

%----Max e Min inside the ROI if no re-segmentation range is provided 
if isfield(DataItemInfo.ROIImageInfo, 'GrayLimits')
    InputRange=DataItemInfo.ROIImageInfo.GrayLimits;
else
    InputRange=[min(CurrentImg(CurrentMask == 1)), max(CurrentImg(CurrentMask == 1))];
end

%----Rescale 'fbs'
idx_min = CurrentImg <= InputRange(1);
idx_max = CurrentImg > InputRange(2);

%----Filter
CurrentImg_fbs = CurrentImg;
CurrentImg_fbs(:) = ceil((CurrentImg(:)-InputRange(1))/Param.BinSize);
CurrentImg_fbs(idx_min) = 1;
CurrentImg_fbs(idx_max) = max(CurrentImg_fbs(CurrentMask == 1));
CurrentImg = CurrentImg_fbs;
Param.NumLevels = max(CurrentImg_fbs(CurrentMask == 1));

wd = 1;
ImgROIVector_d = CurrentImg(CurrentMask == 1);
% X_gl = InputRange(1):Param.BinSize:InputRange(2);     % Voxel set (not used)
X_d = 1:wd:max(ImgROIVector_d);                         % Bin Numbers
X_gl_d = InputRange(1)+(X_d-0.5)*Param.BinSize;         % Voxel set discretised
G = [X_gl_d(1) X_gl_d(end)];                            % Total range

%----Warning
if ~isempty(strfind(lower(DataItemInfo.Modality), 'preprocess'))
    warning('c. fbs with aribitrary intensity values. Consider using ''fbn''')
end
if isfield(DataItemInfo.ROIImageInfo, 'Discretised')
    warning('d. Image was already discretised. Consider using ''off''')
end

%----Update Image
ClassName=class(DataItemInfo.ROIImageInfo.MaskData);
ClassFunc=str2func(ClassName);
ROIImageInfo.MaskData=ClassFunc(CurrentImg);
ROIImageInfo.Discretised = true;
ROIImageInfo.NumLevels = Param.NumLevels;
ROIImageInfo.GrayLimits = [1 Param.NumLevels];
ROIImageInfo.G = G;
ROIImageInfo.X_gl_d = X_gl_d;
ROIImageInfo.X_d = X_d;

%---Summary
Summary.Type = 'FBSDiscretisation';
Summary.Parameters = Param;
Summary.BreakIntensity = true;

%///////////////////////////////////////////////////////////////////////////%
%-----------------------------DO_NOT_CHANGE_STARTS--------------------------%
%---Return Value
ROIImageInfo.Summary = Summary;
ROIImageInfo.Description=MFileName;
ImageInfo_InROIBox=ROIImageInfo;
BinaryMaskInfo_InROIBox=ROIBWInfo;
%-----------------------------DO_NOT_CHANGE_ENDS----------------------------%
%///////////////////////////////////////////////////////////////////////////%
