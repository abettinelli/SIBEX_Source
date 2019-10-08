function [ResultStruct, ResultStructBW]=Threshold_Mask(CDataSetInfo, Param)
%%%Doc Starts%%%
%-Description: 
%This method is to modify mask only by applying image intensity threshold and 2D binary mask erosion.

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

ResultStruct=CDataSetInfo.ROIImageInfo;
ResultStructBW=CDataSetInfo.ROIBWInfo;
