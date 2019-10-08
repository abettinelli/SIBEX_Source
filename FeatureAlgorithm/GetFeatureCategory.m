function Category=GetFeatureCategory
Category=[];

[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

CategoryPath=[MFilePath, '\Category'];

FileList=GetFileList(CategoryPath);
FileList=FilterFileList(FileList, '_Category.m');

if ~isempty(FileList)
    Category=RemoveTrailStr(FileList, '_Category.m');    
end

