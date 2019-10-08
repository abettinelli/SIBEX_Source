function UpdateFileFeatureName(FileName, FeatureName)

TextInfo=ReadPinnTextFileOri(FileName);

TempIndex=strmatch('%Feature: GlobalMax', TextInfo);

%Template Feature String
TemplateStr=TextInfo(TempIndex(1):end);

TextInfo(TempIndex(1):end)=[];

%Insert new feature
for i=1:length(FeatureName)
    CurrentStr=regexprep(TemplateStr, 'GlobalMax', FeatureName{i});
    
    TextInfo=[TextInfo; CurrentStr];
    TextInfo=[TextInfo; {' '}; {' '}];
end

%Write out
FID=fopen(FileName, 'w');
for i=1:length(TextInfo)
    fprintf(FID, '%s\n', TextInfo{i});
end
fclose(FID);