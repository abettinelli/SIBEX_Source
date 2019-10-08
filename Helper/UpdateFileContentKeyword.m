function UpdateFileContentKeyword(FileName, OldStr, NewStr)
TextInfo=ReadPinnTextFileOri(FileName);

TextInfo=regexprep(TextInfo, OldStr, NewStr);

FID=fopen(FileName, 'w');
for i=1:length(TextInfo)
    fprintf(FID, '%s\n', TextInfo{i});
end
fclose(FID);