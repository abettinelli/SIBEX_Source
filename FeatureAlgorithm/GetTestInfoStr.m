function InfoStr=GetTestInfoStr(handles)
InfoStr='Preprocess: ';

%Preprocess
PreprocessTestStruct=handles.TestStruct{1};
if ~isempty(PreprocessTestStruct)
    for i=1:length(PreprocessTestStruct)
        InfoStr=[InfoStr, num2str(i), '. ', PreprocessTestStruct(i).Name, ', '];
    end
    InfoStr(end-1:end)=[];
else
    InfoStr=[InfoStr, ' '];
end

%Category
if length(handles.TestStruct) > 1
    CurrentTestStruct=handles.TestStruct{2};    
    InfoStr=[InfoStr, '. Category: ', CurrentTestStruct.Name];
end

%Feature
if length(handles.TestStruct) > 2
    CurrentTestStruct=handles.TestStruct{3};
   
    InfoStr=[InfoStr, '. Feature: ', CurrentTestStruct.Name, '. '];   
end
