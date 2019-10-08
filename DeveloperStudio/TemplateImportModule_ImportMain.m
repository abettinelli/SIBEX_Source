function ReturnFlag=TemplateImportModule_ImportMain(IbexEnvStruct)

%Purpose:         To import the external data into IBEX database
%Architecture:   All the importer-relevant files are under \IBEXCodePath\ImportExport\ImportModule\*ImporterName*\
%Files:              *ImporterName*ImportMain.m, *ImporterName*ImportMain.INI

%%---------------Input Parameters Passed by IBEX-------------%
%IbexEnvStruct:            a structure telling the information on IBEX enviroment
%IbexEnvStruct.figure1: handle of the main figure

%IbexEnvStruct.INIConfigInfo.DataDir:        database path
%IbexEnvStruct.INIConfigInfo.CurrentUser:  user in Location
%IbexEnvStruct.INIConfigInfo.CurrentSite:   site in Location

%%--------------Output Parameters------------%
%ReturnFlag:     1: succeed. 0: Fail

%///////////////////////////////////////////////////////////////////////////////////////////////////////////////////%
%-----------------------------DO_NOT_CHANGE_STARTS--------------------------%
%%-----------TemplateImportModule_ImportMain.INI------%
%Load the default parameters from INI
[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

ConfigFile=[MFilePath, '\', MFileName, '.INI'];
Param=GetParamFromINI(ConfigFile);
%-----------------------------DO_NOT_CHANGE_ENDS------------------------------%
%///////////////////////////////////////////////////////////////////////////////////////////////////////////////////%


%///////////////////////////////////////////////////////////////////////////////////////////////////////////////////%
%%-----------Implement your code starting from here---------%
%---Explore variables by display
IbexEnvStruct
IbexEnvStruct.INIConfigInfo
PatDataPath=[IbexEnvStruct.INIConfigInfo.DataDir, '\', IbexEnvStruct.CurrentUser, '\', IbexEnvStruct.CurrentSite];
disp(PatDataPath);

Param
Param.DataPathIn


%****The skeleton importer copys the example patient to the local database****%

%New Patient Path
NewPatPath=[IbexEnvStruct.INIConfigInfo.DataDir, '\', IbexEnvStruct.CurrentUser, '\', IbexEnvStruct.CurrentSite, '\Pat', datestr(now, 30)];

%---Replace this with your own implementation-----Copy example patient Starts
TempIndex=strfind(MFilePath, '\');
DeveloperStudioPath=[MFilePath(1:TempIndex(end-2)), '\DeveloperStudio'];

copyfile([DeveloperStudioPath, '\ImportExample\*.*'], NewPatPath)

MsgboxGuiIFOA('Example patient is successfully imported.', 'Confirm', 'help', 'modal');
%---Replace this with your own implementation-----Copy example patient Ends

%---Return Value
ReturnFlag=1;















