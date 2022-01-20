function [ImageInfo_InROIBox, BinaryMaskInfo_InROIBox]=IBSI2_LoG_filter(DataItemInfo, Param)
%%%Doc Starts%%%
%-Description: 
% Laplacian of Gaussian (LoG) FILTER

%-Parameters:
% 1. padding:
%       C: double. The image is padded with a constant value C.
%       'nearest': it repeats the values of the image at the boundary.
%       'periodisation': repeats the image along every dimension.
%       'mirror': symmetrises the image at the boundaries (default).
% 2. sigma_star(cm):
%       standard deviation of the filter (default is 0.1 cm). Within the function, it will be
%       converted in voxel units.
% 3. type:
%       '2D': slice by slice filtering (default).
%       '3D': 3D filtering.
% 4. d:
%       truncation parameter(default is 4). Truncation and standard deviation parameters of the filter are used to create
%       filter support, M.

%-Revision:
% 27/07/2021: First version.
% 20/01/2022: update.

%-Author:
% Francesca Marturano
% Andrea Bettinelli
%%%Doc Ends%%%

%///////////////////////////////////////////////////////////////////////////%
%-----------------------------DO_NOT_CHANGE_STARTS--------------------------%
%%-----------IBS2_LoG_filter.INI------%
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
if ~isfield(Param, 'sigma_star') || ~isfield(Param, 'padding') || ~isfield(Param, 'd') || ~isfield(Param, 'type')
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

% calculating filter support, M
M = 1+2*floor(Param.d*sigma + 0.5); % depending on sigma, M could be 3D

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
switch Param.type
    case '2D'
        % Kernel
        FilterKernel=fspecial('log', M, sigma);

        par_Image = ROIImageInfo.MaskData;
        parfor i=1:DataItemInfo.ROIImageInfo.ZDim
            CurrentData=par_Image(:, :, i);
            CurrentData=imfilter(CurrentData, FilterKernel, Param.padding, 'same', 'conv');
            par_FilteredImage(:, :, i)=CurrentData;
        end
        ROIImageInfo.MaskData = par_FilteredImage;
    case '3D'
        % Kernel
        FilterKernel=fspecial3('log', M, sigma);

        % All volume at once
        CurrentData=ROIImageInfo.MaskData;
        CurrentData=imfilter(CurrentData, FilterKernel, Param.padding, 'same', 'conv');
        ROIImageInfo.MaskData=CurrentData;
end

%---Summary
Summary.Type = 'IBS2_LoG_filter';
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
