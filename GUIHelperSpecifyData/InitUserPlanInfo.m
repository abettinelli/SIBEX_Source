function PlansInfo=InitUserPlanInfo(PlansInfo, PinnType)
    
PlansInfo.PlanNameStr=[PlansInfo.PlanNameStr; {'User'}];
PlansInfo.PlanIDList=[PlansInfo.PlanIDList; 99999];

PlansInfo.PlanComment=[PlansInfo.PlanComment; {'User'}];
PlansInfo.PlanDosimetrist=[PlansInfo.PlanDosimetrist; {'User'}];

if ~isempty(PlansInfo.PlanFusionIDList)
    PlansInfo.PlanFusionIDList(end+1).IDIndex=[];
end

PlansInfo.PlanPrimayImageID=[PlansInfo.PlanPrimayImageID; {0}];

switch PinnType
    case 'Pinn9'
        PlansInfo.Pinn9=[PlansInfo.PinnV9, 1];
    case 'Pinn8'
        PlansInfo.Pinn9=[PlansInfo.PinnV9, 0];
    otherwise
        PlansInfo.Pinn9=[PlansInfo.PinnV9, 1];
end