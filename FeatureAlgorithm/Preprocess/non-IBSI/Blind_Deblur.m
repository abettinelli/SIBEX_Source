function [ResultStruct, ResultStructBW]=Blind_Deblur(CDataSetInfo, Param)
%%%Doc Starts%%%
%-Description: 
%This method is to delur image using blind deconvolution. 

%-Parameters:
%1.  Size:   The size of the initial guss INITPSF. Assume INITPSF has the same size in X, Y, Z dimension.

%-Formula:
%Matlab build-in function deconvblind is used.

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
ROIImageInfo=CDataSetInfo.ROIImageInfo;
INITPSF=ones([Param.Size, Param.Size, Param.Size]);

ROIImageInfo.MaskData=deconvblind(ROIImageInfo.MaskData, INITPSF);

%Return Value
ROIImageInfo.Description=MFileName;
ResultStruct=ROIImageInfo;
ResultStructBW=CDataSetInfo.ROIBWInfo;