function [ImageInfo_InROIBox, BinaryMaskInfo_InROIBox]=IBSI_FixedBinNumber(DataItemInfo, Param)
%%%Doc Starts%%%
% -Description: 
% 1. To apply a fixed bin number discretisation to image intensity values as a separate preprocessing step.
% 
% -Parameters:
% 1. BinNumber: Integer specifying the number of bin number to use when scaling the grayscale values.
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

%----Max e Min inside the ROI
CurrentImg = double(CurrentImg);
InputRange=[min(CurrentImg(CurrentMask == 1)), max(CurrentImg(CurrentMask == 1))]; % overwrite Max e Min

wd = 1;
G = [1 Param.BinNumber];                                % Total range
X_d = 1:wd:Param.BinNumber;                             % Bin Numbers
X_gl_d = X_d;                                           % Voxel set discretised [? min(ImgROIVector):wb:max(ImgROIVector)]

%----Rescale 'fbn'
idx_min = CurrentImg <= InputRange(1);
idx_max = CurrentImg >= InputRange(2);
CurrentImg_fbn = CurrentImg;

% % IBSIv6
% CurrentImg_fbn(:) = ceil(Param.BinNumber*(CurrentImg(:)-InputRange(1))/(InputRange(2)-InputRange(1)));
% % end IBSIv6

% IBSIv11
CurrentImg_fbn(:) = floor(Param.BinNumber*(CurrentImg(:)-InputRange(1))/(InputRange(2)-InputRange(1)))+1;
% end IBSIv11

CurrentImg_fbn(idx_min) = 1;
CurrentImg_fbn(idx_max) = Param.BinNumber;
CurrentImg = CurrentImg_fbn;
NumLevels = max(CurrentImg_fbn(CurrentMask == 1));

Param.NumLevels = NumLevels;

%----Warning
if isfield(DataItemInfo.ROIImageInfo, 'Discretised')
    warning('b. Image was already discretised. Consider using ''off''')
end

%----Update Image
ClassName=class(DataItemInfo.ROIImageInfo.MaskData);
ClassFunc=str2func(ClassName);
ROIImageInfo.MaskData=ClassFunc(CurrentImg);
ROIImageInfo.Discretised = true;
ROIImageInfo.NumLevels = Param.NumLevels;
ROIImageInfo.G = G;
ROIImageInfo.X_gl_d = X_gl_d;
ROIImageInfo.X_d = X_d;

%---Summary
Summary.Type = 'FBNDiscretisation';
Summary.Parameters = Param;
Summary.BreakIntensity = true;
ROIImageInfo.GrayLimits = [1 Param.NumLevels];

%///////////////////////////////////////////////////////////////////////////%
%-----------------------------DO_NOT_CHANGE_STARTS--------------------------%
%---Return Value
ROIImageInfo.Summary = Summary;
ROIImageInfo.Description=MFileName;
ImageInfo_InROIBox=ROIImageInfo;
BinaryMaskInfo_InROIBox=ROIBWInfo;
%-----------------------------DO_NOT_CHANGE_ENDS----------------------------%
%///////////////////////////////////////////////////////////////////////////%
