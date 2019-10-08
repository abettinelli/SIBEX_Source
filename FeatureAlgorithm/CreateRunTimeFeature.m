function CreateRunTimeFeature(ProgramPath)
%List
Category=GetFeatureCategoryFolder;

%Create Category/Feature Name List
for i=1:length(Category)
    FileContent=[];
    
    %Parse FeatureName
    CategoryPath=[ProgramPath, '\FeatureAlgorithm\Category\', Category{i}];
    FeatureName=ParseFeatureName(CategoryPath, Category{i});
    
    FileContent=[FileContent; {[Category{i}, 'List={']}];
    for j=1:length(FeatureName)
         FileContent=[FileContent; {['''', FeatureName{j}, ''';']}];
    end
    FileContent=[FileContent; {'};'}];    
    
    %Write to .fl
    FID=fopen([ProgramPath, '\FeatureAlgorithm\Category\',  Category{i}, '\', Category{i}, '_Feature.list'], 'w');
    for j=1:length(FileContent)
        fprintf(FID, '%s\n', FileContent{j});
    end
    fclose(FID);
end














