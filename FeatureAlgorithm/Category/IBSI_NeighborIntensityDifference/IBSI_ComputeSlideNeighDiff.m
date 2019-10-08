function [NGTDMstruct] = IBSI_ComputeSlideNeighDiff(CurrentImg, CurrentMask, delta, levels, AggregationMethod)


    
if  isequal(AggregationMethod, 3) || isequal(lower(AggregationMethod), '3d')
    
    % 3D CASE
    [NGTDMstruct.HistDiffSum, NGTDMstruct.ValidNumVoxel] = IBSI_NGTDM3D_Mask(CurrentImg, CurrentMask, levels, delta);
    NGTDMstruct.HistOccurPropability=NGTDMstruct.ValidNumVoxel./sum(NGTDMstruct.ValidNumVoxel);
    NGTDMstruct.ValidNumVoxel = sum(NGTDMstruct.ValidNumVoxel);
    NGTDMstruct.HistBinLoc=levels;
else
    
    % 2D CASE
    N = size(CurrentImg,3);
    for n = 1:N
        [NGTDMstruct(n).HistDiffSum, NGTDMstruct(n).ValidNumVoxel] = IBSI_NGTDM2D_Mask(CurrentImg(:,:,n), CurrentMask(:,:,n), levels, delta(1:2));
    end
    
    if  isequal(AggregationMethod, 2) || isequal(lower(AggregationMethod), '2dmrg')
        % Find max dimension
        max_dim_vv = [0 0];
        max_dim_hd = [0 0];
        for n = 1:N
            max_dim_vv = max(max_dim_vv, size(NGTDMstruct(n).ValidNumVoxel));
            max_dim_hd = max(max_dim_hd, size(NGTDMstruct(n).HistDiffSum));
        end
        % Sum over matrices
        ValidNumVoxel = zeros(max_dim_vv);
        HistDiffSum = zeros(max_dim_hd);
        for n = 1:N
            curr_ValidNumVoxel = NGTDMstruct(n).ValidNumVoxel;
            curr_HistDiffSum = NGTDMstruct(n).HistDiffSum;
            ValidNumVoxel(1:size(curr_ValidNumVoxel,1), 1:size(curr_ValidNumVoxel,2)) = ValidNumVoxel(1:size(curr_ValidNumVoxel,1), 1:size(curr_ValidNumVoxel,2)) + curr_ValidNumVoxel;
            HistDiffSum(1:size(curr_HistDiffSum,1), 1:size(curr_HistDiffSum,2)) = HistDiffSum(1:size(curr_HistDiffSum,1), 1:size(curr_HistDiffSum,2)) + curr_HistDiffSum;
        end
        
        NGTDMstruct = [];
        NGTDMstruct.HistDiffSum = HistDiffSum;
        NGTDMstruct.HistOccurPropability = ValidNumVoxel./sum(ValidNumVoxel);
        NGTDMstruct.ValidNumVoxel = sum(ValidNumVoxel);
        NGTDMstruct.HistBinLoc=levels;
        
    elseif isequal(AggregationMethod, 1) || isequal(lower(AggregationMethod), '2davg')
        for n = 1:N
            NGTDMstruct(n).HistOccurPropability = NGTDMstruct(n).ValidNumVoxel./sum(NGTDMstruct(n).ValidNumVoxel);
            NGTDMstruct(n).ValidNumVoxel = sum(NGTDMstruct(n).ValidNumVoxel);
            NGTDMstruct(n).HistBinLoc=levels;
        end
    end
end
end

function [s, n_vc] = IBSI_NGTDM3D_Mask(CurrentImg, CurrentMask, levels, delta)
CurrentMask = double(CurrentMask);
CurrentMask(CurrentMask == 0) = NaN;
CurrentImg_nan = CurrentImg.*CurrentMask;
CurrentImg_nan = padarray(CurrentImg_nan,delta,nan,'both');

s = zeros(length(levels), 1);
n_vc = zeros(length(levels), 1);
for level = 1:max(levels)
    idx = find(CurrentImg_nan == level);
    
    level_CurrentImg = zeros(length(idx), prod(2*delta + 1));
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
    mu = nanmean(level_CurrentImg,2);
    
    s(level,1) = nansum(abs(I-mu)); % exclude isolated voxels
    
    % Remove isolated voxels
    idx_nan = isnan(mu);
    level_CurrentImg(idx_nan,:) = [];
    
    n_vc(level,1) = size(level_CurrentImg,1);
end

end

function [s, n_vc] = IBSI_NGTDM2D_Mask(CurrentImg, CurrentMask, levels, delta)
CurrentMask = double(CurrentMask);
CurrentMask(CurrentMask == 0) = NaN;
CurrentImg_nan = CurrentImg.*CurrentMask;
CurrentImg_nan = padarray(CurrentImg_nan,delta,nan,'both');

s = zeros(length(levels), 1);
n_vc = zeros(length(levels), 1);
for level = 1:max(levels)
    idx = find(CurrentImg_nan == level);
    
    level_CurrentImg = zeros(length(idx), prod(2*delta + 1));
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
    mu = nanmean(level_CurrentImg,2);
    
    s(level,1) = nansum(abs(I-mu)); % exclude isolated voxels
    
    % Remove isolated voxels
    idx_nan = isnan(mu);
    level_CurrentImg(idx_nan,:) = [];
    
    n_vc(level,1) = size(level_CurrentImg,1);
end

end