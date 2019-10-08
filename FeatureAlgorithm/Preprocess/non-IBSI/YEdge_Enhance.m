function [ResultStruct, ResultStructBW]=YEdge_Enhance(CDataSetInfo, Param)
%%%Doc Starts%%%
%-Description: 
%This method is to apply 2D sobel vertical edge-emphasizing filter in slice-by-slice. 

%-Parameters:
%No


%-Revision:
%2013-10-12: The method is implemented.

%-Author:
%Joy Zhang, lifzhang@mdanderson.org
%%%Doc Ends%%%

%--Parameters
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

%--Preprocess
%Kernel
FilterKernel=fspecial('sobel');
FilterKernel=FilterKernel';

ROIImageInfo=CDataSetInfo.ROIImageInfo;

%Filter
for i=1:CDataSetInfo.ROIImageInfo.ZDim
    CurrentData=ROIImageInfo.MaskData(:, :, i);
    CurrentData=imfilter(CurrentData, FilterKernel,'replicate', 'same');
    ROIImageInfo.MaskData(:, :, i)=CurrentData;
end

%Return Value
ROIImageInfo.Description=MFileName;
ResultStruct=ROIImageInfo;
ResultStructBW=CDataSetInfo.ROIBWInfo;