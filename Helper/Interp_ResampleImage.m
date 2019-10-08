function SuccessFlag=Interp_ResampleImage(ProgramPath, ConfigFile)
%Path
UtilsPath=[ProgramPath, 'Utils'];

%Status file
statusFile=[UtilsPath, '\Reformate_', datestr(now, 30), '.status'];

%Action
launch_command = [UtilsPath, '\Reformate ',  '"', ConfigFile,'"',  ' "', statusFile,'"' ];
[Status, Result]=dos(launch_command);

status_info = textread(statusFile, '%s', 'delimiter', '\n');
tline = status_info{1,:};
        
if strcmp(tline,'success') 
    SuccessFlag=1;      
else    
    SuccessFlag=0;  
end

delete(ConfigFile);
delete(statusFile);