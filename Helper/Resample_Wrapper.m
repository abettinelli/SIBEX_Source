function [ROIImageInfoNew, ROIBWInfoNew, CDataSetInfoNew]=Resample_Wrapper(ROIImageInfo, ProgramPath, ROIImageInfoNew, CDataSetInfo, ROIBWInfo, ResampleImageFlag, ResampleROIFlag, BoxKernelFlag)

%Interpolate kernel
if nargin > 7
    BoxKernelFlag=BoxKernelFlag;
else
    BoxKernelFlag=0;
end

%--Resample Image
ImageDo=0;
if nargin < 6
    ImageDo=1;
else
    if ResampleImageFlag> 0
        ImageDo=1;
    end
end

if ImageDo > 0 
    ROIImageInfoNew=Interp_ROIImage(ROIImageInfo, ProgramPath, ROIImageInfoNew, BoxKernelFlag);
end

%--Recreate  BWMask and Resample ROI
ROIDo=0;
if nargin < 6
    ROIDo=1;
else
    if ResampleROIFlag> 0
        ROIDo=1;
    end
end

if ROIDo > 0
    [CDataSetInfoNew, ROIBWInfoNew]=UpdateROIImageInfoMask(CDataSetInfo,  ROIImageInfo, ROIBWInfo, ROIImageInfoNew);
else
    CDataSetInfoNew=[];
    ROIBWInfoNew=[];
end


%---------------------------------------------------------Sub Functions---------------------------%
function [CDataSetInfoNew, ROIBWInfoNew]=UpdateROIImageInfoMask(CDataSetInfo, ROIImageInfo, ROIBWInfo, ROIImageInfoNew)
%Update CDataSetInfo image format
if EqualRelativeZ(ROIImageInfo.ZPixDim, ROIImageInfoNew.ZPixDim) 
    ResampleROIFlag=0;
else
    ResampleROIFlag=1;   
end

CDataSetInfoNew= GetCDataSetInfoNew(CDataSetInfo, ROIImageInfoNew, ResampleROIFlag);    

%Update structAxialROI
if ResampleROIFlag > 0    
    structAxialROI=ResampleROI(ROIBWInfo, ROIImageInfoNew, CDataSetInfo.structAxialROI);
    
    CDataSetInfoNew.structAxialROI=structAxialROI;
else
    CDataSetInfoNew.structAxialROI=CDataSetInfo.structAxialROI;
end

%Update Mask
ROIImageInfoNew.structAxialROI=CDataSetInfoNew.structAxialROI;

ROIBWInfoNew=BWFillROI(1, [], ROIImageInfoNew);
ROIBWInfoNew.ROINamePlanIndex=ROIBWInfo.ROINamePlanIndex;


function structAxialROIFinal=ResampleROI(ROIBWInfo, ROIImageInfoNew, structAxialROI)
%Initialize
structAxialROIFinal(1).ZLocation=[];
structAxialROIFinal(1).CurvesCor=[];
structAxialROIFinal(1).OrganCurveNum=0;

ZLocation=structAxialROI(1).ZLocation;

%Interpolate
ContourZLoc=ROIBWInfo.ZStart+((1:ROIBWInfo.ZDim)'-1)*ROIBWInfo.ZPixDim;

MinZLoc=min(ContourZLoc);
MaxZLoc=max(ContourZLoc);

for i=1:ROIImageInfoNew.ZDim
    CurrentZLoc=ROIImageInfoNew.ZStart+(i-1)*ROIImageInfoNew.ZPixDim;
    
    if (CurrentZLoc >= MinZLoc) && (CurrentZLoc <= MaxZLoc)
        
        TempIndex=find(abs(CurrentZLoc-ZLocation) <= 2*ROIImageInfoNew.ZPixDim/100);
        
        if ~isempty(TempIndex)
            %Copy ROIs
            ResultCurve=structAxialROI.CurvesCor(TempIndex);        
        else
            %Resample ROIs
            ResultCurve=InterpolateROI(ROIBWInfo, CurrentZLoc, ContourZLoc);                        
        end
        
        %Update structAxialROI
        for j=1:length(ResultCurve)
            structAxialROIFinal(1).ZLocation=[structAxialROIFinal(1).ZLocation; CurrentZLoc];
            structAxialROIFinal(1).CurvesCor=[structAxialROIFinal(1).CurvesCor; ResultCurve(j)];
            structAxialROIFinal(1).OrganCurveNum=structAxialROIFinal(1).OrganCurveNum+1;
        end
        
    end    
end


function CDataSetInfoNew= GetCDataSetInfoNew(CDataSetInfo, ROIImageInfoNew, ResampleROIFlag)

CDataSetInfoNew=CDataSetInfo;

CDataSetInfoNew=rmfield(CDataSetInfoNew, 'structAxialROI');

CDataSetInfoNew.XPixDim=ROIImageInfoNew.XPixDim;
CDataSetInfoNew.YPixDim=ROIImageInfoNew.YPixDim;
CDataSetInfoNew.ZPixDim=ROIImageInfoNew.ZPixDim;

XDim=ceil((ROIImageInfoNew.XStart-CDataSetInfo.XStart)/ROIImageInfoNew.XPixDim+1);
CDataSetInfoNew.XStart=ROIImageInfoNew.XStart-(XDim-1)*ROIImageInfoNew.XPixDim;

YDim=ceil((ROIImageInfoNew.YStart-CDataSetInfo.YStart)/ROIImageInfoNew.YPixDim+1);
CDataSetInfoNew.YStart=ROIImageInfoNew.YStart-(YDim-1)*ROIImageInfoNew.YPixDim;

if ResampleROIFlag > 0
    ZDim=ceil((ROIImageInfoNew.ZStart-CDataSetInfo.ZStart)/ROIImageInfoNew.ZPixDim+1);
    CDataSetInfoNew.ZStart=ROIImageInfoNew.ZStart-(ZDim-1)*ROIImageInfoNew.ZPixDim;
else
    CDataSetInfoNew.ZStart=CDataSetInfo.ZStart;
end

XEnd=CDataSetInfo.XStart+(CDataSetInfo.XDim-1)*CDataSetInfo.XPixDim;
YEnd=CDataSetInfo.YStart+(CDataSetInfo.YDim-1)*CDataSetInfo.YPixDim;
ZEnd=CDataSetInfo.ZStart+(CDataSetInfo.ZDim-1)*CDataSetInfo.ZPixDim;

CDataSetInfoNew.XDim=ceil((XEnd-CDataSetInfoNew.XStart)/CDataSetInfoNew.XPixDim+1);
CDataSetInfoNew.YDim=ceil((YEnd-CDataSetInfoNew.YStart)/CDataSetInfoNew.YPixDim+1);
CDataSetInfoNew.ZDim=ceil((ZEnd-CDataSetInfoNew.ZStart)/CDataSetInfoNew.ZPixDim+1);