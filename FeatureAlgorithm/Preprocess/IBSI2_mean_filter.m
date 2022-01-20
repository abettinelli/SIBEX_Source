function [ImageInfo_InROIBox, BinaryMaskInfo_InROIBox]=IBSI2_mean_filter(DataItemInfo, Param)
%%%Doc Starts%%%
%-Description:
% The MEAN FILTER computes the average intensity over an MxM spatial
% support

% -Parameters:
% 1. padding:
%       C: double. The image is padded with a constant value C.
%       'nearest': it repeats the values of the image at the boundary.
%       'periodisation': repeats the image along every dimension.
%       'mirror': symmetrises the image at the boundaries. (default)
% 2. M: odd number. Dimensions of the spatial support in voxel units (default 15)
% 3. type:
%       '2D': slice by slice filtering.
%       '3D': 3D filtering (default).

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
if ~isfield(Param, 'M') || ~isfield(Param, 'padding') || ~isfield(Param, 'type')
    ImageInfo_InROIBox=[];
    BinaryMaskInfo_InROIBox=[];
    return;
end

%---Warnings
if mod(Param.M,2)==0
    warning('M must be odd')
    ImageInfo_InROIBox=[];
    BinaryMaskInfo_InROIBox=[];
    return
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

%Filter
switch Param.type
    case '2D'   % slice by slice
        %Kernel
        FilterKernel=fspecial('average', Param.M);

        par_Image = ROIImageInfo.MaskData;
        parfor i=1:DataItemInfo.ROIImageInfo.ZDim
            CurrentData=par_Image(:, :, i);
            CurrentData=imfilter(CurrentData, FilterKernel, Param.padding, 'same', 'conv');
            par_FilteredImage(:, :, i)=CurrentData;
        end
        ROIImageInfo.MaskData = par_FilteredImage;
    case '3D'
        %Kernel
        FilterKernel=fspecial3('average', Param.M);

        % All volume at once
        CurrentData=ROIImageInfo.MaskData;
        CurrentData=imfilter(CurrentData, FilterKernel, Param.padding, 'same', 'conv');
        ROIImageInfo.MaskData=CurrentData;
end

% niftiwrite(CurrentData,'C:\Users\k000868\Desktop\Output\Checkboard_15')

%---Summary
Summary.Type = 'IBSI2_mean_filter';
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
