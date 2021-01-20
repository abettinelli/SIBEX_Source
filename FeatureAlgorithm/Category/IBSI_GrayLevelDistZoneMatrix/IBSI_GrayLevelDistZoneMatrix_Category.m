function ParentInfo=IBSI_GrayLevelDistZoneMatrix_Category(CDataSetInfo, Mode, Param)
%%%Doc Starts%%%
% -Description:
% 1. This method is to compute gray-level distance zone matrix(GLDZM) from image inside
%    the binary mask.
% 2. GLDZM is passed into IBSI_GrayLevelDistZoneMatrix_Feature.m to compute the related features.
%
% -Parameters:
% 1. AggregationMethod:
%	1: 2D:avg 	averaged over slices
%	2: 2D:mrg	merged over all slices              (rare)
%	3: 3D       calculated from single 3D matrix    (default)
% 2. Rescale:
%	'fbn': fixed bin number -> specify BinNumber
%	'fbs': fixed bin size   -> specify BinSize
%	'off': do not perform the discretization step
% 3. BinNumber: Integer specifying the number of bin number to use when scaling the grayscale values. [] when rescale is set to 'fbs' or 'off';
% 4. BinSize: Integer specifying the bin size to use when scaling the grayscale values. [] when rescale is set to 'fbn' or 'off';
%
% -Revision:
% 2019-02-13: The method is implemented.
%
% -Authors:
% Andrea Bettinelli
%%%Doc Ends%%%

if isequal(Mode, 'InfoID')
    CDataSetInfo.AggregationMethod = Param.AggregationMethod;
    ParentInfo=CDataSetInfo;
else
    % Pinnacle to IBSI
    CDataSetInfo = IBSI_waterCTnumber(CDataSetInfo);
    
    % GL DISCRETISATION
    [CDataSetInfo, Param] = IBSI_gl_rescale(CDataSetInfo, Param);
    
    ROIImageData = CDataSetInfo.ROIImageInfo.MaskData;
    
    % Intensity Mask - Morphological Mask
    ROIBWData = logical(CDataSetInfo.ROIBWInfo.MaskData);
    ROIBWMorphologicalData = logical(CDataSetInfo.ROIBWInfo.MorphologicalMaskData);
    
    % Remove empty slices above and below ROI
    [ROIImageData, ~] = IBSI_minimal_ROI(ROIImageData, ROIBWData);
    [ROIBWMorphologicalData, ROIBWData] = IBSI_minimal_ROI(ROIBWMorphologicalData, ROIBWData);
    
    %Code
    GLSZMStruct = IBSI_GLDZM_Mask(ROIImageData, ROIBWData, ROIBWMorphologicalData,Param.AggregationMethod);
    
    switch Mode
        case 'Review'
            ReviewInfo=CDataSetInfo.ROIImageInfo;
            ReviewInfo.GLDZMStruct3=GLSZMStruct;
            ParentInfo=ReviewInfo;
            
        case 'Child'
            CDataSetInfo.ROIImageInfo.GLDZMStruct3=GLSZMStruct;
            CDataSetInfo.AggregationMethod = Param.AggregationMethod;
            ParentInfo=CDataSetInfo;
    end
end