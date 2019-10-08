
function Pinn9DBNameDisplay=GetDBNameDisplayStr(Pinn9DBName)
Pinn9DBNameDisplay=[];
for i=1:length(Pinn9DBName)
    TempStr=Pinn9DBName{i};
    
    TempIndex=strfind(TempStr, ':');
    if isempty(TempIndex)
        Pinn9DBNameDisplay=[Pinn9DBNameDisplay; {TempStr}];
    else
        Pinn9DBNameDisplay=[Pinn9DBNameDisplay; {TempStr(1:TempIndex(1)-1)}];
    end
end