function StrValue=GetHtmlValue(HtmlStr)
if ~iscell(HtmlStr)
    StrValue=GetStrValue(HtmlStr);    
else
    StrValue=[];
    for i=1:length(HtmlStr)
        THtmlStr=HtmlStr{i};
        TStrValue=GetStrValue(THtmlStr);
        
        StrValue=[StrValue; {TStrValue}];
    end
end


function StrValue=GetStrValue(HtmlStr)
TempIndex=strfind(HtmlStr, '>');
if ~isempty(TempIndex)
    StrValue=HtmlStr(TempIndex(end)+1:end);
else
    StrValue=[];
end