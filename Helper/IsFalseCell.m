function TrueIndex=IsFalseCell(TableCell)

if islogical(TableCell)
    if TableCell
        TrueIndex=0;
    else
        TrueIndex=1;
    end
else
    TrueIndex=0;
end
