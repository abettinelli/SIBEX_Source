function [ResultStruct, ResultStructBW]=Average_Smooth(CDataSetInfo, Param)
%%%Doc Starts%%%
%-Description: 
%This method is to perform 2D averaging filter in slice-by-slice. 

%-Parameters:
%1. Size: The kernel size in the pixel unit. Kernal is a square matrix.

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

%--Preprocess
if ~isfield(Param, 'Size')
    ResultStruct=[];
    ResultStructBW=[];
    return;
end

%Kernel
FilterKernel=fspecial('average', Param.Size);

ROIImageInfo=CDataSetInfo.ROIImageInfo;

%Filter
for i=1:CDataSetInfo.ROIImageInfo.ZDim
    CurrentData=ROIImageInfo.MaskData(:, :, i);
    CurrentData=imfilter(CurrentData, FilterKernel,'replicate', 'same');
    ROIImageInfo.MaskData(:, :, i)=CurrentData;
end

%Return Value
%--------DEBUG Layer--------%
% LayerInfo=[];
% 
% TLayerInfo=CDataSetInfo.ROIBWInfo;
% TLayerInfo.Color=[0, 0, 1];
% TLayerInfo.Alpha=0.2;
% 
% LayerInfo=[LayerInfo, TLayerInfo];
% 
% TLayerInfo=CDataSetInfo.ROIBWInfo;
% TLayerInfo.MaskData=uint8(~TLayerInfo.MaskData);
% TLayerInfo.Color=[1, 0, 0];
% TLayerInfo.Alpha=0.2;
% 
% LayerInfo=[LayerInfo, TLayerInfo];
% 
% ROIImageInfo.LayerInfo=LayerInfo;
%--------DEBUG Layer---------%

ROIImageInfo.Description=MFileName;
ResultStruct=ROIImageInfo;
ResultStructBW=CDataSetInfo.ROIBWInfo;












