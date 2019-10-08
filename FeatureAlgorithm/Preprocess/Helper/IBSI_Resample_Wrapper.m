function [ROIImageInfoNew, ROIBWInfoNew, CDataSetInfoNew]=IBSI_Resample_Wrapper(ROIImageInfo, ROIImageInfoNew, CDataSetInfo, ROIBWInfo, Method, alpha, ResampleImageFlag, ResampleROIFlag)

gray_precision_img = 'double';
gray_precision_mask = 'single';
grid_precision = 'double';

%--Resample Image
ImageDo=0;
if nargin <= 6
    ImageDo=1;
else
    if ResampleImageFlag> 0
        ImageDo=1;
    end
end

if ImageDo > 0
    ROIImageInfoNew=IBSI_Interpolation3D_gridInterp(ROIImageInfo, ROIImageInfoNew, Method, gray_precision_img, grid_precision);
end

%--Recreate BWMask and Resample ROI
ROIDo=0;
if nargin <= 6
    ROIDo=1;
else
    if ResampleROIFlag> 0
        ROIDo=1;
    end
end

if ROIDo > 0
    
    % Create a structure for Morph
    ROIBWInfo_temp = ROIBWInfo;
    ROIBWInfo_temp.MaskData = ROIBWInfo_temp.MorphologicalMaskData;
    
    % Update Mask
    ROIBWInfoNew_t=IBSI_Interpolation3D_gridInterp(ROIBWInfo, ROIImageInfoNew, 'linear', gray_precision_mask, grid_precision); % force linear
    ROIBWInfoNew_t.MaskData = uint8(ROIBWInfoNew_t.MaskData >= alpha);

    % Update Morphological Mask
    if isfield(CDataSetInfo.ROIBWInfo, 'ReSegmented')
        ROIBWInfoNew_tm=IBSI_Interpolation3D_gridInterp(ROIBWInfo_temp, ROIImageInfoNew, 'linear', gray_precision_mask, grid_precision);
        ROIBWInfoNew_tm.MaskData = uint8(ROIBWInfoNew_tm.MaskData >= alpha);
    else
        ROIBWInfoNew_tm = ROIBWInfoNew_t;
    end
    CDataSetInfoNew=UpdateROIImageInfoMask(CDataSetInfo,  ROIImageInfo, ROIBWInfo, ROIImageInfoNew);
    
    ROIBWInfoNew = ROIImageInfoNew;
    ROIBWInfoNew.MaskData = uint8(ROIBWInfoNew_t.MaskData);
    ROIBWInfoNew.MorphologicalMaskData = uint8(ROIBWInfoNew_tm.MaskData);
    
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

CDataSetInfoNew= GetCDataSetInfoNew(CDataSetInfo, ROIImageInfoNew);    

%Update structAxialROI
if ResampleROIFlag > 0    
    structAxialROI=ResampleROI(ROIBWInfo, ROIImageInfoNew, CDataSetInfo.structAxialROI);
    
    CDataSetInfoNew.structAxialROI=structAxialROI;
else
    CDataSetInfoNew.structAxialROI=CDataSetInfo.structAxialROI;
end

%Update Mask
ROIImageInfoNew.structAxialROI=CDataSetInfoNew.structAxialROI;

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

function CDataSetInfoNew= GetCDataSetInfoNew(CDataSetInfo, ROIImageInfoNew)

CDataSetInfoNew=CDataSetInfo;

CDataSetInfoNew=rmfield(CDataSetInfoNew, {'structAxialROI'}); %, 'ImageXDim', 'ImageYDim', 'ImageZDim', 'ROIXDim', 'ROIYDim', 'ROIZDim'

CDataSetInfoNew.XPixDim=ROIImageInfoNew.XPixDim;
CDataSetInfoNew.YPixDim=ROIImageInfoNew.YPixDim;
CDataSetInfoNew.ZPixDim=ROIImageInfoNew.ZPixDim;

CDataSetInfoNew.XDim=ROIImageInfoNew.XDim;
CDataSetInfoNew.YDim=ROIImageInfoNew.YDim;
CDataSetInfoNew.ZDim=ROIImageInfoNew.ZDim;

CDataSetInfoNew.XStart=ROIImageInfoNew.XStart;
CDataSetInfoNew.YStart=ROIImageInfoNew.YStart;
CDataSetInfoNew.ZStart=ROIImageInfoNew.ZStart;
