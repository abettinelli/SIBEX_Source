function [ResultStruct, ResultStructBW]=Log_Filter(CDataSetInfo, Param)
%%%Doc Starts%%%
%-Description: 
%This method is to perform 2D Laplacian of Gaussian filter in slice-by-slice. 

%-Parameters:
%1.  Size: Maxtrix size of the filter.
%2.  Sigma: Standard deviation.
%3.  FillROIOutOn: 1==Overwrite the outside of mask with FillROIOutValue. 0==No overwrite the ouside of mask.
%4.  FillROIOutValue:  The value is used when FillROIOutOn=1, 

%-Revision:
%2014-02-15: The method is implemented.

%-Author:
%Joy Zhang, lifzhang@mdanderson.org
%David Fried, DVFried@mdanderson.org
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
FilterKernel=fspecial('log', Param.Size, Param.Sigma);

%Extend
ExtendFlag=1;
MarginSize=50;

if ExtendFlag > 0
    [ROIImageMat, ROIBWMat]=ExtendROIMat(CDataSetInfo, MarginSize);
else
    ROIImageMat=CDataSetInfo.ROIImageInfo.MaskData;
    ROIBWMat=CDataSetInfo.ROIBWInfo.MaskData;
end

if isfield(Param, 'FillROIOutOn') && isfield(Param, 'FillROIOutValue') && Param.FillROIOutOn > 0
    ROIImageMat(~ROIBWMat)=Param.FillROIOutValue;    
end

%Filter
ClassName=class(ROIImageMat);
ClassFunc=str2func(ClassName);

FilterData=zeros(size(ROIImageMat), ClassName);
FilterDataBW=zeros(size(ROIImageMat), 'uint8');


for i=1:size(ROIImageMat, 3)
    CurrentBW=ROIBWMat(:, :, i);    
    CurrentData=ROIImageMat(:, :, i);
    
    TempData =imfilter(CurrentData, -FilterKernel, 'replicate', 'same', 'conv');
    
    BWPerim=bwperim(CurrentBW, 8);
    ValidBWMat=xor(CurrentBW, BWPerim);
    CurrentData=TempData.*ClassFunc(ValidBWMat);
    
    TempIndex=find(CurrentData < 0);
    CurrentData(TempIndex)=0;
    
    FilterData(:, :, i)=CurrentData;    
  
    FilterDataBW(:, :, i)=uint8(ValidBWMat);   
end

if ExtendFlag > 0
    FilterData=ReduceROIMat(FilterData, MarginSize);
    FilterDataBW=ReduceROIMat(FilterDataBW, MarginSize);    
end

ROIImageInfo=CDataSetInfo.ROIImageInfo;
ROIImageInfo.MaskData=FilterData;

ROIBWInfo=CDataSetInfo.ROIBWInfo;
ROIBWInfo.MaskData=FilterDataBW;

%Return Value
ROIImageInfo.Description=MFileName;
ResultStruct=ROIImageInfo;

ResultStructBW=ROIBWInfo;

function  FilterData=ReduceROIMat(FilterData, MarginSize)
FilterData(1:MarginSize, :, :)=[];
FilterData(end-MarginSize+1:end, :, :)=[];

FilterData(:, 1:MarginSize, :)=[];
FilterData(:, end-MarginSize+1:end, :)=[];


function [ROIImageMatM, ROIBWMatM]=ExtendROIMat(CDataSetInfo,MarginSize)

ROIImageMat=CDataSetInfo.ROIImageInfo.MaskData;
ROIBWMat=CDataSetInfo.ROIBWInfo.MaskData;

[RowNum, ColNum, PageNum]=size(ROIImageMat);

ROIImageMatM=zeros(RowNum+2*MarginSize, ColNum+2*MarginSize, PageNum, class(ROIImageMat));
ROIBWMatM=zeros(RowNum+2*MarginSize, ColNum+2*MarginSize, PageNum, 'uint8');

ROIImageMatM(MarginSize+1:MarginSize+RowNum, MarginSize+1:MarginSize+ColNum, :) = ROIImageMat;
ROIBWMatM(MarginSize+1:MarginSize+RowNum, MarginSize+1:MarginSize+ColNum, :) = ROIBWMat;





