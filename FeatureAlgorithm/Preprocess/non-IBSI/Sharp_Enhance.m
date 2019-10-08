function [ResultStruct, ResultStructBW]=Sharp_Enhance(CDataSetInfo, Param)

%%%Doc Starts%%%
%-Description: 
%This method is to enhance image by applying 2D unsharp contrast enhancement filter in slice-by-slice. 

%-Parameters:
%1. Alpha: Alpha controls the shape of the Laplacian.

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
if ~isfield(Param, 'Alpha')
    ResultStruct=[];
    ResultStructBW=[];
    return;
end


%--Preprocess
%Kernel
FilterKernel=fspecial('unsharp', Param.Alpha);

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