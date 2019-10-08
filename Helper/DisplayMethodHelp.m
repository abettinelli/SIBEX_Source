function DisplayMethodHelp(MethodFileName, ModeStr, FeatureName)
[MFilePath, MFileName]=fileparts(MethodFileName);

ProgramPath=fileparts(mfilename('fullpath'));
StrPattern=GetFolerName(ProgramPath);

%Doc Path
TempIndex=strfind(MFilePath, StrPattern);

MidPos=TempIndex(end)+length(StrPattern);

DocPath=[MFilePath(1:MidPos), 'Doc\', MFilePath(MidPos+1:end)];
if ~exist(DocPath, 'dir')
    mkdir(DocPath);
end

InfoFileName=[DocPath, '\', MFileName, '.txt'];

%Create help document on the fly
if ~isdeployed
    if exist(MethodFileName, 'file')       
        
        if nargin < 3
            %Read Help information in
            TextInfo=ReadPinnTextFileOri(MethodFileName);
            HelpContent=GetHelpContent(TextInfo);            
        else
            HelpContent=GetFeatureDoc(MethodFileName);
        end
    else
        HelpContent={' '};
    end    
    
    %Write into txt file
    FID=fopen(InfoFileName, 'w');
    for i=1:length(HelpContent)
        fprintf(FID, '%s\r\n', HelpContent{i});
    end
    fclose(FID);    
end

%Open txt file
if ModeStr > 0
    if exist(InfoFileName, 'file')
        if nargin < 3            
            winopen(InfoFileName);            
        else
            %Feature
            TempInfoFileName=[InfoFileName(1:end-4), '_', FeatureName, '.txt'];
            WriteTempInfo(InfoFileName, FeatureName, TempInfoFileName);
            
            winopen(TempInfoFileName);
            pause(1);
            delete(TempInfoFileName);
        end        
    else
%         InfoFileName
        MsgboxGuiIFOA('No documentation is available to this item.', 'Warn', 'warn');
    end
end

function WriteTempInfo(InfoFileName, FeatureName, TempInfoFileName)
TextInfo=ReadPinnTextFileOri(InfoFileName);

IndexStartAll=strmatch('***Feature_', TextInfo);

FuncStr=['***Feature_', FeatureName, '_Info***'];
IndexStart=strmatch(FuncStr, TextInfo, 'exact');

if ~isempty(IndexStart)
    TempIndex=find(IndexStartAll > IndexStart);
    
    if ~isempty(TempIndex)
        HelpContent=TextInfo(IndexStart+1:IndexStartAll(TempIndex(1))-1);
    else
        HelpContent=TextInfo(IndexStart+1:end);
    end    
else
    HelpContent={' '};
end

%Write into txt file
FID=fopen(TempInfoFileName, 'w');
for i=1:length(HelpContent)
    fprintf(FID, '%s\r\n', HelpContent{i});
end
fclose(FID);


function HelpContent=GetHelpContent(TextInfo)
IndexStart=strmatch('%%%Doc Starts%%%', TextInfo, 'exact');
IndexEnd=strmatch('%%%Doc Ends%%%', TextInfo, 'exact');

if ~isempty(IndexStart) && ~isempty(IndexEnd)
    HelpContent=TextInfo(IndexStart+1:IndexEnd-1);
    HelpContent = regexprep(HelpContent, '%', '', 1);
else
    HelpContent={' '};
end

function HelpContent=GetFeatureDoc(MethodFileName)
%Ininit
HelpContent=[];

%Get FeatureName List
TempIndex=strfind(MethodFileName, '\');
TempStr=MethodFileName(TempIndex(end)+1:end);
CategoryName=TempStr(1:end-length('_Feature.m'));

FeatureFuncH=str2func([CategoryName, '_Feature']);
FeatureInfo=FeatureFuncH([], [], 'ParseFeature');
FeatureInfo=sortStruct(FeatureInfo, 'Name');
FeatureNameList={FeatureInfo.Name}';

%Get Help
TextInfo=ReadPinnTextFileOri(MethodFileName);

FuncStrAll=['function [Value, ReviewInfo]=', CategoryName, '_Feature_'];
IndexStartAll=strmatch(FuncStrAll, TextInfo);

for i=1:length(FeatureNameList)
    FuncStr=['function [Value, ReviewInfo]=', CategoryName, '_Feature_', FeatureNameList{i}, '(ParentInfo, Param)'];    
    
    IndexStart=strmatch(FuncStr, TextInfo, 'exact');
    if ~isempty(IndexStart)
        %Feature is defined in the *_Feature.m
        TempIndex=find(IndexStartAll > IndexStart);
        
        if ~isempty(TempIndex)
            FuncContent=TextInfo(IndexStart+1:IndexStartAll(TempIndex(1))-1);
        else
            FuncContent=TextInfo(IndexStart+1:end);
        end
    else
        TFileName=[MethodFileName(1:end-2), '_', FeatureNameList{i}, '.m'];
        FuncContent=ReadPinnTextFileOri(TFileName);      
    end
    
    CHelpContent=GetHelpContent(FuncContent); 
    CHelpContent=[{['***Feature_', FeatureNameList{i}, '_Info***']}; CHelpContent];
    
    HelpContent=[HelpContent; CHelpContent; {' '}];
end


function StrPattern=GetFolerName(ProgramPath)
TempIndex=strfind(ProgramPath, '\');

StartIndex=TempIndex(end-1)+1;
EndIndex=TempIndex(end)-1;

StrPattern=ProgramPath(StartIndex:EndIndex);








