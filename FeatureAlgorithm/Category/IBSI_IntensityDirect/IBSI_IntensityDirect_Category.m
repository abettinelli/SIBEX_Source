function ParentInfo=IBSI_IntensityDirect_Category(CDataSetInfo, Mode, Param)
%%%Doc Starts%%%
% -Description: 
% 1. This method is to preprocess the binary mask for the features derived directly from the image intensity.
%    The binary mask can be modified through the intensity thresholding.
% 2. Image and binary mask are passed into IBSI_IntensityDirect_Feature.m to compute the related features.
% 
% -Parameters:
% 
% -Revision:
% 2018-21-12: The method is made IBSI compliant.
% 2014-01-01: The method is implemented.
% 
% -Authors:
% Joy Zhang, lifzhang@mdanderson.org
% ----
% Andrea Bettinelli
%%%Doc Ends%%%

% Code
% Mod Bettinelli
% if isfield(Param, 'Threshold') || isfield(Param, 'ThresholdLow')
%    CDataSetInfo=ThresholdDataSet(CDataSetInfo, Param, Mode);      
% end

% Pinnacle to IBSI
CDataSetInfo = IBSI_waterCTnumber(CDataSetInfo);

switch Mode
    case 'Review'
        ReviewInfo=CDataSetInfo.ROIImageInfo;
        ParentInfo=ReviewInfo;
        
    case 'Child'
        ParentInfo=CDataSetInfo;
end