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
    if isequal(Mode, 'Review')
        [FeatureValue, FeatureReviewInfo]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix);
        FeatureInfo(i).FeatureValue=FeatureValue;
        FeatureInfo(i).FeatureReviewInfo=FeatureReviewInfo;
    else
        FeatureValue=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix);
        
        if length(FeatureValue) > 1
            FeatureInfo(i).FeatureValueParam=FeatureValue(:, 1);
            FeatureInfo(i).FeatureValue=FeatureValue(:, 2);
        else
            FeatureInfo(i).FeatureValue=FeatureValue;
        end
    end
end

function [FeatureValue, FeatureReviewInfo]=GetFeatureValue(ParentInfo, CurrentFeatureInfo,  FeaturePrefix)
FeatureName=CurrentFeatureInfo.Name;

FuncName=[FeaturePrefix, '_', FeatureName];
FuncHandle=str2func(FuncName);

[FeatureValue, FeatureReviewInfo]=FuncHandle(ParentInfo, CurrentFeatureInfo.Value);

%FEATURES
function [Value, null]=IBSI_IntensityVolumeHistogram_Feature_VolumeIntFract_10(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%

counts = ParentInfo.ROIImageInfo.counts;
gamma = ParentInfo.ROIImageInfo.gamma;

idxs = find(gamma >= 0.1);
if ~isempty(idxs)
    Value = counts(idxs(1));
else
    Value = NaN;
end
null = [];

function [Value, null]=IBSI_IntensityVolumeHistogram_Feature_VolumeIntFract_90(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
counts = ParentInfo.ROIImageInfo.counts;
gamma = ParentInfo.ROIImageInfo.gamma;

idxs = find(gamma >= 0.9);
if ~isempty(idxs)
    Value = counts(idxs(1));
else
    Value = NaN;
end
null = [];

function [Value, null]=IBSI_IntensityVolumeHistogram_Feature_IntensityVolFract_10(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%

volume = ParentInfo.ROIImageInfo.counts;
gamma = ParentInfo.ROIImageInfo.gamma;
intensities = ParentInfo.ROIImageInfo.intensities;

idxs = find(volume <= 0.1);
if ~isempty(idxs)
    Value = intensities(idxs(1));
else
    Value = NaN;
end
null = [];

function [Value, null]=IBSI_IntensityVolumeHistogram_Feature_IntensityVolFract_90(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%

volume = ParentInfo.ROIImageInfo.counts;
gamma = ParentInfo.ROIImageInfo.gamma;
intensities = ParentInfo.ROIImageInfo.intensities;

idxs = find(volume <= 0.9);
if ~isempty(idxs)
    Value = intensities(idxs(1));
else
    Value = NaN;
end
null = [];

function [Value, null]=IBSI_IntensityVolumeHistogram_Feature_VolumeFractionDiff(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%

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
null = [];

function [Value, null]=IBSI_IntensityVolumeHistogram_Feature_IntensityFractDiff(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%

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
null = [];

function [Value, null]=IBSI_IntensityVolumeHistogram_Feature_AreaUnderIVHCurve(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%

volume = ParentInfo.ROIImageInfo.counts;
gamma = ParentInfo.ROIImageInfo.gamma;
%intensities = ParentInfo.ROIImageInfo.intensities;

Value = trapz(gamma, volume);
null = [];