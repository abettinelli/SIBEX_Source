function ModifyFeatureSet

FeatureSetFile='D:\DataIFOA\Choi\Category1\1FeatureModelSet_Algorithm\FeatureSet_TextureGTV.mat';

load(FeatureSetFile)

ItemLength=length(FeatureSetsInfo);

for i=1:ItemLength
    FeatureSetsInfo(i).Preprocess(end)=[];
    FeatureSetsInfo(i).PreprocessStore(end)=[];
end

save('-mat', FeatureSetFile, 'FeatureSetsInfo')

A=1;

