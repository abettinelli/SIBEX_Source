function Flag=EqualRelativeZ(NumA, NumB)
if abs(NumA-NumB)/NumA <= (2/100)
    Flag=1;
else
    Flag=0;
end