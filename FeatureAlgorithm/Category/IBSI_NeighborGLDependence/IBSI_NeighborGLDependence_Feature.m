function FeatureInfo=IBSI_NeighborGLDependence_Feature(ParentInfo, FeatureInfo, Mode)

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
function [Value, ReviewInfo]=IBSI_NeighborGLDependence_Feature_LowDepenEmphasis(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'LowDependenceEmphasis');

function [Value, ReviewInfo]=IBSI_NeighborGLDependence_Feature_HighDepenEmphasis(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'HighDependenceEmphasis');

function [Value, ReviewInfo]=IBSI_NeighborGLDependence_Feature_LowGLCountEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'LowGrayLevelCountEmphasis');

function [Value, ReviewInfo]=IBSI_NeighborGLDependence_Feature_HighGLCountEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'HighGrayLevelCountEmphasis');

function [Value, ReviewInfo]=IBSI_NeighborGLDependence_Feature_LowDepenLowGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'LowDependenceLowGrayLevelEmphasis');

function [Value, ReviewInfo]=IBSI_NeighborGLDependence_Feature_LowDepenHighGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'LowDependenceHighGrayLevelEmphasis');

function [Value, ReviewInfo]=IBSI_NeighborGLDependence_Feature_HighDepenLowGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'HighDependenceLowGrayLevelEmphasis');

function [Value, ReviewInfo]=IBSI_NeighborGLDependence_Feature_HighDepenHighGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'HighDependenceHighGrayLevelEmphasis');

function [Value, ReviewInfo]=IBSI_NeighborGLDependence_Feature_GLNonuniformity(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'GrayLevelNonuniformity');

function [Value, ReviewInfo]=IBSI_NeighborGLDependence_Feature_GLNonuniformityNorm(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'GrayLevelNonuniformityNorm');

function [Value, ReviewInfo]=IBSI_NeighborGLDependence_Feature_DepCountNonuniformity(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'DependenceCountNonuniformity');

function [Value, ReviewInfo]=IBSI_NeighborGLDependence_Feature_DepCountNonuniformityNorm(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'DependenceCountNonuniformityNorm');

function [Value, ReviewInfo]=IBSI_NeighborGLDependence_Feature_DepCountPercentage(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'DependenceCountPercentage');

function [Value, ReviewInfo]=IBSI_NeighborGLDependence_Feature_GLVariance(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'GrayLevelVariance');

function [Value, ReviewInfo]=IBSI_NeighborGLDependence_Feature_DepCountVariance(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'DependenceCountVariance');

function [Value, ReviewInfo]=IBSI_NeighborGLDependence_Feature_DepCountEntropy(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'DependenceCountEntropy');

function [Value, ReviewInfo]=IBSI_NeighborGLDependence_Feature_DepCountEnergy(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'DependenceCountEnergy');


function [Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, Mode)
SliceNum=length(ParentInfo.ROIImageInfo.NGLDMStruct);

FeatureValue=zeros(SliceNum, 1);

for i=1:SliceNum
    CurrentItem=ParentInfo.ROIImageInfo.NGLDMStruct(i);
    
    NGLDM=CurrentItem.NGLDM;
    Nv=CurrentItem.Nv;
    
    [GrayLevelNum, RunLenLevelNum]= size(NGLDM);
    
    RunLenVec2=(1:RunLenLevelNum).^2;    
    GrayVec2=(1:GrayLevelNum)'.^2;
    
    Pij = NGLDM(:)/sum(NGLDM(:));
        
    switch Mode
        case 'LowDependenceEmphasis'
            TempMat=repmat(RunLenVec2, GrayLevelNum, 1);            
            TempMat=NGLDM./TempMat;
            
            FinalValue=sum(TempMat(:))/sum(NGLDM(:));            
            
        case 'HighDependenceEmphasis'
            TempMat=repmat(RunLenVec2, GrayLevelNum, 1);            
            TempMat=NGLDM.*TempMat;
            
            FinalValue=sum(TempMat(:))/sum(NGLDM(:));
            
        case 'LowGrayLevelCountEmphasis'
            TempMat=repmat(GrayVec2, 1, RunLenLevelNum);
            TempMat=NGLDM./TempMat;
            
            FinalValue=sum(TempMat(:))/sum(NGLDM(:));
            
        case 'HighGrayLevelCountEmphasis'                        
            TempMat=repmat(GrayVec2, 1, RunLenLevelNum);
            TempMat=NGLDM.*TempMat;
            
            FinalValue=sum(TempMat(:))/sum(NGLDM(:));
            
        case 'LowDependenceLowGrayLevelEmphasis'           
            TempMatRun=repmat(RunLenVec2, GrayLevelNum, 1);  
            TempMatGray=repmat(GrayVec2, 1, RunLenLevelNum);
            
            TempMat=NGLDM./TempMatRun./TempMatGray;
            
            FinalValue=sum(TempMat(:))/sum(NGLDM(:));            
            
        case 'LowDependenceHighGrayLevelEmphasis'          
            TempMatRun=repmat(RunLenVec2, GrayLevelNum, 1);     
            TempMatGray=repmat(GrayVec2, 1, RunLenLevelNum);
            
            TempMat=NGLDM.*TempMatGray./TempMatRun;
            
            FinalValue=sum(TempMat(:))/sum(NGLDM(:));            
            
        case 'HighDependenceLowGrayLevelEmphasis'           
            TempMatRun=repmat(RunLenVec2, GrayLevelNum, 1);        
            TempMatGray=repmat(GrayVec2, 1, RunLenLevelNum);
            
            TempMat=NGLDM.*TempMatRun./TempMatGray;
            
            FinalValue=sum(TempMat(:))/sum(NGLDM(:));            
            
        case 'HighDependenceHighGrayLevelEmphasis'
            TempMatRun=repmat(RunLenVec2, GrayLevelNum, 1);        
            TempMatGray=repmat(GrayVec2, 1, RunLenLevelNum);
            
            TempMat=NGLDM.*TempMatRun.*TempMatGray;
            
            FinalValue=sum(TempMat(:))/sum(NGLDM(:));
            
        case 'GrayLevelNonuniformity'
            TempMat=sum(NGLDM, 2).^2;
            FinalValue=sum(TempMat(:))/sum(NGLDM(:));
            
        case 'GrayLevelNonuniformityNorm'
            TempMat=sum(NGLDM, 2).^2;
            FinalValue=sum(TempMat(:))/(sum(NGLDM(:)).^2);
            
        case 'DependenceCountNonuniformity'     
            TempMat=sum(NGLDM, 1).^2;
            FinalValue=sum(TempMat(:))/sum(NGLDM(:));

        case 'DependenceCountNonuniformityNorm'     
            TempMat=sum(NGLDM, 1).^2;
            FinalValue=sum(TempMat(:))/(sum(NGLDM(:)).^2);
            
        case 'DependenceCountPercentage'
            FinalValue=sum(NGLDM(:))/Nv;
            
        case 'GrayLevelVariance'
            [J, I] = meshgrid(1:RunLenLevelNum, 1:GrayLevelNum);
            I = I(:);
            J = J(:);
            mu = sum(I.*Pij);
            
            FinalValue=sum((I-mu).^2.*Pij);
        case 'DependenceCountVariance'
            [J, I] = meshgrid(1:RunLenLevelNum, 1:GrayLevelNum);
            I = I(:);
            J = J(:);
            mu = sum(J.*Pij);
            
            FinalValue=sum((J-mu).^2.*Pij);
        case 'DependenceCountEntropy'
            idx_nz = Pij ~= 0;
            
            FinalValue=-sum(Pij(idx_nz).*log2(Pij(idx_nz)));
        case 'DependenceCountEnergy'
            idx_nz = Pij ~= 0;
            
            FinalValue=sum(Pij(idx_nz).^2);
    end           
        
    FeatureValue(i)=FinalValue;
end

ReviewInfo=ParentInfo.ROIImageInfo;
ReviewInfo.Description=['NGLDM Feature', ' (Direction VS ', Mode, ')'];

Value=FeatureValue;
ReviewInfo.MaskData=Value;