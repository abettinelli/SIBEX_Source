function PatsInfo=ReadPatsInfo(handles)
PatsInfo=[];

DirList=GetDirList(handles.PatsParentDir);

if isempty(DirList)    
    return;
end

if isequal(handles.DataFormat, 'Pinnacle')
    for i=1:length(DirList)
        if ~exist([handles.PatsParentDir, '\', DirList{i}, '\Plan'], 'dir')
            PatPath=[handles.PatsParentDir, '\', DirList{i}];
        else
            PatPath=[handles.PatsParentDir, '\', DirList{i}, '\Plan'];
        end
        
        PatientFile=[PatPath, '\Patient'];
        
        if exist(PatientFile, 'file')
            PatInfo=ReadPatInfo(PatientFile);
            
            PatsLen=length(PatsInfo);
            PatsInfo(PatsLen+1).LastName=PatInfo.LastName;
            PatsInfo(PatsLen+1).FirstName=PatInfo.FirstName;
            PatsInfo(PatsLen+1).MiddleName=PatInfo.MiddleName;
            PatsInfo(PatsLen+1).MRN=PatInfo.MRN;
            PatsInfo(PatsLen+1).Comment=PatInfo.Comment;
            PatsInfo(PatsLen+1).Directory=DirList{i};            
        end        
    end
    
    if ~isempty(PatsInfo)
        PatsInfo=sortStruct(PatsInfo, 'LastName');
    end
end


