function NGLDMstruct = IBSI_ComputeSlideDependence(CurrentImg, CurrentMask, delta, Param, AggregationMethod)

alpha = Param.Alpha;

if  isequal(AggregationMethod, 3) || isequal(lower(AggregationMethod), '3d') 
    
    % 3D CASE
    NGLDMstruct.NGLDM = IBSI_NGLDM3D_Mask(CurrentImg, CurrentMask, delta, alpha);
    NGLDMstruct.Nv = nnz(CurrentMask);
else 
    
    % 2D CASE
    N = size(CurrentImg,3);
    for n = 1:N
        NGLDMstruct(n).NGLDM = IBSI_NGLDM2D_Mask(CurrentImg(:,:,n), CurrentMask(:,:,n), delta(1:2), alpha);
        NGLDMstruct(n).Nv = nnz(CurrentMask(:,:,n));
    end
    
    if  isequal(AggregationMethod, 2) || isequal(lower(AggregationMethod), '2dmrg')
        % Find max dimension
        max_dim = [0 0];
        for n = 1:N
            max_dim = max(max_dim, size(NGLDMstruct(n).NGLDM));
        end
        % Sum over matrices
        NGLDM = zeros(max_dim);
        for n = 1:N
            curr_GLSZM = NGLDMstruct(n).NGLDM;
            NGLDM(1:size(curr_GLSZM,1), 1:size(curr_GLSZM,2)) = NGLDM(1:size(curr_GLSZM,1), 1:size(curr_GLSZM,2)) + curr_GLSZM;
        end
        NGLDMstruct = [];
        NGLDMstruct.NGLDM = NGLDM;
        NGLDMstruct.Nv = nnz(CurrentMask(:,:,n))*N;
    end
end
end

function NGLDM  = IBSI_NGLDM3D_Mask(CurrentImg, CurrentMask, delta, alpha)

CurrentMask = double(CurrentMask);
CurrentMask(CurrentMask == 0) = NaN;
CurrentImg_nan = CurrentImg.*CurrentMask;
CurrentImg_nan = padarray(CurrentImg_nan,delta,nan,'both');

max_levels = max(CurrentImg(CurrentMask == 1));

NGLDM = zeros(max(CurrentImg(:)), 1);
for level = 1:max_levels
    idx = find(CurrentImg_nan == level);
    
    level_CurrentImg = zeros(length(idx), prod(delta*2+1));
    for i = 1:length(idx)
        
        curr_idx = idx(i);
        
        [X,Y,Z] = ind2sub(size(CurrentImg_nan),curr_idx);
        start_idx = [X-delta(1),Y-delta(2),Z-delta(3)];
        end_idx = [X+delta(1),Y+delta(2),Z+delta(3)];
        
        temp = CurrentImg_nan(start_idx(1):end_idx(1), start_idx(2):end_idx(2), start_idx(3):end_idx(3));
        temp = temp(:);
        
        level_CurrentImg(i,:) = temp;
        
    end
    I = level_CurrentImg(:,median(1:size(level_CurrentImg,2)));
    level_CurrentImg(:,median(1:size(level_CurrentImg,2))) = [];
    
    if size(I,2) ~= size(level_CurrentImg,2)
        n_rep = size(level_CurrentImg,2)/size(I,2);
        I = repmat(I, [1 n_rep]);
    end
    
    abs_diff = abs(I-level_CurrentImg);
    flag_Iverson = abs_diff <=  alpha;
    dependence = 1 + sum(flag_Iverson,2);
    
    [value, ~, ic] = unique(dependence, 'sorted');
    a_counts = accumarray(ic,1);
    
    try
        NGLDM(level, value) = NGLDM(level, value)+a_counts';
    catch
        NGLDM(level, value(end)) = 0;
        NGLDM(level, value) = NGLDM(level, value)+a_counts';
    end
end

end

function NGLDM  = IBSI_NGLDM2D_Mask(CurrentImg, CurrentMask, delta, alpha)

CurrentMask = double(CurrentMask);
CurrentMask(CurrentMask == 0) = NaN;
CurrentImg_nan = CurrentImg.*CurrentMask;
CurrentImg_nan = padarray(CurrentImg_nan,delta,nan,'both');

max_levels = max(CurrentImg(CurrentMask == 1));

NGLDM = zeros(max(CurrentImg(:)), 1);
for level = 1:max_levels
    idx = find(CurrentImg_nan == level);
    
    level_CurrentImg = zeros(length(idx), prod(delta*2+1));
    for i = 1:length(idx)
        
        curr_idx = idx(i);
        
        [X,Y] = ind2sub(size(CurrentImg_nan),curr_idx);
        start_idx = [X-delta(1),Y-delta(2)];
        end_idx = [X+delta(1),Y+delta(2)];
        
        temp = CurrentImg_nan(start_idx(1):end_idx(1), start_idx(2):end_idx(2));
        temp = temp(:);
        
        level_CurrentImg(i,:) = temp;
        
    end
    I = level_CurrentImg(:,median(1:size(level_CurrentImg,2)));
    level_CurrentImg(:,median(1:size(level_CurrentImg,2))) = [];
    
    if size(I,2) ~= size(level_CurrentImg,2)
        n_rep = size(level_CurrentImg,2)/size(I,2);
        I = repmat(I, [1 n_rep]);
    end
    
    abs_diff = abs(I-level_CurrentImg);
    flag_Iverson = abs_diff <=  alpha;
    dependence = 1 + sum(flag_Iverson,2);
    
    [value, ~, ic] = unique(dependence, 'sorted');
    a_counts = accumarray(ic,1);
    
    try
        NGLDM(level, value) = NGLDM(level, value)+a_counts';
    catch
        NGLDM(level, value(end)) = 0;
        NGLDM(level, value) = NGLDM(level, value)+a_counts';
    end
end

end