function FeatureInfo=IBSI_GrayLevelDistZoneMatrix_Feature(ParentInfo, FeatureInfo, Mode)

[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

%Parse Feature Names and Params
if isempty(FeatureInfo)
    FeatureName=ParseFeatureName(MFilePath, MFileName(1:end-8));
    
    if isempty(FeatureName)
        FeatureInfo=[];
        return;
    end
    
    for i=1:length(FeatureName)
        FeatureInfo(i).Name=FeatureName{i};
        
        ConfigFile=[MFilePath, '\', MFileName, '_', FeatureName{i}, '.INI'];
        Param=GetParamFromINI(ConfigFile);
        FeatureInfo(i).Value=Param;
    end
    
    %For passing the feature name
    if isequal(Mode, 'ParseFeature')
        return;
    end
end

%Parent Information
FeaturePrefix=MFileName;

for i=1:length(FeatureInfo)
    if isequal(Mode, 'Review')
        [FeatureValue, FeatureReviewInfo]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix);
        FeatureInfo(i).FeatureValue=FeatureValue;
        FeatureInfo(i).FeatureReviewInfo=FeatureReviewInfo;
    else
        FeatureValue=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix);
        FeatureValue=mean(FeatureValue);
        FeatureInfo(i).FeatureValue=FeatureValue;
    end         
end

function [FeatureValue, FeatureReviewInfo]=GetFeatureValue(ParentInfo, CurrentFeatureInfo,  FeaturePrefix)
FeatureName=CurrentFeatureInfo.Name;

FuncName=[FeaturePrefix, '_', FeatureName];
FuncHandle=str2func(FuncName);

[FeatureValue, FeatureReviewInfo]=FuncHandle(ParentInfo, CurrentFeatureInfo.Value);

%----FEATURES
function [Value, ReviewInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_SmallDistEmphasis(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%

[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'SmallDistEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_LargeDistEmphasis(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'LargeDistEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_LowGrayLevelEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'LowGrayLevelEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_HighGrayLevelEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'HighGrayLevelEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_SmallDistLowGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'SmallDistLowGLEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_SmallDistHighGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'SmallDistHighGLEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_LargeDistLowGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'LargeDistLowGLEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_LargeDistHighGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'LargeDistHighGLEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_GLNonuniformity(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'GLNonuniformity');

function [Value, ReviewInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_GLNonuniformityNorm(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'GLNonuniformityNorm');

function [Value, ReviewInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_ZDNonuniformity(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'ZoneDistNonuniformity');

function [Value, ReviewInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_ZDNonuniformityNorm(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'ZoneDIstNonuniformityNorm');

function [Value, ReviewInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_ZonePercentage(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'ZonePercentage');

function [Value, ReviewInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_GrayLevelVariance(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'GrayLevelVariance');

function [Value, ReviewInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_ZoneDistVariance(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'ZoneDistVariance');

function [Value, ReviewInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_ZoneDistEntropy(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'ZoneDistEntropy');


function [Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, Mode)
SliceNum=length(ParentInfo.ROIImageInfo.GLDZMStruct3);

FeatureValue=zeros(SliceNum, 1);

for i=1:SliceNum
    CurrentItem=ParentInfo.ROIImageInfo.GLDZMStruct3(i);
    
    GLDZM=CurrentItem.GLDZM;
    Nv=CurrentItem.Nv;
    
    [GrayLevelNum, DistZoneLevelNum]= size(GLDZM);

    DistZoneVec2=(1:DistZoneLevelNum).^2;    
    GrayVec2=(1:GrayLevelNum)'.^2;
    
    Pij = GLDZM(:)/sum(GLDZM(:));
        
    switch Mode
        case 'SmallDistEmphasis'
            TempMat=repmat(DistZoneVec2, GrayLevelNum, 1);            
            TempMat=GLDZM./TempMat;
            
            FinalValue=sum(TempMat(:))/sum(GLDZM(:));            
            
        case 'LargeDistEmphasis'
            TempMat=repmat(DistZoneVec2, GrayLevelNum, 1);            
            TempMat=GLDZM.*TempMat;
            
            FinalValue=sum(TempMat(:))/sum(GLDZM(:));
            
        case 'LowGrayLevelEmphasis'
            TempMat=repmat(GrayVec2, 1, DistZoneLevelNum);
            TempMat=GLDZM./TempMat;
            
            FinalValue=sum(TempMat(:))/sum(GLDZM(:));
            
        case 'HighGrayLevelEmphasis'                    
            TempMat=repmat(GrayVec2, 1, DistZoneLevelNum);
            TempMat=GLDZM.*TempMat;
            
            FinalValue=sum(TempMat(:))/sum(GLDZM(:));
            
        case 'SmallDistLowGLEmphasis'     
            TempMatRun=repmat(DistZoneVec2, GrayLevelNum, 1);  
            TempMatGray=repmat(GrayVec2, 1, DistZoneLevelNum);
            
            TempMat=GLDZM./TempMatRun./TempMatGray;
            
            FinalValue=sum(TempMat(:))/sum(GLDZM(:));            
            
        case 'SmallDistHighGLEmphasis'
            TempMatRun=repmat(DistZoneVec2, GrayLevelNum, 1);     
            TempMatGray=repmat(GrayVec2, 1, DistZoneLevelNum);
            
            TempMat=GLDZM.*TempMatGray./TempMatRun;
            
            FinalValue=sum(TempMat(:))/sum(GLDZM(:));            
            
        case 'LargeDistLowGLEmphasis'        
            TempMatRun=repmat(DistZoneVec2, GrayLevelNum, 1);        
            TempMatGray=repmat(GrayVec2, 1, DistZoneLevelNum);
            
            TempMat=GLDZM.*TempMatRun./TempMatGray;
            
            FinalValue=sum(TempMat(:))/sum(GLDZM(:));            
            
        case 'LargeDistHighGLEmphasis'  
            TempMatRun=repmat(DistZoneVec2, GrayLevelNum, 1);        
            TempMatGray=repmat(GrayVec2, 1, DistZoneLevelNum);
            
            TempMat=GLDZM.*TempMatRun.*TempMatGray;
            
            FinalValue=sum(TempMat(:))/sum(GLDZM(:));
            
        case 'GLNonuniformity'
            TempMat=sum(GLDZM, 2).^2;
            FinalValue=sum(TempMat(:))/sum(GLDZM(:));
            
        case 'GLNonuniformityNorm'
            TempMat=sum(GLDZM, 2).^2;
            FinalValue=sum(TempMat(:))/(sum(GLDZM(:)).^2);
            
        case 'ZoneDistNonuniformity'  
            TempMat=sum(GLDZM, 1).^2;
            FinalValue=sum(TempMat(:))/sum(GLDZM(:));

        case 'ZoneDIstNonuniformityNorm'  
            TempMat=sum(GLDZM, 1).^2;
            FinalValue=sum(TempMat(:))/(sum(GLDZM(:)).^2);
            
        case 'ZonePercentage'
            FinalValue=sum(GLDZM(:))/Nv;
            
        case 'GrayLevelVariance'
            [J, I] = meshgrid(1:DistZoneLevelNum, 1:GrayLevelNum);
            I = I(:);
            J = J(:);
            mu = sum(I.*Pij);
            
            FinalValue=sum((I-mu).^2.*Pij);
        case 'ZoneDistVariance'
            [J, I] = meshgrid(1:DistZoneLevelNum, 1:GrayLevelNum);
            I = I(:);
            J = J(:);
            mu = sum(J.*Pij);
            
            FinalValue=sum((J-mu).^2.*Pij);
        case 'ZoneDistEntropy'
            idx_nz = Pij ~= 0;
            
            FinalValue=-sum(Pij(idx_nz).*log2(Pij(idx_nz)));
    end           
        
    FeatureValue(i)=FinalValue;
end

ReviewInfo=ParentInfo.ROIImageInfo;
ReviewInfo.Description=['GLSZM Feature', ' (Direction VS ', Mode, ')'];

%Value=[Direction', FeatureValue];
Value=FeatureValue;
ReviewInfo.MaskData=Value;