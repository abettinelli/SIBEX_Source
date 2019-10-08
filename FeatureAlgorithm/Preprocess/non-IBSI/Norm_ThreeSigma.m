function [ResultStruct, ResultStructBW]=Norm_ThreeSigma(CDataSetInfo, Param)
%%%Doc Starts%%%
%-Description: 
% Consider intensity range between mean +/- 3*sigma.
% Outside the range[u-3sigma, u+3sigma] were not considered

%-Parameters:
%Sigma: Range with std: n=3 (default)
%BitDepth: Quantized to 8 bit: BitDepth = 8 (default)

%-Reference:
%Collewet et. al. 2003, Influence of MRI acquisition protocols and image intensity normalization methods on texture classification

%-Revision:
%2017-03-10: The method is implemented.

%-Author:
% Joonsang Lee, jlee27@mdanderson.org
%%%Doc Ends%%%

%--Parameters
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

if nargin < 2    
    ConfigFile=[MFilePath, '\', MFileName, '.INI'];
    Param=GetParamFromINI(ConfigFile);   
end

%Parameter Check
if ~isfield(Param, 'n') || ~isfield(Param, 'n')
    ResultStruct=[];
    ResultStructBW=[];
    return;
end
 
ROIImageInfo=CDataSetInfo.ROIImageInfo;
CurrentData=double(ROIImageInfo.MaskData);

MaxV=max(CurrentData(:));
MinV=min(CurrentData(:));

% range between [mean-n*sigma, mean+n*sigma]
meanROI = mean(CurrentData(:));
stdROI = std(CurrentData(:));
RangeMin = meanROI - Param.n*stdROI;
RangeMax = meanROI + Param.n*stdROI;
Param.RangeMin = RangeMin;
Param.RangeMax = RangeMax;

if RangeMin < MinV
    Param.RangeMin = MinV;
elseif RangeMax > MaxV
    Param.RangeMax = MaxV;
end
I = CurrentData;
I(I<Param.RangeMin) = min(I(:));
I(I>Param.RangeMax) = max(I(:));

% Excluding outside ranges [mean-3sigma, mean+3sigma]
if isfield(Param, 'RangeFix') && Param.RangeFix < 1
    I(I<Param.RangeMin) = NaN;
    I(I>Param.RangeMax) = NaN;    
end

% Quantized to 6 bit
CurrentData = I*(2^Param.BitDepth-1)/max(I(:))+1; % 1 to 64

ClassName=class(ROIImageInfo.MaskData);
ClassFunc=str2func(ClassName);

ROIImageInfo.MaskData=ClassFunc(CurrentData);

%Return Value
ROIImageInfo.Description=MFileName;
ResultStruct=ROIImageInfo;

ResultStructBW=CDataSetInfo.ROIBWInfo;



