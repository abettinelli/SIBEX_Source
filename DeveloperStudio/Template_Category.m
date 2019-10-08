function ParentInfo=Template_Category(DataItemInfo, Mode, Param)
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

%Purpose:       To implement a feature, two files are needed. 
                       %*CategoryName*_Category.m: to calculate the ParentInfo from DateItemInfo to be used in *CategoryName*_Feature.m.
                       %*CategoryName*_Feature.m:   to calcuate the features using the same ParentInfo that is output from *CategoryName*_Category.m. 
                       %Feature names are describled in the declaration of feature caculation function in *CategoryName*_Feature.m.
                       %Naming Convention of feaure caculation functions:  *CategoryName*_Feature_*FeatureName*
%Architecture: All the feature-relevant files are under \IBEXCodePath\FeatureAlgorithm\Category\*CategoryName*\.
%Files:            *CategoryName*_Category.m, *CategoryName*_Category.INI

%%---------------Input Parameters Passed In By IBEX-------------%
%DataItemInfo:  a structure containing information on the entire image, image-inside-ROIBoundingBox and binary-mask-inside-ROIBoundingBox
%Param:            The entry used for IBEX to accept the parameters from GUI. Use .INI to define the default parameters
%Mode:             Two Statuses.
                          %'Child':  The output ParentInfo is the derived data that is used for feature caculation in  *CategoryName*_Feature.m
                          %'Review': The output ParentInfo is the
                          %ReviewInfo to be reviewed when press "Test" button.
%%--------------Output Parameters------------%
%ParentInfo:    %If Mode == 'Child',  it is the derived data that is used for feature caculation in  *CategoryName*_Feature.m
                        %If Mode == 'Review', it is the ReviewInfo to be reviewed when press "Test" button.                                               
                          
%///////////////////////////////////////////////////////////////////////////////////////////////////////////////////%
%-----------------------------DO_NOT_CHANGE_STARTS--------------------------%
%Empty
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
%****The skeleton category adds 0 to image data****%
DataItemInfo.ROIImageInfo.MaskData=DataItemInfo.ROIImageInfo.MaskData+0;

switch Mode
    case 'Review'        
        ReviewInfo=DataItemInfo.ROIImageInfo;
        ParentInfo=ReviewInfo;
        
    case 'Child'
        ParentInfo=DataItemInfo;
end








