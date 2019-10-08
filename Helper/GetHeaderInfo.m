function HeaderInfo=GetHeaderInfo(PlanDestPath, ReadCommentFlag)

FileList=GetFileList(PlanDestPath);
if isempty(FileList)
    HeaderInfo=[];
    return;
end


FileList=char(FileList);

FileList=strjust(FileList, 'right');
FileListEnd=FileList(:, end-5:end);
FileList=strjust(FileList, 'left');
FileList=cellstr(FileList);


TempIndex=strmatch('header', FileListEnd);

if isempty(TempIndex)
    HeaderInfo=[];
    return;
end

for i=1:length(TempIndex)
    HeaderFile=[PlanDestPath, '\', FileList{TempIndex(i)}];
    [Modality, ImageID, MRN, DBName, ScanTime, NumberofSlice, SeiresDes, Comment]=GetHeaderDescription(HeaderFile);
    
    HeaderInfo(i).Modality=Modality;
    HeaderInfo(i).ID=ImageID;
    HeaderInfo(i).MRN=MRN;
    HeaderInfo(i).DBName=DBName;
    HeaderInfo(i).ScanTime=ScanTime;
    HeaderInfo(i).Slices=NumberofSlice;
    if ReadCommentFlag > 0
        HeaderInfo(i).Comment=Comment;    
    end    
    HeaderInfo(i).SeriesInfo=SeiresDes;    
end


function [Modality, ImageID, MRN, DBName, ScanTime, NumberofSlice, SeiresDes,Comment]=GetHeaderDescription(HeaderFile)

HeaderInfo=ReadPinnTextFile(HeaderFile);

%Modality
TempIndex=strmatch('modality', HeaderInfo);
if ~isempty(TempIndex)    
    TempStr=HeaderInfo{TempIndex(1)};    
    Modality=GetTextStrValue(TempStr);
else
    Modality='';
end

TempIndexStart=strfind(HeaderFile, '_');
TempIndexEnd=strfind(HeaderFile, '.');

%ImageID
ImageID=HeaderFile(TempIndexStart(end)+1:TempIndexEnd(end)-1);

%MRN
TempIndex=strmatch('patient_id', HeaderInfo);
if ~isempty(TempIndex)
    TempStr=HeaderInfo{TempIndex(1)};    
    MRN=GetTextStrValue(TempStr);
else
    MRN='';
end

%DB Name
TempIndex=strmatch('db_name', HeaderInfo);
if ~isempty(TempIndex)
    TempStr=HeaderInfo{TempIndex(1)};    
    DBName=GetTextStrValue(TempStr);
else
    DBName='';
end

%Scan Time
TempIndex=strmatch('SeriesDateTime', HeaderInfo);
if ~isempty(TempIndex)
    TempStr=HeaderInfo{TempIndex(1)};    
    ScanTime=GetTextStrValue(TempStr);
else
    TempIndex=strmatch('date', HeaderInfo);
    if ~isempty(TempIndex)
        TempStr=HeaderInfo{TempIndex(1)};
        ScanTime=GetTextStrValue(TempStr);
    else        
        ScanTime='';
    end
end

%Series Description
TempIndex=strmatch('Series_Description', HeaderInfo);
if ~isempty(TempIndex)
    TempStr=HeaderInfo{TempIndex(1)};    
    SeiresDes=GetTextStrValue(TempStr);
else
    SeiresDes='';
end

%Number of Slice
TempIndex=strmatch('z_dim', HeaderInfo);
if ~isempty(TempIndex)
    TempStr=HeaderInfo{TempIndex(1)};    
    eval(TempStr);
    
    NumberofSlice=num2str(z_dim);
else
    NumberofSlice='';
end

%Comment
TempIndex=strmatch('comment', HeaderInfo);
if ~isempty(TempIndex)
    TempStr=HeaderInfo{TempIndex(1)};    
    Comment=GetTextStrValue(TempStr);
else
    Comment='';
end



function PropValueStr=GetTextStrValue(ValueStr)
TempIndex=strfind(ValueStr, ':');
ValueStr=ValueStr(TempIndex(1)+1:end);    
PropValueStr=strtrim(ValueStr);
