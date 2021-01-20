function ParentInfo=IBSI_MorphologicalFeatures_Category(CDataSetInfo, Mode, Param)
%%%Doc Starts%%%
% -Description:
% 1.  This method is to extract ROI voxel centers, compute the convex-hull, apply the marching cube algorithm
% 2.  The data are passed into IBSI_MorphologicalFeatures_Feature.m to compute the related features.
%
% -Parameters:
%
% -Revision:
% 2019-02-15: The method is implemented.
%
% -Authors:
% Andrea Bettinelli
%%%Doc Ends%%%

if isequal(Mode, 'InfoID')
    ParentInfo=[];
else
    % Pinnacle to IBSI
    CDataSetInfo = IBSI_waterCTnumber(CDataSetInfo);
    
    % From cm to mm
    voxel_size = [CDataSetInfo.ROIBWInfo.XPixDim*10, CDataSetInfo.ROIBWInfo.YPixDim*10, CDataSetInfo.ROIBWInfo.ZPixDim*10];
    CDataSetInfo.Morph.XPixDim = voxel_size(1);
    CDataSetInfo.Morph.YPixDim = voxel_size(2);
    CDataSetInfo.Morph.ZPixDim = voxel_size(3);
    
    % Chose the Morphological Mask if present
    mask_morph = logical(CDataSetInfo.ROIBWInfo.MorphologicalMaskData);
    mask_int = logical(CDataSetInfo.ROIBWInfo.MaskData);
    
    % Extract Center-Voxel Coordinates
    mask_morph = logical(padarray(mask_morph,[1 1 1],0,'both')); % padding for edges overlapping to bounding box
    [m,n,p] = size(mask_morph);
    [X,Y,Z] = meshgrid((1:n)*voxel_size(1),(1:m)*voxel_size(2),(1:p)*voxel_size(3));
    idx = find(mask_morph == 1);
    CDataSetInfo.ROIVoxelCoordinates.V = [X(idx) Y(idx) Z(idx)];
    
    mask_int = logical(padarray(mask_int,[1 1 1],0,'both'));
    idx_int = find(mask_int == 1);
    CDataSetInfo.ROIVoxelCoordinates.V_int = [X(idx_int) Y(idx_int) Z(idx_int)];
    
    % PCA - EigenVector AND EigenValue
    [CDataSetInfo.EigenVector,~,CDataSetInfo.EigenValue] = pca(CDataSetInfo.ROIVoxelCoordinates.V);
    
    % ROI MASK MARCHING CUBES - FACET AND VERTICES
    [CDataSetInfo.MarchingCubes.F,CDataSetInfo.MarchingCubes.V] = marchingCubes(X,Z,Y,mask_morph,0.5);
    
    % CONVEX HULL - FACET AND VERTICES
    K = convhulln(CDataSetInfo.MarchingCubes.V);
    C = unique(K(:));
    LUT = zeros(size(CDataSetInfo.MarchingCubes.V,1),1);
    LUT(C) = 1:length(C);
    CDataSetInfo.Convex.F = LUT(K);
    CDataSetInfo.Convex.V = CDataSetInfo.MarchingCubes.V(C,:);
    
    % ROI MASK - Volume and Area
    CDataSetInfo.MarchingCubes.Volume = compute_Volume(CDataSetInfo.MarchingCubes.F, CDataSetInfo.MarchingCubes.V);
    CDataSetInfo.MarchingCubes.Area = compute_Area(CDataSetInfo.MarchingCubes.F, CDataSetInfo.MarchingCubes.V);
    
    % CONVEX HULL - Volume and Area
    CDataSetInfo.MarchingCubes.Convex.Volume = compute_Volume(CDataSetInfo.Convex.F, CDataSetInfo.Convex.V);
    CDataSetInfo.MarchingCubes.Convex.Area = compute_Area(CDataSetInfo.Convex.F, CDataSetInfo.Convex.V);
    
    %Code
    switch Mode
        case 'Review'
            ReviewInfo=CDataSetInfo.ROIImageInfo;
            ReviewInfo.MaskData=100;
            ParentInfo=ReviewInfo;
            
        case 'Child'
            ParentInfo=CDataSetInfo;
    end
end