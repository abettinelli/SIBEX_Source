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
        [FeatureValue, ~, Info]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix);
        FeatureValue=mean(FeatureValue);
        FeatureInfo(i).FeatureValue=FeatureValue;
        
        % Family/Feature Infos
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
    end         
end

function [FeatureValue, FeatureReviewInfo, FeatureInfo]=GetFeatureValue(ParentInfo, CurrentFeatureInfo,  FeaturePrefix)
FeatureName=CurrentFeatureInfo.Name;

FuncName=[FeaturePrefix, '_', FeatureName];
FuncHandle=str2func(FuncName);

[FeatureValue, FeatureReviewInfo, FeatureInfo]=FuncHandle(ParentInfo, CurrentFeatureInfo.Value);

%----FEATURES
function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_LowDepenEmphasis(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'LowDependenceEmphasis');

FeatureInfo.FeatureName = 'Low dependence emphasis';
FeatureInfo.FeatureID   = 'SODN';

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_HighDepenEmphasis(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'HighDependenceEmphasis');

FeatureInfo.FeatureName = 'High dependence emphasis';
FeatureInfo.FeatureID   = 'IMOQ';

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_LowGLCountEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'LowGrayLevelCountEmphasis');

FeatureInfo.FeatureName = 'Low grey level count emphasis';
FeatureInfo.FeatureID   = 'TL9H';

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_HighGLCountEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'HighGrayLevelCountEmphasis');

FeatureInfo.FeatureName = 'High grey level count emphasis';
FeatureInfo.FeatureID   = 'OAE7';

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_LowDepenLowGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'LowDependenceLowGrayLevelEmphasis');

FeatureInfo.FeatureName = 'Low dependence low grey level emphasis';
FeatureInfo.FeatureID   = 'EQ3F';

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_LowDepenHighGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'LowDependenceHighGrayLevelEmphasis');

FeatureInfo.FeatureName = 'Low dependence high grey level emphasis';
FeatureInfo.FeatureID   = 'JA6D';

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_HighDepenLowGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'HighDependenceLowGrayLevelEmphasis');

FeatureInfo.FeatureName = 'High dependence low grey level emphasis';
FeatureInfo.FeatureID   = 'NBZI';

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_HighDepenHighGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'HighDependenceHighGrayLevelEmphasis');

FeatureInfo.FeatureName = 'High dependence high grey level emphasis';
FeatureInfo.FeatureID   = '9QMG';

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_GLNonuniformity(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'GrayLevelNonuniformity');

FeatureInfo.FeatureName = 'Grey level non-uniformity';
FeatureInfo.FeatureID   = 'FP8K';

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_GLNonuniformityNorm(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'GrayLevelNonuniformityNorm');

FeatureInfo.FeatureName = 'Normalised grey level non-uniformity';
FeatureInfo.FeatureID   = '5SPA';

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_DepCountNonuniformity(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'DependenceCountNonuniformity');

FeatureInfo.FeatureName = 'Dependence count non-uniformity';
FeatureInfo.FeatureID   = 'Z87G';

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_DepCountNonuniformityNorm(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'DependenceCountNonuniformityNorm');

FeatureInfo.FeatureName = 'Normalised dependence count non-uniformity';
FeatureInfo.FeatureID   = 'OKJI';

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_DepCountPercentage(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'DependenceCountPercentage');

FeatureInfo.FeatureName = 'Dependence count percentage';
FeatureInfo.FeatureID   = '6XV8';

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_GLVariance(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'GrayLevelVariance');

FeatureInfo.FeatureName = 'Grey level variance';
FeatureInfo.FeatureID   = '1PFV';

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_DepCountVariance(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'DependenceCountVariance');

FeatureInfo.FeatureName = 'Dependence count variance';
FeatureInfo.FeatureID   = 'DNX2';

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_DepCountEntropy(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'DependenceCountEntropy');

FeatureInfo.FeatureName = 'Dependence count entropy';
FeatureInfo.FeatureID   = 'FCBV';

function [Value, ReviewInfo, FeatureInfo]=IBSI_NeighborGLDependence_Feature_DepCountEnergy(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNGLDMFeature(ParentInfo, 'DependenceCountEnergy');

FeatureInfo.FeatureName = 'Dependence count energy';
FeatureInfo.FeatureID   = 'CAS9';


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