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
    if isequal(Mode, 'Review')
        [FeatureValue, FeatureReviewInfo]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix);
        FeatureInfo(i).FeatureValue=FeatureValue;
        FeatureInfo(i).FeatureReviewInfo=FeatureReviewInfo;
    else
        FeatureValue=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix);               
        
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

function [FeatureValue, FeatureReviewInfo]=GetFeatureValue(ParentInfo, CurrentFeatureInfo,  FeaturePrefix)
FeatureName=CurrentFeatureInfo.Name;

FuncName=[FeaturePrefix, '_', FeatureName];
FuncHandle=str2func(FuncName);

[FeatureValue, FeatureReviewInfo]=FuncHandle(ParentInfo, CurrentFeatureInfo.Value);

%----FEATURES
function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_Mean(ParentInfo, Param)
%%%Doc Starts%%%
%The mean of discretised voxel intensities.
%%%Doc Ends%%%
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

function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_Variance(ParentInfo, Param)
%%%Doc Starts%%%
%The variance of discretised voxel intensities.
%%%Doc Ends%%%
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

function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_Skewness(ParentInfo, Param)
%%%Doc Starts%%%
%Measure the  asymmetry of all the discretized voxels' intensity.
%%%Doc Ends%%%
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

function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_Kurtosis(ParentInfo, Param)
%%%Doc Starts%%%
%Measure the peakedness of all the discretized voxels' intensity.
%%%Doc Ends%%%
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

function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_Median(ParentInfo, Param)
%%%Doc Starts%%%
%The intensity median among all the discretized voxel intensities.
%%%Doc Ends%%%
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

function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_Min(ParentInfo, Param)
%%%Doc Starts%%%
%The intensity minimum among all the discretized voxel intensities.
%%%Doc Ends%%%
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

function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_10thPercentile(ParentInfo, Param)
%%%Doc Starts%%%
%10th percentile of the intensity values among all the discretized voxel intensities.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, '10thPercentile');

function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_90thPercentile(ParentInfo, Param)
%%%Doc Starts%%%
%-Description: 
%90th percentile of the intensity values among all the discretized voxel intensities.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, '90thPercentile');

function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_Max(ParentInfo, Param)
%%%Doc Starts%%%
%The intensity maximum among all the discretized voxel intensities.
%%%Doc Ends%%%
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

function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_Mode(ParentInfo, Param)
%%%Doc Starts%%%
%The intensity mode among all the discretized voxel intensities.
%%%Doc Ends%%%
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

function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_InterQuartileRange(ParentInfo, Param)
%%%Doc Starts%%%
%The interquartile range of the intensity values among all the discretized voxel intensities.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, 'InterQuartileRange');

function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_Range(ParentInfo, Param)
%%%Doc Starts%%%
%The intensity range(MaxValue-MinValue) among all the discretized voxel intensities.
%%%Doc Ends%%%
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

function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_MeanAbsoluteDeviation(ParentInfo, Param)
%%%Doc Starts%%%
%The mean absolute deviation of the intensity values among all the discretized voxel intensities.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, 'MeanAbsoluteDeviation');

function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_RobustMeanAbsoluteDeviation(ParentInfo, Param)
%%%Doc Starts%%%
%The robust mean absolute deviation of the intensity values among all the discretized voxel intensities.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, 'RobustMeanAbsoluteDeviation');

function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_MedianAbsoluteDeviation(ParentInfo, Param)
%%%Doc Starts%%%
%The median absolute deviation of the intensity values among all the discretized voxel intensities.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, 'MedianAbsoluteDeviation');

function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_CoefficientOfVariation(ParentInfo, Param)
%%%Doc Starts%%%
%The coefficient of variation of the intensity values among all the discretized voxel intensities.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, 'CoefficientOfVariation');

function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_QuartileCoefficientOfDispersion(ParentInfo, Param)
%%%Doc Starts%%%
%The quartile coefficient of dispersion of the intensity values among all the discretized voxel intensities.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeStatFeature(ParentInfo, Param, 'QuartileCoefficientOfDispersion');

function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_Entropy(ParentInfo, Param)
%%%Doc Starts%%%
%The energy of the intensity values among all the discretized voxel intensities.
%%%Doc Ends%%%

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

function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_Uniformity(ParentInfo, Param)
%%%Doc Starts%%%
%The uniformity of the intensity values among all the discretized voxel intensities.
%%%Doc Ends%%%

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

function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_MaximumHistogramGradient(ParentInfo, Param)
%%%Doc Starts%%%
%The maximum of the histogram gradient.
%%%Doc Ends%%%

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
                            
function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_MaximumHistogramGradientGL(ParentInfo, Param)
%%%Doc Starts%%%
% The discretised intensity corresponding to the maximum histogram gradient.
%%%Doc Ends%%%

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

function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_MinimumHistogramGradient(ParentInfo, Param)
%%%Doc Starts%%%
%The minimum of the histogram gradient.
%%%Doc Ends%%%

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

function [Value, ReviewInfo]=IBSI_IntensityHistogram_Feature_MinimumHistogramGradientGL(ParentInfo, Param)
%%%Doc Starts%%%
% The discretised intensity corresponding to the minimum histogram gradient.
%%%Doc Ends%%%

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