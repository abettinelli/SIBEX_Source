function FeatureInfo=IBSI_NeighborIntensityDifference_Feature(ParentInfo, FeatureInfo, Mode)

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
        FeatureValue = mean(FeatureValue); % bettinelli
        FeatureInfo(i).FeatureValue=FeatureValue;
    end         
end

function [FeatureValue, FeatureReviewInfo]=GetFeatureValue(ParentInfo, CurrentFeatureInfo,  FeaturePrefix)
FeatureName=CurrentFeatureInfo.Name;

FuncName=[FeaturePrefix, '_', FeatureName];
FuncHandle=str2func(FuncName);

[FeatureValue, FeatureReviewInfo]=FuncHandle(ParentInfo, CurrentFeatureInfo.Value);

%----FEATURES
function [Value, ReviewInfo]=IBSI_NeighborIntensityDifference_Feature_Coarseness(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNIDFeature(ParentInfo, 'Coarseness');

function [Value, ReviewInfo]=IBSI_NeighborIntensityDifference_Feature_Contrast(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNIDFeature(ParentInfo, 'Contrast');

function [Value, ReviewInfo]=IBSI_NeighborIntensityDifference_Feature_Busyness(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNIDFeature(ParentInfo, 'Busyness');

function [Value, ReviewInfo]=IBSI_NeighborIntensityDifference_Feature_Complexity(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNIDFeature(ParentInfo, 'Complexity');

function [Value, ReviewInfo]=IBSI_NeighborIntensityDifference_Feature_TextureStrength(ParentInfo, Param)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative. 
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
[Value, ReviewInfo]=ComputeNIDFeature(ParentInfo, 'TextureStrength');


function [FinalValue, ReviewInfo]=ComputeNIDFeature(ParentInfo, Mode)
Epsilon= 1e-10;
NIDStruct=ParentInfo.ROIImageInfo.NIDStruct;

SliceNum=length(ParentInfo.ROIImageInfo.NIDStruct);

FeatureValue=zeros(SliceNum, 1);

for i=1:SliceNum
    curr_NIDStruct = NIDStruct(i);
    
    if isnan(curr_NIDStruct.HistOccurPropability)
        Value=NaN;
        ReviewInfo.MaskData=Value;
        
        return;
    end
    
    switch Mode
        case 'Coarseness'
            Value=1/(Epsilon+sum(curr_NIDStruct.HistOccurPropability.*curr_NIDStruct.HistDiffSum));
            
        case 'Contrast'
            ValidNumVoxel=curr_NIDStruct.ValidNumVoxel;
            
            AveDiff1D=sum(curr_NIDStruct.HistDiffSum)/ValidNumVoxel;
            AveDiff2D=ComputeAverageCrossDiff(curr_NIDStruct);
            
            Value=AveDiff1D*AveDiff2D;
            
        case 'Busyness'
            WeightDiff=curr_NIDStruct.HistOccurPropability.*curr_NIDStruct.HistDiffSum;
            SumDiff1D=sum(WeightDiff);
            
            SumDiff2D=ComputeSumCrossDiff(curr_NIDStruct);
            
            Value=SumDiff1D/(Epsilon+SumDiff2D);
            
        case 'Complexity'
            Value=ComputeComplex(curr_NIDStruct);
            
        case 'TextureStrength'
            SumDiff=sum(curr_NIDStruct.HistDiffSum);
            
            SumWeightDiff2D=ComputeSumCrossWeightDiff(curr_NIDStruct);
            
            Value=SumWeightDiff2D/(Epsilon+SumDiff);
    end           
        
    FeatureValue(i)=Value;
end

ReviewInfo=ParentInfo.ROIImageInfo;
ReviewInfo.MaskData=Value;

FinalValue=FeatureValue;

function SumComplex=ComputeComplex(NIDStruct)
ValidNumVoxel=NIDStruct.ValidNumVoxel;

ProbPos=NIDStruct.HistOccurPropability;
DiffSum=NIDStruct.HistDiffSum;
BinLoc=NIDStruct.HistBinLoc;

%Remove empty entries
TempIndex=find(ProbPos == 0);
if ~isempty(TempIndex)
    ProbPos(TempIndex)=[];
    DiffSum(TempIndex)=[];
    BinLoc(TempIndex)=[];
end

%Cross part
IntensityMat1=repmat(BinLoc, 1, length(BinLoc));
IntensityMat2=IntensityMat1';

Occur=ProbPos*ValidNumVoxel;

OccurMat1=repmat(Occur, 1, length(BinLoc));
OccurMat2=OccurMat1';

NormIntensityCrossDiff=abs(IntensityMat1-IntensityMat2)./(OccurMat1+OccurMat2);

%Self part
PropMat1=repmat(ProbPos, 1, length(BinLoc));
PropMat2=PropMat1';

DiffSumMat1=repmat(DiffSum, 1, length(BinLoc));
DiffSumMat2=DiffSumMat1';

IntensityDiff=PropMat1.*DiffSumMat1+PropMat2.*DiffSumMat2;

Result=NormIntensityCrossDiff.*IntensityDiff;

SumComplex=sum(Result(:));

function SumDiff2D=ComputeSumCrossWeightDiff(NIDStruct)
Prop=NIDStruct.HistOccurPropability;
BinLoc=NIDStruct.HistBinLoc;

%Remove empty entries
TempIndex=find(Prop == 0);
if ~isempty(TempIndex)
    Prop(TempIndex)=[];
    BinLoc(TempIndex)=[];
end

IntensityMat1=repmat(BinLoc, 1, length(BinLoc));
IntensityMat2=IntensityMat1';

PropMat1=repmat(Prop, 1, length(BinLoc));
PropMat2=PropMat1';

Result=(PropMat1+PropMat2).*(IntensityMat1-IntensityMat2).*(IntensityMat1-IntensityMat2);

SumDiff2D=sum(Result(:));

function SumDiff2D=ComputeSumCrossDiff(NIDStruct)
Prop=NIDStruct.HistOccurPropability;
BinLoc=NIDStruct.HistBinLoc;

%Remove empty entries
TempIndex=find(Prop == 0);
if ~isempty(TempIndex)
    Prop(TempIndex)=[];
    BinLoc(TempIndex)=[];
end

WeightBinLoc=BinLoc.*Prop;

DiffMat1=repmat(WeightBinLoc, 1, length(BinLoc));
DiffMat2=DiffMat1';

TempMat=abs(DiffMat1-DiffMat2);

SumDiff2D=sum(TempMat(:));

function AveDiff2D=ComputeAverageCrossDiff(NIDStruct)
Prop=NIDStruct.HistOccurPropability;
BinLoc=NIDStruct.HistBinLoc;

%Remove empty entries
TempIndex=find(Prop == 0);
if ~isempty(TempIndex)
    Prop(TempIndex)=[];
    BinLoc(TempIndex)=[];
end
Np = length(Prop);

IntensityMat1=repmat(BinLoc, 1, length(BinLoc));
IntensityMat2=repmat(BinLoc', length(BinLoc), 1);

PropMat1=repmat(Prop, 1, length(BinLoc));
PropMat2=repmat(Prop', length(BinLoc), 1);

SqrtDiff2D=(IntensityMat1-IntensityMat2).^2;
Prop2D=PropMat1.*PropMat2;

SumDiff2D=SqrtDiff2D.*Prop2D;
AveDiff2D=sum(SumDiff2D(:))/(Np*(Np-1));
