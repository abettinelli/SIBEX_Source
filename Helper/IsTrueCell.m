function TrueIndex=IsTrueCell(TableCell)

if islogical(TableCell)
    if TableCell
        TrueIndex=1;
    else
        TrueIndex=0;
    end
else
    TrueIndex=0;
end
