function FeatureInfo=IBSI_MorphologicalFeatures_Feature(ParentInfo, FeatureInfo, Mode)

[MFilePath, MFileName]=fileparts(mfilename('fullpath'));

%Parse Feature Names and Params
if isempty(FeatureInfo)
    FeatureName=ParseFeatureName(MFilePath, MFileName(1:end-8));
    
    if isempty(FeatureName)
        FeatureInfo=[];
        return;
    end
    
    for i=1:length(FeatureName)
        FeatureInfo(i).Name=FeatureName{i};
        
        ConfigFile=[MFilePath, '\', MFileName, '_', FeatureName{i}, '.INI'];
        Param=GetParamFromINI(ConfigFile);
        FeatureInfo(i).Value=Param;
    end
    
    %For passing the feature name
    if isequal(Mode, 'ParseFeature')
        return;
    end
end

%Parent Information
FeaturePrefix=MFileName;

for i=1:length(FeatureInfo)
    if isequal(Mode, 'InfoID')
        % Family/Feature Infos
        [~, ~,Info]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix, 'InfoID');
        FeatureInfo(i).FeatureValue=[];
        FeatureInfo(i).Category = 'Morphology';
        FeatureInfo(i).CatAbbreviation = 'MORPH';
        FeatureInfo(i).CategoryID = 'HCUG';
        FeatureInfo(i).FeatureName=Info.FeatureName;
        FeatureInfo(i).FeatureID=Info.FeatureID;
        FeatureInfo(i).AggregationMethod = '';
        FeatureInfo(i).AggregationMethodID = 'DHQ4';
        
    elseif isequal(Mode, 'Review')
        % Review Info
        [FeatureValue, FeatureReviewInfo]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix,'Value');
        FeatureInfo(i).FeatureValue=FeatureValue;
        FeatureInfo(i).FeatureReviewInfo=FeatureReviewInfo;
    else
        % Calculate FeatureValue
        try
            [FeatureValue, ~, ~]=GetFeatureValue(ParentInfo, FeatureInfo(i), FeaturePrefix,'Value');
        catch
            FeatureValue=[];
        end
        FeatureInfo(i).FeatureValue=FeatureValue;
    end
end

function [FeatureValue, FeatureReviewInfo, FeatureInfo]=GetFeatureValue(ParentInfo, CurrentFeatureInfo,  FeaturePrefix, modality)
FeatureName=CurrentFeatureInfo.Name;

FuncName=[FeaturePrefix, '_', FeatureName];
FuncHandle=str2func(FuncName);

[FeatureValue, FeatureReviewInfo, FeatureInfo]=FuncHandle(ParentInfo, CurrentFeatureInfo.Value, modality);

%----FEATURES
function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_Volume(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        Value = ParentInfo.MarchingCubes.Volume;
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Volume (mesh)';
        FeatureInfo.FeatureID   = 'RNU0';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_ApproximateVolume(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        BWMatInfo=ParentInfo.ROIBWInfo;
        
        % Chose the Morphological Mask if present
        if isfield(BWMatInfo, 'ReSegmented')
            mask = logical(BWMatInfo.MorphologicalMaskData);
        else
            mask = logical(BWMatInfo.MaskData);
        end
        
        TempIndex=find(mask == 1);
        NumVox = length(TempIndex);
        
        if ~isempty(TempIndex)
            Value=NumVox*ParentInfo.Morph.XPixDim*ParentInfo.Morph.YPixDim*ParentInfo.Morph.ZPixDim;
        else
            Value=0;
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Volume (voxel counting)';
        FeatureInfo.FeatureID   = 'YEKZ';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_SurfaceArea(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        Value = ParentInfo.MarchingCubes.Area;
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Surface area (mesh)';
        FeatureInfo.FeatureID   = 'C0JK';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_SurfaceToVolumeRatio(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        if ~isempty(ParentInfo.MarchingCubes.F)
            Value = ParentInfo.MarchingCubes.Area/ParentInfo.MarchingCubes.Volume;
        else
            Value=[];
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Surface to volume ratio';
        FeatureInfo.FeatureID   = '2PR5';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_Compactness1(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        if ~isempty(ParentInfo.MarchingCubes.F)
            SurfaceArea = ParentInfo.MarchingCubes.Area;
            Volume = ParentInfo.MarchingCubes.Volume;
            Value=Volume/(sqrt(pi)*(SurfaceArea^(3/2)));
        else
            Value=[];
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Compactness 1';
        FeatureInfo.FeatureID   = 'SKGS';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_Compactness2(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        if ~isempty(ParentInfo.MarchingCubes.F)
            SurfaceArea = ParentInfo.MarchingCubes.Area;
            Volume = ParentInfo.MarchingCubes.Volume;
            
            Value=36*pi*(Volume^2)/(SurfaceArea^3);
        else
            Value=[];
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Compactness 2';
        FeatureInfo.FeatureID   = 'BQWJ';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_SphericalDisproportion(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        if ~isempty(ParentInfo.MarchingCubes.F)
            SurfaceArea = ParentInfo.MarchingCubes.Area;
            Volume = ParentInfo.MarchingCubes.Volume;
            
            Radius=(Volume*3/4/pi)^(1/3);
            
            Value=SurfaceArea/((4*pi)*(Radius^2));
        else
            Value=[];
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Spherical disproportion';
        FeatureInfo.FeatureID   = 'KRCK';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_Sphericity(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        if ~isempty(ParentInfo.MarchingCubes.F)
            SurfaceArea = ParentInfo.MarchingCubes.Area;
            Volume = ParentInfo.MarchingCubes.Volume;
            
            Value=(pi^(1/3))*((6*Volume)^(2/3))/SurfaceArea;
        else
            Value=[];
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Sphericity';
        FeatureInfo.FeatureID   = 'QCFX';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_Asphericity(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        if ~isempty(ParentInfo.MarchingCubes.F)
            SurfaceArea = ParentInfo.MarchingCubes.Area;
            Volume = ParentInfo.MarchingCubes.Volume;
            
            Value=(SurfaceArea.^3/(36*pi*Volume.^2)).^(1/3)-1;
        else
            Value=[];
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Asphericity';
        FeatureInfo.FeatureID   = '25C7';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_CentreOfMassShift(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        image = ParentInfo.ROIImageInfo.MaskData;
        
        % Chose the Morphological Mask if present
        if isfield(ParentInfo.ROIBWInfo, 'ReSegmented')
            morphological_mask = logical(ParentInfo.ROIBWInfo.MorphologicalMaskData);
        else
            morphological_mask = logical(ParentInfo.ROIBWInfo.MaskData);
        end
        
        if isfield(ParentInfo.ROIBWInfo, 'ReSegmented')
            intensity_mask = logical(ParentInfo.ROIBWInfo.MaskData);
        else
            intensity_mask = logical(ParentInfo.ROIBWInfo.MaskData);
        end
        
        % MORPH
        [m,n,p] = size(morphological_mask);
        voxel_size = [ParentInfo.Morph.XPixDim, ParentInfo.Morph.YPixDim, ParentInfo.Morph.ZPixDim];
        [X,Y,Z] = meshgrid((1:n)*voxel_size(1),(1:m)*voxel_size(2),(1:p)*voxel_size(3));
        idx_morph = find(morphological_mask == 1);
        centre_voxel_coordinates_morph = [X(idx_morph) Y(idx_morph) Z(idx_morph)];
        
        % INTENSITY
        [m,n,p] = size(intensity_mask);
        voxel_size = [ParentInfo.Morph.XPixDim, ParentInfo.Morph.YPixDim, ParentInfo.Morph.ZPixDim];
        [X,Y,Z] = meshgrid((1:n)*voxel_size(1),(1:m)*voxel_size(2),(1:p)*voxel_size(3));
        idx_int = find(intensity_mask == 1);
        centre_voxel_coordinates_int = [X(idx_int) Y(idx_int) Z(idx_int)];
        voxel_intensities = double(image(idx_int));
        
        COM = mean(centre_voxel_coordinates_morph);
        
        COMiw = sum(centre_voxel_coordinates_int.*repmat(voxel_intensities,1,3))/sum(voxel_intensities);
        
        try
            Value=norm(COM-COMiw);
        catch
            Value=NaN;
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Centre of mass shift';
        FeatureInfo.FeatureID   = 'KLMA';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_Maximum3DDiameter(ParentInfo, Param, modality)
%%%Doc Starts%%%
% -Description:
% Max3DDiameter= largest pairwise Euclidean distance between voxels on the surface of the tumor volume.
%
% For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        if ~isempty(ParentInfo.Convex.V)
            Value= max(pdist(ParentInfo.Convex.V));
        else
            Value=[];
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Maximum 3D diameter';
        FeatureInfo.FeatureID   = 'L0JK';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_MajorAxisLength(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        lambda = ParentInfo.EigenValue(1);
        
        if ~isempty(ParentInfo.EigenValue)
            Value= 4*sqrt(lambda);
        else
            Value=[];
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Major axis length';
        FeatureInfo.FeatureID   = 'TDIC';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_MinorAxisLength(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        lambda = ParentInfo.EigenValue(2);
        
        if ~isempty(ParentInfo.EigenValue)
            Value= 4*sqrt(lambda);
        else
            Value=[];
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Minor axis length';
        FeatureInfo.FeatureID   = 'P9VJ';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_LeastAxisLength(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        lambda = ParentInfo.EigenValue(3);
        
        if ~isempty(ParentInfo.EigenValue)
            Value= 4*sqrt(lambda);
        else
            Value=[];
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Least axis length';
        FeatureInfo.FeatureID   = '7J51';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_Elongation(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        if ~isempty(ParentInfo.EigenValue)
            Value= sqrt(ParentInfo.EigenValue(2)/ParentInfo.EigenValue(1));
        else
            Value=[];
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Elongation';
        FeatureInfo.FeatureID   = 'Q3CK';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_Flatness(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        if ~isempty(ParentInfo.EigenValue)
            Value= sqrt(ParentInfo.EigenValue(3)/ParentInfo.EigenValue(1));
        else
            Value=[];
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Flatness';
        FeatureInfo.FeatureID   = 'N17B';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_VolumeDensity_AABB(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        V = ParentInfo.Convex.V;
        Volume_AABB = prod(max(V)-min(V));
        
        Value = ParentInfo.MarchingCubes.Volume/Volume_AABB;
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Volume density (axis-aligned bounding box)';
        FeatureInfo.FeatureID   = 'PBX1';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_AreaDensity_AABB(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        V = ParentInfo.Convex.V;
        edges = max(V)-min(V);
        surfaces = triu(edges'*edges,1);
        Area_AABB = 2*sum(surfaces(:));
        
        Value = ParentInfo.MarchingCubes.Area/Area_AABB;
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Area density (axis-aligned bounding box)';
        FeatureInfo.FeatureID   = 'R59B';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_VolumeDensity_OMBB(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        x = ParentInfo.Convex.V(:,1);
        y = ParentInfo.Convex.V(:,2);
        z = ParentInfo.Convex.V(:,3);
        [~,~,volume_OMBB, ~,~] = minboundbox(x,y,z,'v',1);
        
        Value = ParentInfo.MarchingCubes.Volume/volume_OMBB;
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Volume density (oriented minimum bounding box)';
        FeatureInfo.FeatureID   = 'ZH1A';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_AreaDensity_OMBB(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        x = ParentInfo.Convex.V(:,1);
        y = ParentInfo.Convex.V(:,2);
        z = ParentInfo.Convex.V(:,3);
        [~,~,~, surface_OMBB,~] = minboundbox(x,y,z,'v',1);
        
        Value = ParentInfo.MarchingCubes.Area/surface_OMBB;
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Area density (oriented minimum bounding box)';
        FeatureInfo.FeatureID   = 'IQYR';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_VolumeDensity_AEE(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        a = 2*sqrt(ParentInfo.EigenValue(1));
        b = 2*sqrt(ParentInfo.EigenValue(2));
        c = 2*sqrt(ParentInfo.EigenValue(3));
        Volume_AEE = a*b*c*4*pi/3;
        
        Value = ParentInfo.MarchingCubes.Volume/Volume_AEE;
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Volume density (approximate enclosing ellipsoid)';
        FeatureInfo.FeatureID   = '6BDE';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_AreaDensity_AEE(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        a = 2*sqrt(ParentInfo.EigenValue(1));
        b = 2*sqrt(ParentInfo.EigenValue(2));
        c = 2*sqrt(ParentInfo.EigenValue(3));
        alpha = sqrt(1-(b/a)^2);
        beta = sqrt(1-(c/a)^2);
        Area_AEE = 0;
        for ni = 0:20
            X = (alpha^2+beta^2)/(2*alpha*beta);
            temp = (alpha*beta)^ni/(1-4*(ni^2))*legendreP(ni,X);
            Area_AEE = Area_AEE + temp;
        end
        Area_AEE = 4*pi*a*b*Area_AEE;
        
        Value = ParentInfo.MarchingCubes.Area/Area_AEE;
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Area density (approximate enclosing ellipsoid)';
        FeatureInfo.FeatureID   = 'RDD2';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_VolumeDensity_MVEE(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [C, ~] = MinVolEllipse(ParentInfo.Convex.V', 0.001);
        C=inv(C);
        [~,Va]=eig(C);
        EigenValue=diag(Va);
        a = 2*sqrt(EigenValue(1));
        b = 2*sqrt(EigenValue(2));
        c = 2*sqrt(EigenValue(3));
        
        Volume_MVEE = a*b*c*4*pi/3;
        
        Value = ParentInfo.MarchingCubes.Volume/Volume_MVEE;
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Volume density (minimum volume enclosing ellipsoid)';
        FeatureInfo.FeatureID   = 'SWZ1';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_AreaDensity_MVEE(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        [C, ~] = MinVolEllipse(ParentInfo.Convex.V', 0.001);
        C=inv(C);
        [~,Va]=eig(C);
        EigenValue=diag(Va);
        a = 2*sqrt(EigenValue(1));
        b = 2*sqrt(EigenValue(2));
        c = 2*sqrt(EigenValue(3));
        alpha = sqrt(1-(b/a)^2);
        beta = sqrt(1-(c/a)^2);
        Area_AEE = 0;
        for ni = 0:20
            X = (alpha^2+beta^2)/(2*alpha*beta);
            temp = (alpha*beta)^ni/(1-4*(ni^2))*legendreP(ni,X);
            Area_AEE = Area_AEE + temp;
        end
        Area_AEE = 4*pi*a*b*Area_AEE;
        
        Value = ParentInfo.MarchingCubes.Area/Area_AEE;
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Area density (minimum volume enclosing ellipsoid)';
        FeatureInfo.FeatureID   = 'BRI8';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_VolumeDensity_CH(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        Value = ParentInfo.MarchingCubes.Volume/ParentInfo.MarchingCubes.Convex.Volume;
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Volume density (convex hull)';
        FeatureInfo.FeatureID   = 'R3ER';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_AreaDensity_CH(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        Value = ParentInfo.MarchingCubes.Area/ParentInfo.MarchingCubes.Convex.Area;
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Area density (convex hull)';
        FeatureInfo.FeatureID   = '7T7F';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_IntegratedIntensity(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        CurrentImage = ParentInfo.ROIImageInfo.MaskData;
        CurrentMask = ParentInfo.ROIBWInfo.MaskData;
        
        Value = ParentInfo.MarchingCubes.Volume*mean(CurrentImage(logical(CurrentMask)));
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Integrated intensity';
        FeatureInfo.FeatureID   = '99N0';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_MoransIIndex(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        image = ParentInfo.ROIImageInfo.MaskData;
        intensity_mask = logical(ParentInfo.ROIBWInfo.MaskData);
        img_vect = double(image(intensity_mask == 1));
        img_vect_no_mean = img_vect-mean(img_vect);
        coordinates = ParentInfo.ROIVoxelCoordinates.V_int;
        N = length(img_vect);
        
        if isfield(Param, 'Approximate')
            flag_approx_user = Param.Approximate;
        else
            flag_approx_user = true;
        end
        
        if nnz(intensity_mask) > 5000 && flag_approx_user
            flag = true;
        elseif nnz(intensity_mask) > 5000 && ~flag_approx_user
            flag = false;
        elseif nnz(intensity_mask) <= 5000
            flag = false;
        end
        
        rng(1)
        if flag
            repetitons = 1000;
            N = 500;
            Value = zeros(repetitons,1);
            for i = 1:repetitons
                % random repeted sampling
                data = datasample([img_vect_no_mean coordinates], N, 'Replace', false);
                img_vect_no_mean_sample = data(:,1);
                coordinates_sample = data(:,2:end);
                
                W = 1./pdist(coordinates_sample, 'euclidean');
                GL = pdist(img_vect_no_mean_sample,'@distfun');
                
                NUM = N*(sum(W.*GL));
                DEN = sum(W)*sum((img_vect_no_mean_sample).^2);
                
                Value(i) = NUM/DEN;
            end
            Value = mean(Value);
        else
            W = 1./pdist(coordinates, 'euclidean');
            GL = pdist(img_vect_no_mean,'@distfun');
            
            NUM = N*(sum(W.*GL));
            DEN = sum(W)*sum((img_vect_no_mean).^2);
            
            Value = NUM/DEN;
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Moran’s I index';
        FeatureInfo.FeatureID   = 'N365';
end

function [Value, ReviewInfo, FeatureInfo]=IBSI_MorphologicalFeatures_Feature_GearysCMeasure(ParentInfo, Param, modality)
%%%Doc Starts%%%
%For the feature description, refer to the paper below.
% Zwanenburg A, Leger S, Vallières M, Löck S. Image biomarker standardisation initiative.
% December 2016. http://arxiv.org/abs/1612.07003. Accessed May 21, 2019.
%%%Doc Ends%%%
Value = [];
ReviewInfo = [];
FeatureInfo = [];

switch modality
    case 'Value'
        image = double(ParentInfo.ROIImageInfo.MaskData);
        intensity_mask = logical(ParentInfo.ROIBWInfo.MaskData);
        img_vect = image(intensity_mask == 1);
        img_vect_no_mean = img_vect-mean(img_vect);
        coordinates = ParentInfo.ROIVoxelCoordinates.V_int;
        N = length(img_vect);
        
        if isfield(Param, 'Approximate')
            flag_approx_user = Param.Approximate;
        else
            flag_approx_user = true;
        end
        
        if nnz(intensity_mask) > 5000 && flag_approx_user
            flag = true;
        elseif nnz(intensity_mask) > 5000 && ~flag_approx_user
            flag = false;
        elseif nnz(intensity_mask) <= 5000
            flag = false;
        end
        
        rng(1)
        if flag
            repetitons = 1000;
            N = 500;
            Value = zeros(repetitons,1);
            for i = 1:repetitons
                % random repeted sampling
                data = datasample([img_vect img_vect_no_mean coordinates], N, 'Replace', false);
                img_vect_sample = data(:,1);
                img_vect_no_mean_sample = data(:,2);
                coordinates_sample = data(:,3:end);
                
                W = 1./pdist(coordinates_sample, 'euclidean');
                GL = pdist(img_vect_sample,'euclidean').^2; % 'squaredeuclidean' mod2014
                
                NUM = (N-1)*(sum(W.*GL));
                DEN = 2*sum(W)*sum((img_vect_no_mean_sample).^2);
                
                Value(i) = NUM/DEN;
            end
            Value = mean(Value);
        else
            W = 1./pdist(coordinates, 'euclidean');
            GL = pdist(img_vect,'squaredeuclidean');
            
            NUM = (N-1)*(sum(W.*GL));
            DEN = 2*sum(W)*sum((img_vect_no_mean).^2);
            
            Value = NUM/DEN;
        end
        ReviewInfo.MaskData=Value;
    case 'InfoID'
        FeatureInfo.FeatureName = 'Geary’s C measure';
        FeatureInfo.FeatureID   = 'NPT7';
end
