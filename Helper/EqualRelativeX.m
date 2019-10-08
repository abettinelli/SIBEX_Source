function Flag=EqualRelativeX(NumA, NumB)
if abs(NumA-NumB)/NumA <= (0.2/100)
    Flag=1;
else
    Flag=0;
end