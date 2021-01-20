function FeatureInfo=IBSI_IntensityVolumeHistogram_Feature(ParentInfo, FeatureInfo, Mode)

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
        FeatureInfo(i).CatAbbreviation = 'IVH';
        FeatureInfo(i).Category = 'Intensity-volume histogram';
        FeatureInfo(i).CategoryID = 'P88C';
        FeatureInfo(i).FeatureName=Info.FeatureName;
        FeatureInfo(i).FeatureID=Info.FeatureID;
        FeatureInfo(i).AggregationMethod = '';
        FeatureInfo(i).AggregationMethodID = 'DHQ4';
    elseif isequal(Mode, 'Review')
        [FeatureValue, FeatureReviewInfo]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix,'Value');
        FeatureInfo(i).FeatureValue=FeatureValue;
        FeatureInfo(i).FeatureReviewInfo=FeatureReviewInfo;
    else
        try
            [FeatureValue,~, ~]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix,'Value');
        catch
            FeatureValue = [];
        end
        if length(FeatureValue) > 1
            FeatureInfo(i).FeatureValueParam=FeatureValue(:, 1);
            FeatureInfo(i).FeatureValue=FeatureValue(:, 2);
        else
            FeatureInfo(i).FeatureValue=FeatureValue;
        end
    end
end

function [FeatureValue, FeatureReviewInfo, FeatureInfo]=GetFeatureValue(ParentInfo, CurrentFeatureInfo,  FeaturePrefix, modality)
FeatureName=CurrentFeatureInfo.Name;

FuncName=[FeaturePrefix, '_', FeatureName];
FuncHandle=str2func(FuncName);

[FeatureValue, FeatureReviewInfo, FeatureInfo]=FuncHandle(ParentInfo, CurrentFeatureInfo.Value, modality);

%FEATURES
function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityVolumeHistogram_Feature_VolumeIntFract_10(ParentInfo, Param, modality)
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
        counts = ParentInfo.ROIImageInfo.counts;
        gamma = ParentInfo.ROIImageInfo.gamma;
        
        idxs = find(gamma >= 0.1);
        if ~isempty(idxs)
            Value = counts(idxs(1));
        else
            Value = NaN;
        end
    case 'InfoID'
        FeatureInfo.FeatureName = 'Volume at intensity fraction 10';
        FeatureInfo.FeatureID   = 'BC2M';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityVolumeHistogram_Feature_VolumeIntFract_90(ParentInfo, Param, modality)
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
        counts = ParentInfo.ROIImageInfo.counts;
        gamma = ParentInfo.ROIImageInfo.gamma;
        
        idxs = find(gamma >= 0.9);
        if ~isempty(idxs)
            Value = counts(idxs(1));
        else
            Value = NaN;
        end
    case 'InfoID'
        FeatureInfo.FeatureName = 'Volume at intensity fraction 90';
        FeatureInfo.FeatureID   = 'BC2M';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityVolumeHistogram_Feature_IntensityVolFract_10(ParentInfo, Param, modality)
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
        volume = ParentInfo.ROIImageInfo.counts;
        gamma = ParentInfo.ROIImageInfo.gamma;
        intensities = ParentInfo.ROIImageInfo.intensities;
        
        idxs = find(volume <= 0.1);
        if ~isempty(idxs)
            Value = intensities(idxs(1));
        else
            Value = NaN;
        end
    case 'InfoID'
        FeatureInfo.FeatureName = 'Intensity at volume fraction 10';
        FeatureInfo.FeatureID   = 'GBPN';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityVolumeHistogram_Feature_IntensityVolFract_90(ParentInfo, Param, modality)
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
        volume = ParentInfo.ROIImageInfo.counts;
        gamma = ParentInfo.ROIImageInfo.gamma;
        intensities = ParentInfo.ROIImageInfo.intensities;
        
        idxs = find(volume <= 0.9);
        if ~isempty(idxs)
            Value = intensities(idxs(1));
        else
            Value = NaN;
        end
    case 'InfoID'
        FeatureInfo.FeatureName = 'Intensity at volume fraction 90';
        FeatureInfo.FeatureID   = 'GBPN';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityVolumeHistogram_Feature_VolumeFractionDiff(ParentInfo, Param, modality)
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
        counts = ParentInfo.ROIImageInfo.counts;
        gamma = ParentInfo.ROIImageInfo.gamma;
        
        idxs = find(gamma >= 0.1);
        idxs2 = find(gamma >= 0.9);
        if ~isempty(idxs) && ~isempty(idxs2)
            V10 = counts(idxs(1));
            V90 = counts(idxs2(1));
            Value = V10-V90;
        else
            Value = NaN;
        end
    case 'InfoID'
        FeatureInfo.FeatureName = 'Volume fraction difference between intensity fractions';
        FeatureInfo.FeatureID   = 'DDTU';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityVolumeHistogram_Feature_IntensityFractDiff(ParentInfo, Param, modality)
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
        volume = ParentInfo.ROIImageInfo.counts;
        gamma = ParentInfo.ROIImageInfo.gamma;
        intensities = ParentInfo.ROIImageInfo.intensities;
        
        idxs = find(volume <= 0.1);
        idxs2 = find(volume <= 0.9);
        if ~isempty(idxs) && ~isempty(idxs2)
            I10 = intensities(idxs(1));
            I90 = intensities(idxs2(1));
            Value = I10-I90;
        else
            Value = NaN;
        end
    case 'InfoID'
        FeatureInfo.FeatureName = 'Intensity fraction difference between volume fractions';
        FeatureInfo.FeatureID   = 'CNV2';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityVolumeHistogram_Feature_AreaUnderIVHCurve(ParentInfo, Param, modality)
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
        volume = ParentInfo.ROIImageInfo.counts;
        gamma = ParentInfo.ROIImageInfo.gamma;
        intensities = ParentInfo.ROIImageInfo.intensities;
        
        Value = trapz(gamma, volume);
    case 'InfoID'
        FeatureInfo.FeatureName = 'Area under the IVH curve';
        FeatureInfo.FeatureID   = '9CMM';
end