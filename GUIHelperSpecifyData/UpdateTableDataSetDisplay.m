
function [Flag, TableDataItemID, DataSetsInfo]=UpdateTableDataSetDisplay(DataSetFile, handles, CurrentItemNum)
Flag=1;


if ~isstruct(DataSetFile)  %File
    try
        load(DataSetFile, '-mat', 'DataSetsInfo');
    catch
        TableDataItemID=[];
        DataSetsInfo=[];
        Flag=0;
        return;
    end      
else    
    DataSetsInfo=DataSetFile;   %memory      
end

set(handles.PushbuttonReview, 'Enable', 'off');

if ~exist('DataSetsInfo') || isempty(DataSetsInfo)
    DataSetsInfo=[];
    TableDataItemID=[];
    
    set(handles.UITableDataSet, 'Data', []);    
    
    set(handles.PushbuttonDelete, 'Enable', 'off');    
    set(handles.PushbuttonMove, 'Enable', 'off');
    set(handles.PushbuttonCopy, 'Enable', 'off');
    
    set(handles.PushbuttonSortBy, 'Enable', 'off');
    set(handles.PopupmenuDataSetHeader, 'Enable', 'off', 'String', {''});
    
    set(handles.TextNum, 'String', '0 items');
    
else
    if isfield(handles, 'SimpleFormatDisplay') && handles.SimpleFormatDisplay > 0
        TableHeader={'XPixDim', 'YPixDim', 'ZPixDim', 'ImageXDim', 'ImageYDim', 'ImageZDim', 'ROIXDim', 'ROIYDim', 'ROIZDim',  ...
            'Modality', 'MRN', 'DBName', 'ROIName','CreationDate'};        
    else
        TableHeader={'Modality', 'MRN', 'DBName', 'ROIName',  'ROIVol', 'ROIMinV', 'ROIMaxV', 'SeriesInfo', 'Comment','CreationDate', ...
            'XPixDim', 'YPixDim', 'ZPixDim', 'ImageXDim', 'ImageYDim', 'ImageZDim', 'ROIXDim', 'ROIYDim', 'ROIZDim'};
    end
  
    TableWidth=repmat({70}, 1, length(TableHeader));
    TableFormat=repmat({'char'}, 1,  length(TableHeader));
    TableEdit=repmat(false, 1,  length(TableHeader));
    
    TempIndex=strmatch('Comment', TableHeader, 'exact');
    TableEdit(TempIndex)=true;    
        
    TableWidth=SetFieldWidth(TableHeader, TableWidth, 'Modality', 60);    
    TableWidth=SetFieldWidth(TableHeader, TableWidth, 'DBName', 200);
    TableWidth=SetFieldWidth(TableHeader, TableWidth, 'ROIName', 120);
    TableWidth=SetFieldWidth(TableHeader, TableWidth, 'SeriesInfo', 200);
    TableWidth=SetFieldWidth(TableHeader, TableWidth, 'CreationDate', 140);
     
    TableData=SetTableData(DataSetsInfo, TableHeader);
    
    %Add selection
    TableHeader=[{' '}, TableHeader];
    TableWidth=[{30}, TableWidth];
    TableFormat=[{'logical'}, TableFormat];
    TableEdit=[true, TableEdit];
    
    TempV=repmat({false}, size(TableData, 1), 1);      
    TableData=[TempV, TableData];
    
    TableDataItemID=(1:size(TableData, 1))';       
    
    
    SortByStr='CreationDate';    %Data Set Item adding order
    [TableDataItemID, TableData]=SortTableData(TableData, SortByStr, TableHeader, TableDataItemID);    
    
     if nargin > 2
        TableData(1)={true};
    end
    
    TableHeader=FormatTableHeader(TableHeader);
    TableHeader(1)=[];
    
    set(handles.UITableDataSet, 'Visible', 'on', 'Enable', 'on', 'Data', TableData, ...
        'ColumnName', TableHeader, 'ColumnFormat', TableFormat, ...
        'ColumnEditable', TableEdit, 'ColumnWidth', TableWidth);
    
    if nargin > 2
        set(handles.PushbuttonDelete, 'Enable', 'on');
        set(handles.PushbuttonMove, 'Enable', 'on');
        set(handles.PushbuttonCopy, 'Enable', 'on');
        
    else
        set(handles.PushbuttonDelete, 'Enable', 'off');
        set(handles.PushbuttonMove, 'Enable', 'off');
        set(handles.PushbuttonCopy, 'Enable', 'off');
    end
    
    TableHeader=GetHtmlValue(TableHeader);
    set(handles.PushbuttonSortBy, 'Enable', 'on');
    TempIndex=strmatch(SortByStr, TableHeader, 'exact');
        
    set(handles.PopupmenuDataSetHeader, 'Enable', 'on', 'String', TableHeader, 'Value', TempIndex);
    
    set(handles.TextNum, 'String', [num2str(size(TableData, 1)), ' items']);
end


function TableWidth=SetFieldWidth(TableHeader, TableWidth, FieldName, FieldLen)
TempIndex=strmatch(FieldName, TableHeader, 'exact');
TableWidth(TempIndex)={FieldLen};


function TableData=SetTableData(DataSetsInfo, TableHeader)

for i=1:length(TableHeader)
    FieldNames=fieldnames(DataSetsInfo);
    
    TempIndex=strmatch(TableHeader{i}, FieldNames, 'exact');    
    
    if ~isempty(TempIndex)
        TableData(:, i)={DataSetsInfo.(FieldNames{TempIndex})}';
    else
        TableData(:, i)=repmat({' '}, size(TableData, 1), 1);
    end
end












