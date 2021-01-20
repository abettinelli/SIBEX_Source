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
    if isequal(Mode, 'InfoID')
        % Family/Feature Infos
        [~, ~, Info]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix, 'InfoID');
        FeatureInfo(i).FeatureValue=[];
        FeatureInfo(i).CatAbbreviation = 'LI';
        FeatureInfo(i).Category = 'Local intensity';
        FeatureInfo(i).CategoryID = '9ST6';
        FeatureInfo(i).FeatureName=Info.FeatureName;
        FeatureInfo(i).FeatureID=Info.FeatureID;
        FeatureInfo(i).AggregationMethod = '';
        FeatureInfo(i).AggregationMethodID = 'DHQ4';
    elseif isequal(Mode, 'Review')
        % Review Info
        [FeatureValue, FeatureReviewInfo]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix,'Value');
        FeatureInfo(i).FeatureValue=FeatureValue;
        FeatureInfo(i).FeatureReviewInfo=FeatureReviewInfo;
    else
        % Calculate FeatureValue
        try
            [FeatureValue, ~, ~]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix,'Value');
        catch
            FeatureValue=[];
        end
        
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
    end
end

function [FeatureValue, FeatureReviewInfo, FeatureInfo]=GetFeatureValue(ParentInfo, CurrentFeatureInfo,  FeaturePrefix, modality)
FeatureName=CurrentFeatureInfo.Name;

FuncName=[FeaturePrefix, '_', FeatureName];
FuncHandle=str2func(FuncName);

[FeatureValue, FeatureReviewInfo, FeatureInfo]=FuncHandle(ParentInfo, CurrentFeatureInfo.Value, modality);

% FEATURES
function [Value, ReviewInfo, FeatureInfo]=IBSI_LocalIntensityFeatures_Feature_LocalIntensityPeak(ParentInfo, Param, modality)
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
        CurrentImage=double(ParentInfo.ROIImageInfo.MaskData);
        CurrentMask=double(ParentInfo.ROIBWInfo.MaskData);
        CurrentImage_filter=ParentInfo.ROIImageInfo.FilterMask;
        
        temp = CurrentImage(logical(CurrentMask));
        idx_max = find(CurrentImage(:) == max(temp) & logical(CurrentMask(:)));
        max_vect=CurrentImage_filter(idx_max);
        
        if ~isempty(max_vect)
            Value= max(double(max_vect(:)));
        else
            Value=NaN;
        end
    case 'InfoID'
        FeatureInfo.FeatureName = 'Local intensity peak';
        FeatureInfo.FeatureID   = 'VJGA';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_LocalIntensityFeatures_Feature_GlobalIntensityPeak(ParentInfo, Param, modality)
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
        CurrentMask=double(ParentInfo.ROIBWInfo.MaskData);
        CurrentImage_filter=ParentInfo.ROIImageInfo.FilterMask;
        
        max_vect=CurrentImage_filter(logical(CurrentMask));
        
        if ~isempty(max_vect)
            Value= max(double(max_vect(:)));
        else
            Value=NaN;
        end
    case 'InfoID'
        FeatureInfo.FeatureName = 'Global intensity peak';
        FeatureInfo.FeatureID   = '0F91';
end