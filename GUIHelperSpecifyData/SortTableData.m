function [TableDataItemID, TableData]=SortTableData(TableData, SortByStr, TableHeader, TableDataItemID)
TempIndex=strmatch(SortByStr, TableHeader, 'exact');

try
    %Char Type    
    [SortItem, SortIndex]=sort(TableData(:, TempIndex));
catch
    try
        %Numeric Type
        [SortItem, SortIndex]=sort(cell2mat(TableData(:, TempIndex)));           
    catch
        try
            %Feature Cell Category
            A=TableData(:, TempIndex);
            
            SortData=[];
            for i=1:length(A)
                SortData=[SortData; A{i}];
            end
            
            [SortItem, SortIndex]=sort(SortData);
        catch
            return;
        end
    end
end

SortIndex=flipdim(SortIndex, 1);

for i=1:size(TableData, 2)
    A=TableData(:, i);
    TableData(:, i)=A(SortIndex);
end

TableDataItemID=TableDataItemID(SortIndex);