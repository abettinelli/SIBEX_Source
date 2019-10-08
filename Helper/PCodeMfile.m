function PCodeMfile(InputPath)

OldPath=pwd;

InputPathTot={'C:\Work\MyProgram\Matlab\ImageFeatureOutcomeAnalysis_PCode'; ...
    'C:\Work\MyProgram\Matlab\ImageFeatureOutcomeAnalysis_PCode\FeatureAlgorithm'; ...
     'C:\Work\MyProgram\Matlab\ImageFeatureOutcomeAnalysis_PCode\FeatureAlgorithm\Category'; ...     
     'C:\Work\MyProgram\Matlab\ImageFeatureOutcomeAnalysis_PCode\ImportExport'; ...
     'C:\Work\MyProgram\Matlab\ImageFeatureOutcomeAnalysis_PCode\ImportExport\ImportModule'};

for j=1:length(InputPathTot)
    InputPath=InputPathTot{j};
    
    if j == 1
        cd(InputPath);

        pcode *.m;

        delete('*.m');
        delete('*.asv');
        delete('*.c');
        delete('*.cpp');
        delete('*.dsw');
        delete('*.dsp');
        delete('*.ncb');
        delete('*.opt');
    end
    
    %get the file list in the given directory
    structFilesList = dir(InputPath);
    structFilesList(1:2) = [];    %delete the default system directory name

    %Convert struct FilesList to char array
    cellFilesList=struct2cell(structFilesList);
    cellFilesName=cellFilesList(1,:);

    %Delete folder name
    TempDirFlag=cellFilesList(4,:);
    TempDirFlag=cell2mat(TempDirFlag);

    TempDirOrder=find(TempDirFlag);

    if isempty(TempDirOrder)
        cellFilesName(TempDirOrder)=[];
    end

    charFilesName=char(cellFilesName');

    cellDirName=cellstr(charFilesName);

    for i=1:length(cellDirName)
        
        if ~exist([InputPath, '\', cellDirName{i}], 'dir')
            continue;
        end
        
        cd([InputPath, '\', cellDirName{i}]);

        pcode *.m;

        delete('*.m');
        delete('*.asv');
        delete('*.c');
        delete('*.cpp');
        delete('*.dsw');
        delete('*.dsp');
        delete('*.ncb');
        delete('*.opt');
        
    end
end

cd(OldPath);

disp('Done');
