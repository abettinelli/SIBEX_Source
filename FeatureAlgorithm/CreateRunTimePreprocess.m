function CreateRunTimePreprocess(ProgramPath)
FileName='CompilePreprocess';

%List
PreprocessMethod=GetPreprocessMethod([ProgramPath, '\FeatureAlgorithm\Preprocess']);

%Create Preprocess compile file
FileContent=[{'%Force compile preprocess method'}; {' '}];
for i=1:length(PreprocessMethod)
    TempStr=['%#function ', PreprocessMethod{i}];
    FileContent=[FileContent; {TempStr}];
end

FID=fopen([ProgramPath, '\FeatureAlgorithm\', FileName, '.m'], 'w');
for i=1:length(FileContent)
    fprintf(FID, '%s\n', FileContent{i});
end
fclose(FID);

%Create PreprocessName List
FileContent=[{'NameList={'}];
for i=1:length(PreprocessMethod)
     FileContent=[FileContent; {['''', PreprocessMethod{i}, ''';']}];
end
FileContent=[FileContent; {'};'}];

FID=fopen([ProgramPath, '\FeatureAlgorithm\', FileName, '.INI'], 'w');
for i=1:length(FileContent)
    fprintf(FID, '%s\n', FileContent{i});
end
fclose(FID);

