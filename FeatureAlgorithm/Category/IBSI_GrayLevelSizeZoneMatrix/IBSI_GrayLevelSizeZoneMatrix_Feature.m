function FeatureInfo=IBSI_GrayLevelSizeZoneMatrix_Feature(ParentInfo, FeatureInfo, Mode)

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
        FeatureInfo(i).CatAbbreviation = 'GLSZM';
        FeatureInfo(i).Category = 'Grey level size zone matrix';
        FeatureInfo(i).CategoryID = '9SAK';
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



% FEATURES
function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_SmallZoneEmphasis(ParentInfo, Param, modality)
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
        [Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'SmallZoneEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Small zone emphasis';
        FeatureInfo.FeatureID   = '5QRC';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_LargeZoneEmphasis(ParentInfo, Param, modality)
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
        [Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'LargeZoneEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Large zone emphasis';
        FeatureInfo.FeatureID   = '48P8';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_LowGLZoneEmpha(ParentInfo, Param, modality)
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
        [Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'LowGraySizeZoneEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Low grey level zone emphasis';
        FeatureInfo.FeatureID   = 'XMSY';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_HighGLZoneEmpha(ParentInfo, Param, modality)
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
        [Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'HighGraySizeZoneEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'High grey level zone emphasis';
        FeatureInfo.FeatureID   = '5GN9';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_SmallZoneLowGLEmpha(ParentInfo, Param, modality)
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
        [Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'ShortRunLowSizeZoneEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Small zone low grey level emphasis';
        FeatureInfo.FeatureID   = '5RAI';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_SmallZoneHighGLEmpha(ParentInfo, Param, modality)
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
        [Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'ShortRunHighSizeZoneEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Small zone high grey level emphasis';
        FeatureInfo.FeatureID   = 'HW1V';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_LargeZoneLowGLEmpha(ParentInfo, Param, modality)
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
        [Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'SizeZoneLowGrayLevelEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Large zone low grey level emphasis';
        FeatureInfo.FeatureID   = 'YH51';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_LargeZoneHighGLEmpha(ParentInfo, Param, modality)
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
        [Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'SizeZoneHighGrayLevelEmphasis');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Large zone high grey level emphasis';
        FeatureInfo.FeatureID   = 'J17V';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_GLNonuniformity(ParentInfo, Param, modality)
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
        [Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'GLNonuniformity');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Grey level non-uniformity';
        FeatureInfo.FeatureID   = 'JNSA';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_GLNonuniformityNorm(ParentInfo, Param, modality)
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
        [Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'GLNonuniformityNorm');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Normalised grey level non-uniformity';
        FeatureInfo.FeatureID   = 'Y1RO';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_SZNonuniformity(ParentInfo, Param, modality)
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
        [Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'SizeZoneNonuniformity');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Zone size non-uniformity';
        FeatureInfo.FeatureID   = '4JP3';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_SZNonuniformityNorm(ParentInfo, Param, modality)
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
        [Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'SizeZoneNonuniformityNorm');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Normalised zone size non-uniformity';
        FeatureInfo.FeatureID   = 'VB3A';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_ZonePercentage(ParentInfo, Param, modality)
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
        [Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'ZonePercentage');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Zone percentage';
        FeatureInfo.FeatureID   = 'P30P';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_GrayLevelVariance(ParentInfo, Param, modality)
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
        [Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'GrayLevelVariance');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Grey level variance';
        FeatureInfo.FeatureID   = 'BYLV';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_SizeZoneVariance(ParentInfo, Param, modality)
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
        [Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'ZoneSizeVariance');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Zone size variance';
        FeatureInfo.FeatureID   = '3NSA';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_SizeZoneEntropy(ParentInfo, Param, modality)
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
        [Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'ZoneSizeEntropy');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Zone size entropy';
        FeatureInfo.FeatureID   = 'GU8N';
end

function [Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, Mode)
SliceNum=length(ParentInfo.ROIImageInfo.GLSZMStruct3);

FeatureValue=zeros(SliceNum, 1);

for i=1:SliceNum
    CurrentItem=ParentInfo.ROIImageInfo.GLSZMStruct3(i);
    
    GLSZM=CurrentItem.GLSZM;
    Nv=CurrentItem.Nv;
    
    [GrayLevelNum, SizeZoneLevelNum]= size(GLSZM);
    
    SizeZoneVec2=(1:SizeZoneLevelNum).^2;
    GrayVec2=(1:GrayLevelNum)'.^2;
    
    Pij = GLSZM(:)/sum(GLSZM(:));
    
    switch Mode
        case 'SmallZoneEmphasis'
            TempMat=repmat(SizeZoneVec2, GrayLevelNum, 1);
            TempMat=GLSZM./TempMat;
            
            FinalValue=sum(TempMat(:))/sum(GLSZM(:));
            
        case 'LargeZoneEmphasis'
            TempMat=repmat(SizeZoneVec2, GrayLevelNum, 1);
            TempMat=GLSZM.*TempMat;
            
            FinalValue=sum(TempMat(:))/sum(GLSZM(:));
            
        case 'LowGraySizeZoneEmphasis'
            TempMat=repmat(GrayVec2, 1, SizeZoneLevelNum);
            TempMat=GLSZM./TempMat;
            
            FinalValue=sum(TempMat(:))/sum(GLSZM(:));
            
        case 'HighGraySizeZoneEmphasis'
            TempMat=repmat(GrayVec2, 1, SizeZoneLevelNum);
            TempMat=GLSZM.*TempMat;
            
            FinalValue=sum(TempMat(:))/sum(GLSZM(:));
            
        case 'ShortRunLowSizeZoneEmphasis'
            TempMatRun=repmat(SizeZoneVec2, GrayLevelNum, 1);
            TempMatGray=repmat(GrayVec2, 1, SizeZoneLevelNum);
            
            TempMat=GLSZM./TempMatRun./TempMatGray;
            
            FinalValue=sum(TempMat(:))/sum(GLSZM(:));
            
        case 'ShortRunHighSizeZoneEmphasis'
            TempMatRun=repmat(SizeZoneVec2, GrayLevelNum, 1);
            TempMatGray=repmat(GrayVec2, 1, SizeZoneLevelNum);
            
            TempMat=GLSZM.*TempMatGray./TempMatRun;
            
            FinalValue=sum(TempMat(:))/sum(GLSZM(:));
            
        case 'SizeZoneLowGrayLevelEmphasis'
            TempMatRun=repmat(SizeZoneVec2, GrayLevelNum, 1);
            TempMatGray=repmat(GrayVec2, 1, SizeZoneLevelNum);
            
            TempMat=GLSZM.*TempMatRun./TempMatGray;
            
            FinalValue=sum(TempMat(:))/sum(GLSZM(:));
            
        case 'SizeZoneHighGrayLevelEmphasis'
            TempMatRun=repmat(SizeZoneVec2, GrayLevelNum, 1);
            TempMatGray=repmat(GrayVec2, 1, SizeZoneLevelNum);
            
            TempMat=GLSZM.*TempMatRun.*TempMatGray;
            
            FinalValue=sum(TempMat(:))/sum(GLSZM(:));
            
        case 'GLNonuniformity'
            TempMat=sum(GLSZM, 2).^2;
            FinalValue=sum(TempMat(:))/sum(GLSZM(:));
            
        case 'GLNonuniformityNorm'
            TempMat=sum(GLSZM, 2).^2;
            FinalValue=sum(TempMat(:))/(sum(GLSZM(:)).^2);
            
        case 'SizeZoneNonuniformity'
            TempMat=sum(GLSZM, 1).^2;
            FinalValue=sum(TempMat(:))/sum(GLSZM(:));
            
        case 'SizeZoneNonuniformityNorm'
            TempMat=sum(GLSZM, 1).^2;
            FinalValue=sum(TempMat(:))/(sum(GLSZM(:)).^2);
            
        case 'ZonePercentage'
            FinalValue=sum(GLSZM(:))/Nv;
            
        case 'GrayLevelVariance'
            [J, I] = meshgrid(1:SizeZoneLevelNum, 1:GrayLevelNum);
            I = I(:);
            J = J(:);
            mu = sum(I.*Pij);
            
            FinalValue=sum((I-mu).^2.*Pij);
        case 'ZoneSizeVariance'
            [J, I] = meshgrid(1:SizeZoneLevelNum, 1:GrayLevelNum);
            I = I(:);
            J = J(:);
            mu = sum(J.*Pij);
            
            FinalValue=sum((J-mu).^2.*Pij);
        case 'ZoneSizeEntropy'
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