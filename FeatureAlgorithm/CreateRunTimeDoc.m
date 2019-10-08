function CreateRunTimeDoc(ProgramPath)
%1: Preprocess
PreprocessMethod=GetPreprocessMethod([ProgramPath, '\FeatureAlgorithm\Preprocess']);
for i=1:length(PreprocessMethod)
    MethodFileName=[ProgramPath, '\FeatureAlgorithm\Preprocess\',PreprocessMethod{i}, '.m'];
    DisplayMethodHelp(MethodFileName, 0);
end

%2: Category/Feature
Category=GetFeatureCategoryFolder;
for i=1:length(Category)
    MethodFileName=[ProgramPath, '\FeatureAlgorithm\Category\', Category{i}, '\', Category{i}, '_Category.m'];
    DisplayMethodHelp(MethodFileName, 0);
    
    MethodFileName=[ProgramPath, '\FeatureAlgorithm\Category\', Category{i}, '\', Category{i},  '_Feature.m'];
    DisplayMethodHelp(MethodFileName, 0, 0);
end

%3: Export Filters
DirList=GetDirList([ProgramPath, '\ImportExport\ExportModule']);

for j=1:length(DirList)
    FormatList=GetExportModuleFormatList([ProgramPath, '\ImportExport\ExportModule\', DirList{j}], [DirList{j}, 'Export']);
    for i=1:length(FormatList)
        MethodFileName=[ProgramPath, '\ImportExport\ExportModule\', DirList{j}, '\', DirList{j}, 'ExportMethod_', FormatList{i}, '.m'];
        DisplayMethodHelp(MethodFileName, 0);
    end
end


