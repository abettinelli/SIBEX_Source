function CreateSiteFolder(PatsParentDir)
if ~exist([PatsParentDir, '\1FeatureDataSet_ImageROI'], 'dir')
    mkdir([PatsParentDir, '\1FeatureDataSet_ImageROI']);
end

if ~exist([PatsParentDir, '\1FeatureModelSet_Algorithm'], 'dir')
    mkdir([PatsParentDir, '\1FeatureModelSet_Algorithm']);
end

