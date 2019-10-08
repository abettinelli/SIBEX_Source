function GLDZMstruct = IBSI_GLDZM_Mask(CurrentImg, CurrentMask, CurrentMorphologicalMask, AggregationMethod)

if  isequal(AggregationMethod, 3) || isequal(lower(AggregationMethod), '3d') 
    
    % 3D CASE
    GLDZMstruct.GLDZM = IBSI_GLDZM3D_Mask(CurrentImg, CurrentMask, CurrentMorphologicalMask);
    GLDZMstruct.Nv = nnz(CurrentMask);
    
else 
    
    % 2D CASE
    N = size(CurrentImg,3);
    for n = 1:N
        GLDZMstruct(n).GLDZM = IBSI_GLDZM2D_Mask(CurrentImg(:,:,n), CurrentMask(:,:,n), CurrentMorphologicalMask(:,:,n));
        GLDZMstruct(n).Nv = nnz(CurrentMask(:,:,n));
    end
    
    if  isequal(AggregationMethod, 2) || isequal(lower(AggregationMethod), '2dmrg')
        % Find max dimension
        max_dim = [0 0];
        for n = 1:N
            max_dim = max(max_dim, size(GLDZMstruct(n).GLDZM));
        end
        % Sum over matrices
        GLDZM = zeros(max_dim);
        for n = 1:N
            curr_GLSZM = GLDZMstruct(n).GLDZM;
            GLDZM(1:size(curr_GLSZM,1), 1:size(curr_GLSZM,2)) = GLDZM(1:size(curr_GLSZM,1), 1:size(curr_GLSZM,2)) + curr_GLSZM;
        end
        GLDZMstruct = [];
        GLDZMstruct.GLDZM = GLDZM;
        GLDZMstruct.Nv = nnz(CurrentMask(:,:,n))*N;
    end
end
end

function GLDZM = IBSI_GLDZM3D_Mask(CurrentImg, CurrentMask, CurrentMorphologicalMask)

% DISTANCE MAP CALCULATION
CurrentMask_temp = padarray(CurrentMorphologicalMask, [1 1 1], 0, 'both');

mask(:,:,1) =  [0   0   0
                0   1   0
                0   0   0];
mask(:,:,2) =  [0   1   0
                1   1   1
                0   1   0];
mask(:,:,3) =  [0   0   0
                0   1   0
                0   0   0];
            
SE = strel('arbitrary',mask);
distance_map = CurrentMask_temp;
while nnz(CurrentMask_temp) ~= 0
    CurrentMask_temp = imerode(CurrentMask_temp, SE);
    distance_map = distance_map + CurrentMask_temp;
end
distance_map = distance_map(2:end-1,2:end-1,2:end-1);
global x_distance_map
x_distance_map =  distance_map;

% GLDZM CALCULATION
CurrentImg(CurrentMask == 0) = -1;
GLDZM = zeros(max(CurrentImg(:)), 1);
for i = 1:max(CurrentImg(:))
    
    curr_levels = CurrentImg == i;
    
    CC = bwconncomp(curr_levels, 26);

    celldist = cellfun(@zone_distance, CC.PixelIdxList);
    [value, ~, ic] = unique(celldist, 'sorted');
    a_counts = accumarray(ic,1);
    idx_zero = find(value == 0);
    value(idx_zero) = [];
    a_counts(idx_zero) = [];
    
    try
        GLDZM(i, value) = GLDZM(i, value)+a_counts';
    catch
        GLDZM(i, value(end)) = 0;
        GLDZM(i, value) = GLDZM(i, value)+a_counts';
    end
end

clear global
end

function GLDZM = IBSI_GLDZM2D_Mask(CurrentImg, CurrentMask, CurrentMorphologicalMask)
% DISTANCE MAP CALCULATION
CurrentMask_temp = padarray(CurrentMorphologicalMask, [1 1 1], 0, 'both');

mask =  [0   1   0
         1   1   1
         0   1   0];
            
SE = strel('arbitrary',mask);
distance_map = CurrentMask_temp;
while nnz(CurrentMask_temp) ~= 0
    CurrentMask_temp = imerode(CurrentMask_temp, SE);
    distance_map = distance_map + CurrentMask_temp;
end
distance_map = distance_map(2:end-1,2:end-1,2:end-1);
global x_distance_map
x_distance_map =  distance_map;

% GLDZM CALCULATION
CurrentImg(CurrentMask == 0) = -1;
GLDZM = zeros(max(CurrentImg(:)), 1);
for i = 1:max(CurrentImg(:))
    
    curr_levels = CurrentImg == i;
    
    CC = bwconncomp(curr_levels, 8);

    celldist = cellfun(@zone_distance, CC.PixelIdxList);
    [value, ~, ic] = unique(celldist, 'sorted');
    a_counts = accumarray(ic,1);
    idx_zero = find(value == 0);
    value(idx_zero) = [];
    a_counts(idx_zero) = [];
    
    try
        GLDZM(i, value) = GLDZM(i, value)+a_counts';
    catch
        GLDZM(i, value(end)) = 0;
        GLDZM(i, value) = GLDZM(i, value)+a_counts';
    end
end

clear global
end