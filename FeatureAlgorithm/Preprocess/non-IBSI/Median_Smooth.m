function [ResultStruct, ResultStructBW]=Median_Smooth(CDataSetInfo, Param)

%%%Doc Starts%%%
%-Description: 
%This method is to perform 2D median filter in slice-by-slice. 

%-Parameters:
%1.  Size: Neighborhood size.

%-Revision:
%2013-10-12: The method is implemented.

%-Author:
%Joy Zhang, lifzhang@mdanderson.org
%%%Doc Ends%%%

%--Parameters
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

if nargin < 2
    ConfigFile=[MFilePath, '\', MFileName, '.INI'];
    
    Param=GetParamFromINI(ConfigFile);
end

%Parameter Check
if ~isfield(Param, 'Size')
    ResultStruct=[];
    ResultStructBW=[];
    return;
end

%--Preprocess
ROIImageInfo=CDataSetInfo.ROIImageInfo;

%Filter
for i=1:CDataSetInfo.ROIImageInfo.ZDim
    CurrentData=ROIImageInfo.MaskData(:, :, i);
    CurrentData=medfilt2(CurrentData, [Param.Size, Param.Size]);
    ROIImageInfo.MaskData(:, :, i)=CurrentData;
end

%Return Value
ROIImageInfo.Description=MFileName;
ResultStruct=ROIImageInfo;
ResultStructBW=CDataSetInfo.ROIBWInfo;