function [ResultStruct, ResultStructBW]=BitDepthRescale_Range(CDataSetInfo, Param)
%%%Doc Starts%%%
%-Description: 
%This method is to scale the image intensity into the certain bit range. 

%-Parameters:
%1. BitDepth:   Bit depth for the scaled image
%2. RangeMin:   Mininum value of the source range.
%3. RangeMax:   Maximum value of the source range.
%4. RangeFix:   1==RangeMin and RangeMax in the parameter window are used. 0==Ignore RangeMin and RangeMax in the parameter window. 
%               RangeMin and RangeMax are dynamically determined by min and max of the current image.

%-Formula:
%InputRange=[Param.RangeMin, Param.RangeMax];
%FinalRange=[1, 2^Param.BitDepth];
%CurrentData=(CurrentData-InputRange(1))*(FinalRange(2)-FinalRange(1))/(InputRange(2)-InputRange(1))+FinalRange(1);

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
if ~isfield(Param, 'RangeMin')  || ~isfield(Param, 'RangeMin') || ~isfield(Param, 'BitDepth')
    ResultStruct=[];
    ResultStructBW=[];
    return;
end

ROIImageInfo=CDataSetInfo.ROIImageInfo;
CurrentData=double(ROIImageInfo.MaskData);

MaxV=max(CurrentData(:));
MinV=min(CurrentData(:));

%Dynamic Range
if isfield(Param, 'RangeFix') && Param.RangeFix < 1
    Param.RangeMin=MinV;
    Param.RangeMax=MaxV;    
end

%--Preprocess
InputRange=[Param.RangeMin, Param.RangeMax];
FinalRange=round([1, 2^Param.BitDepth]);

%Filter
CurrentData=(CurrentData-InputRange(1))*(FinalRange(2)-FinalRange(1))/(InputRange(2)-InputRange(1))+FinalRange(1);

%----Update Image
ClassName=class(ROIImageInfo.MaskData);
ClassFunc=str2func(ClassName);
ROIImageInfo.MaskData=ClassFunc(CurrentData);
ROIImageInfo.Discretised_nIBSI = true;
ROIImageInfo.NumLevels = round(2^Param.BitDepth);
ROIImageInfo.GrayLimits = round([1, 2^Param.BitDepth]);

%---Summary
Summary.Type = 'BitDepthRescale';
Summary.Parameters = Param;
Summary.BreakIntensity = true;
ROIImageInfo.Summary = Summary;
ROIImageInfo.Description=MFileName;

%Return Value
ResultStruct=ROIImageInfo;
ResultStructBW=CDataSetInfo.ROIBWInfo;



