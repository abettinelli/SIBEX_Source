function FeatureStore=SyncFeatureParams(Module, FeatureStore, FeaturePrefixStr, ModulePara)
TempIndex=strmatch(FeaturePrefixStr, Module);
if ~isempty(TempIndex)
    FeatureName={FeatureStore.Name}';
    
    TempIndex=strmatch(FeaturePrefixStr, FeatureName);
    if ~isempty(TempIndex)
        for i=1:length(TempIndex)
            FeatureStore(TempIndex(i)).Value=ModulePara;
        end
    end
end