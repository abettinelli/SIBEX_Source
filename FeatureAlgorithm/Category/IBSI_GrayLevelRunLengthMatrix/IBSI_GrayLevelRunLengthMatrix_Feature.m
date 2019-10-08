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
    if isequal(Mode, 'Review')
        [FeatureValue, FeatureReviewInfo]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix);
        FeatureInfo(i).FeatureValue=mean(FeatureValue);
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
function [Value, ReviewInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_ShortRunEmphasis(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'ShortRunEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_LongRunEmphasis(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'LongRunEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_LowGLRunEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'LowGrayLevelRunEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_HighGLRunEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'HighGrayLevelRunEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_ShortRunLowGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'ShortRunLowGrayLevelEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_ShortRunHighGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'ShortRunHighGrayLevelEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_LongRunLowGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'LongRunLowGrayLevelEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_LongRunHighGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'LongRunHighGrayLevelEmphasis');

function [Value, ReviewInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_GLNonuniformity(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% 1. Xiaoou Tang. Texture information in run-length matrices. IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609.
% 2. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'GrayLevelNonuniformity');

function [Value, ReviewInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_GLNonuniformityNorm(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% 1. Xiaoou Tang. Texture information in run-length matrices. IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609.
% 2. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'GrayLevelNonuniformityNorm');

function [Value, ReviewInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_RLNonuniformity(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% 1. Xiaoou Tang. Texture information in run-length matrices. IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609.
% 2. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'RunLengthNonuniformity');

function [Value, ReviewInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_RLNonuniformityNorm(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% 1. Xiaoou Tang. Texture information in run-length matrices. IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609.
% 2. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'RunLengthNonuniformityNorm');

function [Value, ReviewInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_RunPercentage(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
%  "Xiaoou Tang. Texture information in run-length matrices.
%  IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609."
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'RunPercentage');

function [Value, ReviewInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_GrayLevelVariance(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% 1. Xiaoou Tang. Texture information in run-length matrices. IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609.
% 2. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'GrayLevelVariance');

function [Value, ReviewInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_RunLengthVariance(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% 1. Xiaoou Tang. Texture information in run-length matrices. IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609.
% 2. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'RunLengthVariance');

function [Value, ReviewInfo]=IBSI_GrayLevelRunLengthMatrix_Feature_RunEntropy(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% 1. Xiaoou Tang. Texture information in run-length matrices. IEEE Transactions on Image Processing ,Volume 7 Issue 11, Page 1602-1609.
% 2. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLRLMFeature(ParentInfo, 'RunEntropy');


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