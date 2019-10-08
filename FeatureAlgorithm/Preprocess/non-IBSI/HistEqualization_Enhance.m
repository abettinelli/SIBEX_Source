function [ResultStruct, ResultStructBW]=HistEqualization_Enhance(CDataSetInfo, Param)

%%%Doc Starts%%%
%-Description: 
%This method is to perform 3D contrast enhancement using histogram equalization.

%-Parameters:
%1. NBins: The number of bins.

%-Formula:
%Matlab build-in function histeq is used.

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
if ~isfield(Param, 'NBins')
    ResultStruct=[];
    ResultStructBW=[];
    return;
end


%--Preprocess
ROIImageInfo=CDataSetInfo.ROIImageInfo;

%Filter
FilterDim=3;

switch FilterDim
    case 2        
        for i=1:CDataSetInfo.ROIImageInfo.ZDim
            CurrentData=ROIImageInfo.MaskData(:, :, i);
            
            CurrentData=double(CurrentData);
            CurrentDataMin=min(CurrentData(:));
            CurrentDataMax=max(CurrentData(:));
            
            if CurrentDataMax > CurrentDataMin
                CurrentData=(CurrentData-CurrentDataMin)/(CurrentDataMax-CurrentDataMin);
                CurrentData=histeq(CurrentData, Param.NBins);
                
                CurrentData=CurrentDataMin+CurrentData*(CurrentDataMax-CurrentDataMin);
            end
            
            ROIImageInfo.MaskData(:, :, i)=uint16(CurrentData);
        end
        
    case 3
        Size=size(ROIImageInfo.MaskData);
        
        CurrentData=ROIImageInfo.MaskData(:);
        
        CurrentData=double(CurrentData);
        CurrentDataMin=min(CurrentData(:));
        CurrentDataMax=max(CurrentData(:));
        
        if CurrentDataMax > CurrentDataMin
            CurrentData=(CurrentData-CurrentDataMin)/(CurrentDataMax-CurrentDataMin);
            CurrentData=histeq(CurrentData, Param.NBins);
            
            CurrentData=CurrentDataMin+CurrentData*(CurrentDataMax-CurrentDataMin);
        end
        
        ROIImageInfo.MaskData=reshape(uint16(CurrentData), Size);
end

%Return Value
ROIImageInfo.Description=MFileName;
ResultStruct=ROIImageInfo;
ResultStructBW=CDataSetInfo.ROIBWInfo;



