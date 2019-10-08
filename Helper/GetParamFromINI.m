function Param=GetParamFromINI(ConfigFile)

if ~exist(ConfigFile, 'file')
    Param=[];
    return;
end

%Read file in
TextInfo=ReadPinnTextFileOri(ConfigFile);
for i=1:length(TextInfo)
    CurrentStr=TextInfo{i};
    
    [VarName, VarValue]=GetVarName(CurrentStr);   
    
    if ~isempty(VarName)
        Param.(VarName)=VarValue;
    end
end


function [VarName, VarValue]=GetVarName(StrIn)
eval(StrIn);

VarNames=who;

TempIndex=strmatch('StrIn', VarNames, 'exact');
VarNames(TempIndex)=[];

if ~isempty(VarNames)
    VarName=VarNames{1};
else
    VarName=[];
    VarValue=[];
    return;
end

eval(['VarValue=', VarName, ';']);