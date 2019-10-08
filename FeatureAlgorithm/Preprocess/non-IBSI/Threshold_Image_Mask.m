function [ResultStruct, ResultStructBW]=Threshold_Image_Mask(CDataSetInfo, Param)
%%%Doc Starts%%%
%-Description: 
%This method is to modify image and mask by applying image intensity threshold and 2D binary mask erosion.

%-Parameters:
%1. ThresholdLow:   Lower threshold of image intensity.
%2. ThresholdHigh:  Upper threshold of image intensity.
%3. ErosionDist:    Distance in mm for binary mask erosion.

%-Revision:
%2014-02-06: The method is implemented.

%-Author:
%Joy Zhang, lifzhang@mdanderson.org
%%%Doc Ends%%%


%--Parameters
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

if nargin < 2    
    ConfigFile=[MFilePath, '\', MFileName, '.INI'];
    
    Param=GetParamFromINI(ConfigFile);    
end

%--Preprocess
if ~isfield(Param, 'ThresholdLow') && ~isfield(Param, 'ThresholdHigh')
    ResultStruct=[];
    ResultStructBW=[];
    return;
end

%Threshod
CDataSetInfo= ThresholdDataSet(CDataSetInfo, Param, []);


%---Erosion Shrink
CDataSetInfo=ErodeDataSet(CDataSetInfo, Param, []);

%Mask
ResultStructBW=CDataSetInfo.ROIBWInfo;

%ROI
TempIndex=find(~CDataSetInfo.ROIBWInfo.MaskData);
CDataSetInfo.ROIImageInfo.MaskData(TempIndex)=0;

ResultStruct=CDataSetInfo.ROIImageInfo;
