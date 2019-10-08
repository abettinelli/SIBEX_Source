function ImgUIDInfo=GetImgUIDs(PatInfo)

ImgUIDInfo.SeriesUID=[];
ImgUIDInfo.StudyInstanceUID=[];
ImgUIDInfo.FrameUID=[];
ImgUIDInfo.ClassUID=[];
ImgUIDInfo.InstanceUID=[];

ImgUIDInfo.TablePos=[];

InfoFile=[PatInfo.PatDir, '\', 'ImageSet_', PatInfo.ImageID, '.ImageInfo'];
if ~exist(InfoFile, 'file')
    return;
end

ImageInfo=textread(InfoFile, '%s', 'delimiter', '\n');

%SeriesUID
TempIndex=strmatch('TablePosition', ImageInfo);
if ~isempty(TempIndex)
    TablePosT=[];
    for i=1:length(TempIndex)
        TempStr=ImageInfo{TempIndex(i)};
        TempStr=regexprep(TempStr, '"', '''');
        eval(TempStr);
        
        TablePosT=[TablePosT; TablePosition];
    end    
    
    TablePos=TablePosT;
    ImgUIDInfo.TablePos=TablePos;
else
    return;
end

%SeriesUID
TempIndex=strmatch('SeriesUID', ImageInfo);
if ~isempty(TempIndex)
    TempStr=ImageInfo{TempIndex(1)};
    TempStr=regexprep(TempStr, '"', '''');
    eval(TempStr);
    
     ImgUIDInfo.SeriesUID=SeriesUID;
else    
    return;
end

%StudyInstanceUID
TempIndex=strmatch('StudyInstanceUID', ImageInfo);
if ~isempty(TempIndex)
    TempStr=ImageInfo{TempIndex(1)};
    TempStr=regexprep(TempStr, '"', '''');
    eval(TempStr);
    
    ImgUIDInfo.StudyInstanceUID=StudyInstanceUID;
else
    return;
end

%FrameUID----DICOM FrameOfReferenceUID
TempIndex=strmatch('FrameUID', ImageInfo);
if ~isempty(TempIndex)
    TempStr=ImageInfo{TempIndex(1)};
    TempStr=regexprep(TempStr, '"', '''');
    eval(TempStr);
    
    ImgUIDInfo.FrameUID=FrameUID;
else
    return;
end

%ClassUID---No Need
TempIndex=strmatch('ClassUID', ImageInfo);
if ~isempty(TempIndex)
    TempStr=ImageInfo{TempIndex(1)};
    TempStr=regexprep(TempStr, '"', '''');
    eval(TempStr);
    
     ImgUIDInfo.ClassUID=ClassUID;
else
    return;
end

%InstanceUID----DICOM SOP InstanceUID ?
TempIndex=strmatch('InstanceUID', ImageInfo);
if ~isempty(TempIndex)
    InstanceUIDT=[];
    for i=1:length(TempIndex)
        TempStr=ImageInfo{TempIndex(i)};
        TempStr=regexprep(TempStr, '"', '''');
        eval(TempStr);
        
        InstanceUIDT=[InstanceUIDT; cellstr(InstanceUID)];
    end    
    
    InstanceUID=InstanceUIDT;
    
    ImgUIDInfo.InstanceUID=InstanceUID;
else
    return;
end

