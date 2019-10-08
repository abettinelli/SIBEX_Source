
function [Flag, TableFeatureItemID, TableData, FeatureSetsInfo]=UpdateTableFeatureSetDisplay(FeatureSetFile, handles, Mode)
Flag=1;

%Sanity Check
if ~isstruct(FeatureSetFile)  %File
    try
        load(FeatureSetFile, '-mat', 'FeatureSetsInfo');
    catch
        TableFeatureItemID=[];
        FeatureSetsInfo=[];        
        TableData=[];
        Flag=0;
        return;
    end      
else        
    FeatureSetsInfo=FeatureSetFile;  %Memory
end

if ~exist('FeatureSetsInfo') || isempty(FeatureSetsInfo)
    TableFeatureItemID=[];
    FeatureSetsInfo=[];
    TableData=[]; 
end

%Initialize Table, Set table header for the first table
TableHeader={'Preprocess', 'Para.', 'Category', 'Para.',  'Feature', 'Para.', 'Comment', 'CreationDate'};
TableHeaderOri=TableHeader;
TableWidth=num2cell([30, 220, 50, 280, 50, 160, 50, 120, 120]);

TableHeader=[{' '}, TableHeader];
TableHeader=FormatTableHeader(TableHeader);
TableHeader(1)=[];

TableEdit=repmat(false, 1,  length(TableHeader));
TableEdit(1)=true;
TableEdit(2)=true;
TableEdit(6)=true;
TableEdit(8)=true;

set(handles.UITableItem1, 'ColumnName', TableHeader);

for i=1:10
    set(handles.(['UITableItem', num2str(i)]), 'Data', '', 'Visible', 'on', 'ColumnEditable', TableEdit, 'ColumnWidth', TableWidth);
end

if ~exist('FeatureSetsInfo') || isempty(FeatureSetsInfo)
    FeatureSetsInfo=[];
    TableFeatureItemID=[];
    
    for i=1:10
        set(handles.(['UITableItem', num2str(i)]), 'Data', '',  'ColumnWidth', TableWidth);
    end       
    
    set(handles.PushbuttonDelete, 'Enable', 'off');  
    set(handles.PushbuttonCopy, 'Enable', 'off'); 
    set(handles.PopupmenuFeatureSetHeader, 'Enable', 'off', 'String', {''});
    
    set(handles.PushbuttonPrev, 'Enable', 'Off');
    set(handles.PushbuttonNext, 'Enable', 'Off');    
    set(handles.TextPage, 'String', '0/0');
else      
    ProgramPath=fileparts(mfilename('fullpath'));
    TempIndex=strfind(ProgramPath, '\');
    ProgramPath=ProgramPath(1:TempIndex(end)-1);
    
    InfoPic=[ProgramPath, '\Pic\FeatureInfo.png'];
    InfoImgHtml=['<html><img src="file:/', InfoPic, '"></html>'];

    TableData=SetTableData(FeatureSetsInfo, TableHeaderOri, InfoImgHtml);   
    
    %Select
    SelectMat=repmat({false}, size(TableData, 1), 1);
    TableData=[SelectMat, TableData];
    
    SortByStr=' ';    %Data Set Item adding order
    TableFeatureItemID=(1:size(TableData, 1))';    
    TableHeader=GetHtmlValue(TableHeader);    
    [TableFeatureItemID, TableData]=SortTableData(TableData, SortByStr, TableHeader, TableFeatureItemID);    
       
    
    GroupNum=1;
    DisplayFeatureTableData(handles, TableData, GroupNum);    
    
    if isequal(Mode, 'Add')
        CheckItemNum=1;
        SetTableSelectTrue(handles, CheckItemNum);
        TableData{1, 1}=true;
    end
   
    set(handles.PushbuttonDelete, 'Enable', 'off');  
    set(handles.PushbuttonCopy, 'Enable', 'off');  
    set(handles.PushbuttonPrev, 'Enable', 'on');
    set(handles.PushbuttonNext, 'Enable', 'on');    
    
    set(handles.TextPage, 'String', [num2str(GroupNum), '/', num2str(ceil(size(TableData, 1)/10))]);
    
    set(handles.PopupmenuFeatureSetHeader, 'Enable', 'on', 'String', {' '; 'Category'; 'Comment'}, 'Value', 1);
end

function SetTableSelectTrue(handles, CheckItemNum)
GroupNum=floor((CheckItemNum-1)/10)+1;

ItemIndex=rem(CheckItemNum, 10);
if ItemIndex == 0
    ItemIndex=10;
end

TableData=get(handles.(['UITableItem', num2str(ItemIndex)]), 'Data');
TableData(1)={true};

set(handles.(['UITableItem', num2str(ItemIndex)]), 'Data', TableData);

     

function TableData=SetTableData(FeatureSetsInfo, TableHeader, InfoImgHtml)
for i=1:length(TableHeader)
    FieldNames=fieldnames(FeatureSetsInfo);
    
    TempIndex=strmatch(TableHeader{i}, FieldNames, 'exact');    
    
    if ~isempty(TempIndex)
        TableData(:, i)={FeatureSetsInfo.(FieldNames{TempIndex})}';
    else
        TableData(:, i)=repmat({InfoImgHtml}, size(TableData, 1), 1);
    end
end














