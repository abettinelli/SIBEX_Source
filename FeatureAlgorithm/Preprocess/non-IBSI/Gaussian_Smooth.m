function [ResultStruct, ResultStructBW]=Gaussian_Smooth(CDataSetInfo, Param)
%%%Doc Starts%%%
%-Description: 
%This method is to perform 2D gaussian smoothing in slice-by-slice. 

%-Parameters:
%1.  Size: Size of gaussian filter.
%2.  Sigma: Standard deviation of gaussian filter.

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
if ~isfield(Param, 'Size') || ~isfield(Param, 'Sigma')
    ResultStruct=[];
    ResultStructBW=[];
    return;
end

%--Preprocess
%Kernel
FilterKernel=fspecial('gaussian', Param.Size, Param.Sigma);

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






