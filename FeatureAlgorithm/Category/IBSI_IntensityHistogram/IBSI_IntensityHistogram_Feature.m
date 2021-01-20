function FeatureInfo=IBSI_IntensityHistogram_Feature(ParentInfo, FeatureInfo, Mode)

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
        FeatureInfo(i).CatAbbreviation = 'IH';
        FeatureInfo(i).Category = 'Intensity histogram';
        FeatureInfo(i).CategoryID = 'ZVCW';
        FeatureInfo(i).FeatureName=Info.FeatureName;
        FeatureInfo(i).FeatureID=Info.FeatureID;
        FeatureInfo(i).AggregationMethod = '';
        FeatureInfo(i).AggregationMethodID = 'DHQ4';
    elseif isequal(Mode, 'Review')
        % Review Info
        [FeatureValue, FeatureReviewInfo]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix, 'Value');
        FeatureInfo(i).FeatureValue=FeatureValue;
        FeatureInfo(i).FeatureReviewInfo=FeatureReviewInfo;
    else
        % Calculate Feature Value
        try
            [FeatureValue, ~,~]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix, 'Value');
        catch
            FeatureValue=[];
        end
        
        if ~isstruct(FeatureValue)	%handle buffer data or not
            if length(FeatureValue) > 1
                FeatureInfo(i).FeatureValueParam=FeatureValue(:, 1);
                FeatureInfo(i).FeatureValue=FeatureValue(:, 2);
            else
                FeatureInfo(i).FeatureValue=FeatureValue;
            end
        else	%Handle a group of feature
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
function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_Mean(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The mean of discretised voxel intensities.
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
        FeatureInfo.FeatureName = 'Mean discretised intensity';
        FeatureInfo.FeatureID   = 'X6K6';
end


function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_Variance(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The variance of discretised voxel intensities.
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
        FeatureInfo.FeatureName = 'Discretised intensity variance';
        FeatureInfo.FeatureID   = 'CH89';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_Skewness(ParentInfo, Param, modality)
%%%Doc Starts%%%
%Measure the  asymmetry of all the discretized voxels' intensity.
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
        FeatureInfo.FeatureName = 'Discretised intensity skewness';
        FeatureInfo.FeatureID   = '88K1';
end


function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_Kurtosis(ParentInfo, Param, modality)
%%%Doc Starts%%%
%Measure the peakedness of all the discretized voxels' intensity.
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
        FeatureInfo.FeatureName = '(Excess) discretised intensity kurtosis';
        FeatureInfo.FeatureID   = 'C3I7';
end


function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_Median(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The intensity median among all the discretized voxel intensities.
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
        FeatureInfo.FeatureName = 'Median discretised intensity';
        FeatureInfo.FeatureID   = 'WIFQ';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_Min(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The intensity minimum among all the discretized voxel intensities.
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
        FeatureInfo.FeatureName = 'Minimum discretised intensity';
        FeatureInfo.FeatureID   = '1PR8';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_10thPercentile(ParentInfo, Param, modality)
%%%Doc Starts%%%
%10th percentile of the intensity values among all the discretized voxel intensities.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, '10thPercentile');
    case 'InfoID'
        FeatureInfo.FeatureName = '10th discretised intensity percentile';
        FeatureInfo.FeatureID   = 'GPMT';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_90thPercentile(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Description:
%90th percentile of the intensity values among all the discretized voxel intensities.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, '90thPercentile');
    case 'InfoID'
        FeatureInfo.FeatureName = '90th discretised intensity percentile';
        FeatureInfo.FeatureID   = 'OZ0C';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_Max(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The intensity maximum among all the discretized voxel intensities.
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
        FeatureInfo.FeatureName = 'Maximum discretised intensity';
        FeatureInfo.FeatureID   = '3NCY';
end


function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_Mode(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The intensity mode among all the discretized voxel intensities.
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
            Value= mode(double(MaskImageMat));
        else
            Value=NaN;
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Intensity histogram mode';
        FeatureInfo.FeatureID   = 'AMMC';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_InterQuartileRange(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The interquartile range of the intensity values among all the discretized voxel intensities.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, 'InterQuartileRange');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Discretised intensity interquartile range';
        FeatureInfo.FeatureID   = 'WR0O';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_Range(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The intensity range(MaxValue-MinValue) among all the discretized voxel intensities.
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
        FeatureInfo.FeatureName = 'Discretised intensity range';
        FeatureInfo.FeatureID   = '5Z3W';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_MeanAbsoluteDeviation(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The mean absolute deviation of the intensity values among all the discretized voxel intensities.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, 'MeanAbsoluteDeviation');
        
    case 'InfoID'
        FeatureInfo.FeatureName = 'Intensity histogram mean absolute deviation';
        FeatureInfo.FeatureID   = 'D2ZX';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_RobustMeanAbsoluteDeviation(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The robust mean absolute deviation of the intensity values among all the discretized voxel intensities.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, 'RobustMeanAbsoluteDeviation');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Intensity histogram robust mean absolute deviation';
        FeatureInfo.FeatureID   = 'WRZB';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_MedianAbsoluteDeviation(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The median absolute deviation of the intensity values among all the discretized voxel intensities.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, 'MedianAbsoluteDeviation');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Intensity histogram median absolute deviation';
        FeatureInfo.FeatureID   = '4RNL';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_CoefficientOfVariation(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The coefficient of variation of the intensity values among all the discretized voxel intensities.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, 'CoefficientOfVariation');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Intensity histogram coefficient of variation';
        FeatureInfo.FeatureID   = 'CWYJ';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_QuartileCoefficientOfDispersion(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The quartile coefficient of dispersion of the intensity values among all the discretized voxel intensities.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, 'QuartileCoefficientOfDispersion');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Intensity histogram quartile coefficient of dispersion';
        FeatureInfo.FeatureID   = 'SLWD';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_Entropy(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The energy of the intensity values among all the discretized voxel intensities.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        ImageInfo=ParentInfo.ROIImageInfo;
        BWInfo= ParentInfo.ROIBWInfo;
        
        MaskImageMat=ImageInfo.MaskData(logical(BWInfo.MaskData));
        MaskImageMat=double(MaskImageMat(:));
        
        if ~isempty(MaskImageMat)
            % Build the probabilities vector
            MaskImageMat_uni = unique(MaskImageMat);
            MaskImageMat_uni_size = numel(MaskImageMat_uni);
            P = zeros(MaskImageMat_uni_size,1);
            for i = 1:MaskImageMat_uni_size
                P(i) = sum(MaskImageMat == MaskImageMat_uni(i));
            end
            P = P ./ numel(MaskImageMat);
            
            % Shannon's Entropy
            Value = -sum(P .* log2(P));
        else
            Value=NaN;
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Discretised intensity entropy';
        FeatureInfo.FeatureID   = 'TLU2';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_Uniformity(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The uniformity of the intensity values among all the discretized voxel intensities.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        ImageInfo=ParentInfo.ROIImageInfo;
        BWInfo= ParentInfo.ROIBWInfo;
        
        MaskImageMat=ImageInfo.MaskData(logical(BWInfo.MaskData));
        MaskImageMat=double(MaskImageMat(:));
        
        if ~isempty(MaskImageMat)
            uninque_values = unique(MaskImageMat);
            temp = zeros(length(uninque_values),1);
            for n = 1:length(unique(MaskImageMat))
                temp(n) = sum(MaskImageMat==uninque_values(n));
            end
            p = temp./length(MaskImageMat);
            
            Value = sum(p.^2);
        else
            Value=NaN;
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Discretised intensity uniformity';
        FeatureInfo.FeatureID   = 'BJ5W';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_MaximumHistogramGradient(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The maximum of the histogram gradient.
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
            [H_g, ~] = histogram_gradient(double(MaskImageMat));
            Value = max(H_g);
        else
            Value=NaN;
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Maximum histogram gradient';
        FeatureInfo.FeatureID   = '12CE';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_MaximumHistogramGradientGL(ParentInfo, Param, modality)
%%%Doc Starts%%%
% The discretised intensity corresponding to the maximum histogram gradient.
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
            [H_g, levels] = histogram_gradient(double(MaskImageMat));
            [~, idx] = max(H_g);
            Value = levels(idx);
        else
            Value=NaN;
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Maximum histogram gradient intensity';
        FeatureInfo.FeatureID   = '8E6O';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_MinimumHistogramGradient(ParentInfo, Param, modality)
%%%Doc Starts%%%
%The minimum of the histogram gradient.
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
            [H_g, ~] = histogram_gradient(double(MaskImageMat));
            Value = min(H_g);
        else
            Value=NaN;
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Minimum histogram gradient';
        FeatureInfo.FeatureID   = 'VQB3';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_IntensityHistogram_Feature_MinimumHistogramGradientGL(ParentInfo, Param, modality)
%%%Doc Starts%%%
% The discretised intensity corresponding to the minimum histogram gradient.
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
            [H_g, levels] = histogram_gradient(double(MaskImageMat));
            [~, idx] = min(H_g);
            Value = levels(idx);
        else
            Value=NaN;
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Minimum histogram gradient intensity';
        FeatureInfo.FeatureID   = 'RHQZ';
end


function [Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, Mode)
ImageInfo=ParentInfo.ROIImageInfo;
BWInfo= ParentInfo.ROIBWInfo;

MaskImageMat=ImageInfo.MaskData(logical(BWInfo.MaskData));
MaskImageMat=double(MaskImageMat(:));

ReviewInfo=ParentInfo.ROIImageInfo;

switch Mode
    case  'Skewness'
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

% function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_Std(ParentInfo, Param)
% ImageInfo=ParentInfo.ROIImageInfo;
% BWInfo= ParentInfo.ROIBWInfo;
%
% MaskImageMat=ImageInfo.MaskData(logical(BWInfo.MaskData));
% MaskImageMat=MaskImageMat(:);
%
% if ~isempty(MaskImageMat)
%     Value=std(double(MaskImageMat));
% else
%     Value=NaN;
% end
%
% ReviewInfo.MaskData=Value;
%
% function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_EnergyNorm(ParentInfo, Param)
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
%
% function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_RootMeanSquare(ParentInfo, Param)
% ImageInfo=ParentInfo.ROIImageInfo;
% BWInfo= ParentInfo.ROIBWInfo;
%
% MaskImageMat=ImageInfo.MaskData(logical(BWInfo.MaskData));
% MaskImageMat=MaskImageMat(:);
%
% if ~isempty(MaskImageMat)
%     Value= sqrt(mean((double(MaskImageMat)).^2));
% else
%     Value=NaN;
% end
%
% ReviewInfo.MaskData=Value;