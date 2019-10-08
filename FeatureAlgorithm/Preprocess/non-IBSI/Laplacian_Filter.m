function [ResultStruct, ResultStructBW]=Laplacian_Smooth(CDataSetInfo, Param)
%%%Doc Starts%%%
%-Description: 
%This method is to perform 2D laplacian filter in slice-by-slice. 

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
FilterKernel=fspecial('laplacian', Param.Alpha);

ROIImageInfo=CDataSetInfo.ROIImageInfo;
ROIBWInfo=CDataSetInfo.ROIBWInfo;

ClassName=class(ROIImageInfo.MaskData);
ClassFunc=str2func(ClassName);

%Filter
for i=1:CDataSetInfo.ROIImageInfo.ZDim
    CurrentData=ROIImageInfo.MaskData(:, :, i);
    CurrentBW=ROIBWInfo.MaskData(:, :, i);
    
    TempData=imfilter(CurrentData, -FilterKernel, 'replicate', 'same', 'conv');
       
    BWPerim=bwperim(CurrentBW, 8);
    ValidBWMat=xor(CurrentBW, BWPerim);
    CurrentData=TempData.*ClassFunc(ValidBWMat);
    
    TempIndex=find(CurrentData < 0);
    CurrentData(TempIndex)=0;
    
    ROIImageInfo.MaskData(:, :, i)=CurrentData;
    ROIBWInfo.MaskData(:, :, i)=uint8(ValidBWMat);
end

%Return Value
ROIImageInfo.Description=MFileName;
ResultStruct=ROIImageInfo;
ResultStructBW=CDataSetInfo.ROIBWInfo;



