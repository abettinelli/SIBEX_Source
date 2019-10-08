function FeatureName=ParseFeatureName(FeaturePath, FeatureCategory)

if exist([FeaturePath, '\', FeatureCategory, '_Feature.m'], 'file')
    FileType='.m';
else
    FileType='.p';
end

if ~isdeployed && ~isequal(FileType, '.p')  %Mcode
    FeatureName=[];
    
    for i=1:2
        switch i
            case 1
                %Inside the feature file
                Funs = SubFuns([FeaturePath, '\', FeatureCategory, '_Feature.m']);
                if ~isempty(Funs)
                    SubFunsName=Funs(:, 2);
                else
                    SubFunsName=[];
                end
                
            case 2
                %Inside the category directory
                FileList=GetFileList(FeaturePath);
                FileList=FilterFileList(FileList, '.m');
                
                SubFunsName=FileList;
                SubFunsName=RemoveTrailStr(SubFunsName, '.m');
        end
        
        if ~isempty(SubFunsName)
            TempIndex=strmatch([FeatureCategory, '_Feature_'], SubFunsName);
            
            if ~isempty(TempIndex)
                TempStr=SubFunsName(TempIndex);
                TempStr=RemoveLeadStr(TempStr, [FeatureCategory, '_Feature_']);
                
                FeatureName=[FeatureName; TempStr];
            end
        end
    end
else
    FeatureListFile=[FeaturePath, '\', FeatureCategory, '_Feature.list'];
    TextInfo=ReadPinnTextFileOri(FeatureListFile);
    
    EvalStr=[];
    for i=1:length(TextInfo)
        EvalStr=strcat(EvalStr, TextInfo{i});
    end
    
    eval(EvalStr);
    
    eval(['TempValue=isempty(', FeatureCategory, 'List);']);
    
    if TempValue > 0
        FeatureName=[];
    else
        eval(['FeatureName=', FeatureCategory, 'List;']);        
    end    
end



