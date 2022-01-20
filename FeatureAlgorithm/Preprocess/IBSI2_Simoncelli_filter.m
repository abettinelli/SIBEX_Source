function [ImageInfo_InROIBox, BinaryMaskInfo_InROIBox]=IBSI2_Simoncelli_filter(DataItemInfo, Param)
%%%Doc Starts%%%
%-Description:
% SIMONCELLI FILTERING

% -Parameters:
% 1. padding:
%       C: double. The image is padded with a constant value C.
%       'nearest': it repeats the values of the image at the boundary.
%       'periodisation': repeats the image along every dimension.
%       'mirror': symmetrises the image at the boundaries. (default)
% 2. type:
%       '2D': slice by slice filtering.
%       '3D': 3D filtering (default).
% 3. level:
%       l: integer. Level of undecimated filtering.

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
if ~isfield(Param, 'padding') || ~isfield(Param, 'type') || ~isfield(Param, 'level')
    ImageInfo_InROIBox=[];
    BinaryMaskInfo_InROIBox=[];
    return;
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

%----Apply Simoncelli Filtering
ROIImageInfo.MaskData=simoncelli_filtering(ROIImageInfo.MaskData, Param);

%---Summary
Summary.Type = 'IBSI2_Simoncelli_filter';
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


function [MaskData_filtered] = simoncelli_filtering(MaskData, Param)

N=max(size(MaskData));

% Image_padding
pad_square = N-size(MaskData);
N_pad = ceil((N+1)/2)-1;
pad_pre=ceil(pad_square/2) + N_pad;
pad_post=floor(pad_square/2) + N_pad;

% pad_post = pad_post+(1-mod(size(MaskData)+pad_pre+pad_post,2))*1;
MaskData_pad = padarray(MaskData, pad_pre, Param.padding, 'pre');
MaskData_pad = padarray(MaskData_pad, pad_post, Param.padding, 'post');

NF=max(size(MaskData_pad));

%Fourier space
switch Param.type
    case '2D'
        f_IMG=MaskData_pad;
        parfor i = 1:size(MaskData_pad,3)
            f_IMG(:,:,i)= fftn(squeeze(MaskData_pad(:,:,i)));
        end
    case '3D'
        f_IMG = fftn(MaskData_pad);   
end

idx_k = (1:NF)-(floor(NF/2)+1); % +1 to get most frequencies on the right part
% idx_k = idx_k./max(abs(idx_k)).*pi;

switch Param.type
    case '2D'
        [K1, K2] = meshgrid(idx_k, idx_k);
        modFreq = sqrt(K1.^2+K2.^2);
    case '3D'
        [K1, K2, K3] = meshgrid(idx_k, idx_k, idx_k);
        modFreq = sqrt(K1.^2+K2.^2+K3.^2);
end

% Create Simoncelli filter
vB=max(abs(idx_k))/(2.^(Param.level-1));
filter = cos(pi/2*log2(2*modFreq/vB)).*(modFreq>=vB/4 & modFreq<vB);
flag=(modFreq>=vB/4 & modFreq<vB);
filter(flag==0) = 0;
filter = ifftshift(filter); % Shift filter

% Apply filter
switch Param.type
    case '2D'
        MaskData_filtered=f_IMG;
        parfor i = 1:size(f_IMG,3)
            MaskData_filtered(:,:,i)= ifftn(squeeze((f_IMG(:,:,i)).*filter));
        end
        
    case '3D'
        MaskData_filtered=ifftn(f_IMG.*filter);
end

% Delete Padding
MaskData_filtered=MaskData_filtered((pad_pre(1)+1):end-pad_post(1),(pad_pre(2)+1):end-pad_post(2),(pad_pre(3)+1):end-pad_post(3));