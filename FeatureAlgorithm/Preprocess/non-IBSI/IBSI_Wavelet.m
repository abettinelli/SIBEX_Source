function [ImageInfo_InROIBox, BinaryMaskInfo_InROIBox]=IBSI_Wavelet(DataItemInfo, Param)
%%%Doc Starts%%%
%-Description: 
%wavelet decomposition.

%-Parameters:
% rec_type: desired decomposition output (ex. 'lll' 'hhh')
% m_wavelet: motherwavelet type (ex. 'sym8')

%-Revision:
%Put revision history here.

%-Author:
%Put author descriptoin here.
%%%Doc Ends%%%

%Purpose:                   To preprocess image data before feature caculation
%Architecture:              All the preprocess-relevant files are under \IBEXCodePath\FeatureAlgorithm\Preprocess.
%Files:                     Wavelet.m, Wavelet.INI

%%---------------Input Parameters Passed In By IBEX--------------%
%DataItemInfo:              a structure containing information on the entire image, image-inside-ROIBoundingBox and binary-mask-inside-ROIBoundingBox
%Param:                     The entry used for IBEX to accept the parameters from GUI. Use .INI to define the default parameters

%%--------------Output Parameters------------%
%ImageInfo_InROIBox:        information on image-inside-ROIBoundingBox
%BinaryMaskInfo_InROIBox:	information on binary-mask-inside-ROIBoundingBox

%///////////////////////////////////////////////////////////////////////////%
%----DO_NOT_CHANGE_STARTS---------------------------------------------------%
%----Wavelet.INI------------------------------------------------------------%
%Load the default parameters from INI
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

if nargin < 2
    ConfigFile=[MFilePath, '\', MFileName, '.INI'];
    Param=GetParamFromINI(ConfigFile);
end
%----DO_NOT_CHANGE_ENDS-----------------------------------------------------%

%----Sanity Check
if ~isfield(Param, 'rec_type')
    ImageInfo_InROIBox=[];
    BinaryMaskInfo_InROIBox=[];
    return;
end

%----Initialization
ROIImageInfo=DataItemInfo.ROIImageInfo;
CurrentImg = double(ROIImageInfo.MaskData);
ROIBWInfo=DataItemInfo.ROIBWInfo;

%----Traslate Image intensieties for CT
if isequal(DataItemInfo.Modality, 'CT')
    CurrentImg = CurrentImg-1000;
end

%----Wavelet decomposition
rec_type = Param.rec_type;
rec_types = {'LLL','HLL','LHL','HHL','LLH','HLH','LHH','HHH'};
rec_type = rec_types{rec_type};

%----Filter
CurrentImg_wavelet = double(CurrentImg);
CurrentImg_wavelet = wavedec3(CurrentImg_wavelet, 1, 'sym8');
CurrentImg_wavelet = waverec3(CurrentImg_wavelet, rec_type, 1);

ROIImageInfo.MaskData = double(CurrentImg_wavelet);

%----In case preprocess breaks relationship between intensity levels change
%----the modality of ROIImage
ROIImageInfo.Modality = ['wavelet_' rec_type];

%----Summary----------------------------------------------------------------%
Param.rec_type = rec_type;
Summary.Type = ['Wavelet_' rec_type];
Summary.Parameters = Param;
Summary.BreakIntensity = true;

%----------------------------DO_NOT_CHANGE_STARTS---------------------------%
%----Return Value
ROIImageInfo.Summary = Summary;
ROIImageInfo.Description=MFileName;
ImageInfo_InROIBox=ROIImageInfo;
BinaryMaskInfo_InROIBox=ROIBWInfo;
%-----------------------------DO_NOT_CHANGE_ENDS----------------------------%
