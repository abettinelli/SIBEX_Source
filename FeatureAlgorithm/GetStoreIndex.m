function ItemIndex=GetStoreIndex(Module, handles, Mode)
switch Mode
    case 'Preprocess'
        ParaStore=handles.ParaStore;
    case 'Category'
        ParaStore=handles.CategoryStore;
end

if isempty(ParaStore)
    ItemIndex=1;
else
    ModuleName={ParaStore.Name}';
    
    TempIndex=strmatch(Module, ModuleName, 'exact');
    if ~isempty(TempIndex)
        ItemIndex=TempIndex;
    else
        ItemIndex=length(ParaStore)+1;
    end
end
