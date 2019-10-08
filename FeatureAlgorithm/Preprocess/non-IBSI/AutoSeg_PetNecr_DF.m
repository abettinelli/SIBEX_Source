function [ImageInfo_InROIBox, BinaryMaskInfo_InROIBox]=AutoSeg_PetNecr_DF(CDataSetInfo, Param)
%%%Doc Starts%%%
%-Description:
%Put the method decription here.

%-Parameters:
%Put paramenter description here.

%-Revision:
%Put revision history here.

%-Author:
%Put author descriptoin here.
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
%%-----------AutoSeg_PetNecr_DF.INI------%
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

%%%%code here%%%%%
TLayerInfo=CDataSetInfo.ROIImageInfo;
Image3D = padarray(CDataSetInfo.ROIImageInfo.MaskData,[1 1 0]);
Mask3D = padarray(single(CDataSetInfo.ROIBWInfo.MaskData),[1 1 0]);
Initial_Guess = padarray(single(CDataSetInfo.ROIBWInfo.MaskData),[1 1 0]);
Vals_Eligible = [];
for i = 1:size(Initial_Guess,3);
    Mask_slice_temp = imerode(Mask3D(:,:,i),ones(5));
    Image_Eligible = nonzeros(Mask_slice_temp.*Image3D(:,:,i));
    Vals_Eligible = [Vals_Eligible;Image_Eligible];
end

if isempty(Vals_Eligible)||max(Vals_Eligible)<8
    BW= zeros(size(CDataSetInfo.ROIImageInfo.MaskData));
else
        [ID,centroids] = kmeans(Vals_Eligible,round(range(Vals_Eligible)/5)+1);
        %%% if you  have a higher range you need more groups to try and
        %%% isolate the lower group... also prevents tumors with overall
        %%% low uptake from being deemed all necrosis
        lowID = find(centroids==min(centroids));
        cutoff_guess=max(Vals_Eligible(ID==lowID));
        if cutoff_guess>5
            cutoff_guess=5;
        end
        disp(['cutoff_guess = ',num2str(cutoff_guess)])
        Initial_Guess(find(Image3D>cutoff_guess))=0;
        BW = zeros(size(CDataSetInfo.ROIImageInfo.MaskData));
        
        for i = 1:size(Initial_Guess,3);
            Mask_slice = imerode(Mask3D(:,:,i),ones(5));
            Initial_Guess(:,:,i) = bwareaopen(Initial_Guess(:,:,i), 3);
            Initial_Guess(:,:,i) = Initial_Guess(:,:,i).*Mask_slice;
            BW(:,:,i) = Initial_Guess(2:end-1,2:end-1,i);
        end
       
end

TLayerInfo.MaskData=uint8(BW);
TLayerInfo.Color=[0, 0, 1];
TLayerInfo.Alpha=1;

CDataSetInfo.ROIImageInfo.LayerInfo=TLayerInfo;
%///////////////////////////////////////////////////////////////////////////////////////////////////////////////////%
%-----------------------------DO_NOT_CHANGE_STARTS--------------------------%
%---Return Value
CDataSetInfo.ROIImageInfo.Description=MFileName;
ImageInfo_InROIBox=CDataSetInfo.ROIImageInfo;

BinaryMaskInfo_InROIBox=CDataSetInfo.ROIBWInfo;
%-----------------------------DO_NOT_CHANGE_ENDS------------------------------%
%///////////////////////////////////////////////////////////////////////////////////////////////////////////////////%




