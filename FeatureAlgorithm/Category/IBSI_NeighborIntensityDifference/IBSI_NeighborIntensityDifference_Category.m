function ParentInfo=IBSI_NeighborIntensityDifference_Category(CDataSetInfo, Mode, Param)
%%%Doc Starts%%%
% -Description: 
% 1. This method is to compute neighborhood intensity difference matrix (NIDM) from image inside
%    the binary mask.
% 2. NIDM is passed into NeighborIntensityDifference_Feature.m to compute the related features.
% 
% -Parameters:
% 1. AggregationMethod:
%	1: 2D:avg 	averaged over slices.
%	2: 2D:mrg	merged over all slices.             (rare)
%	3: 3D       calculated from single 3D matrix.   (default)
% 2. Rescale: 
%	'fbn': fixed bin number -> specify BinNumber.
%	'fbs': fixed bin size   -> specify BinSize.
%	'off': do not perform the discretization step.
% 3. BinNumber: Integer specifying the number of bin number to use when scaling the grayscale values. [] when rescale is set to 'fbs' or 'off'.
% 4. BinSize: Integer specifying the bin size to use when scaling the grayscale values. [] when rescale is set to 'fbn' or 'off'.
% 5. NHood: The neighborhood matrix size in X dimension.
% 6. NHoodSym:      
%	1: neighborhood matrix size in Y and Z are calculated to best match neighborhood physical length in X dimension.
%	0: neighborhood matrx size are same in X, Y, and Z dimensions.
% 7. IncludeEdge:
%	1: include edge pixels for analysis.
%	0: do not include edge pixels for analysis.
% 
% -Revision:
% 2019-02-13: The method is implemented.
% 
% -Authors:
% Andrea Bettinelli
%%%Doc Ends%%%

% Pinnacle to IBSI
CDataSetInfo = IBSI_waterCTnumber(CDataSetInfo);

% Limiti opzionali (modificano ROI)
[CDataSetInfo, Param] = IBSI_gl_rescale(CDataSetInfo, Param);

ROIImageData=double(CDataSetInfo.ROIImageInfo.MaskData);
ROIBWData=CDataSetInfo.ROIBWInfo.MaskData;

% Remove empty slices above and below ROI
[ROIImageData, ROIBWData] = IBSI_minimal_ROI(ROIImageData, ROIBWData);

%Code
NIDStruct=ComputeNIDM(ROIImageData, ROIBWData, CDataSetInfo, Param);

switch Mode
    case 'Review'
        ReviewInfo=CDataSetInfo.ROIImageInfo;
        ReviewInfo.NIDStruct=NIDStruct;        
        
        ClassName=class(CDataSetInfo.ROIImageInfo.MaskData);
        FuncH=str2func(ClassName);
        
        %DiffMat: Force the float difference to the current type
        ReviewInfo.MaskData=FuncH(NIDStruct.DiffMaskData);
        
        %Occurence Probability Histogram Curve
        ReviewInfo.CurvesInfo(1).Description='Occurence Probability Histogram (Prob. VS Intensity)';
        ReviewInfo.CurvesInfo(1).CurveData=[ReviewInfo.NIDStruct.HistBinLoc, ReviewInfo.NIDStruct.HistOccurPropability];
        
        %Diff. Sum Histogram Curve
        ReviewInfo.CurvesInfo(2).Description='Difference Sum. Histogram (Sum. VS Intensity)';
        ReviewInfo.CurvesInfo(2).CurveData=[ReviewInfo.NIDStruct.HistBinLoc, ReviewInfo.NIDStruct.HistDiffSum];
                
        ParentInfo=ReviewInfo;
        
    case 'Child'
        CDataSetInfo.ROIImageInfo.NIDStruct=NIDStruct;
        CDataSetInfo.AggregationMethod = Param.AggregationMethod;
        ParentInfo=CDataSetInfo;
end

function NGTDMstruct=ComputeNIDM(CurrentImg, CurrentMask, CDataSetInfo, Param)
ROIImageInfo=CDataSetInfo.ROIImageInfo;

NHoodX=Param.NHood;

if Param.NHoodSym > 0
    NHoodY=round(NHoodX*ROIImageInfo.XPixDim/ROIImageInfo.YPixDim);
    NHoodZ=round(NHoodX*ROIImageInfo.XPixDim/ROIImageInfo.ZPixDim);
else
    NHoodY=NHoodX;
    NHoodZ=NHoodX;    
end

% Compute NGTDM
levels = (1:max(CurrentImg(CurrentMask == 1)))';
NGTDMstruct = IBSI_ComputeSlideNeighDiff(CurrentImg, CurrentMask, [NHoodX, NHoodY, NHoodZ], levels, Param.AggregationMethod);
