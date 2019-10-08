function HeaderCell=ExtendResultHeaderCell(FeatureInfo, kkk, Mode, HeaderCell, ResultCCell)
switch Mode
    case '1Column'
        TempStr=cellstr(num2str(FeatureInfo(kkk).FeatureValueParam));
        HeaderExt=strcat(TempStr, FeatureInfo(kkk).Name)';
    case '2MoreColumn'
        HeaderExt=[];
        for iii=1:length(FeatureInfo(kkk).FeatureValueParam)
            for lll=1:size(FeatureInfo(kkk).FeatureValue, 1)
                HeaderExt=...
                    [HeaderExt, {[num2str(FeatureInfo(kkk).FeatureValueParam(iii)), '-', num2str(FeatureInfo(kkk).FeatureValue(lll, 1)), FeatureInfo(kkk).Name]}];
            end
        end
end

LenResult=length(ResultCCell);
BackStr=HeaderCell(1, LenResult+1);

% HeaderExtFirst=repmat({' '}, 1, length(HeaderExt));
HeaderExtFirst=repmat(BackStr, 1, length(HeaderExt));

A=[HeaderCell(1, 1:LenResult), HeaderExtFirst, HeaderCell(1, LenResult+2:end)];
B=[HeaderCell(2, 1:LenResult), HeaderExt, HeaderCell(2, LenResult+2:end)];

HeaderCell=[A; B];

HeaderCell(1, LenResult+1)=BackStr;