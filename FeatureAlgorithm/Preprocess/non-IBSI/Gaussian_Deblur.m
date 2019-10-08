function [ResultStruct, ResultStructBW]=Gaussian_Deblur(CDataSetInfo, Param)
%%%Doc Starts%%%
%-Description: 
%This method is to deblur 2D image using Lucy-Richardson method and gussian PSF in slice-by-slice. 

%-Parameters:
%1.  Size: Size of Gaussian lowpass filter.

%-Formula:
%Matlab build-in function deconvlucy is used.

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
%Kernel
FilterKernel=fspecial('gaussian', Param.Size);

ROIImageInfo=CDataSetInfo.ROIImageInfo;

%Filter
for i=1:ROIImageInfo.ZDim
    CurrentData=ROIImageInfo.MaskData(:, :, i);
    CurrentData=deconvlucy(CurrentData,FilterKernel,5);    
    ROIImageInfo.MaskData(:, :, i)=CurrentData;
end

%Return Value
ROIImageInfo.Description=MFileName;
%ROIImageInfo.CallBackFunc='Test_ReviewFunc';

ResultStruct=ROIImageInfo;
ResultStructBW=CDataSetInfo.ROIBWInfo;





