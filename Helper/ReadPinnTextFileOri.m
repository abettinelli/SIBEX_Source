function PatInfo2=ReadPinnTextFileOri(PatFileName)
FID=fopen(PatFileName, 'r');
TempContent=textscan(FID, '%s', 'delimiter', '\n');
fclose(FID);

PatInfoO=TempContent{1};
clear('TempContent');

PatInfo2=PatInfoO;
