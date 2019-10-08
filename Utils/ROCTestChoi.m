function Test

NumPatCat1=21;
NumPatCat2=19;
NumPatCat3=14;


FileName='C:\Work\Papers\ClinicStudy\Choi\GTV_Texture_M.xlsm';

SheetName={'Cat1'; 'Cat2'; 'Cat3'};
PostRangeStr={'F6:BG26'; 'F6:BG24'; 'F6:BG19'};
PreRangeStr={'F29:BG49'; 'F27:BG45'; 'F22:BG35'};

OutSheetName={'TTestPost'; 'TTestPre'};
OutRangeStr={'C13:BD15'; 'C13:BD15'};


% FileName='C:\Work\Papers\ClinicStudy\Choi\Geometric_Feature_m.xlsm';
% 
% SheetName={'Cat1'; 'Cat2'; 'Cat3'};
% PostRangeStr={'F6:AL26'; 'F6:AL24'; 'F6:AL19'};
% PreRangeStr={'F29:AL49'; 'F27:AL45'; 'F22:AL35'};
% 
% OutSheetName={'TTestPost'; 'TTestPre'};
% OutRangeStr={'C13:AI15'; 'C13:AI15'};

for j=1:2        
    switch j
        case 1 %Post            
            RangeStr=PostRangeStr;
        case 2 %Pre            
            RangeStr=PreRangeStr;
    end
    
    tic
    Cat1Data=xlsread(FileName, SheetName{1}, RangeStr{1});
    Cat2Data=xlsread(FileName, SheetName{2}, RangeStr{2});
    Cat3Data=xlsread(FileName, SheetName{3}, RangeStr{3});
    toc
    
    ResultData=[];
    for i=1:3
        switch i
            case 1     %Cat1-Cat3
                labels=[ones(NumPatCat1, 1); zeros(NumPatCat3, 1)];
                
                GroupDataA=Cat1Data;
                GroupDataB=Cat3Data;
            case 2   %Cat1-Cat2
                labels=[ones(NumPatCat1, 1); zeros(NumPatCat2, 1)];
                
                GroupDataA=Cat1Data;
                GroupDataB=Cat2Data;
            case 3   %Cat2-Cat3
                labels=[ones(NumPatCat2, 1)*2; zeros(NumPatCat3, 1)];
                
                GroupDataA=Cat2Data;
                GroupDataB=Cat3Data;
        end
        
        TAUC=[];
        for k=1:size(GroupDataA, 2)
            scores=[GroupDataA(:, k); GroupDataB(:, k)];
            [X,Y,T,AUC] = perfcurve(labels, scores,  0);
            
            if AUC < 0.5
                AUC=1-AUC;            
            end
            
            TAUC=[TAUC, AUC];
        end
        
        ResultData=[ResultData; TAUC];
    end
    
    %Out
    xlswrite(FileName, ResultData, OutSheetName{j}, OutRangeStr{j});
    
end


A=1;












