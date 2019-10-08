function Pinn9DBHostDisplay=GetHostDisplayStr(Pinn9DBHost)
Pinn9DBHostDisplay=[];
for i=1:length(Pinn9DBHost)
    TempStr=Pinn9DBHost{i};
    
    TempIndex=strfind(TempStr, ':');
    if isempty(TempIndex)
        Pinn9DBHostDisplay=[Pinn9DBHostDisplay; {TempStr}];
    else
        Pinn9DBHostDisplay=[Pinn9DBHostDisplay; {TempStr(1:TempIndex(1)-1)}];
    end
end
