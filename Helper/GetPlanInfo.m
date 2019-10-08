function PlanInfo=GetPlanInfo(PatInfoO)
%Plan Name
PlanNameStr=[];
PlanNameIndex=strmatch('PlanName', PatInfoO);
cellPlanName=PatInfoO(PlanNameIndex);

for i=1:length(cellPlanName)      
    eval(cellPlanName{i});
    PlanNameStr=[PlanNameStr; {PlanName}];    
end

%Plan PrimarySetID
PlanPrimayImageID=[];
PlanNameIndex=strmatch('PrimaryCTImageSetID', PatInfoO);
cellPlanName=PatInfoO(PlanNameIndex);

for i=1:length(cellPlanName)      
    eval(cellPlanName{i});
    PlanPrimayImageID=[PlanPrimayImageID; {PrimaryCTImageSetID}];    
end


%Plan ID
PlanIDList=[];
PlanNameIndex=strmatch('PlanID', PatInfoO);
cellPlanName=PatInfoO(PlanNameIndex,:);

for i=1:length(cellPlanName)
    eval(cellPlanName{i});
    PlanIDList=[PlanIDList; PlanID];
end


PlanSectionIndex=strmatch('PlanList', PatInfoO);
if ~isempty(PlanSectionIndex)
    PlanSecton=PatInfoO(PlanSectionIndex(1):end);
    
    %Plan Comment
    PlanComment=[];
    PlanNameIndex=strmatch('Comment ', PlanSecton);
    cellPlanName=PlanSecton(PlanNameIndex);
    
    for i=1:length(cellPlanName)
        try
            eval(cellPlanName{i});
        catch
            Comment=' ';
        end
        PlanComment=[PlanComment; {Comment}];
    end
    
    %Plan Dosimetrist
    PlanDosimetrist=[];
    PlanNameIndex=strmatch('Dosimetrist ', PlanSecton);
    cellPlanName=PlanSecton(PlanNameIndex);
    
    for i=1:length(cellPlanName)
        try
            eval(cellPlanName{i});
        catch
            Dosimetrist='';
        end
        
        PlanDosimetrist=[PlanDosimetrist; {Dosimetrist}];
    end
else
    PlanComment=[];
    PlanDosimetrist=[];   
end

%Get fusion ID
if ~isempty(PlanSectionIndex)
          
    PlanSecton=PatInfoO(PlanSectionIndex(1):end);
    
    TempIndexStart=strmatch('FusionIDArray', PlanSecton);
    TempIndexEnd=strmatch('PrimaryImageType ', PlanSecton);
    
    if ~isempty(TempIndexStart)
        for i=1:length(TempIndexStart)
            FusionIDSection=PlanSecton(TempIndexStart(i):TempIndexEnd(i));
            
            TempIndexValue=strmatch('Value', FusionIDSection);
            if ~isempty(TempIndexValue)
                PlanFusionIDList(i).IDIndex=[];
                for j=1:length(TempIndexValue)
                    eval(FusionIDSection{TempIndexValue(j)});
                    PlanFusionIDList(i).IDIndex=[PlanFusionIDList(i).IDIndex; Value];
                end
            else
                PlanFusionIDList(i).IDIndex=[];
            end
        end
    else
        PlanFusionIDList=[];
    end
else
    PlanFusionIDList=[];    
end

%Save
PlanInfo.PlanNameStr=PlanNameStr;
PlanInfo.PlanIDList=PlanIDList;
PlanInfo.PlanComment=PlanComment;
PlanInfo.PlanDosimetrist=PlanDosimetrist;
PlanInfo.PlanFusionIDList=PlanFusionIDList;
PlanInfo.PlanPrimayImageID=PlanPrimayImageID;
