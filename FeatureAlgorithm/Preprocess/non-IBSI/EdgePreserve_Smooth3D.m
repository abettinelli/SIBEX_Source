function [ResultStruct, ResultStructBW]=EdgePreserve_Smooth3D(CDataSetInfo, Param)
%%%Doc Starts%%%
%-Description: 
%This method is to perform anisotropoic diffusion smoothing and edge enhancement in 3D. The core code is in C++.

%-Parameters:
%No.

%-Revision:
%2013-12-12: The method is implemented.

%-Author:
%Joy Zhang, lifzhang@mdanderson.org
%%%Doc Ends%%%

%--Parameters
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

%--Preprocess
%Force data type ==Uint16 if not
if ~isinteger(CDataSetInfo.ROIImageInfo.MaskData)
    ROIImageInfo=ScaleDataSet2Int(CDataSetInfo.ROIImageInfo);
else
    ROIImageInfo=CDataSetInfo.ROIImageInfo;
end

OriData=permute(ROIImageInfo.MaskData, [2, 1, 3]);
FinalData=permute(ROIImageInfo.MaskData, [2, 1, 3]);


%Filter
Smooth3D(OriData, FinalData, ...
    ROIImageInfo.XDim, ROIImageInfo.YDim, ROIImageInfo.ZDim, ROIImageInfo.XPixDim, ROIImageInfo.YPixDim, ROIImageInfo.ZPixDim, ...
    1, 16, 3, Param.Kappa);

ROIImageInfo.MaskData=permute(FinalData, [2,1,3]);

%Force data type back to original data type
if isfield(ROIImageInfo, 'RescaleMinV')
    ROIImageInfo=ScaleDataSet2Ori(ROIImageInfo);
end

%Return Value
ROIImageInfo.Description=MFileName;
ResultStruct=ROIImageInfo;
ResultStructBW=CDataSetInfo.ROIBWInfo;