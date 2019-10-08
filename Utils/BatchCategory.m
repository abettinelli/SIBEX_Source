function BatchCategory

tic

%DataSet
% DataSetFile='D:\DataIFOA\Joy\CTPETHole_PreCT\1FeatureDataSet_ImageROI\DateSet_PreCTYesHole.mat';

% FigName='Hole Group Smooth Edge';

% DataSetFile='D:\DataIFOA\Joy\CTPETHole_PreCT\1FeatureDataSet_ImageROI\DateSet_PreCTNoHole.mat';

%Pre-process
PrePath='C:\Work\MyProgram\Matlab\ImageFeatureOutcomeAnalysis\FeatureAlgorithm\Preprocess\';


% TPreName={'EdgePreserve_Smooth3D'; 'Threshold_Image_Mask'; 'Laplacian_Filter'};
% % TPreName={'EdgePreserve_Smooth3D'; 'Threshold_Image_Mask'};
% Type='Aniso';
% ParaRange=[5, 10:10:110];

% TPreName={'Gaussian_Smooth'; 'Threshold_Image_Mask'; 'Laplacian_Filter'};
% % TPreName={'Gaussian_Smooth'; 'Threshold_Image_Mask'};
% Type='Gauss';
% ParaRange=0.1:0.2:2.3;
% GasussSize=11;

% TPreName={ 'Threshold_Image_Mask'; 'Log_Filter'};
% TPreName={'Threshold_Image_Mask'; 'Threshold_Image_Mask'; 'Laplacian_Filter'};

% TPreName={'Threshold_Image_Mask'; 'Log_Filter'};
% TPreName={'Threshold_Mask'; 'LogW_Filter'};
% Type='Gauss';
% ParaRange=0.1:0.2:2.3;
% GasussSize=11;

% TPreName={'Threshold_Image_Mask'; 'Laplacian_Filter'};
% TPreName={'Threshold_Image_Mask'};
% Type='None';
% ParaRange=1;


% TPreName={'EdgePreserve_Smooth3D'; 'Threshold_Image_Mask'};
TPreName={'Gaussian_Smooth'; 'Threshold_Image_Mask'};
Type='Gauss';
%ParaRange=0.1:0.2:2.3;
ParaRange=0.1:0.2:2.3;
GasussSize=11;

ResultInfoT=[]; NameMat={[]}; GroupMat=[]; ResultInfoTT=[]; ResultInfo=[];
for jjj=1:length(ParaRange)
    ResultInfoT=[];
    for kkk=1:2
        if kkk == 2
            DataSetFile='D:\DataIFOA\Joy\CTPETHole\1FeatureDataSet_ImageROI\Data_PTNoHole.mat';
        end
        
        if kkk == 1
            DataSetFile='D:\DataIFOA\Joy\CTPETHole\1FeatureDataSet_ImageROI\Data_PTYesHole.mat';
        end
        
        
        for i=1:length(TPreName)
            PreName=TPreName{i};
            PreFile=[PrePath, PreName, '.INI'];
            
            if exist(PreFile, 'file')
                Param=GetParamFromINI(PreFile);
            else
                Param=[];
            end
            
            if i == 2
               switch Type
                   case 'Gauss'
                       Param.Sigma=ParaRange(jjj);
                       Param.Size=GasussSize;
                       
                   case 'Aniso'
                       Param.Kappa=ParaRange(jjj);
               end
           end
            
            TestStruct(i).Name=PreName;
            TestStruct(i).Value=Param;                      
            %TestStruct(i)
        end
        
        
        %Skewness Feature
        CatPath='C:\Work\MyProgram\Matlab\ImageFeatureOutcomeAnalysis\FeatureAlgorithm\Category\';
        
        %Feature temp
        TConfigFile=[CatPath, 'IntensityHistogram', '\', 'IntensityHistogram', '_Category.INI'];
        TParam=GetParamFromINI(TConfigFile);
        TFHandleC=str2func(['IntensityHistogram', '_Category']);
        
        %Feature to be computed
        FeatureName='IntensityDirect';
        % FeatureName='IntensityHistogram';
        ConfigFile=[CatPath, FeatureName, '\', FeatureName, '_Category.INI'];
        
        Param=GetParamFromINI(ConfigFile);
        
        FHandleC=str2func([FeatureName, '_Category']);
        
        FHandleF=str2func([FeatureName, '_Feature']);
        
%             FeatureInfo(1).Name='Kurtosis';
           FeatureInfo(1).Name='Skewness';
        %FeatureInfo(1).Name='GlobalEntropy';
%         FeatureInfo(1).Name='GlobalUniformity';
%         FeatureInfo(1).Name='GlobalEntropy';
        
        FPara=GetParamFromINI([CatPath, FeatureName, '\', FeatureName, '_Feature', '_',FeatureInfo(1).Name,  '.INI']);
        FeatureInfo(1).Value=FPara;
        
        %Intensity Range Low
        GrayLow=980;
        
        ResultInfo=[];
        load(DataSetFile);
        for i=1:size(DataSetsInfo)
            DataItemInfo=DataSetsInfo(i);
            
            TempIndex=strmatch('REDDIC', DataItemInfo.DBName);
            if ~isempty(TempIndex)
                A=1;
            end
            
            %Intensity Range Up
            GrayUp=GetGrayUp(TestStruct, DataItemInfo, TParam, TFHandleC, GrayLow);
            
            GrayUp=1180;
            
            TestStruct(2).Value.ThresholdLow=GrayLow;
            TestStruct(2).Value.ThresholdHigh=GrayUp;
            TestStruct(2).Value.ErosionDist=0;
            
            DataItemInfo=PreprocessImage(TestStruct, DataItemInfo);
            
            ParentInfo=FHandleC(DataItemInfo, 'Child', Param);
            
            FeatureInfo=FHandleF(ParentInfo, FeatureInfo, 'NoReview');
                       
            if jjj == 1
                TempIndex=strmatch('(5)', DataItemInfo.DBName);
                
                if ~isempty(TempIndex)
                    NameMat=[NameMat; {DataItemInfo.DBName(5:end)}];
                else
                    NameMat=[NameMat; {DataItemInfo.DBName}];
                end
                
                GroupMat=[GroupMat; kkk];
            end
            
            ResultInfo=[ResultInfo; FeatureInfo(1).FeatureValue];            
        end        
        
        
        ResultInfoT=[ResultInfoT; ResultInfo];                
    end
    
    ResultInfoTT=[ResultInfoTT, ResultInfoT];    
end

toc

ResultInfoTT=[NameMat(2:end), num2cell(ResultInfoTT), num2cell(GroupMat)];

A=1;


%Gauss Fit Feature
ConfigFile='C:\Work\MyProgram\Matlab\ImageFeatureOutcomeAnalysis\FeatureAlgorithm\Category\IntensityHistogramGaussFit\IntensityHistogramGaussFit_Category.INI';

load(DataSetFile);

Param=GetParamFromINI(ConfigFile);

figure, set(gcf, 'Name', FigName);
for i=1:size(DataSetsInfo)
    DataItemInfo=DataSetsInfo(i);
    
    DataItemInfo=PreprocessImage(TestStruct, DataItemInfo);
    
    ParentInfo=IntensityHistogramGaussFit_Category(DataItemInfo, 'Review', Param);
    
%     subplot_tight(4, ColNum, i);
    subplot(4, ColNum, i);

    %Original Hist
%     hold on, plot(ParentInfo.HistDataOri(:, 1), ParentInfo.HistDataOri(:, 2), 'b');
        
    %Smooth Hist
    hold on, plot(ParentInfo.HistData(:, 1), ParentInfo.HistData(:, 2), 'b');
    
%     %Fitted gaussian
%     hold on, plot(ParentInfo.CurvesInfo(4).CurveData(:, 1), ParentInfo.CurvesInfo(4).CurveData(:, 2), 'g-');
%     
%     %Individual gaussian
%     hold on, plot(ParentInfo.CurvesInfo(2).CurveData(:, 1), ParentInfo.CurvesInfo(2).CurveData(:, 2), 'r');
%     hold on, plot(ParentInfo.CurvesInfo(3).CurveData(:, 1), ParentInfo.CurvesInfo(3).CurveData(:, 2), 'r');    
    
    set(gca, 'YLim', [0, 0.11]);
        
    %Title
    title(DataItemInfo.DBName);    
end

toc

A=1;


%--------------------Utilities----------------%
function Param=GetFPara(PreFile)
if exist(PreFile, 'file')
    Param=GetParamFromINI(PreFile);
else
    Param=[];
end


function GrayUp=GetGrayUp(TestStruct, DataItemInfo, Param, FHandleC, GrayLow)
TTestStruct=TestStruct(1);
TDataItemInfo=PreprocessImage(TTestStruct, DataItemInfo);

TParentInfo=FHandleC(TDataItemInfo, 'Review', Param);

HistData=TParentInfo.MaskData;

BinLoc=HistData(:, 1);
BinProp=HistData(:, 2);

GrayLowProp=interp1(BinLoc, BinProp, GrayLow);

TempIndex=find(BinProp > GrayLowProp);

TProp=[BinProp(TempIndex(end)), BinProp(TempIndex(end)+1)];
TLoc=[BinLoc(TempIndex(end)), BinLoc(TempIndex(end)+1)];

GrayUp=interp1(TProp, TLoc, GrayLowProp);


A=1;

    


