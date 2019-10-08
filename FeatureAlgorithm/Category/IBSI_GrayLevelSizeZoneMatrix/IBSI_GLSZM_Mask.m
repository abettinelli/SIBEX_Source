function GLSZMstruct = IBSI_GLSZM_Mask(ROIImageData, ROIBWData, AggregationMethod)

if  isequal(AggregationMethod, 3) || isequal(lower(AggregationMethod), '3d') 
    
    % 3D CASE
    GLSZMstruct.GLSZM = IBSI_GLSZM3D_Mask(ROIImageData, ROIBWData);
    GLSZMstruct.Nv = nnz(ROIBWData);
else 
    
    % 2D CASE
    N = size(ROIImageData,3);
    for n = 1:N
        GLSZMstruct(n).GLSZM = IBSI_GLSZM2D_Mask(ROIImageData(:,:,n), ROIBWData(:,:,n));
        GLSZMstruct(n).Nv = nnz(ROIBWData(:,:,n));
    end
    
    if  isequal(AggregationMethod, 2) || isequal(lower(AggregationMethod), '2dmrg')
        % Find max dimension
        max_dim = [0 0];
        for n = 1:N
            max_dim = max(max_dim, size(GLSZMstruct(n).GLSZM));
        end
        % Sum over matrices
        GLSZM = zeros(max_dim);
        for n = 1:N
            curr_GLSZM = GLSZMstruct(n).GLSZM;
            GLSZM(1:size(curr_GLSZM,1), 1:size(curr_GLSZM,2)) = GLSZM(1:size(curr_GLSZM,1), 1:size(curr_GLSZM,2)) + curr_GLSZM;
        end
        GLSZMstruct = [];
        GLSZMstruct.GLSZM = GLSZM;
        GLSZMstruct.Nv = nnz(ROIBWData(:,:,n))*N;
    end
end
end

function GLSZM = IBSI_GLSZM3D_Mask(CurrentImg, CurrentMask)
    CurrentImg(CurrentMask == 0) = -1;
    GLSZM = zeros(max(CurrentImg(:)), 1);
    for i = 1:max(CurrentImg(:))
        
        curr_levels = CurrentImg == i;
        
        CC = bwconncomp(curr_levels, 26);
        
        cellnumel = cellfun(@numel,CC.PixelIdxList);
        [value, ~, ic] = unique(cellnumel, 'sorted');
        a_counts = accumarray(ic,1);
        
        try
            GLSZM(i, value) = GLSZM(i, value)+a_counts';
        catch
            GLSZM(i, value(end)) = 0;
            GLSZM(i, value) = GLSZM(i, value)+a_counts';
        end
    end
end

function GLSZM = IBSI_GLSZM2D_Mask(CurrentImg, CurrentMask)
    CurrentImg(CurrentMask == 0) = -1;
    GLSZM = zeros(max(CurrentImg(:)), 1);
    for i = 1:max(CurrentImg(:))
        
        curr_levels = CurrentImg == i;
        
        CC = bwconncomp(curr_levels, 8);
        
        cellnumel = cellfun(@numel,CC.PixelIdxList);
        [value, ~, ic] = unique(cellnumel, 'sorted');
        a_counts = accumarray(ic,1);
        
        try
            GLSZM(i, value) = GLSZM(i, value)+a_counts';
        catch
            GLSZM(i, value(end)) = 0;
            GLSZM(i, value) = GLSZM(i, value)+a_counts';
        end
    end
end