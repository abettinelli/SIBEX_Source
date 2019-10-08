function PlanNameAll=GetPlanNameAll(PlansInfo)

PlanIDStr=strtrim(cellstr(num2str(PlansInfo.PlanIDList)));
PlanNameAll=strcat(PlanIDStr, {' '}, PlansInfo.PlanNameStr);