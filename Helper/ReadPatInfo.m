function PatInfo=ReadPatInfo(PatientFile)
TextContent=ReadPinnTextFile(PatientFile);

TempIndex=strmatch('LastName', TextContent);
try
    eval(TextContent{TempIndex(1)});
catch
    LastName='';
end

TempIndex=strmatch('FirstName', TextContent);
try
    eval(TextContent{TempIndex(1)});
catch
    FirstName='';
end

TempIndex=strmatch('MiddleName', TextContent);
try
    eval(TextContent{TempIndex(1)});
catch
    MiddleName='';
end

TempIndex=strmatch('MedicalRecordNumber', TextContent);
try
    eval(TextContent{TempIndex(1)});
catch
    MedicalRecordNumber='';
end

TempIndex=strmatch('Comment', TextContent);
try
    eval(TextContent{TempIndex(1)});
catch
    Comment='';
end


PatInfo.LastName=LastName;
PatInfo.FirstName=FirstName;
PatInfo.MiddleName=MiddleName;
PatInfo.MRN=MedicalRecordNumber;
PatInfo.Comment=Comment;