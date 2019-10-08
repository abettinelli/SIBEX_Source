function PatInfo2=ReadPinnTextFile(PatFileName)
FID=fopen(PatFileName, 'r');
TempContent=textscan(FID, '%s', 'delimiter', '\n');
fclose(FID);

PatInfoO=TempContent{1};
clear('TempContent');

%Replace ' with *, " with '
a=char(39);
PatInfo2 = regexprep(PatInfoO, a, '*');
PatInfo2 = regexprep(PatInfo2, '"', a);
