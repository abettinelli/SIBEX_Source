function [ImageInfo_InROIBox, BinaryMaskInfo_InROIBox]=IBSI2_Riesz_LoG_filter(DataItemInfo, Param)
%%%Doc Starts%%%
%-Description:
% RIESZ-LoG FILTERING

% -Parameters:
% 1. padding:
%       C: double. The image is padded with a constant value C.
%       'nearest': it repeats the values of the image at the boundary.
%       'periodisation': repeats the image along every dimension.
%       'mirror': symmetrises the image at the boundaries. (default)
% 2. sigma_star(cm):
%       standard deviation of the filter (default is 0.1 cm). Within the function, it will be
%       converted in voxel units.
% 3. type:
%       '2D': slice by slice filtering.
%       '3D': 3D filtering (default).
% 4. d:
%       truncation parameter(default is 4) for LoG. Truncation and standard deviation parameters of the filter are used to create
%       filter support, M.
% 5. l:
%       sequence of two (2D) or 3 (3D) integer defining the lth-order
%       derivatives for each dimesnion
% 6. sigma_tensor: [] not implemented yet

%-Revision:
% 04/08/2021: first implementation.
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
if ~isfield(Param, 'padding') || ~isfield(Param, 'type') || ~isfield(Param, 'l')
    ImageInfo_InROIBox=[];
    BinaryMaskInfo_InROIBox=[];
    return;
end

% Check sigma_star dimension and conversion from cm to n° of voxels
switch length(Param.sigma_star)
	case 1 % sigma is 1D
		if strcmp(Param.type,'2D')
% 			warning('Image has been considered isotropic')
			sigma = Param.sigma_star/DataItemInfo.XPixDim;
		else % type = '3D'
			sigma_x = Param.sigma_star/DataItemInfo.XPixDim;
			sigma_y = Param.sigma_star/DataItemInfo.YPixDim;
			sigma_z = Param.sigma_star/DataItemInfo.ZPixDim;
			sigma = [sigma_x,sigma_y,sigma_z];
		end
		
	case 2
		if strcmp(Param.type,'2D')
			sigma_x = Param.sigma_star(1)/DataItemInfo.XPixDim;
			sigma_y = Param.sigma_star(2)/DataItemInfo.YPixDim;
			sigma = [sigma_x, sigma_y];
		else % type = '3D'
			warning('sigma_star must be three-dimensional for 3D filtering')
			return;
		end
		
	case 3
		if strcmp(Param.type,'2D')
			warning('sigma_star must be one- or two-dimensional for 2D filtering')
			return;
		else % type = '3D'
			sigma_x = Param.sigma_star(1)/DataItemInfo.XPixDim;
			sigma_y = Param.sigma_star(2)/DataItemInfo.YPixDim;
			sigma_z = Param.sigma_star(3)/DataItemInfo.ZPixDim;
			sigma = [sigma_x,sigma_y,sigma_z];
		end
end

Param.M = 1+2*floor(Param.d*sigma + 0.5); % depending on sigma, M could be 3D

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

%----Get Riesz Filter
filter_riesz_freq=IBSI2_get_riesz_filter(ROIImageInfo.MaskData, Param);

%----Get LoG Filter
filter_LoG_freq=LoG_filter(ROIImageInfo.MaskData, Param, sigma);

% Apply_filters
[ROIImageInfo.MaskData] = IBSI2_apply_riesz_filtering(ROIImageInfo.MaskData, filter_riesz_freq.*filter_LoG_freq, Param);
ROIImageInfo.MaskData = real(ROIImageInfo.MaskData);

%---Summary
Summary.Type = 'IBSI2_Riesz_LoG_filter';
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


function filter = LoG_filter(MaskData, Param, sigma)

% Padding measurements
N=max(size(MaskData));
pad_square = N-size(MaskData);
N_half_filter = ceil((N+1)/2)-1;

pad_pre=ceil(pad_square/2) + N_half_filter;
pad_post=floor(pad_square/2) + N_half_filter;

NF=max(pad_pre+size(MaskData)+pad_post);

%Fourier space
idx_k = (1:NF)-(floor(NF/2)+1); % +1 to get most frequencies on the right side

% Create LoG filter
switch Param.type
    case '2D'
        [K1, K2] = meshgrid(idx_k, idx_k);
        filter=fspecial('log', Param.M, sigma);
    case '3D'
        [K1, K2, K3] = meshgrid(idx_k, idx_k, idx_k);
        filter=fspecial3('log', Param.M, sigma);
end

PAD_pre=ceil((size(K1)-Param.M)/2);
PAD_post=floor((size(K1)-Param.M)/2);
filter=padarray(filter, PAD_pre,0,'pre');
filter=padarray(filter, PAD_post,0,'post');

filter=ifftshift(filter);	% Why ifftshift?

filter = fftn(filter);
