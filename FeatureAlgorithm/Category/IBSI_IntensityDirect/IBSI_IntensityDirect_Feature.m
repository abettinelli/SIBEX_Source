function FeatureInfo=IBSI_IntensityDirect_Feature(ParentInfo, FeatureInfo, Mode)

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
        [~, ~,Info]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix, 'InfoID');
        FeatureInfo(i).FeatureValue=[];
        FeatureInfo(i).CatAbbreviation = 'IS';
        FeatureInfo(i).Category = 'Intensity-based statistics';
        FeatureInfo(i).CategoryID = 'UHIW';
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
            [FeatureValue, ~, ~] =GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix,'Value');
        catch
            FeatureValue = [];
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

%----FEATURES
function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityDirect_Feature_Mean(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The intensity mean among all the voxels.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        ImageInfo=ParentInfo.ROIImageInfo;
        BWInfo= ParentInfo.ROIBWInfo;
        
        MaskImageMat=ImageInfo.MaskData(logical(BWInfo.MaskData));
        MaskImageMat=MaskImageMat(:);
        
        if ~isempty(MaskImageMat)
            Value= mean(double(MaskImageMat));
        else
            Value=NaN;
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Mean intensity';
        FeatureInfo.FeatureID   = 'Q4LE';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityDirect_Feature_Variance(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The intensity variance among all the voxels.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        ImageInfo=ParentInfo.ROIImageInfo;
        BWInfo= ParentInfo.ROIBWInfo;
        
        MaskImageMat=ImageInfo.MaskData(logical(BWInfo.MaskData));
        MaskImageMat=MaskImageMat(:);
        
        if ~isempty(MaskImageMat)
            Value= var(double(MaskImageMat), 1); %MODIFICA BETTINELLI: ,1
        else
            Value=NaN;
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Intensity variance';
        FeatureInfo.FeatureID   = 'ECT3';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityDirect_Feature_Skewness(ParentInfo, Param, modality)
%%%Doc Starts%%%
%Measure the  asymmetry of all the voxels' intensity.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        ImageInfo=ParentInfo.ROIImageInfo;
        BWInfo= ParentInfo.ROIBWInfo;
        
        MaskImageMat=ImageInfo.MaskData(logical(BWInfo.MaskData));
        MaskImageMat=MaskImageMat(:);
        
        if ~isempty(MaskImageMat)
            Value=skewness(double(MaskImageMat));
        else
            Value=NaN;
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Intensity skewness';
        FeatureInfo.FeatureID   = 'KE2A';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityDirect_Feature_Kurtosis(ParentInfo, Param, modality)
%%%Doc Starts%%%
%Measure the peakedness of all the voxels' intensity.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        ImageInfo=ParentInfo.ROIImageInfo;
        BWInfo= ParentInfo.ROIBWInfo;
        
        MaskImageMat=ImageInfo.MaskData(logical(BWInfo.MaskData));
        MaskImageMat=MaskImageMat(:);
        
        if ~isempty(MaskImageMat)
            Value=kurtosis(double(MaskImageMat))-3;
        else
            Value=NaN;
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = '(Excess) intensity kurtosis';
        FeatureInfo.FeatureID   = 'IPH6';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityDirect_Feature_Median(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The intensity median among all the voxels.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        ImageInfo=ParentInfo.ROIImageInfo;
        BWInfo= ParentInfo.ROIBWInfo;
        
        MaskImageMat=ImageInfo.MaskData(logical(BWInfo.MaskData));
        MaskImageMat=MaskImageMat(:);
        
        if ~isempty(MaskImageMat)
            Value= median(double(MaskImageMat));
        else
            Value=NaN;
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Median intensity';
        FeatureInfo.FeatureID   = 'Y12H';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityDirect_Feature_Min(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The intensity minimum among all the voxels.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        ImageInfo=ParentInfo.ROIImageInfo;
        BWInfo= ParentInfo.ROIBWInfo;
        
        MaskImageMat=ImageInfo.MaskData(logical(BWInfo.MaskData));
        MaskImageMat=MaskImageMat(:);
        
        if ~isempty(MaskImageMat)
            Value= min(double(MaskImageMat));
        else
            Value=NaN;
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Minimum intensity';
        FeatureInfo.FeatureID   = '1GSF';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityDirect_Feature_10thPercentile(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Description:
%10th percentile of the intensity values among all the voxels.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, '10thPercentile');
    case 'InfoID'
        FeatureInfo.FeatureName = '10th intensity percentile';
        FeatureInfo.FeatureID   = 'QG58';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityDirect_Feature_90thPercentile(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Description:
%90th percentile of the intensity values among all the voxels.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, '90thPercentile');
    case 'InfoID'
        FeatureInfo.FeatureName = '90th intensity percentile';
        FeatureInfo.FeatureID   = '8DWT';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityDirect_Feature_Max(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The intensity maximum among all the voxels.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        ImageInfo=ParentInfo.ROIImageInfo;
        BWInfo= ParentInfo.ROIBWInfo;
        
        MaskImageMat=ImageInfo.MaskData(logical(BWInfo.MaskData));
        MaskImageMat=MaskImageMat(:);
        
        if ~isempty(MaskImageMat)
            Value= max(double(MaskImageMat));
        else
            Value=NaN;
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Maximum intensity';
        FeatureInfo.FeatureID   = '84IY';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityDirect_Feature_InterQuartileRange(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The interquartile range of the intensity values among all the voxels.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, 'InterQuartileRange');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Intensity interquartile range';
        FeatureInfo.FeatureID   = 'SALO';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityDirect_Feature_Range(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The intensity range(MaxValue-MinValue) among all the voxels.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        ImageInfo=ParentInfo.ROIImageInfo;
        BWInfo= ParentInfo.ROIBWInfo;
        
        MaskImageMat=ImageInfo.MaskData(logical(BWInfo.MaskData));
        MaskImageMat=MaskImageMat(:);
        
        if ~isempty(MaskImageMat)
            Value= max(double(MaskImageMat))-min(double(MaskImageMat));
        else
            Value=NaN;
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Intensity range';
        FeatureInfo.FeatureID   = '2OJQ';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityDirect_Feature_MeanAbsoluteDeviation(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The mean absolute deviation of the intensity values among all the voxels.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, 'MeanAbsoluteDeviation');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Intensity-based mean absolute deviation';
        FeatureInfo.FeatureID   = '4FUA';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityDirect_Feature_RobustMeanAbsoluteDeviation(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The robust mean absolute deviation of the intensity values among all the voxels.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, 'RobustMeanAbsoluteDeviation');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Intensity-based robust mean absolute deviation';
        FeatureInfo.FeatureID   = '1128';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityDirect_Feature_MedianAbsoluteDeviation(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The median absolute deviation of the intensity values among all the voxels.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, 'MedianAbsoluteDeviation');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Intensity-based median absolute deviation';
        FeatureInfo.FeatureID   = 'N72L';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityDirect_Feature_CoefficientOfVariation(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The coefficient of variation of the intensity values among all the voxels.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, 'CoefficientOfVariation');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Intensity-based coefficient of variation';
        FeatureInfo.FeatureID   = '7TET';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityDirect_Feature_QuartileCoefficientOfDispersion(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The quartile coefficient of dispersion of the intensity values among all the voxels.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, 'QuartileCoefficientOfDispersion');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Intensity-based quartile coefficient of dispersion';
        FeatureInfo.FeatureID   = '9S40';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityDirect_Feature_Energy(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The energy of the intensity values among all the voxels.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        ImageInfo=ParentInfo.ROIImageInfo;
        BWInfo= ParentInfo.ROIBWInfo;
        
        MaskImageMat=ImageInfo.MaskData(logical(BWInfo.MaskData));
        MaskImageMat=MaskImageMat(:);
        
        if ~isempty(MaskImageMat)
            Value= sum((double(MaskImageMat)).^2); %%the orig (voldep form)
            %Value=  sum((double(MaskImageMat)).^2)/sum(BWInfo.MaskData(:)); %% XF volindep version(dividing by num of vox)
        else
            Value=NaN;
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Intensity-based energy';
        FeatureInfo.FeatureID   = 'N8CA';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityDirect_Feature_RootMeanSquare(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The root mean square of the intensity values among all the voxels.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        ImageInfo=ParentInfo.ROIImageInfo;
        BWInfo= ParentInfo.ROIBWInfo;
        
        MaskImageMat=ImageInfo.MaskData(logical(BWInfo.MaskData));
        MaskImageMat=MaskImageMat(:);
        
        if ~isempty(MaskImageMat)
            Value= sqrt(mean((double(MaskImageMat)).^2));
        else
            Value=NaN;
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Root mean square intensity';
        FeatureInfo.FeatureID   = '5ZWQ';
end


function [Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, Mode)
ImageInfo=ParentInfo.ROIImageInfo;
BWInfo= ParentInfo.ROIBWInfo;

MaskImageMat=ImageInfo.MaskData(logical(BWInfo.MaskData));
MaskImageMat=double(MaskImageMat(:));

ReviewInfo=ParentInfo.ROIImageInfo;

switch Mode
    case 'Skewness'
        Value = skewness(MaskImageMat);
        ReviewInfo.Value=Value;
    case 'Kurtosis'
        Value = kurtosis(MaskImageMat);
        ReviewInfo.Value=Value;
    case 'Range'
        Value = range(MaskImageMat);
        ReviewInfo.Value=Value;
    case 'MeanAbsoluteDeviation'
        Value = mad(MaskImageMat, 0);
        ReviewInfo.Value=Value;
    case 'RobustMeanAbsoluteDeviation'
        pr_10 = my_prctile(MaskImageMat, 10);
        pr_90 = my_prctile(MaskImageMat, 90);
        flag = MaskImageMat >= pr_10 & MaskImageMat <= pr_90;
        Value = mad(MaskImageMat(flag), 0);
        ReviewInfo.Value=Value;
    case 'MedianAbsoluteDeviation'
        Value = mad_IBSI(MaskImageMat, 1);
        ReviewInfo.Value=Value;
    case 'CoefficientOfVariation'
        Value = std(MaskImageMat,1)/mean(MaskImageMat);
        ReviewInfo.Value=Value;
    case 'InterQuartileRange'
        Value = iqr(MaskImageMat);
        ReviewInfo.Value=Value;
    case 'Percentile'
        Value = prctile(MaskImageMat, Param.Percentile');
        ReviewInfo.MaskData=[Param.Percentile', Value];
        ReviewInfo.Description='Intensity Percentile';
        Value=[Param.Percentile', Value];
        ReviewInfo.Value=[];
    case '10thPercentile'
        Value = my_prctile(MaskImageMat, 10);
        ReviewInfo.Value=Value;
    case '90thPercentile'
        Value = my_prctile(MaskImageMat, 90);
        ReviewInfo.Value=Value;
    case 'Quantile'
        Value = quantile(MaskImageMat, Param.Quantile');
        ReviewInfo.MaskData=[Param.Quantile', Value];
        ReviewInfo.Description='Intensity Quantile';
        
        Value=[Param.Quantile', Value];
        ReviewInfo.Value=[];
    case 'QuartileCoefficientOfDispersion'
        Num = my_prctile(MaskImageMat, 75) - my_prctile(MaskImageMat, 25);
        Den = my_prctile(MaskImageMat, 75) + my_prctile(MaskImageMat, 25);
        Value = Num/Den;
        ReviewInfo.Value=Value;
end

%--- Non IBSI features

% function [Value, ReviewInfo]=IBSI_IntensityDirect_Feature_Std(ParentInfo, Param)
% %%%Doc Starts%%%
% %The intensity standard deviation among all the voxels.
% %%%Doc Ends%%%
% ImageInfo=ParentInfo.ROIImageInfo;
% BWInfo= ParentInfo.ROIBWInfo;
%
% MaskImageMat=ImageInfo.MaskData(logical(BWInfo.MaskData));
% MaskImageMat=MaskImageMat(:);
%
% if ~isempty(MaskImageMat)
%     Value=std(double(MaskImageMat), 1); %MODIFICA BETTINELLI: ,1
% else
%     Value=NaN;
% end
%
% ReviewInfo.MaskData=Value;
%
% function [Value, ReviewInfo]=IBSI_IntensityDirect_Feature_Percentile(ParentInfo, Param)
% %%%Doc Starts%%%
% %-Description:
% %Percentiles of the intensity values among all the voxels.
%
% %-Parameters:
% %1.  Percentile: Percent values.
% %%%Doc Ends%%%
% [Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, 'Percentile');
%
% function [Value, ReviewInfo]=IBSI_IntensityDirect_Feature_Quantile(ParentInfo, Param)
% %%%Doc Starts%%%
% %-Description:
% %Quantiles of the intensity values among all the voxels.
%
% %-Parameters:
% %1.  Quantile: Cumulative probability values.
% %%%Doc Ends%%%
% [Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, 'Quantile');
%
% function [Value, ReviewInfo]=IBSI_IntensityDirect_Feature_EnergyNorm(ParentInfo, Param)
% %%%Doc Starts%%%
% %--Reference:
% %1. Hugo J. W, Sara Cavalho, et al. Decoding tumour phenotype by noninvasive imaging using a quantitative radiomics approach.
% %   Nat. Commun. 2014; 5: 4006.
% %2. http://www.nature.com/ncomms/2014/140603/ncomms5006/extref/ncomms5006-s1.pdf
% %3. Fave, X. et al. Impact of image preprocessing on the volume dependence and prognostic potential of radiomics features in non-small cell lung cancer. Translational Cancer Research 5, 349-363 (2016).
% %%%Doc Ends%%%
% ImageInfo=ParentInfo.ROIImageInfo;
% BWInfo= ParentInfo.ROIBWInfo;
%
% MaskImageMat=ImageInfo.MaskData(logical(BWInfo.MaskData));
% MaskImageMat=MaskImageMat(:);
%
% if ~isempty(MaskImageMat)
%     %Value= sum((double(MaskImageMat)).^2); %%the orig (voldep form)
%     Value=  sum((double(MaskImageMat)).^2)/sum(BWInfo.MaskData(:)); %% XF volindep version(dividing by num of vox)
% else
%     Value=NaN;
% end
%
% ReviewInfo.MaskData=Value;

