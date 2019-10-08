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
    if isequal(Mode, 'Review')
        [FeatureValue, FeatureReviewInfo]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix);
        FeatureInfo(i).FeatureValue=FeatureValue;
        FeatureInfo(i).FeatureReviewInfo=FeatureReviewInfo;
    else
        FeatureValue=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix);
        FeatureValue = mean(FeatureValue); % bettinelli
        FeatureInfo(i).FeatureValue=FeatureValue;
    end         
end

function [FeatureValue, FeatureReviewInfo]=GetFeatureValue(ParentInfo, CurrentFeatureInfo,  FeaturePrefix)
FeatureName=CurrentFeatureInfo.Name;

FuncName=[FeaturePrefix, '_', FeatureName];
FuncHandle=str2func(FuncName);

[FeatureValue, FeatureReviewInfo]=FuncHandle(ParentInfo, CurrentFeatureInfo.Value);

% FEATURES
function [Value, ReviewInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_SmallZoneEmphasis(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'SmallZoneEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_LargeZoneEmphasis(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'LargeZoneEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_LowGLZoneEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'LowGraySizeZoneEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_HighGLZoneEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'HighGraySizeZoneEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_SmallZoneLowGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'ShortRunLowSizeZoneEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_SmallZoneHighGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'ShortRunHighSizeZoneEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_LargeZoneLowGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'SizeZoneLowGrayLevelEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_LargeZoneHighGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'SizeZoneHighGrayLevelEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_GLNonuniformity(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% 1. Xiaoou Tang. Texture information in run-length matrices. IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609.
% 2. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'GLNonuniformity');

function [Value, ReviewInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_GLNonuniformityNorm(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% 1. Xiaoou Tang. Texture information in run-length matrices. IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609.
% 2. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'GLNonuniformityNorm');

function [Value, ReviewInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_SZNonuniformity(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% 1. Xiaoou Tang. Texture information in run-length matrices. IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609.
% 2. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'SizeZoneNonuniformity');

function [Value, ReviewInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_SZNonuniformityNorm(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% 1. Xiaoou Tang. Texture information in run-length matrices. IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609.
% 2. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'SizeZoneNonuniformityNorm');

function [Value, ReviewInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_ZonePercentage(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'ZonePercentage');

function [Value, ReviewInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_GrayLevelVariance(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% 1. Xiaoou Tang. Texture information in run-length matrices. IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609.
% 2. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'GrayLevelVariance');

function [Value, ReviewInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_SizeZoneVariance(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% 1. Xiaoou Tang. Texture information in run-length matrices. IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609.
% 2. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'ZoneSizeVariance');

function [Value, ReviewInfo]=IBSI_GrayLevelSizeZoneMatrix_Feature_SizeZoneEntropy(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% 1. Xiaoou Tang. Texture information in run-length matrices. IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609.
% 2. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'ZoneSizeEntropy');


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