function [ImageInfo_InROIBox, BinaryMaskInfo_InROIBox]=MaskEdgeRing(DataItemInfo, Param)
%%%Doc Starts%%%
%-Description: 
%This filter is to create ring mask around the mask boundary

%-Parameters:
% BandSize: The baned size in the pixel unit. 

%-Revision:
%2015-06-18:  The method is implemented.

%-Author:
%Joy Zhang, lifzhang@mdanderson.org
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
%%-----------MaskEdgeRing.INI------%
%Load the default parameters from INI
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

if nargin < 2
    ConfigFile=[MFilePath, '\', MFileName, '.INI'];
    Param=GetParamFromINI(ConfigFile);
end
%-----------------------------DO_NOT_CHANGE_ENDS------------------------------%
%///////////////////////////////////////////////////////////////////////////////////////////////////////////////////%


%///////////////////////////////////////////////////////////////////////////////////////////////////////////////////%
%%-----------Implement your code starting from here---------%
%****The skeleton preprocess smoothes the image and erodes binary mask****%


%---Sanity Check
if ~isfield(Param, 'BandSize')
    ImageInfo_InROIBox=[];
    BinaryMaskInfo_InROIBox=[];
    
    return;
end


%----Band ROI Binary Mask
MorphNum=floor(Param.BandSize/2);

ROIImageInfo=DataItemInfo.ROIImageInfo;
ROIBWInfo=DataItemInfo.ROIBWInfo;
MaskDataOri=ROIBWInfo.MaskData;

SE = strel('disk', MorphNum);
MaskErode=imerode(ROIBWInfo.MaskData, SE);
MaskDilate=imdilate(ROIBWInfo.MaskData, SE);

ROIBWInfo.MaskData=xor(MaskErode, MaskDilate);

LayerInfo=[];
for i=1:2
    TLayerInfo=ROIImageInfo;
    switch i       
        case 1
            TLayerInfo.MaskData=uint8(xor(MaskDilate, MaskDataOri));
            TLayerInfo.Color=[0, 0, 1];
             TLayerInfo.Alpha=0.3;
        case 2
            TLayerInfo.MaskData=uint8(xor(MaskErode, MaskDataOri));
            TLayerInfo.Color=[0, 1, 0];
            TLayerInfo.Alpha=0.2;
    end     
    
    LayerInfo=[LayerInfo, TLayerInfo];
end

ROIImageInfo.LayerInfo=LayerInfo;

%///////////////////////////////////////////////////////////////////////////////////////////////////////////////////%
%-----------------------------DO_NOT_CHANGE_STARTS--------------------------%
%---Return Value
ROIImageInfo.Description=MFileName;
ImageInfo_InROIBox=ROIImageInfo;

BinaryMaskInfo_InROIBox=ROIBWInfo;
%-----------------------------DO_NOT_CHANGE_ENDS------------------------------%
%///////////////////////////////////////////////////////////////////////////////////////////////////////////////////%




