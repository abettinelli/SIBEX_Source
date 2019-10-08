function FinalStr=RemoveLeadStr(InputStr, PattStr)

TempStr=char(InputStr);

PreLen=length(PattStr);
TempStr=TempStr(:, PreLen+1:end);

TempStr=cellstr(TempStr);

FinalStr=TempStr;