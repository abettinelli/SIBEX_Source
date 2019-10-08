function [ImageInfo_InROIBox, BinaryMaskInfo_InROIBox]=AutoSeg_DF(DataItemInfo, Param)

%%%Doc Starts%%%
%-Description: 
%1. This method is to segment the different tissues and to store the segmention result as the binary layers. 
%2.  It is designed for lung tumors on contrast enhanced scans.

%-Parameters:
%1.  TissueSeg3.m is the core code to perform the segmentation.
%2.  Cutoff values can be changed in TissueSegs.m.


%-Revision:
%2014-06-10: The method is implemented.

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
%%-----------AutoSeg_DF.INI------%
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

[Air,Necrosis,Tissue,Vessels]=TissueSeg3(DataItemInfo);

LayerInfo=[];
for i=1:4
    TLayerInfo=DataItemInfo.ROIImageInfo;
    switch i
        case 1
            TLayerInfo.MaskData=uint8(Air);
            TLayerInfo.Color=[1, 1, 1];
             TLayerInfo.Alpha=0.5;
        case 2
            TLayerInfo.MaskData=uint8(Necrosis);
            TLayerInfo.Color=[1, 0, 0];
             TLayerInfo.Alpha=0.3;
        case 3
            TLayerInfo.MaskData=uint8(Tissue);
            TLayerInfo.Color=[0, 1, 0];
             TLayerInfo.Alpha=0.2;
        case 4
            TLayerInfo.MaskData=uint8(Vessels);
            TLayerInfo.Color=[0, 0, 1];
             TLayerInfo.Alpha=0.5;
    end     
    
    LayerInfo=[LayerInfo, TLayerInfo];
end

DataItemInfo.ROIImageInfo.LayerInfo=LayerInfo;

ROIImageInfo=DataItemInfo.ROIImageInfo;
ROIBWInfo=DataItemInfo.ROIBWInfo;
% ROIBWInfo.MaskData=uint8(Vessels);
% ROIImageInfo.MaskData=uint16(Vessels);
%---Return Value NEVER TOUCH
ROIImageInfo.Description=MFileName;
ImageInfo_InROIBox=ROIImageInfo;

BinaryMaskInfo_InROIBox=ROIBWInfo;





