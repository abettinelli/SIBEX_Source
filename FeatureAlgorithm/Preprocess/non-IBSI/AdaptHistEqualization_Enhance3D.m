function [ResultStruct, ResultStructBW]=AdaptHistEqualization_Enhance3D(CDataSetInfo, Param)
%%%Doc Starts%%%
%-Description: 
%This method is to perform adaptive histogram equalization in 3D. The core code is in C++.

%-Parameters:
%1.  NumTiles:  The number of voxels in the tile X dimension. The method automatically computes
%                  the number of voxels in Y and Z dimensions to match the physical length in X dimension.

%-Revision:
%2013-11-12: The method is implemented.

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
if ~isfield(Param, 'NumTiles')
    ResultStruct=[];
    ResultStructBW=[];
    return;
end

%Force data type ==Uint16 if not
if ~isinteger(CDataSetInfo.ROIImageInfo.MaskData)
    ROIImageInfo=ScaleDataSet2Int(CDataSetInfo.ROIImageInfo);
else
    ROIImageInfo=CDataSetInfo.ROIImageInfo;
end

%--Preprocess
OriData=permute(ROIImageInfo.MaskData, [2, 1, 3]);
FinalData=permute(ROIImageInfo.MaskData, [2, 1, 3]);

%Filter
Smooth3D(OriData, FinalData, ...
    ROIImageInfo.XDim, ROIImageInfo.YDim, ROIImageInfo.ZDim, ROIImageInfo.XPixDim, ROIImageInfo.YPixDim, ROIImageInfo.ZPixDim, ...
    1, Param.NumTiles, 2);

ROIImageInfo.MaskData=permute(FinalData, [2,1,3]);

%Force data type back to original data type
if isfield(ROIImageInfo, 'RescaleMinV')
    ROIImageInfo=ScaleDataSet2Ori(ROIImageInfo);
end

%Return Value
ROIImageInfo.Description=MFileName;
ResultStruct=ROIImageInfo;
ResultStructBW=CDataSetInfo.ROIBWInfo;








