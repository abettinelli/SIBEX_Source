function FeatureInfo=IBSI_GrayLevelCooccurenceMatrix_Feature(ParentInfo, FeatureInfo, Mode)

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
        FeatureInfo(i).CatAbbreviation = 'GLCM';
        FeatureInfo(i).Category = 'Grey level co-occurrence matrix';
        FeatureInfo(i).CategoryID = 'LFYI';
        FeatureInfo(i).FeatureName=Info.FeatureName;
        FeatureInfo(i).FeatureID=Info.FeatureID;
        switch ParentInfo.AggregationMethod
            case 1
                FeatureInfo(i).AggregationMethod = '2D:avg';
                FeatureInfo(i).AggregationMethodID = 'BTW3';
            case 2
                FeatureInfo(i).AggregationMethod = '2D:smrg';
                FeatureInfo(i).AggregationMethodID = 'SUJT';
            case 6
                FeatureInfo(i).AggregationMethod = '2.5D:dmrg';
                FeatureInfo(i).AggregationMethodID = 'JJUI';
            case 3
                FeatureInfo(i).AggregationMethod = '2.5D:vmrg';
                FeatureInfo(i).AggregationMethodID = 'ZW7Z';
            case 4
                FeatureInfo(i).AggregationMethod = '3D:avg';
                FeatureInfo(i).AggregationMethodID = 'ITBB';
            case 5
                FeatureInfo(i).AggregationMethod = '3D:mrg';
                FeatureInfo(i).AggregationMethodID = 'IAZD';
        end
        
    elseif isequal(Mode, 'Review')
        [FeatureValue, FeatureReviewInfo]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix,'Value');
        FeatureInfo(i).FeatureValue=FeatureValue;
        FeatureInfo(i).FeatureReviewInfo=FeatureReviewInfo;
    else
        try
            [FeatureValue, ~, ~]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix,'Value');
        catch
            FeatureValue = [];
        end
        
        if size(FeatureValue,2) > 1
            FeatureInfo(i).FeatureValueParam='GLCM';
            if size(FeatureValue,2) > 2
                % FeatureInfo(i).FeatureValue= [FeatureValue(2:end, 1), nanmean(FeatureValue(2:end, 2:end),2)]; % nanmean instead of mean
                FeatureInfo(i).FeatureValue= [FeatureValue(:, 1), nanmean(FeatureValue(:, 2:end),2)]; % nanmean instead of mean
            else
                % FeatureInfo(i).FeatureValue=[FeatureValue(2:end, 1), FeatureValue(2:end, 2)];
                FeatureInfo(i).FeatureValue=[FeatureValue(:, 1), FeatureValue(:, 2)];
            end
            
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

%----FEATURES
function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_JointMaximum(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Reference:
%1. L. Soh and C. Tsatsoulis. Texture analysis of sar sea ice imagery using gray level co-occurances matrices.
%    IEEE Trans. on Geoscience and Remote Sensing, 37(2):780–795, 1999
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'JointMaximum');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Joint maximum';
        FeatureInfo.FeatureID   = 'GYBY';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_JointAverage(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Reference:
%1. L. Soh and C. Tsatsoulis. Texture analysis of sar sea ice imagery using gray level co-occurances matrices.
%    IEEE Trans. on Geoscience and Remote Sensing, 37(2):780–795, 1999
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'JointAverage');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Joint average';
        FeatureInfo.FeatureID   = '60VM';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_JointVariance(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Reference:
%1. Hugo J. W, Sara Cavalho, et al. Decoding tumour phenotype by noninvasive imaging using a quantitative radiomics approach.
%   Nat. Commun. 2014; 5: 4006.
%2. http://www.nature.com/ncomms/2014/140603/ncomms5006/extref/ncomms5006-s1.pdf
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'JointVariance');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Joint variance';
        FeatureInfo.FeatureID   = 'UR99';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_JointEntropy(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Reference:
%1. L. Soh and C. Tsatsoulis. Texture analysis of sar sea ice imagery using gray level co-occurances matrices.
%    IEEE Trans. on Geoscience and Remote Sensing, 37(2):780–795, 1999
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'JointEntropy');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Joint entropy';
        FeatureInfo.FeatureID   = 'TU9B';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_DifferenceAverage(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Reference:
%1. Haralick, R.M., K. Shanmugan, and I. Dinstein, "Textural Features for Image Classification",
%    IEEE Transactions on Systems, Man, and Cybernetics, Vol. SMC-3, 1973, pp. 610-621.
%2. http://murphylab.web.cmu.edu/publications/boland/boland_node26.html
%3. Hugo J. W, Sara Cavalho, et al. Decoding tumour phenotype by noninvasive imaging using a quantitative radiomics approach.
%   Nat. Commun. 2014; 5: 4006.
%4. http://www.nature.com/ncomms/2014/140603/ncomms5006/extref/ncomms5006-s1.pdf
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'DifferenceAverage');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Difference average';
        FeatureInfo.FeatureID   = 'TF7R';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_DifferenceVariance(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Reference:
%1. Haralick, R.M., K. Shanmugan, and I. Dinstein, "Textural Features for Image Classification",
%    IEEE Transactions on Systems, Man, and Cybernetics, Vol. SMC-3, 1973, pp. 610-621.
%2. http://murphylab.web.cmu.edu/publications/boland/boland_node26.html
%3. Hugo J. W, Sara Cavalho, et al. Decoding tumour phenotype by noninvasive imaging using a quantitative radiomics approach.
%   Nat. Commun. 2014; 5: 4006.
%4. http://www.nature.com/ncomms/2014/140603/ncomms5006/extref/ncomms5006-s1.pdf
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'DifferenceVariance');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Difference variance';
        FeatureInfo.FeatureID   = 'D3YU';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_DifferenceEntropy(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Reference:
%1. Haralick, R.M., K. Shanmugan, and I. Dinstein, "Textural Features for Image Classification",
%    IEEE Transactions on Systems, Man, and Cybernetics, Vol. SMC-3, 1973, pp. 610-621.
%2. http://murphylab.web.cmu.edu/publications/boland/boland_node26.html
%3. Hugo J. W, Sara Cavalho, et al. Decoding tumour phenotype by noninvasive imaging using a quantitative radiomics approach.
%   Nat. Commun. 2014; 5: 4006.
%4. http://www.nature.com/ncomms/2014/140603/ncomms5006/extref/ncomms5006-s1.pdf
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'DifferenceEntropy');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Difference entropy';
        FeatureInfo.FeatureID   = 'NTRS';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_SumAverage(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Reference:
%1. Haralick, R.M., K. Shanmugan, and I. Dinstein, "Textural Features for Image Classification",
%    IEEE Transactions on Systems, Man, and Cybernetics, Vol. SMC-3, 1973, pp. 610-621.
%2. http://murphylab.web.cmu.edu/publications/boland/boland_node26.html
%3. Hugo J. W, Sara Cavalho, et al. Decoding tumour phenotype by noninvasive imaging using a quantitative radiomics approach.
%   Nat. Commun. 2014; 5: 4006.
%4. http://www.nature.com/ncomms/2014/140603/ncomms5006/extref/ncomms5006-s1.pdf
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'SumAverage');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Sum average';
        FeatureInfo.FeatureID   = 'ZGXS';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_SumVariance(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Reference:
%1. Haralick, R.M., K. Shanmugan, and I. Dinstein, "Textural Features for Image Classification",
%    IEEE Transactions on Systems, Man, and Cybernetics, Vol. SMC-3, 1973, pp. 610-621.
%2. http://murphylab.web.cmu.edu/publications/boland/boland_node26.html
%3. Hugo J. W, Sara Cavalho, et al. Decoding tumour phenotype by noninvasive imaging using a quantitative radiomics approach.
%   Nat. Commun. 2014; 5: 4006.
%4. http://www.nature.com/ncomms/2014/140603/ncomms5006/extref/ncomms5006-s1.pdf
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'SumVariance');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Sum variance';
        FeatureInfo.FeatureID   = 'OEEB';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_SumEntropy(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Reference:
%1. Haralick, R.M., K. Shanmugan, and I. Dinstein, "Textural Features for Image Classification",
%    IEEE Transactions on Systems, Man, and Cybernetics, Vol. SMC-3, 1973, pp. 610-621.
%2. http://murphylab.web.cmu.edu/publications/boland/boland_node26.html
%3. Hugo J. W, Sara Cavalho, et al. Decoding tumour phenotype by noninvasive imaging using a quantitative radiomics approach.
%   Nat. Commun. 2014; 5: 4006.
%4. http://www.nature.com/ncomms/2014/140603/ncomms5006/extref/ncomms5006-s1.pdf
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'SumEntropy');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Sum entropy';
        FeatureInfo.FeatureID   = 'P6QZ';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_AngularSecondMoment(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Description:
% For the feature description, refer to the documentation on MATLAB function "graycoprops".

%-Reference:
%1. Haralick, R.M., K. Shanmugan, and I. Dinstein, "Textural Features for Image Classification",
%    IEEE Transactions on Systems, Man, and Cybernetics, Vol. SMC-3, 1973, pp. 610-621.
%2.  Haralick, R.M., and L.G. Shapiro. Computer and Robot Vision: Vol. 1, Addison-Wesley, 1992, p. 459.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'Energy');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Angular second moment';
        FeatureInfo.FeatureID   = '8ZQL';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_Contrast(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Description:
% For the feature description, refer to the documentation on MATLAB function "graycoprops".

%-Reference:
%1. Haralick, R.M., K. Shanmugan, and I. Dinstein, "Textural Features for Image Classification",
%    IEEE Transactions on Systems, Man, and Cybernetics, Vol. SMC-3, 1973, pp. 610-621.
%2.  Haralick, R.M., and L.G. Shapiro. Computer and Robot Vision: Vol. 1, Addison-Wesley, 1992, p. 459.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'Contrast');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Contrast';
        FeatureInfo.FeatureID   = 'ACUI';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_Dissimilarity(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Reference:
%1. L. Soh and C. Tsatsoulis. Texture analysis of sar sea ice imagery using gray level co-occurances matrices.
%    IEEE Trans. on Geoscience and Remote Sensing, 37(2):780–795, 1999
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'Dissimilarity');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Dissimilarity';
        FeatureInfo.FeatureID   = '8S9J';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_InverseDifference(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Description:
% 1.   This feature is equivalent to Homogeneity1 in Hugo's paper.
% 2.  For the feature description, refer to the documentation on MATLAB function "graycoprops".

%-Reference:
%1. Haralick, R.M., K. Shanmugan, and I. Dinstein, "Textural Features for Image Classification",
%    IEEE Transactions on Systems, Man, and Cybernetics, Vol. SMC-3, 1973, pp. 610-621.
%2.  Haralick, R.M., and L.G. Shapiro. Computer and Robot Vision: Vol. 1, Addison-Wesley, 1992, p. 459.
%3. Hugo J. W, Sara Cavalho, et al. Decoding tumour phenotype by noninvasive imaging using a quantitative radiomics approach.
%   Nat. Commun. 2014; 5: 4006.
%4. http://www.nature.com/ncomms/2014/140603/ncomms5006/extref/ncomms5006-s1.pdf
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'Homogeneity');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Inverse difference';
        FeatureInfo.FeatureID   = 'IB1Z';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_InverseDiffNorm(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Reference:
%1. Haralick, R.M., K. Shanmugan, and I. Dinstein, "Textural Features for Image Classification",
%    IEEE Transactions on Systems, Man, and Cybernetics, Vol. SMC-3, 1973, pp. 610-621.
%2. http://murphylab.web.cmu.edu/publications/boland/boland_node26.html
%3. Hugo J. W, Sara Cavalho, et al. Decoding tumour phenotype by noninvasive imaging using a quantitative radiomics approach.
%   Nat. Commun. 2014; 5: 4006.
%4. http://www.nature.com/ncomms/2014/140603/ncomms5006/extref/ncomms5006-s1.pdf
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'InverseDiffNorm');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Normalised inverse difference';
        FeatureInfo.FeatureID   = 'NDRX';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_InverseDiffMoment(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Reference:
%1. Haralick, R.M., K. Shanmugan, and I. Dinstein, "Textural Features for Image Classification",
%    IEEE Transactions on Systems, Man, and Cybernetics, Vol. SMC-3, 1973, pp. 610-621.
%2. http://murphylab.web.cmu.edu/publications/boland/boland_node26.html
%3. Hugo J. W, Sara Cavalho, et al. Decoding tumour phenotype by noninvasive imaging using a quantitative radiomics approach.
%   Nat. Commun. 2014; 5: 4006.
%4. http://www.nature.com/ncomms/2014/140603/ncomms5006/extref/ncomms5006-s1.pdf
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'InverseDiffMoment');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Inverse difference moment';
        FeatureInfo.FeatureID   = 'WF0Z';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_InverseDiffMomentNorm(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Reference:
%1. Haralick, R.M., K. Shanmugan, and I. Dinstein, "Textural Features for Image Classification",
%    IEEE Transactions on Systems, Man, and Cybernetics, Vol. SMC-3, 1973, pp. 610-621.
%2. http://murphylab.web.cmu.edu/publications/boland/boland_node26.html
%3. Hugo J. W, Sara Cavalho, et al. Decoding tumour phenotype by noninvasive imaging using a quantitative radiomics approach.
%   Nat. Commun. 2014; 5: 4006.
%4. http://www.nature.com/ncomms/2014/140603/ncomms5006/extref/ncomms5006-s1.pdf
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'InverseDiffMomentNorm');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Normalised inverse difference moment';
        FeatureInfo.FeatureID   = '1QCO';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_InverseVariance(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Reference:
%1. Hugo J. W, Sara Cavalho, et al. Decoding tumour phenotype by noninvasive imaging using a quantitative radiomics approach.
%   Nat. Commun. 2014; 5: 4006.
%2. http://www.nature.com/ncomms/2014/140603/ncomms5006/extref/ncomms5006-s1.pdf
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'InverseVariance');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Inverse variance';
        FeatureInfo.FeatureID   = 'E8JP';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_Correlation(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Description:
% For the feature description, refer to the documentation on MATLAB function "graycoprops".

%-Reference:
%1. Haralick, R.M., K. Shanmugan, and I. Dinstein, "Textural Features for Image Classification",
%    IEEE Transactions on Systems, Man, and Cybernetics, Vol. SMC-3, 1973, pp. 610-621.
%2.  Haralick, R.M., and L.G. Shapiro. Computer and Robot Vision: Vol. 1, Addison-Wesley, 1992, p. 459.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'Correlation');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Correlation';
        FeatureInfo.FeatureID   = 'NI2N';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_AutoCorrelation(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Reference:
%1. L. Soh and C. Tsatsoulis. Texture analysis of sar sea ice imagery using gray level co-occurances matrices.
%    IEEE Trans. on Geoscience and Remote Sensing, 37(2):780–795, 1999
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'AutoCorrelation');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Autocorrelation';
        FeatureInfo.FeatureID   = 'QWB0';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_ClusterTendendcy(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Reference:
%1. L. Soh and C. Tsatsoulis. Texture analysis of sar sea ice imagery using gray level co-occurances matrices.
%    IEEE Trans. on Geoscience and Remote Sensing, 37(2):780–795, 1999
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'ClusterTendency');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Cluster tendency';
        FeatureInfo.FeatureID   = 'DG8W';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_ClusterShade(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Reference:
%1. L. Soh and C. Tsatsoulis. Texture analysis of sar sea ice imagery using gray level co-occurances matrices.
%    IEEE Trans. on Geoscience and Remote Sensing, 37(2):780–795, 1999
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'ClusterShade');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Cluster shade';
        FeatureInfo.FeatureID   = '7NFM';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_ClusterProminence(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Reference:
%1. L. Soh and C. Tsatsoulis. Texture analysis of sar sea ice imagery using gray level co-occurances matrices.
%    IEEE Trans. on Geoscience and Remote Sensing, 37(2):780–795, 1999
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'ClusterProminence');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Cluster prominence';
        FeatureInfo.FeatureID   = 'AE86';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_InformationMeasureCor1(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Reference:
%1. Haralick, R.M., K. Shanmugan, and I. Dinstein, "Textural Features for Image Classification",
%    IEEE Transactions on Systems, Man, and Cybernetics, Vol. SMC-3, 1973, pp. 610-621.
%2. http://murphylab.web.cmu.edu/publications/boland/boland_node26.html
%3. Hugo J. W, Sara Cavalho, et al. Decoding tumour phenotype by noninvasive imaging using a quantitative radiomics approach.
%   Nat. Commun. 2014; 5: 4006.
%4. http://www.nature.com/ncomms/2014/140603/ncomms5006/extref/ncomms5006-s1.pdf
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'InformationMeasureCorr1');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Information correlation 1';
        FeatureInfo.FeatureID   = 'R8DG';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_GrayLevelCooccurenceMatrix_Feature_InformationMeasureCor2(ParentInfo, Param, modality)
%%%Doc Starts%%%
%-Reference:
%1. Haralick, R.M., K. Shanmugan, and I. Dinstein, "Textural Features for Image Classification",
%    IEEE Transactions on Systems, Man, and Cybernetics, Vol. SMC-3, 1973, pp. 610-621.
%2. http://murphylab.web.cmu.edu/publications/boland/boland_node26.html
%3. Hugo J. W, Sara Cavalho, et al. Decoding tumour phenotype by noninvasive imaging using a quantitative radiomics approach.
%   Nat. Commun. 2014; 5: 4006.
%4. http://www.nature.com/ncomms/2014/140603/ncomms5006/extref/ncomms5006-s1.pdf
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, 'InformationMeasureCorr2');
    case 'InfoID'
        FeatureInfo.FeatureName = 'Information correlation 2';
        FeatureInfo.FeatureID   = 'JN9H';
end

function [Value, ReviewInfo]=ComputeGLCMFeature(ParentInfo, Mode)
DirectionSliceNum=length(ParentInfo.ROIImageInfo.GLCMStruct3);
Offset=ParentInfo.ROIImageInfo.GLCMStruct3(1).Offset;

FeatureValue=zeros(length(Offset), DirectionSliceNum);

% Over Directions-Slice combinations
for i=1:DirectionSliceNum
    CurrentItem=ParentInfo.ROIImageInfo.GLCMStruct3(i);
    
    GLCM=CurrentItem.GLCM;
    
    % Use Matlab implementation
    if isequal(Mode, 'Homogeneity') ||  isequal(Mode, 'Energy') || isequal(Mode, 'Correlation') || isequal(Mode, 'Contrast')
        
        % Over offsets
        for j=1:size(GLCM, 3)
            CGLCM=GLCM(:, :, j);
            
            if false %~any(CGLCM(:))
                FeatureValue(j,i)=NaN;
            else
                GLCMProp=graycoprops(CGLCM, Mode);
                FinalValue=GLCMProp.(Mode);
                
                FeatureValue(j,i)=FinalValue;
            end
        end
        
        % Use custom implemetation
    else
        
        % Over offsets
        for j=1:size(GLCM, 3)
            CGLCM=GLCM(:, :, j);
            
            if false %~any(CGLCM(:))
                FeatureValue(j,i)=NaN;
            else
                CGLCM=NormalizeGLCM(CGLCM);
                
                s = size(CGLCM);
                [c, r] = meshgrid(1:s(1),1:s(2));
                r = r(:);
                c = c(:);
                
                switch Mode
                    case 'JointAverage'
                        FinalValue = CalculateJointAverage(CGLCM, r);
                    case 'JointVariance'
                        FinalValue = CalculateJointVariance(CGLCM, r);
                    case 'JointEntropy'
                        FinalValue = CalculateJointEntropy(CGLCM);
                    case 'DifferenceAverage'
                        FinalValue = CalculateDiffAverage(CGLCM, r, c);
                    case 'DifferenceVariance'
                        FinalValue = CalculateDiffVariance(CGLCM, r, c);
                    case 'DifferenceEntropy'
                        FinalValue = CalculateDiffEntropy(CGLCM, r, c);
                    case 'SumAverage'
                        FinalValue = CalculateSumAverage(CGLCM, r, c);
                    case 'SumEntropy'
                        FinalValue = CalculateSumEntropy(CGLCM, r, c);
                    case 'SumVariance'
                        FinalValue = CalculateSumVariance(CGLCM, r, c);
                    case 'AutoCorrelation'
                        FinalValue = CalculateAutoCorr(CGLCM, r, c);
                    case 'Dissimilarity'
                        FinalValue = CalculateDissim(CGLCM, r, c);
                    case 'ClusterShade'
                        FinalValue = CalculateCluterShade(CGLCM, r, c);
                    case 'ClusterProminence'
                        FinalValue = CalculateCluterP(CGLCM, r, c);
                    case 'ClusterTendency'
                        FinalValue = CalculateCluterT(CGLCM, r, c);
                    case 'JointMaximum'
                        FinalValue = CalculateMaxP(CGLCM);
                    case 'InverseDiffMoment'
                        FinalValue = CalculateInverseDiffMoment(CGLCM, r, c);
                    case 'InformationMeasureCorr1'
                        FinalValue = CalculateIMC1(CGLCM);
                    case 'InformationMeasureCorr2'
                        FinalValue = CalculateIMC2(CGLCM);
                    case 'InverseDiffMomentNorm'
                        FinalValue = CalculateIDMN(CGLCM, r, c);
                    case 'InverseDiffNorm'
                        FinalValue = CalculateIDN(CGLCM, r, c);
                    case 'InverseVariance'
                        FinalValue = CalculateInverseVariance(CGLCM, r, c);
                end
                FeatureValue(j,i)=FinalValue;
            end
        end
    end
end

Value=[Offset, FeatureValue];

ReviewInfo=ParentInfo.ROIImageInfo;
ReviewInfo.MaskData=Value;
ReviewInfo.Description=['GLCM ', Mode];

Direction=cell2mat({ParentInfo.ROIImageInfo.GLCMStruct3.Direction});
Direction=[0, Direction];

% Value=[Direction; Value];

%----Utillites
function glcm = NormalizeGLCM(glcm)
% Normalize glcm so that sum(glcm(:)) is one.
if any(glcm(:))
    glcm = glcm ./ sum(glcm(:));
end

function M = meanIndex(index,glcm)

M = index .* glcm(:);
M = sum(M);

function A = CalculateJointAverage(glcm, r)

glcm=glcm(:);

A = sum(r.*glcm);

function V = CalculateJointVariance(glcm, r)

mr = meanIndex(r,glcm);

term1 = (r - mr).^2 .* glcm(:);
V = sum(term1);

function E = CalculateJointEntropy(glcm)

glcm=glcm(:);

InvalidIndex=find(glcm == 0);
glcm(InvalidIndex)=[];

if ~isempty(glcm)
    E = glcm.*log2(glcm);
    E = -sum(E(:));
else
    E=NaN;
end

function E=CalculateDiffAverage(glcm, r, c)

PMat=glcm(:);
DMat=abs(r-c);
[SortDMat, SortIndex]=sort(DMat);
SortPMat = PMat(SortIndex);
P_XMinusY = grpstats(SortPMat,SortDMat,'sum');
K = unique(SortDMat);

if ~isempty(P_XMinusY)
    E= sum(K.*P_XMinusY);
else
    E=NaN;
end

function E=CalculateDiffVariance(glcm, r, c)

PMat=glcm(:);
DMat=abs(r-c);
[SortDMat, SortIndex]=sort(DMat);
SortPMat = PMat(SortIndex);
P_XMinusY = grpstats(SortPMat,SortDMat,'sum');
K = unique(SortDMat);

mu = CalculateDiffAverage(glcm, r, c);

if ~isempty(P_XMinusY)
    E= sum((K-mu).^2.*P_XMinusY);
else
    E=NaN;
end

function E=CalculateDiffEntropy(glcm, r, c)
PMat=glcm(:);

DMat=abs(r-c);
[SortDMat, SortIndex]=sort(DMat);

%Cum sum of p(i, j)
SortPMat=PMat(SortIndex);
CumSumP=cumsum(SortPMat);

%X-Y
XMinusY=diff(SortDMat);
XMinusY=[XMinusY; 1];

%P_XMinusY
TempIndex=find(XMinusY > 0);
P_XMinusY=CumSumP(TempIndex);

P_XMinusY=[0;P_XMinusY];
P_XMinusY=diff(P_XMinusY);

%Entropy
P_XMinusY(P_XMinusY==0) = [];

if ~isempty(P_XMinusY)
    E= -sum(P_XMinusY.*log2(P_XMinusY));
else
    E=NaN;
end

function E = CalculateAutoCorr(glcm, r, c)
term1 = r.*c;
term2 = glcm;

term = term1 .* term2(:);

E = sum(term);

function E = CalculateDissim(glcm, r, c)
term1 = abs(r-c);
term2 = glcm;

term = term1 .* term2(:);

E = sum(term);

function E = CalculateCluterShade(glcm, r, c)
mr = meanIndex(r,glcm);
mc = meanIndex(c,glcm);

term1 = (r - mr +c - mc).^3 .* glcm(:);
E = sum(term1);

function E = CalculateCluterP(glcm, r, c)
mr = meanIndex(r,glcm);
mc = meanIndex(c,glcm);

term1 = (r - mr +c - mc).^4 .* glcm(:);
E = sum(term1);

function E = CalculateCluterT(glcm, r, c)
mr = meanIndex(r,glcm);
mc = meanIndex(c,glcm);

term1 = (r - mr +c - mc).^2 .* glcm(:);
E = sum(term1);

function E = CalculateMaxP(glcm)
E=max(glcm(:));

function H = CalculateInverseDiffMoment(glcm,r,c)
term1 = (1 + (r - c).^2);
term = glcm(:) ./ term1;
H = sum(term);

%InformationMeasureCorr1
function Value = CalculateIMC1(glcm)
%HXY
HXY = CalculateJointEntropy(glcm);

%HX, HY
PX=sum(glcm, 2);
PY=sum(glcm, 1);
HX = CalculateJointEntropy(PX);
HY = CalculateJointEntropy(PY);

%HXY1
PX=repmat(PX, 1, size(glcm, 2));
PY=repmat(PY, size(glcm, 1), 1);

E=glcm.*log2(PX.*PY);

InvalidIndex=find(PX==0 | PY==0);
E(InvalidIndex)=[];

if ~isempty(E) && ~isnan(HX) && ~isnan(HY) && ~isnan(HXY)
    HXY1=-sum(E(:));
    Value=(HXY-HXY1)/max(HX, HY);
else
    Value=NaN;
end

%InformationMeasureCorr2
function Value = CalculateIMC2(glcm)
%HXY
HXY = CalculateJointEntropy(glcm);

%HXY2
PX=sum(glcm, 2);
PY=sum(glcm, 1);

PX=repmat(PX, 1, size(glcm, 2));
PY=repmat(PY, size(glcm, 1), 1);

E=PX.*PY.*log2(PX.*PY);

InvalidIndex=find(PX==0 | PY==0);
E(InvalidIndex)=[];

if ~isempty(E) &&  ~isnan(HXY)
    HXY2=-sum(E(:));
    Value=sqrt(1-exp(-2*(HXY2-HXY)));
else
    Value=NaN;
end

%InverseDiffMomentNorm
function Value = CalculateIDMN(glcm, r, c)
term1 = 1 + (r - c).^2/(size(glcm, 1)^2);
term = glcm(:) ./ term1;
Value = sum(term);

%InverseDiffNorm
function Value = CalculateIDN(glcm, r, c)
term1 = 1 + abs(r - c)/size(glcm, 1);
term = glcm(:) ./ term1;
Value = sum(term);

%InverseVariance
function Value = CalculateInverseVariance(glcm, r, c)
term1 = (r - c).^2;
term = glcm(:);

InvalidIndex=find(term1 == 0);
term1(InvalidIndex)=[];
term(InvalidIndex)=[];

term=term./term1;

Value = sum(term);

%SumAverage
function Value = CalculateSumAverage(glcm, r, c)
PMat=glcm(:);

SMat=r+c;
[SortSMat, SortIndex]=sort(SMat);

%Cum sum of p(i, j)
SortPMat=PMat(SortIndex);
CumSumP=cumsum(SortPMat);

%X+Y
DXPlusY=diff(SortSMat);
DXPlusY=[DXPlusY; 1];

%P_XPlusY
TempIndex=find(DXPlusY > 0);
XPlusY=SortSMat(TempIndex);

P_XPlusY=CumSumP(TempIndex);
P_XPlusY=[0;P_XPlusY];
P_XPlusY=diff(P_XPlusY);

%Return value
Value=sum(XPlusY.*P_XPlusY);

%SumEntropy
function Value = CalculateSumEntropy(glcm, r, c)
PMat=glcm(:);

SMat=abs(r+c);
[SortSMat, SortIndex]=sort(SMat);

%Cum sum of p(i, j)
SortPMat=PMat(SortIndex);
CumSumP=cumsum(SortPMat);

%X+Y
DXPlusY=diff(SortSMat);
DXPlusY=[DXPlusY; 1];

%P_XPlusY
TempIndex=find(DXPlusY > 0);
P_XPlusY=CumSumP(TempIndex);
P_XPlusY=[0;P_XPlusY];
P_XPlusY=diff(P_XPlusY);

%Entropy
P_XPlusY(P_XPlusY==0) = [];

if ~isempty(P_XPlusY)
    Value= -sum(P_XPlusY.*log2(P_XPlusY));
else
    Value=NaN;
end

%SumVariance
function Value = CalculateSumVariance(glcm, r, c)
mu = CalculateSumAverage(glcm, r, c);
PMat=glcm(:);

SMat=abs(r+c);
[SortSMat, SortIndex]=sort(SMat);

%Cum sum of p(i, j)
SortPMat=PMat(SortIndex);
CumSumP=cumsum(SortPMat);

%X+Y
DXPlusY=diff(SortSMat);
DXPlusY=[DXPlusY; 1];

%P_XPlusY
TempIndex=find(DXPlusY > 0);
XPlusY=SortSMat(TempIndex);

P_XPlusY=CumSumP(TempIndex);
P_XPlusY=[0;P_XPlusY];
P_XPlusY=diff(P_XPlusY);

TempIndex=find(P_XPlusY==0);
P_XPlusY(TempIndex) = [];
XPlusY(TempIndex) = [];

if ~isempty(P_XPlusY)
    Value= sum((XPlusY-mu).^2.*(P_XPlusY));
else
    Value=NaN;
end
