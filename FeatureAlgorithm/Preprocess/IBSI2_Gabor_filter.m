function [ImageInfo_InROIBox, BinaryMaskInfo_InROIBox]=IBSI2_Gabor_filter(DataItemInfo, Param)
%%%Doc Starts%%%
%-Description:
% GABOR FILTER

%-Parameters:
% 1. padding:
%       C: double. The image is padded with a constant value C.
%       'nearest': it repeats the values of the image at the boundary.
%       'periodisation': repeats the image along every dimension.
%       'mirror': symmetrises the image at the boundaries (default).
% 2. sigma_star(cm):
%       filter scale, i.e., standard deviation of the Gaussian envelope (default is 1 cm).
% 3. lambda_star:
%        wavelength of the oscillations in cm (default is 0.4 cm).
% 4. gamma:
%       spatial aspect ratio, i.e., ellipticity of the support of the filter 
%           (default is 1/2).
% 5. theta:
%        angle in radians defining the orientation of the rotated k1 axes. 
%        Numeric scalar in the range [0 2*pi] (default is 0 rad).
% 6. rotation_invariance:
%       1: the response map is invariant to local rotation.
%       0: the response map is NOT invariant to local rotation.
% 7. delta_theta:
%        angle step (in radians) to sample 2*pi when rotation_invariance is 
%           set to 1
% 8. pooling:
%       'avg': average pooling for rotation invariance filter bank.
%       'max': maximum pooling for rotation invariance filter bank.
% 9. approximate_3d
%       false: 2d filtering (default)
%       true: apply 2DGabor filtering in the three orthogonal planes
%           followed by an averaging of the response maps over the three planes.

%-Revision:
% 27/07/2021: First version.
% 18/01/2022: Second version.
% 20/01/2022: Third version.

%-Author:
% Francesca Marturano 
% Andrea Bettinelli
%%%Doc Ends%%%

%///////////////////////////////////////////////////////////////////////////%
%-----------------------------DO_NOT_CHANGE_STARTS--------------------------%
%%-----------IBS2_Gabor_filter.INI------%
%Load the default parameters from INI
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

if nargin < 2
    ConfigFile=[MFilePath, '\', MFileName, '.INI'];
    Param=GetParamFromINI(ConfigFile);
end

DataItemInfo = IBSI_waterCTnumber(DataItemInfo);
DataItemInfo.ROIImageInfo.MaskData = flip(DataItemInfo.ROIImageInfo.MaskData,3);
% DataItemInfo.ROIImageInfo.MaskData = permute(DataItemInfo.ROIImageInfo.MaskData,[2 1 3]);

%-----------------------------DO_NOT_CHANGE_ENDS----------------------------%
%///////////////////////////////////////////////////////////////////////////%

%---Sanity Check
if ~isfield(Param, 'sigma_star') || ~isfield(Param, 'lambda_star') || ~isfield(Param, 'padding') || ~isfield(Param, 'approximate_3d') ||...
        ~isfield(Param, 'gamma') || ~isfield(Param, 'theta') || ~isfield(Param, 'pooling') || ~isfield(Param, 'delta_theta') || ~isfield(Param, 'rotation_invariance')
    ImageInfo_InROIBox=[];
    BinaryMaskInfo_InROIBox=[];
    return;
end

% IBSI will let the user set it?
Param.d = 7;

% Rotate theta for rotation invariance (in rad)
if Param.rotation_invariance
    theta = create_theta_vec(Param.delta_theta);
else
    theta = Param.theta;
end

if isempty(Param.rotation_invariance)
    Param.rotation_invariance = 0;
end

% Padding
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

%----Filter
if Param.approximate_3d
    % Gabor filter bank
    gabor_filter_bank = IBSI2_get_gabor_filters(Param, theta, DataItemInfo.XPixDim);
    
    xyz_lim = size(ROIImageInfo.MaskData);
    InputImage_plane = ROIImageInfo.MaskData;
    FilteredImage_plane1 = zeros(size(ROIImageInfo.MaskData));
    FilteredImage_plane2 = zeros(size(ROIImageInfo.MaskData));
    FilteredImage_plane3 = zeros(size(ROIImageInfo.MaskData));
    FilteredImage_3D = zeros([size(ROIImageInfo.MaskData) 3]);
    
    parfor i=1:xyz_lim(1)	% CORONAL
        CurrentData=squeeze(InputImage_plane(i, :, :));
        FilteredData = IBSI2_apply_gabor_filtering(CurrentData,gabor_filter_bank, Param);
        FilteredImage_plane1(i, :, :) = FilteredData;
    end
    parfor i=1:xyz_lim(2)	% SAGGITTAL
        CurrentData=squeeze(InputImage_plane(:, i, :));
        FilteredData = IBSI2_apply_gabor_filtering(CurrentData,gabor_filter_bank, Param);
        FilteredImage_plane2(:, i, :) = FilteredData;
    end
    parfor i=1:xyz_lim(3)	% AXIAL
        CurrentData=squeeze(InputImage_plane(:, :, i));
        FilteredData = IBSI2_apply_gabor_filtering(CurrentData,gabor_filter_bank, Param);
        FilteredImage_plane3(:, :, i) = FilteredData;
    end
    
    FilteredImage_3D(:,:,:,1) = FilteredImage_plane1;
    FilteredImage_3D(:,:,:,2) = FilteredImage_plane2;
    FilteredImage_3D(:,:,:,3) = FilteredImage_plane3;
    
    ROIImageInfo.MaskData = mean(FilteredImage_3D,4);
else % Only AXIAL
    % Gabor filter bank
    gabor_filter_bank = IBSI2_get_gabor_filters(Param, theta, DataItemInfo.XPixDim);
    
    InputImage_plane = ROIImageInfo.MaskData;
    FilteredImage = zeros(size(ROIImageInfo.MaskData));
    parfor i= 1:DataItemInfo.ROIImageInfo.ZDim
        CurrentData=squeeze(InputImage_plane(:, :, i));
        FilteredData = IBSI2_apply_gabor_filtering(CurrentData,gabor_filter_bank, Param);
        FilteredImage(:, :, i) = FilteredData;
    end
    ROIImageInfo.MaskData = FilteredImage;
end

%---Summary
Summary.Type = 'IBS2_Gabor_filter';
Summary.Parameters = Param;
Summary.BreakIntensity = true; % this must be true for the next operations with SIBEX

%///////////////////////////////////////////////////////////////////////////%
%-----------------------------DO_NOT_CHANGE_STARTS--------------------------%
%---Return Value
ROIImageInfo.Summary = Summary;
ROIImageInfo.Description=MFileName;
% ROIImageInfo.MaskData = permute(ROIImageInfo.MaskData,[2 1 3]);
ROIImageInfo.MaskData = flip(ROIImageInfo.MaskData,3);
ImageInfo_InROIBox=ROIImageInfo;
BinaryMaskInfo_InROIBox=ROIBWInfo;
%-----------------------------DO_NOT_CHANGE_ENDS----------------------------%
%///////////////////////////////////////////////////////////////////////////%


function theta_vec = create_theta_vec(delta_theta)

% Orientations for the filter bank
theta_vec = 0:delta_theta:2*pi; 
if theta_vec(end)==2*pi
    theta_vec = theta_vec(1:end-1);
end

% Check for duplicate angles
idx = find(theta_vec == pi);
if ~isempty(idx)
    theta_vec(idx:end) = [];
end