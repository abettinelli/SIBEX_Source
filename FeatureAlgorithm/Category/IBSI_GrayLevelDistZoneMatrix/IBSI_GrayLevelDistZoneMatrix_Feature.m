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
        [FeatureValue, ~, Info]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix);
        FeatureValue=mean(FeatureValue);
        FeatureInfo(i).FeatureValue=FeatureValue;
        
        % Family/Feature Infos
        FeatureInfo(i).CatAbbreviation = 'GLDZM';
        FeatureInfo(i).Category = 'Grey level distance zone matrix';
        FeatureInfo(i).CategoryID = 'VMDZ';
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
function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_SmallDistEmphasis(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%

[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'SmallDistEmphasis');

FeatureInfo.FeatureName = 'Small distance emphasis';
FeatureInfo.FeatureID   = '0GBI';

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_LargeDistEmphasis(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'LargeDistEmphasis');

FeatureInfo.FeatureName = 'Large distance emphasis';
FeatureInfo.FeatureID   = 'MB4I';

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_LowGrayLevelEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'LowGrayLevelEmphasis');

FeatureInfo.FeatureName = 'Low grey level zone emphasis';
FeatureInfo.FeatureID   = 'S1RA';

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_HighGrayLevelEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'HighGrayLevelEmphasis');

FeatureInfo.FeatureName = 'High grey level zone emphasis';
FeatureInfo.FeatureID   = 'K26C';

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_SmallDistLowGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'SmallDistLowGLEmphasis');

FeatureInfo.FeatureName = 'Small distance low grey level emphasis';
FeatureInfo.FeatureID   = 'RUVG';

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_SmallDistHighGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'SmallDistHighGLEmphasis');

FeatureInfo.FeatureName = 'Small distance high grey level emphasis';
FeatureInfo.FeatureID   = 'DKNJ';

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_LargeDistLowGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'LargeDistLowGLEmphasis');

FeatureInfo.FeatureName = 'Large distance low grey level emphasis';
FeatureInfo.FeatureID   = 'A7WM';

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_LargeDistHighGLEmpha(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'LargeDistHighGLEmphasis');

FeatureInfo.FeatureName = 'Large distance high grey level emphasis';
FeatureInfo.FeatureID   = 'KLTH';

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_GLNonuniformity(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'GLNonuniformity');

FeatureInfo.FeatureName = 'Grey level non-uniformity';
FeatureInfo.FeatureID   = 'VFT7';

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_GLNonuniformityNorm(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'GLNonuniformityNorm');

FeatureInfo.FeatureName = 'Normalised grey level non-uniformity';
FeatureInfo.FeatureID   = '7HP3';

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_ZDNonuniformity(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'ZoneDistNonuniformity');

FeatureInfo.FeatureName = 'Zone distance non-uniformity';
FeatureInfo.FeatureID   = 'V294';

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_ZDNonuniformityNorm(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'ZoneDIstNonuniformityNorm');

FeatureInfo.FeatureName = 'Normalised zone distance non-uniformity';
FeatureInfo.FeatureID   = 'IATH';

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_ZonePercentage(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'ZonePercentage');

FeatureInfo.FeatureName = 'Zone percentage';
FeatureInfo.FeatureID   = 'VIWW';

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_GrayLevelVariance(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'GrayLevelVariance');

FeatureInfo.FeatureName = 'Grey level variance';
FeatureInfo.FeatureID   = 'QK93';

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_ZoneDistVariance(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'ZoneDistVariance');

FeatureInfo.FeatureName = 'Zone distance variance';
FeatureInfo.FeatureID   = '7WT1';

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelDistZoneMatrix_Feature_ZoneDistEntropy(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeGLSZMFeature(ParentInfo, 'ZoneDistEntropy');

FeatureInfo.FeatureName = 'Zone distance entropy';
FeatureInfo.FeatureID   = 'GBDU';


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