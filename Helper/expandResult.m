function [EResultCell, EInfoCatAbbreviation, EInfoCategoryName, EInfoCategoryID, EInfoFeatureName, EInfoFeatureID]=expandResult(ResultCell, InfoCatAbbreviation, InfoCategoryName, InfoCategoryID, InfoFeatureName, InfoFeatureID)

EResultCell = ResultCell;
EInfoCatAbbreviation = InfoCatAbbreviation;
EInfoCategoryName = InfoCategoryName;
EInfoCategoryID = InfoCategoryID;
EInfoFeatureName = InfoFeatureName;
EInfoFeatureID = InfoFeatureID;

% EXPAND HIST LIKE
s1=cellfun('size',EResultCell,1);
s2=cellfun('size',EResultCell,2);
s1=max(s1);
s2=max(s2);
flag1 = s1>1 & s2==1;
for i = 1:nnz((flag1 == 1))
    s1=cellfun('size',EResultCell,1);
    s2=cellfun('size',EResultCell,2);
    s1=max(s1);
    s2=max(s2);
    flag = s1>1 & s2==1;
    
    %Index current feature
    curr_idx = find(flag == 1,1,'first');
%     ResultCellMultiple=cell(size(EResultCell(:,curr_idx)));
    ResultCellMultiple=EResultCell(:,curr_idx);
    
    % Number of values and fill empty
    s1_c=cellfun('size',ResultCellMultiple,1);
    n_distinc_values = max(s1_c);
    ResultCellMultiple(cellfun(@isempty,ResultCellMultiple))={NaN(1,n_distinc_values)};
    
    for l = n_distinc_values:-1:1
        
        curr_col = cellfun(@(x)x(l),ResultCellMultiple, 'UniformOutput', false);
        EResultCell=[EResultCell(:,1:curr_idx) curr_col EResultCell(:,curr_idx+1:end)];
        
        % HEADER
        EInfoCatAbbreviation = [EInfoCatAbbreviation(1:curr_idx) EInfoCatAbbreviation(curr_idx) EInfoCatAbbreviation(curr_idx+1:end)];
        EInfoCategoryName    = [EInfoCategoryName(1:curr_idx) EInfoCategoryName(curr_idx) EInfoCategoryName(curr_idx+1:end)];
        EInfoCategoryID      = [EInfoCategoryID(1:curr_idx) EInfoCategoryID(curr_idx) EInfoCategoryID(curr_idx+1:end)];
        EInfoFeatureName     = [EInfoFeatureName(1:curr_idx) strcat({'[PARAM '},num2str(l),{'] '},EInfoFeatureName(curr_idx)) EInfoFeatureName(curr_idx+1:end)];
        EInfoFeatureID       = [EInfoFeatureID(1:curr_idx) EInfoFeatureID(curr_idx) EInfoFeatureID(curr_idx+1:end)];
    end
    EResultCell(:,curr_idx) = [];
    EInfoCatAbbreviation(curr_idx) = [];
    EInfoCategoryName(curr_idx) = [];
    EInfoCategoryID(curr_idx) = [];
    EInfoFeatureName(curr_idx) = [];
    EInfoFeatureID(curr_idx) = [];
end


% EXPAND GLCM LIKE
s1=cellfun('size',EResultCell,1);
s2=cellfun('size',EResultCell,2);
s1=max(s1);
s2=max(s2);
flag2 = s1>=1 & s2>1;
for i = 1:nnz(flag2 == 1)
    s1=cellfun('size',EResultCell,1);
    s2=cellfun('size',EResultCell,2);
    s1=max(s1);
    s2=max(s2);
    flag = s1>=1 & s2>1;

    %Index current feature
    curr_idx = find(flag == 1,1,'first');
%     ResultCellMultiple=cell(size(EResultCell(:,curr_idx)));
%     ResultCellOffset=cell(size(EResultCell(:,curr_idx)));
    ResultCellMultiple=cellfun(@(x)x(1:end,2:end),EResultCell(:,curr_idx), 'UniformOutput', false);
    ResultCellOffset=cellfun(@(x)x(1:end,1),EResultCell(:,curr_idx), 'UniformOutput', false);
    
    % Number of values and fill empty
    s1_c=cellfun('size',ResultCellMultiple,1);
    n_distinc_values = max(s1_c);
    ResultCellMultiple(cellfun(@isempty,ResultCellMultiple))={NaN(1,n_distinc_values)};
    
    for l = n_distinc_values:-1:1
        
        curr_col = cellfun(@(x)x(l),ResultCellMultiple, 'UniformOutput', false);
        EResultCell=[EResultCell(:,1:curr_idx) curr_col EResultCell(:,curr_idx+1:end)];
        
        % HEADER
        EInfoCatAbbreviation = [EInfoCatAbbreviation(1:curr_idx) EInfoCatAbbreviation(curr_idx) EInfoCatAbbreviation(curr_idx+1:end)];
        EInfoCategoryName    = [EInfoCategoryName(1:curr_idx) EInfoCategoryName(curr_idx) EInfoCategoryName(curr_idx+1:end)];
        EInfoCategoryID      = [EInfoCategoryID(1:curr_idx) EInfoCategoryID(curr_idx) EInfoCategoryID(curr_idx+1:end)];
        EInfoFeatureName     = [EInfoFeatureName(1:curr_idx) strcat({'[OFFSET '},num2str(l),{'] '},EInfoFeatureName(curr_idx)) EInfoFeatureName(curr_idx+1:end)];
        EInfoFeatureID       = [EInfoFeatureID(1:curr_idx) EInfoFeatureID(curr_idx) EInfoFeatureID(curr_idx+1:end)];
    end
    EResultCell(:,curr_idx) = [];
    EInfoCatAbbreviation(curr_idx) = [];
    EInfoCategoryName(curr_idx) = [];
    EInfoCategoryID(curr_idx) = [];
    EInfoFeatureName(curr_idx) = [];
    EInfoFeatureID(curr_idx) = [];
end