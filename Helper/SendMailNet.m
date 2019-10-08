function ReturnFlag=SendMailNet(MailInfo)

ReturnFlag=0;

[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

TempIndex=strfind(MFilePath, '\');
ProgramPath=MFilePath(1:TempIndex(end));

try 
    %Check .NET framework V4.0 or above available
    [Status, Result]=dos([ProgramPath, 'Utils\clrver.exe']);
    
    TempIndex=strfind(Result, 'Versions installed on the machine:');    
    if isempty(TempIndex)
        return;
    end

    VerInfo=Result(TempIndex(1)+length('Versions installed on the machine:'):end);
    TempIndex=strfind(VerInfo, 'v');
    if isempty(TempIndex)
        return;
    end
    
    VerInfo=textscan(VerInfo, '%s');
    VerInfo=VerInfo{1};
    VerInfo=char(VerInfo);
    VerInfo(:, 1)=[];
    VerInfo=VerInfo(:, 1:3);
    VerInfo=str2double(cellstr(VerInfo));
    TempIndex=find(VerInfo>3);
    if isempty(TempIndex)
        return;
    end             
    
    %Add Assembly
    NET.addAssembly([ProgramPath, 'Utils\EASendMail.dll']);
    NET.addAssembly([ProgramPath, 'Utils\InfoComputer.dll']);
    
    %Get computer information
    InfoComp=InfoComputer.Info();
    
    HostName=InfoComp.GetHostName();
    IP=InfoComp.GetIP();
    Domain=InfoComp.GetDomain();
    UserName=InfoComp.GetUserName();
    
    %Send mail
    oMail = EASendMail.SmtpMail('TryIt');
    oMail.Subject='New User of IBEX V 1.0';
    oMail.From=EASendMail.MailAddress('IBEX', 'lifzhang@mdanderson.org');
    
    Addr=NET.createArray('EASendMail.MailAddress', 2);
    Addr(1)=EASendMail.MailAddress('lifzhang@mdanderson.org');
    Addr(2)=EASendMail.MailAddress('lecourt@mdanderson.org');

    AddrList=EASendMail.AddressCollection;
    AddRange(AddrList, Addr);  
    
    oMail.To=AddrList;   
    
    if nargin < 1
        oMail.TextBody=['HostName: ', char(HostName), sprintf('\n'), ' IP: ', char(IP), sprintf('\n'), ' Domain: ', char(Domain), sprintf('\n'), ...
            'UserName: ', char(UserName), sprintf('\n'), sprintf('\n'), sprintf('\n'), 'Sent from IBEX'];
    else
        oMail.Subject=MailInfo.Subject;
        
        if ischar(MailInfo.Body)
            MailInfo.Body={MailInfo.Body};
        end
        
        TextBody=['IBEX Bug Report/Feedback', sprintf('\n'), '-----------------------User Information------------------------', ...
             sprintf('\n'), 'Date: ', datestr(now, 31), sprintf('\n')];
         TextBody=[TextBody, 'HostName: ', char(HostName), sprintf('\n'), ' IP: ', char(IP), sprintf('\n'), ' Domain: ', char(Domain), sprintf('\n'), ...
            'UserName: ', char(UserName), sprintf('\n'), 'Email: ',  MailInfo.SenderEmail, sprintf('\n'), sprintf('\n'), ...
            '-----------------------From User Starts------------------------',  sprintf('\n'), sprintf('\n'), My_strjoin(MailInfo.Body, sprintf('\n')), sprintf('\n'), ...
            '-----------------------From User Ends-------------------------'];
        
        oMail.TextBody=TextBody;
        
        if exist(MailInfo.Attachment, 'file')
            oMail.AddAttachment(MailInfo.Attachment);
        end
    end
    
    oSmtp=EASendMail.SmtpClient();    
    oServer=EASendMail.SmtpServer(' ');
    
    try
        oSmtp.SendMail(oServer, oMail);      
        
        ReturnFlag=1;
    catch e
        e.message
        if isa(e, 'NET.NetException')
            e.ExceptionObject
        end       
    end       
catch
    
end




