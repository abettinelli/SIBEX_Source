function FeatureInfo=IBSI_LocalIntensityFeatures_Feature(ParentInfo, FeatureInfo, Mode)

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
        
        %handle buffer data or not
        if ~isstruct(FeatureValue)                    
            if length(FeatureValue) > 1
                FeatureInfo(i).FeatureValueParam=FeatureValue(:, 1);
                FeatureInfo(i).FeatureValue=FeatureValue(:, 2);
            else
                FeatureInfo(i).FeatureValue=FeatureValue;
            end
        else
            %Handle a group of feature
             FeatureInfo(i).FeatureValue=FeatureValue.Value;
        
             ParentInfo.BufferData=FeatureValue.BufferData;
             ParentInfo.BufferType=FeatureValue.BufferType;
        end
        
        % Family/Feature Infos
        FeatureInfo(i).CatAbbreviation = 'LI';
        FeatureInfo(i).Category = 'Local intensity';
        FeatureInfo(i).CategoryID = '9ST6';
        FeatureInfo(i).FeatureName=Info.FeatureName;
        FeatureInfo(i).FeatureID=Info.FeatureID;
        FeatureInfo(i).AggregationMethod = '';
        FeatureInfo(i).AggregationMethodID = 'DHQ4';
    end
end

function [FeatureValue, FeatureReviewInfo, FeatureInfo]=GetFeatureValue(ParentInfo, CurrentFeatureInfo,  FeaturePrefix)
FeatureName=CurrentFeatureInfo.Name;

FuncName=[FeaturePrefix, '_', FeatureName];
FuncHandle=str2func(FuncName);

[FeatureValue, FeatureReviewInfo, FeatureInfo]=FuncHandle(ParentInfo, CurrentFeatureInfo.Value);

% FEATURES
function [Value, ReviewInfo, FeatureInfo]=IBSI_LocalIntensityFeatures_Feature_LocalIntensityPeak(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%

CurrentImage=double(ParentInfo.ROIImageInfo.MaskData);
CurrentMask=double(ParentInfo.ROIBWInfo.MaskData);
CurrentImage_filter=ParentInfo.ROIImageInfo.FilterMask;

temp = CurrentImage(:).*CurrentMask(:);
maxval=max(temp);
idx_max = find(temp == maxval);

max_vect=CurrentImage_filter(idx_max);

if ~isempty(max_vect)    
    Value= max(double(max_vect(:)));
else
    Value=NaN;
end

FeatureInfo.FeatureName = 'Local intensity peak';
FeatureInfo.FeatureID   = 'VJGA';

ReviewInfo.MaskData=Value;

function [Value, ReviewInfo, FeatureInfo]=IBSI_LocalIntensityFeatures_Feature_GlobalIntensityPeak(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%

CurrentMask=double(ParentInfo.ROIBWInfo.MaskData);
CurrentImage_filter=ParentInfo.ROIImageInfo.FilterMask;

max_vect=CurrentImage_filter(logical(CurrentMask));

if ~isempty(max_vect)    
    Value= max(double(max_vect(:)));
else
    Value=NaN;
end

FeatureInfo.FeatureName = 'Global intensity peak';
FeatureInfo.FeatureID   = '0F91';

ReviewInfo.MaskData=Value;