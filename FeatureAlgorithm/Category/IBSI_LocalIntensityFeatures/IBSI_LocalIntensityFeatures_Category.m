function ParentInfo=IBSI_LocalIntensityFeatures_Category(CDataSetInfo, Mode, Param)
%%%Doc Starts%%%
% -Description: 
% 1. This method is to apply an appropriate spatial spherical mean convolution filter to the image 
% 2. Filtered image is passed into IBSI_LocalIntensityFeatures_Feature.m to compute the related features.
% 
% -Parameters:
% 1. Radius: the Radius of the sphere centered on the maximum intensity voxel
% 
% -Revision:
% 2019-02-13: The method is implemented.
% 
% -Authors:
% Andrea Bettinelli
%%%Doc Ends%%%

%Code
% Pinnacle to IBSI
CDataSetInfo = IBSI_waterCTnumber(CDataSetInfo);

CurrentImage = CDataSetInfo.ROIImageInfo.MaskData;
%CurrentMask = CDataSetInfo.ROIBWInfo.MaskData;

SE = IBSI_strel(Param,  CDataSetInfo);
CDataSetInfo.ROIImageInfo.SE = SE;
SE = SE./sum(SE(:));

% Zero-pad edge correction
c = convn(CurrentImage,SE,'same');
flat = convn(ones(size(CurrentImage)),SE,'same');
c = gather(c);
flat = gather(flat);
CDataSetInfo.ROIImageInfo.FilterMask = c./flat;

switch Mode
    case 'Review'
        ReviewInfo=CDataSetInfo.ROIImageInfo;
        ParentInfo=ReviewInfo;
        
    case 'Child'
        ParentInfo=CDataSetInfo;
end