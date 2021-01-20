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
    if isequal(Mode, 'InfoID')
        % Family/Feature Infos
        [~, ~, Info]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix, 'InfoID');
        FeatureInfo(i).FeatureValue=[];
        FeatureInfo(i).CatAbbreviation = 'NGLDM';
        FeatureInfo(i).Category = 'Neighbouring grey level dependence matrix';
        FeatureInfo(i).CategoryID = 'REK0';
        FeatureInfo(i).FeatureName=Info.FeatureName;
        FeatureInfo(i).FeatureID=Info.FeatureID;
        switch ParentInfo.AggregationMethod
            case 1
                FeatureInfo(i).AggregationMethod = '2D';
                FeatureInfo(i).AggregationMethodID = '8QNN';
            case 2
                FeatureInfo(i).AggregationMethod = '2.5D';
                FeatureInfo(i).AggregationMethodID = '62GR';
            case 3
                FeatureInfo(i).AggregationMethod = '3D';
                FeatureInfo(i).AggregationMethodID = 'KOBO';
        end
    elseif isequal(Mode, 'Review')
        [FeatureValue, FeatureReviewInfo]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix,'Value');
        FeatureInfo(i).FeatureValue=FeatureValue;
        FeatureInfo(i).FeatureReviewInfo=FeatureReviewInfo;
    else
        try
            [FeatureValue, ~, ~]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix,'Value');
        catch
            FeatureValue=[];
        end
        FeatureValue=mean(FeatureValue);
        FeatureInfo(i).FeatureValue=FeatureValue;
    end
end

function [FeatureValue, FeatureReviewInfo, FeatureInfo]=GetFeatureValue(ParentInfo, CurrentFeatureInfo,  FeaturePrefix, modality)
FeatureName=CurrentFeatureInfo.Name;

FuncName=[FeaturePrefix, '_', FeatureName];
FuncHandle=str2func(FuncName);

[FeatureValue, FeatureReviewInfo, FeatureInfo]=FuncHandle(ParentInfo, CurrentFeatureInfo.Value, modality);

%----FEATURES
function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_LowDepenEmphasis(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'LowDependenceEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Low dependence emphasis';
        FeatureInfo.FeatureID   = 'SODN';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_HighDepenEmphasis(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'HighDependenceEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'High dependence emphasis';
        FeatureInfo.FeatureID   = 'IMOQ';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_LowGLCountEmpha(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'LowGrayLevelCountEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Low grey level count emphasis';
        FeatureInfo.FeatureID   = 'TL9H';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_HighGLCountEmpha(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'HighGrayLevelCountEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'High grey level count emphasis';
        FeatureInfo.FeatureID   = 'OAE7';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_LowDepenLowGLEmpha(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'LowDependenceLowGrayLevelEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Low dependence low grey level emphasis';
        FeatureInfo.FeatureID   = 'EQ3F';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_LowDepenHighGLEmpha(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'LowDependenceHighGrayLevelEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Low dependence high grey level emphasis';
        FeatureInfo.FeatureID   = 'JA6D';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_HighDepenLowGLEmpha(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'HighDependenceLowGrayLevelEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'High dependence low grey level emphasis';
        FeatureInfo.FeatureID   = 'NBZI';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_HighDepenHighGLEmpha(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'HighDependenceHighGrayLevelEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'High dependence high grey level emphasis';
        FeatureInfo.FeatureID   = '9QMG';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_GLNonuniformity(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'GrayLevelNonuniformity');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Grey level non-uniformity';
        FeatureInfo.FeatureID   = 'FP8K';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_GLNonuniformityNorm(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'GrayLevelNonuniformityNorm');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Normalised grey level non-uniformity';
        FeatureInfo.FeatureID   = '5SPA';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_DepCountNonuniformity(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'DependenceCountNonuniformity');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Dependence count non-uniformity';
        FeatureInfo.FeatureID   = 'Z87G';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_DepCountNonuniformityNorm(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'DependenceCountNonuniformityNorm');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Normalised dependence count non-uniformity';
        FeatureInfo.FeatureID   = 'OKJI';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_DepCountPercentage(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'DependenceCountPercentage');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Dependence count percentage';
        FeatureInfo.FeatureID   = '6XV8';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_GLVariance(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'GrayLevelVariance');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Grey level variance';
        FeatureInfo.FeatureID   = '1PFV';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_DepCountVariance(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'DependenceCountVariance');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Dependence count variance';
        FeatureInfo.FeatureID   = 'DNX2';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_DepCountEntropy(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'DependenceCountEntropy');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Dependence count entropy';
        FeatureInfo.FeatureID   = 'FCBV';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_DepCountEnergy(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'DependenceCountEnergy');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Dependence count energy';
        FeatureInfo.FeatureID   = 'CAS9';
end

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