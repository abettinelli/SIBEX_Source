function CurrentBinary=GetCurrentROIMask(handles, CurrentZLoc, ROIName, PlanIndex)

ROIPlanStr={handles.BWMatInfo.ROINamePlanIndex}';

BWMatIndex=strmatch([deblank(ROIName), num2str(PlanIndex)], ROIPlanStr, 'exact');

if isempty(BWMatIndex)
    CurrentBinary=[];    
    return;
end

SliceNum=(CurrentZLoc-handles.BWMatInfo(BWMatIndex).ZStart)/handles.BWMatInfo(BWMatIndex).ZPixDim+1;
SliceNum=round(SliceNum);

if SliceNum < 1 || SliceNum > handles.BWMatInfo(BWMatIndex).ZDim
    CurrentBinary=[];    
    return;
end

BWMatInfoT=handles.BWMatInfo(BWMatIndex);
CurrentBinary.MaskData= BWMatInfoT.MaskData(:, :, SliceNum);

CurrentBinary.XStart=BWMatInfoT.XStart;
CurrentBinary.YStart=BWMatInfoT.YStart;
CurrentBinary.ZStart=CurrentZLoc;

CurrentBinary.XDim=BWMatInfoT.XDim;
CurrentBinary.YDim=BWMatInfoT.YDim;
CurrentBinary.ZDim=1;

CurrentBinary.XPixDim=BWMatInfoT.XPixDim;
CurrentBinary.YPixDim=BWMatInfoT.YPixDim;
CurrentBinary.ZPixDim=BWMatInfoT.ZPixDim;
