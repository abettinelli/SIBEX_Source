function FeatureInfo=Template_Feature(ParentInfo, FeatureInfo, Mode)
%Purpose:       To implement a feature, two files are needed. 
                       %*CategoryName*_Category.m: to calculate the ParentInfo from DateItemInfo to be used in *CategoryName*_Feature.m.
                       %*CategoryName*_Feature.m:   to calcuate the features using the same ParentInfo that is output from *CategoryName*_Category.m. 
                       %Feature names are describled in the declaration of feature caculation function in *CategoryName*_Feature.m.
                       %Naming Convention of feaure caculation functions:  *CategoryName*_Feature_*FeatureName*
%Architecture: All the feature-relevant files are under \IBEXCodePath\FeatureAlgorithm\Category\*CategoryName*\.
%Files:            *CategoryName*_Feature.m, *CategoryName*_Feature.INI

%%---------------Input Parameters Passed In By IBEX-------------%
%ParentInfo:      The structure from *CategoryName*_Category.m and all features are caculated from this ParentInfo.
%FeatureInfo:    The structure containing the feature info.
                         %length(FeatureInfo): the number of features
                         %FeatureInfo.Name: Feature Name  
                         %FeatureInfo.Value:  Parameters from GUI or from *CategoryName*_Feature_*FeatureName*.INI                         
%Mode:             Three Statuses.                          
                          %'ParseFeature': FeatureInfo is the feature name list.
                          %'Review':         FeatureInfo is the ReviewInfo to be reviewed when press "Test" button.
                          %'NoReview':    FeatureInfo contains the value of the features
                          
%%--------------Output Parameters------------%
%FeatureInfo:    The structure containing the feature info.
                         %length(FeatureInfo): the number of features
                         %FeatureInfo.Name: Feature Name  
                         %FeatureInfo.Value:  Parameters from GUI or from *CategoryName*_Feature_*FeatureName*.INI
                         %FeatureInfo.FeatureValue: value of the features( for Mode == 'Review' or Mode == 'NoReview')

%///////////////////////////////////////////////////////////////////////////////////////////////////////////////////%
%-----------------------------DO_NOT_CHANGE_STARTS--------------------------%
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

ParentInfo.Mode=Mode;

for i=1:length(FeatureInfo)
    if isequal(Mode, 'Review')
        [FeatureValue, FeatureReviewInfo]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix);
        
        FeatureInfo(i).FeatureValue=FeatureValue;
        FeatureInfo(i).FeatureReviewInfo=FeatureReviewInfo;
    else
        FeatureValue=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix);
        
        if ~isstruct(FeatureValue)        
             if length(FeatureValue) > 1
                FeatureInfo(i).FeatureValueParam=FeatureValue(:, 1);
                FeatureInfo(i).FeatureValue=FeatureValue(:, 2);
            else
                FeatureInfo(i).FeatureValue=FeatureValue;
            end
        else
            %Handle a group of feature caculated for the same buffer data
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
%-----------------------------DO_NOT_CHANGE_ENDS------------------------------%
%///////////////////////////////////////////////////////////////////////////////////////////////////////////////////%


%///////////////////////////////////////////////////////////////////////////////////////////////////////////////////%
%%------------------------Implement your code starting from here--------------------%
%Feature: GlobalMax
function [Value, ReviewInfo]=Template_Feature_GlobalMax(ParentInfo, Param)
%%%Doc Starts%%%
%The skeleton feature returns intensity maximum of ROI image data
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
