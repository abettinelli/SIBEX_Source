function ImgUIDInfo=NewDCMImageUID(NumSlice, PatInfo)

ImgUIDInfo.SeriesUID=dicomuid;
ImgUIDInfo.StudyInstanceUID=dicomuid;
ImgUIDInfo.FrameUID=dicomuid;
ImgUIDInfo.ClassUID='1.2.840.10008.5.1.4.1.1.2';

NumSlice=str2num(NumSlice);

ImgUIDInfo.InstanceUID=[];
for i=1:NumSlice
    ImgUIDInfo.InstanceUID=[ImgUIDInfo.InstanceUID; {dicomuid}];
end

%Table Pos
InfoFile=[PatInfo.PatDir, '\', 'ImageSet_', PatInfo.ImageID, '.ImageInfo'];

if exist(InfoFile, 'file')
    ImageInfo=textread(InfoFile, '%s', 'delimiter', '\n');
    
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
        ImgUIDInfo.TablePos=PatInfo.ZStart+((1:NumSlice)-1)*PatInfo.ZPixDim;
    end
else
    ImgUIDInfo.TablePos=PatInfo.ZStart+((1:NumSlice)-1)*PatInfo.ZPixDim;
end



