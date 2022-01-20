function [ImageInfo_InROIBox, BinaryMaskInfo_InROIBox]=IBSI2_Coiflets_filter(DataItemInfo, Param)
%%%Doc Starts%%%
%-Description:
% COIFLETS WAVELET FILTERING

% -Parameters:
% 1. padding:
%       C: double. The image is padded with a constant value C.
%       'nearest': it repeats the values of the image at the boundary.
%       'periodisation': repeats the image along every dimension.
%       'mirror': symmetrises the image at the boundaries. (default)
% 2. sequence: character sequence of length 2 (for 2D filtering) or 3 (for 
%           3D filtering) definining the filter type the for each image dimension. 
%           For example 'HLH'.
%       'H': high-pass filter.
%       'L': low-pass filter.
% 3. type:
%       '2D': slice by slice filtering.
%       '3D': 3D filtering (default).
% 4. rotation_invariance:
%       1: the response map is invariant to local rotation.
%       0: the response map is NOT invariant to local rotation.
% 5. pooling:
%       'avg': average pooling for rotation invariance filter bank.
%       'max': maximum pooling for rotation invariance filter bank.
% 6. level:
%       l: integer. Level of undecimated filtering.
% 7. number:
%       p: integer. Number of vanishing moments.

%-Revision:
% 27/07/2021: first implementation.
% 20/01/2022: update.

%-Author:
% Andrea Bettinelli.
%%%Doc Ends%%%

%///////////////////////////////////////////////////////////////////////////%
%-----------------------------DO_NOT_CHANGE_STARTS--------------------------%
%%-----------IBSI2_mean_filter.INI------%
%Load the default parameters from INI
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

if nargin < 2
    ConfigFile=[MFilePath, '\', MFileName, '.INI'];
    Param=GetParamFromINI(ConfigFile);
end

DataItemInfo = IBSI_waterCTnumber(DataItemInfo);
DataItemInfo.ROIImageInfo.MaskData = flip(DataItemInfo.ROIImageInfo.MaskData,3);

%-----------------------------DO_NOT_CHANGE_ENDS----------------------------%
%///////////////////////////////////////////////////////////////////////////%

%---Sanity Check
if ~isfield(Param, 'sequence') || ~isfield(Param, 'padding') || ~isfield(Param, 'type') || ~isfield(Param, 'rotation_invariance') || ~isfield(Param, 'number')
    ImageInfo_InROIBox=[];
    BinaryMaskInfo_InROIBox=[];
    return;
end

%---Warnings
switch Param.type
    case '2D'
        if length(Param.sequence)~=2
            warning('You must provide 2 for 2D filtering')
            ImageInfo_InROIBox=[];
            BinaryMaskInfo_InROIBox=[];
            return
        end
    case '3D'
        if length(Param.sequence)~=3
            warning('You must provide 3 for 3D filtering')
            ImageInfo_InROIBox=[];
            BinaryMaskInfo_InROIBox=[];
            return
        end
end

if isnumeric(Param.padding)
    C = Param.padding;
    Param.padding = 'constant';
end

switch Param.padding
    case 'constant'
        Param.padding = C;
    case 'nearest'
        Param.padding = 'replicate';
    case 'periodic'
        Param.padding = 'circular';
    case 'mirror'
        Param.padding = 'symmetric';
end

%----ROIImage
ROIImageInfo=DataItemInfo.ROIImageInfo;
ROIImageInfo.MaskData = double(ROIImageInfo.MaskData);

%----Binary Mask
ROIBWInfo=DataItemInfo.ROIBWInfo;

% Low pass Kernels
ROIImageInfo = IBSI2_separable_wavelets(ROIImageInfo, Param, 'coif');

%---Summary
Summary.Type = ['IBSI2_Coiflets' num2str(Param.number) '_filter'];
Summary.Parameters = Param;
Summary.BreakIntensity = true;

%///////////////////////////////////////////////////////////////////////////%
%-----------------------------DO_NOT_CHANGE_STARTS--------------------------%
%---Return Value
ROIImageInfo.Summary = Summary;
ROIImageInfo.Description=MFileName;
ROIImageInfo.MaskData = flip(ROIImageInfo.MaskData,3);
ImageInfo_InROIBox=ROIImageInfo;
BinaryMaskInfo_InROIBox=ROIBWInfo;
%-----------------------------DO_NOT_CHANGE_ENDS----------------------------%
%///////////////////////////////////////////////////////////////////////////%
