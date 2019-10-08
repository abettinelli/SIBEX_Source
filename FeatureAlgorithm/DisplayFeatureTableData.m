function DisplayFeatureTableData(handles, TableData, GroupNum)

%Format
TableHeader=get(handles.UITableItem1, 'ColumnName');
TableEdit=get(handles.UITableItem1, 'ColumnEditable');
TableWidth=get(handles.UITableItem1, 'ColumnWidth');

TableFormat=repmat({'char'}, 1,  length(TableHeader)-1);  %Need to be overwritten
TableFormat=[{'logical'}, TableFormat];

%Clear Data
for i=1:10
    set(handles.(['UITableItem', num2str(i)]), 'Data', '', 'Visible', 'on');
end

if isempty(TableData)
    return;
end

%Text Page
UpdateTextPage(handles, GroupNum, TableData);

%Set Data
StartIndex=(GroupNum-1)*10+1;
EndIndex=GroupNum*10;

if EndIndex > size(TableData, 1)
    EndIndex=size(TableData, 1);
end

for i=StartIndex:EndIndex
    ItemIndex=rem(i, 10);
    if ItemIndex == 0
        ItemIndex=10;
    end
    
    %Preprocess
    PreprocessItem=TableData(i, 2);
    PreprocessItem=PreprocessItem{1};
    TableFormat(2)={PreprocessItem'};
    
    FeatureItem=TableData(i, 6);
    FeatureItem=FeatureItem{1};
    TableFormat(6)={FeatureItem'};
    
    CurrentItem=TableData(i, :);
       
    CurrentItem(2)=PreprocessItem(1);

    CurrentItem(6)=FeatureItem(1);
    
    A=CurrentItem{4};
    CurrentItem(4)=A;
    
    set(handles.(['UITableItem', num2str(ItemIndex)]), 'Visible', 'on', 'Enable', 'on', 'Data', CurrentItem, ...
        'ColumnFormat', TableFormat, 'ColumnEditable', TableEdit, 'ColumnWidth', TableWidth);
end


function UpdateTextPage(handles, GroupNum, TableData)
TextPage=get(handles.TextPage, 'String');

TempIndex=strfind(TextPage, '/');

TotalPage=floor((size(TableData, 1)-1)/10)+1;
set(handles.TextPage, 'String',  [num2str(GroupNum), '/', num2str(TotalPage)]);
