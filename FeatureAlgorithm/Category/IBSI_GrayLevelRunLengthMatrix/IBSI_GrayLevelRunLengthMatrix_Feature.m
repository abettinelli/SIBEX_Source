function FeatureInfo=IBSI_GrayLevelRunLengthMatrix_Feature(ParentInfo, FeatureInfo, Mode)

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
        FeatureInfo(i).CatAbbreviation = 'GLRLM';
        FeatureInfo(i).Category = 'Grey level run length matrix';
        FeatureInfo(i).CategoryID = 'TP0I';
        FeatureInfo(i).FeatureName=Info.FeatureName;
        FeatureInfo(i).FeatureID=Info.FeatureID;
        switch ParentInfo.AggregationMethod
            case 1
                FeatureInfo(i).AggregationMethod = '2D:avg';
                FeatureInfo(i).AggregationMethodID = 'BTW3';
            case 2
                FeatureInfo(i).AggregationMethod = '2D:smrg';
                FeatureInfo(i).AggregationMethodID = 'SUJT';
            case 6
                FeatureInfo(i).AggregationMethod = '2.5D:dmrg';
                FeatureInfo(i).AggregationMethodID = 'JJUI';
            case 3
                FeatureInfo(i).AggregationMethod = '2.5D:vmrg';
                FeatureInfo(i).AggregationMethodID = 'ZW7Z';
            case 4
                FeatureInfo(i).AggregationMethod = '3D:avg';
                FeatureInfo(i).AggregationMethodID = 'ITBB';
            case 5
                FeatureInfo(i).AggregationMethod = '3D:mrg';
                FeatureInfo(i).AggregationMethodID = 'IAZD';
        end
    elseif isequal(Mode, 'Review')
        [FeatureValue, FeatureReviewInfo]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix,'Value');
        FeatureInfo(i).FeatureValue=mean(FeatureValue);
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
function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_ShortRunEmphasis(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'ShortRunEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Short runs emphasis';
        FeatureInfo.FeatureID   = '22OV';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_LongRunEmphasis(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'LongRunEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Long runs emphasis';
        FeatureInfo.FeatureID   = 'W4KF';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_LowGLRunEmpha(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'LowGrayLevelRunEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Low grey level run emphasis';
        FeatureInfo.FeatureID   = 'V3SW';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_HighGLRunEmpha(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'HighGrayLevelRunEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'High grey level run emphasis';
        FeatureInfo.FeatureID   = 'G3QZ';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_ShortRunLowGLEmpha(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'ShortRunLowGrayLevelEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Short run low grey level emphasis';
        FeatureInfo.FeatureID   = 'HTZT';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_ShortRunHighGLEmpha(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'ShortRunHighGrayLevelEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Short run high grey level emphasis';
        FeatureInfo.FeatureID   = 'GD3A';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_LongRunLowGLEmpha(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'LongRunLowGrayLevelEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Long run low grey level emphasis';
        FeatureInfo.FeatureID   = 'IVPO';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_LongRunHighGLEmpha(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'LongRunHighGrayLevelEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Long run high grey level emphasis';
        FeatureInfo.FeatureID   = '3KUM';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_GLNonuniformity(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% 1. Xiaoou Tang. Texture information in run-length matrices. IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609.
% 2. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'GrayLevelNonuniformity');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Grey level non-uniformity';
        FeatureInfo.FeatureID   = 'R5YN';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_GLNonuniformityNorm(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% 1. Xiaoou Tang. Texture information in run-length matrices. IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609.
% 2. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'GrayLevelNonuniformityNorm');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Normalised grey level non-uniformity';
        FeatureInfo.FeatureID   = 'OVBL';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_RLNonuniformity(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% 1. Xiaoou Tang. Texture information in run-length matrices. IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609.
% 2. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'RunLengthNonuniformity');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Run length non-uniformity';
        FeatureInfo.FeatureID   = 'W92Y';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_RLNonuniformityNorm(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% 1. Xiaoou Tang. Texture information in run-length matrices. IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609.
% 2. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'RunLengthNonuniformityNorm');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Normalised run length non-uniformity';
        FeatureInfo.FeatureID   = 'IC23';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_RunPercentage(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'RunPercentage');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Run percentage';
        FeatureInfo.FeatureID   = '9ZK5';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_GrayLevelVariance(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% 1. Xiaoou Tang. Texture information in run-length matrices. IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609.
% 2. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'GrayLevelVariance');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Grey level variance';
        FeatureInfo.FeatureID   = '8CE5';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_RunLengthVariance(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% 1. Xiaoou Tang. Texture information in run-length matrices. IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609.
% 2. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'RunLengthVariance');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Run length variance';
        FeatureInfo.FeatureID   = 'SXLW';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_RunEntropy(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% 1. Xiaoou Tang. Texture information in run-length matrices. IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609.
% 2. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'RunEntropy');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Run entropy';
        FeatureInfo.FeatureID   = 'HJ9O';
end

function [Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, Mode)
Direction_Slice_Num=length(ParentInfo.ROIImageInfo.GLRLMStruct25);

FeatureValue=zeros(Direction_Slice_Num, 1);

for i=1:Direction_Slice_Num
    CurrentItem=ParentInfo.ROIImageInfo.GLRLMStruct25(i);
    
    GLRLM=CurrentItem.GLRLM;
    [GrayLevelNum, RunLenLevelNum]= size(GLRLM);
    
    RunLenVec2=(1:RunLenLevelNum).^2;
    GrayVec2=(1:GrayLevelNum)'.^2;
    
    Pij = GLRLM(:)/sum(GLRLM(:));
    
    switch Mode
        case 'ShortRunEmphasis'
            TempMat=repmat(RunLenVec2, GrayLevelNum, 1);
            TempMat=GLRLM./TempMat;
            
            FinalValue=sum(TempMat(:))/sum(GLRLM(:));
            
        case 'LongRunEmphasis'
            TempMat=repmat(RunLenVec2, GrayLevelNum, 1);
            TempMat=GLRLM.*TempMat;
            
            FinalValue=sum(TempMat(:))/sum(GLRLM(:));
            
        case 'LowGrayLevelRunEmphasis'
            TempMat=repmat(GrayVec2, 1, RunLenLevelNum);
            TempMat=GLRLM./TempMat;
            
            FinalValue=sum(TempMat(:))/sum(GLRLM(:));
            
        case 'HighGrayLevelRunEmphasis'
            TempMat=repmat(GrayVec2, 1, RunLenLevelNum);
            TempMat=GLRLM.*TempMat;
            
            FinalValue=sum(TempMat(:))/sum(GLRLM(:));
            
        case 'ShortRunLowGrayLevelEmphasis'
            TempMatRun=repmat(RunLenVec2, GrayLevelNum, 1);
            TempMatGray=repmat(GrayVec2, 1, RunLenLevelNum);
            
            TempMat=GLRLM./TempMatRun./TempMatGray;
            
            FinalValue=sum(TempMat(:))/sum(GLRLM(:));
            
        case 'ShortRunHighGrayLevelEmphasis'
            TempMatRun=repmat(RunLenVec2, GrayLevelNum, 1);
            TempMatGray=repmat(GrayVec2, 1, RunLenLevelNum);
            
            TempMat=GLRLM.*TempMatGray./TempMatRun;
            
            FinalValue=sum(TempMat(:))/sum(GLRLM(:));
            
        case 'LongRunLowGrayLevelEmphasis'
            TempMatRun=repmat(RunLenVec2, GrayLevelNum, 1);
            TempMatGray=repmat(GrayVec2, 1, RunLenLevelNum);
            
            TempMat=GLRLM.*TempMatRun./TempMatGray;
            
            FinalValue=sum(TempMat(:))/sum(GLRLM(:));
            
        case 'LongRunHighGrayLevelEmphasis'
            TempMatRun=repmat(RunLenVec2, GrayLevelNum, 1);
            TempMatGray=repmat(GrayVec2, 1, RunLenLevelNum);
            
            TempMat=GLRLM.*TempMatRun.*TempMatGray;
            
            FinalValue=sum(TempMat(:))/sum(GLRLM(:));
            
        case 'GrayLevelNonuniformity'
            FinalValue=sum(sum(GLRLM, 2).^2)/sum(GLRLM(:));
            
        case 'GrayLevelNonuniformityNorm'
            FinalValue=sum(sum(GLRLM, 2).^2)/(sum(GLRLM(:)).^2);
            
        case 'RunLengthNonuniformity'
            FinalValue=sum(sum(GLRLM, 1).^2)/sum(GLRLM(:));
            
        case 'RunLengthNonuniformityNorm'
            FinalValue=sum(sum(GLRLM, 1).^2)/(sum(GLRLM(:)).^2);
            
        case 'RunPercentage'
            FinalValue=sum(GLRLM(:))/CurrentItem.Nv;
            
        case 'GrayLevelVariance'
            [J, I] = meshgrid(1:RunLenLevelNum, 1:GrayLevelNum);
            I = I(:);
            J = J(:);
            mu = sum(I.*Pij);
            
            FinalValue=sum((I-mu).^2.*Pij);
        case 'RunLengthVariance'
            [J, I] = meshgrid(1:RunLenLevelNum, 1:GrayLevelNum);
            I = I(:);
            J = J(:);
            mu = sum(J.*Pij);
            
            FinalValue=sum((J-mu).^2.*Pij);
        case 'RunEntropy'
            idx_nz = Pij ~= 0;
            
            FinalValue=-sum(Pij(idx_nz).*log2(Pij(idx_nz)));
    end
    
    FeatureValue(i)=FinalValue;
end

ReviewInfo=ParentInfo.ROIImageInfo;
ReviewInfo.Description=['GLRLM Feature', ' (Direction VS ', Mode, ')'];

Value=FeatureValue;
ReviewInfo.MaskData=Value;