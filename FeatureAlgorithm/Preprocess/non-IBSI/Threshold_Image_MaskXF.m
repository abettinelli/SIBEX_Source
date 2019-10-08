function [ResultStruct, ResultStructBW]=Threshold_Image_MaskXF(CDataSetInfo, Param)
%%%Doc Starts%%%
%-Description: 
%This method modifies the image and mask by applying an image intensity
%threshold and 2D binary mask erosion. After applying the image intensity
%threshold it uses the MatLab 'imfill' function to recover pixels whose
%intensities are below the threshold value but are surrounded by pixels
%above the threshold in all nine 2D directions. This allows for the
%inclusion of low density areas within the tumor while excluding any
%surrounding areas of air that shouldn't be included in the ROI. 

%-Parameters:
%1. ThresholdLow:   Lower threshold of image intensity.
%2. ThresholdHigh:  Upper threshold of image intensity.
%3. ErosionDist:    Distance in mm for binary mask erosion.

%-Revision:
%2014-06-21: The method is implemented.

%-Author:
%Xenia Fave, XJFave@mdanderson.org
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
CDataSetInfo= ThresholdDataSetXF(CDataSetInfo, Param, []);

%---Erosion Shrink
CDataSetInfo=ErodeDataSet(CDataSetInfo, Param, []);

%Mask
ResultStructBW=CDataSetInfo.ROIBWInfo;

%ROI
TempIndex=find(~CDataSetInfo.ROIBWInfo.MaskData);
CDataSetInfo.ROIImageInfo.MaskData(TempIndex)=0;

ResultStruct=CDataSetInfo.ROIImageInfo;


function CDataSetInfo= ThresholdDataSetXF(CDataSetInfo, Param, Mode)
ImageData=CDataSetInfo.ROIImageInfo.MaskData;
BWData=CDataSetInfo.ROIBWInfo.MaskData;

TempBW=zeros(size(BWData), 'uint8');

TempIndex=[];

%For compatibility
if isfield(Param, 'Threshold')
    TempIndex=find(ImageData < Param.Threshold);
end

if isfield(Param, 'ThresholdLow')
    TempIndex=find(ImageData < Param.ThresholdLow |  ImageData > Param.ThresholdHigh);
end

if isempty(TempIndex)
    return;
end

%BW
TempBW(TempIndex)=1; 

TempBW=TempBW+BWData;


TempIndex=find(TempBW > 1);
if ~isempty(TempIndex)

    BWData(TempIndex)=uint8(0);
    
    %%RIGHT HERE, I filled some of the zeroed points
    [s1, s2,s3]=size(BWData);
    BWFilled=zeros(s1,s2,s3);
    for Iter=1:s3
        BWFilled(:,:,Iter)=imfill(BWData(:,:,Iter),'holes');
    end;
    BWData=BWFilled;
    
    CDataSetInfo.ROIBWInfo.MaskData=BWData; 
end

%Image
if isequal(Mode, 'Review')
    TempImageData=zeros(size(BWData), class(CDataSetInfo.ROIImageInfo.MaskData));
    
    TempIndex=find(BWData);
    
    TempImageData(TempIndex)=ImageData(TempIndex);
    CDataSetInfo.ROIImageInfo.MaskData=TempImageData;
end