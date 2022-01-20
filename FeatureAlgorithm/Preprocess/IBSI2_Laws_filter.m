function [ImageInfo_InROIBox, BinaryMaskInfo_InROIBox]=IBSI2_Laws_filter(DataItemInfo, Param)
%%%Doc Starts%%%
%-Description:
% LAWS KERNELS

% -Parameters:
% 1. padding:
%       C: double. The image is padded with a constant value C.
%       'nearest': it repeats the values of the image at the boundary.
%       'periodisation': repeats the image along every dimension.
%       'mirror': symmetrises the image at the boundaries. (default)
% 2. sequence: e.g. 'S5L5E3' -> S5 on first dimension, L5 on second E3 on third
%       'LX': low pass kernel with a spatial support of X (3 or 5) pixels
%       'EX': edge kernel with a spatial support of X (3 or 5) pixels
%       'SX': spot kernel with a spatial support of X (3 or 5) pixels
%       'R5': wave kernel with a spatial support of X 5 pixels
%       'W5': ripples kernel with a spatial support of X 5 pixels
% 3. type:
%       '2D': slice by slice filtering.
%       '3D': 3D filtering (default).
% 4. rotation_invariance:
%       true: the response map is invariant to local rotation.
%       false: the response map is NOT invariant to local rotation.
% 5. pooling:
%       'avg': average pooling for rotation invariance filter bank.
%       'max': maximum pooling for rotation invariance filter bank.
% 6. output_type:
%       'response_map': filtered image (default).
%       'energy_map': smoothed version of the absolute intensities of the
%       response map.
% 7. distance: to be specify if the output type is "energy map"
%       d: integer. Parameter controlling the support [2d + 1] of the
%       smoothing filter.

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
if ~isfield(Param, 'sequence') || ~isfield(Param, 'padding') || ~isfield(Param, 'type') || ~isfield(Param, 'rotation_invariance') || ~isfield(Param, 'output_type') || ~isfield(Param, 'distance')
    ImageInfo_InROIBox=[];
    BinaryMaskInfo_InROIBox=[];
    return;
end

%---Warnings
switch Param.type
    case '2D'
        if length(Param.sequence)~=4
            warning('You must provide 2 for 2D filtering')
            ImageInfo_InROIBox=[];
            BinaryMaskInfo_InROIBox=[];
            return
        end
    case '3D'
        if length(Param.sequence)~=6
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

rotation_invariance = Param.rotation_invariance;

%----ROIImage
ROIImageInfo=DataItemInfo.ROIImageInfo;
ROIImageInfo.MaskData = double(ROIImageInfo.MaskData);

%----Binary Mask
ROIBWInfo=DataItemInfo.ROIBWInfo;

% Laws Kernel
[monoFilterBank, FilterKernel]=laws(Param.sequence);
    
% Laws Filter
switch Param.type
    case '2D'
        % slice by slice
        par_Image = ROIImageInfo.MaskData;
        parfor i=1:DataItemInfo.ROIImageInfo.ZDim
            CurrentData=par_Image(:, :, i);
            if ~rotation_invariance
                CurrentData=imfilter(CurrentData, FilterKernel, Param.padding, 'same', 'conv');
            else
                CurrentData=IBSI2_imfilter_ri(CurrentData, monoFilterBank, Param.padding, Param.pooling);
            end
            par_FilteredImage(:, :, i)=CurrentData;
        end
        ROIImageInfo.MaskData = par_FilteredImage;
    case '3D'
        % All volume at once
        CurrentData=ROIImageInfo.MaskData;
        if ~Param.rotation_invariance
            CurrentData=imfilter(CurrentData, FilterKernel, Param.padding, 'same', 'conv');
        else
            CurrentData=IBSI2_imfilter_ri(CurrentData, monoFilterBank, Param.padding, Param.pooling);
        end
        ROIImageInfo.MaskData=CurrentData;
end

% Additional Mean Filter
if isequal(Param.output_type, 'energy_map')
    
    % Absolute value
    ROIImageInfo.MaskData = abs(ROIImageInfo.MaskData);
    
    W=2*Param.distance+1;
    switch Param.type
        case '2D'
            %Kernel
            MeanKernel=fspecial('average', W);
            
            % slice by slice
            for i=1:DataItemInfo.ROIImageInfo.ZDim
                CurrentData=ROIImageInfo.MaskData(:, :, i);
                CurrentData=imfilter(CurrentData, MeanKernel, Param.padding, 'same', 'conv');
                ROIImageInfo.MaskData(:, :, i)=CurrentData;
            end
        case '3D'
            %Kernel
            MeanKernel=fspecial3('average', W);
            
            % All volume at once
            CurrentData=ROIImageInfo.MaskData;
            CurrentData=imfilter(CurrentData, MeanKernel, Param.padding, 'same', 'conv');
            ROIImageInfo.MaskData=CurrentData;
    end
end

%---Summary
Summary.Type = 'IBSI2_Laws_filter';
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


function [monoFilterBank, FilterKernel] = laws(seq)

filters = reshape(seq',2,[])';

for i =1:size(filters,1)
    f_type=filters(i,1);
    f_size=filters(i,2);
    switch f_type
        case 'L'
            switch f_size
                case '3'
                    monoFilterBank{i,1} = [1 2 1]./(norm([1 2 1]));
                case '5'
                    monoFilterBank{i,1} = [1 4 6 4 1]./(norm([1 4 6 4 1]));
            end
        case 'E'
            switch f_size
                case '3'
                    monoFilterBank{i,1} = [-1 0 1]./(norm([-1 0 1]));
                case '5'
                    monoFilterBank{i,1} = [-1 -2 0 2 1]./(norm([-1 -2 0 2 1]));
            end
        case 'S'
            switch f_size
                case '3'
                    monoFilterBank{i,1} = [-1 -2 -1]./(norm([-1 -2 -1]));
                case '5'
                    monoFilterBank{i,1} = [-1 0 2 0 -1]./(norm([-1 0 2 0 -1]));
            end
        case 'W'
            switch f_size
                case '3'
                    warning('No size 3 with Wave filter')
                case '5'
                    monoFilterBank{i,1} = [-1 2 0 -2 1]./(norm([-1 2 0 -2 1]));
            end
        case 'R'
            switch f_size
                case '3'
                    warning('No size 3 with Ripple filter')
                case '5'
                    monoFilterBank{i,1} = [1 -4 6 -4 1]./(norm([1 -4 6 -4 1]));
            end
    end
end

% Create Kernel
FilterKernel = IBSI2_create_filter_kernel(monoFilterBank);