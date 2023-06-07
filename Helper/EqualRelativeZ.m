function Flag=EqualRelativeZ(NumA, NumB)
if abs((NumA-NumB)/NumA) <= 10^-4
    Flag=1;
else
    Flag=0;
end