
function   DirNum=GetDirectoryNum(structFilesList)
FieldName=fieldnames(structFilesList);
DirNum=strmatch('isdir', FieldName);
