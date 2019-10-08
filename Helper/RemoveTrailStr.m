function FinalStr=RemoveTrailStr(InputStr, PattStr)

TempStr=char(InputStr);
TempStr=strjust(TempStr, 'right');

PreLen=length(PattStr);
TempStr=TempStr(:, 1:end-PreLen);

TempStr=strjust(TempStr, 'left');
TempStr=cellstr(TempStr);

FinalStr=TempStr;