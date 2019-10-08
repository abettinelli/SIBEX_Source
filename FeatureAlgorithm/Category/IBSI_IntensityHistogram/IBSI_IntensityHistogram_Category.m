function ParentInfo=IBSI_IntensityHistogram_Category(CDataSetInfo, Mode, Param)
%%%Doc Starts%%%
% -Description: 
% 1. This method is to preprocess the binary mask for the features derived directly from the image intensity.
% 2. Image and binary mask are passed into IBSI_IntensityHistogram_Feature.m to compute the related features.
% 
% -Parameters:
% 1. Rescale: 
%	'fbn': fixed bin number -> specify BinNumber
%	'fbs': fixed bin size   -> specify BinSize
%	'off': do not perform the discretization step
% 2. BinNumber: Integer specifying the number of bin number to use when scaling the grayscale values. [] when rescale is set to 'fbs' or 'off';
% 3. BinSize: Integer specifying the bin size to use when scaling the grayscale values. [] when rescale is set to 'fbn' or 'off';
% 
% -Revision:
% 2018-20-12: The method is implemented.
% 
% -Authors:
% -Authors:
% Joy Zhang, lifzhang@mdanderson.org
% ----
% Andrea Bettinelli
%%%Doc Ends%%%

% Pinnacle to IBSI
CDataSetInfo = IBSI_waterCTnumber(CDataSetInfo);

% Discretization
[CDataSetInfo, Param] = IBSI_gl_rescale(CDataSetInfo, Param);

switch Mode
    case 'Review'
        ReviewInfo=CDataSetInfo.ROIImageInfo;
        ParentInfo=ReviewInfo;
        
    case 'Child'
        ParentInfo=CDataSetInfo;
end