function [ImageInfo_InROIBox, BinaryMaskInfo_InROIBox]=RoundtoNearest(DataItemInfo, Param)
%%%Doc Starts%%%
%-Description: 
%This function rounds the image data to the nearest X where X is the value
%of the input  parameter.

%-Parameters:
%Value: The value which all numbers should be rounded to its nearest
%increment
%e.g. if value is 0.5 for [1.1,2.6,3.2] the result is [1.0, 2.5, 3.0]
%e.g. if value is 1 for [1.1,2.6,3.2] the result is [1.0, 3.0, 3.0]

%-Revision:
%08-11-2014: Implemented

%-Author:
%David Fried, DVFried@mdanderson.org
%%%Doc Ends%%%

%Purpose:       To preprocess image data or binary mask before caculating features
%Architecture: All the preprocess-relevant files are under \IBEXCodePath\FeatureAlgorithm\Preprocess.
%Files:            *PreprocessName*.m, *PreprocessName*.INI

%%---------------Input Parameters Passed In By IBEX--------------%
%DataItemInfo:  a structure containing information on the entire image, image-inside-ROIBoundingBox and binary-mask-inside-ROIBoundingBox
%Param:            The entry used for IBEX to accept the parameters from GUI. Use .INI to define the default parameters

%%--------------Output Parameters------------%
%ImageInfo_InROIBox:           information on image-inside-ROIBoundingBox
%BinaryMaskInfo_InROIBox:  information on binary-mask-inside-ROIBoundingBox

%///////////////////////////////////////////////////////////////////////////////////////////////////////////////////%
%-----------------------------DO_NOT_CHANGE_STARTS--------------------------%
%%-----------RoundtoNearest.INI------%
%Load the default parameters from INI
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

if nargin < 2    
ConfigFile=[MFilePath, '\', MFileName, '.INI'];    
Param=GetParamFromINI(ConfigFile);    
end
%-----------------------------DO_NOT_CHANGE_ENDS------------------------------%
%///////////////////////////////////////////////////////////////////////////////////////////////////////////////////%

%DataItemInfo.XDim: X Dimension of the entire image
%DataItemInfo.YDim: Y Dimension of the entire image
%DataItemInfo.ZDim: Z Dimension of the entire image
%DataItemInfo.XPixDim: X Pixel Size of the entire image
%DataItemInfo.YPixDim: Y Pixel Size of the entire image
%DataItemInfo.ZPixDim: Z Pixel Size of the entire image
%DataItemInfo.XStart: X Start Point of the entire image
%DataItemInfo.YStart: Y Start point of the entire image
%DataItemInfo.ZStart: Z Start Point of the entire image

%DataItemInfo.ROIImageInfo:  information on image-inside-ROIBoundingBox
%DataItemInfo.ROIImageInfo.MaskData: Image Data of the image-inside-ROIBoundingBox
%DataItemInfo.ROIImageInfo.XDim: X Dimension of the image-inside-ROIBoundingBox
%DataItemInfo.ROIImageInfo.YDim: Y Dimension of the image-inside-ROIBoundingBox
%DataItemInfo.ROIImageInfo.ZDim: Z Dimension of the image-inside-ROIBoundingBox
%DataItemInfo.ROIImageInfo.XPixDim: X Pixel Size of the image-inside-ROIBoundingBox
%DataItemInfo.ROIImageInfo.YPixDim: Y Pixel Size of the image-inside-ROIBoundingBox
%DataItemInfo.ROIImageInfo.ZPixDim: Z Pixel Size of the image-inside-ROIBoundingBox
%DataItemInfo.ROIImageInfo.XStart: X Start Point of the image-inside-ROIBoundingBox
%DataItemInfo.ROIImageInfo.YStart: Y Start point of the image-inside-ROIBoundingBox
%DataItemInfo.ROIImageInfo.ZStart: Z Start Point of the image-inside-ROIBoundingBox

%DataItemInfo.ROIBWInfo:  information on ROI-binary-mask-inside-ROIBoundingBox
%DataItemInfo.ROIBWInfo.MaskData: Image Data of the ROI-binary-mask-inside-ROIBoundingBox
%DataItemInfo.ROIBWInfo.XDim: X Dimension of the ROI-binary-mask-inside-ROIBoundingBox
%DataItemInfo.ROIBWInfo.YDim: Y Dimension of the ROI-binary-mask-inside-ROIBoundingBox
%DataItemInfo.ROIBWInfo.ZDim: Z Dimension of the ROI-binary-mask-inside-ROIBoundingBox
%DataItemInfo.ROIBWInfo.XPixDim: X Pixel Size of the ROI-binary-mask-inside-ROIBoundingBox
%DataItemInfo.ROIBWInfo.YPixDim: Y Pixel Size of the ROI-binary-mask-inside-ROIBoundingBox
%DataItemInfo.ROIBWInfo.ZPixDim: Z Pixel Size of the ROI-binary-mask-inside-ROIBoundingBox
%DataItemInfo.ROIBWInfo.XStart: X Start Point of the ROI-binary-mask-inside-ROIBoundingBox
%DataItemInfo.ROIBWInfo.YStart: Y Start point of the ROI-binary-mask-inside-ROIBoundingBox
%DataItemInfo.ROIBWInfo.ZStart: Z Start Point of the ROI-binary-mask-inside-ROIBoundingBox


%///////////////////////////////////////////////////////////////////////////////////////////////////////////////////%
%%-----------Implement your code starting from here---------%
%****The skeleton preprocess smoothes the image and erodes binary mask****%

%---Explore variables by display
% DataItemInfo
% DataItemInfo.ROIImageInfo
% DataItemInfo.ROIBWInfo

%---Sanity Check
if ~isfield(Param, 'Value')
ImageInfo_InROIBox=[];
BinaryMaskInfo_InROIBox=[];
return;
end
%----
ROIImageInfo=DataItemInfo.ROIImageInfo;

if(length(min(floor(ROIImageInfo.MaskData(:))):Param.Value:max(ceil(ROIImageInfo.MaskData(:))))<3)
    error('Value parameter not appropriate.  Please choose a different parameter value!')
end


%Round 
for i=1:DataItemInfo.ROIImageInfo.ZDim
    CurrentData=double(ROIImageInfo.MaskData(:, :, i));
    if max(CurrentData(:))==0
        ROIImageInfo.MaskData(:, :, i)=CurrentData;
    else
        ROIImageInfo.MaskData(:, :, i)=reshape(interp1(min(floor(CurrentData(:))):Param.Value:max(ceil(CurrentData(:))),min(floor(CurrentData(:))):Param.Value:max(ceil(CurrentData(:))),CurrentData(:),'nearest'),size(CurrentData,1),size(CurrentData,2));
    end
end




%///////////////////////////////////////////////////////////////////////////////////////////////////////////////////%
%-----------------------------DO_NOT_CHANGE_STARTS--------------------------%
%---Return Value
ROIImageInfo.Description=MFileName;
ROIImageInfo.Round=Param.Value;
ImageInfo_InROIBox=ROIImageInfo;

BinaryMaskInfo_InROIBox=DataItemInfo.ROIBWInfo;
%-----------------------------DO_NOT_CHANGE_ENDS------------------------------%
%///////////////////////////////////////////////////////////////////////////////////////////////////////////////////%




