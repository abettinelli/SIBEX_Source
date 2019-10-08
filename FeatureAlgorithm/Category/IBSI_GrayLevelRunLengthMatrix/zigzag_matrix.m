function mat_shift = zigzag_matrix(mat, direction)

if isequal(direction, '0/90')
    mat_shift = mat;
    
elseif isequal(direction, '90/90')
    mat_shift = permute(mat, [2 1 3]);
    
elseif isequal(direction, '0/0')
    mat_shift = permute(mat, [1 3 2]);
    
elseif isequal(direction, '45/90')
    [X, Y, Z] = size(mat);
    
    mat_shift = 0*ones(X, Y+X-1, Z);
    for x = 1:X
        mat_shift(x,x:(x+Y-1),:) = mat(x,:,:);
    end
    mat_shift = permute(mat_shift, [2 1 3]);
elseif isequal(direction, '135/90')
    [X, Y, Z] = size(mat);
    
    mat_shift = 0*ones(X, Y+X-1, Z);
    for x = 1:X
        mat_shift(end-x+1,x:(x+Y-1),:) = mat(end-x+1,:,:);
    end
    mat_shift = permute(mat_shift, [2 1 3]);
elseif isequal(direction, '90/45')
    img_align = permute(mat, [1 3 2]);
    [X, Y, Z] = size(img_align);
    
    mat_shift = 0*ones(X, Y+X-1, Z);
    for x = 1:X
        mat_shift(x,x:(x+Y-1),:) = img_align(x,:,:);
    end
    mat_shift = permute(mat_shift, [2 1 3]);
elseif isequal(direction, '90/135')
    img_align = permute(mat, [1 3 2]);
    [X, Y, Z] = size(img_align);
    
    mat_shift = 0*ones(X, Y+X-1, Z);
    for x = 1:X
        mat_shift(end-x+1,x:(x+Y-1),:) = img_align(end-x+1,:,:);
    end
    mat_shift = permute(mat_shift, [2 1 3]);
    
elseif isequal(direction, '0/45')
    img_align = permute(mat, [3 2 1]);
    [X, Y, Z] = size(img_align);
    
    mat_shift = 0*ones(X, Y+X-1, Z);
    for x = 1:X
        mat_shift(end-x+1,x:(x+Y-1),:) = img_align(end-x+1,:,:);
    end
    mat_shift = permute(mat_shift, [2 1 3]);
    
elseif isequal(direction, '0/135')
    img_align = permute(mat, [3 2 1]);
    [X, Y, Z] = size(img_align);
    
    mat_shift = 0*ones(X, Y+X-1, Z);
    for x = 1:X
        mat_shift(x,x:(x+Y-1),:) = img_align(x,:,:);
    end
    mat_shift = permute(mat_shift, [2 1 3]);
    
elseif isequal(direction, '135/135')
    
    [X, Y, Z] = size(mat);
    
    mat_shift = 0*ones(X+Z-1, Y+Z-1, Z);
    for z = 1:Z
        mat_shift(z:(z+X-1),z:(z+Y-1),z) = mat(:,:,z);
    end
    mat_shift = permute(mat_shift, [1 3 2]);
    
elseif isequal(direction, '45/135')
    
    [X, Y, Z] = size(mat);
    
    mat_shift = 0*ones(X+Z-1, Y+Z-1, Z);
    for z = 1:Z
        mat_shift(z:(z+X-1),end-(z:(z+Y-1))+1,z) = mat(:,end:-1:1,z);
    end
    mat_shift = permute(mat_shift, [1 3 2]);
    
elseif isequal(direction, '45/45')
    
    [X, Y, Z] = size(mat);
    
    mat_shift = 0*ones(X+Z-1, Y+Z-1, Z);
    for z = 1:Z
        mat_shift(end-(z:(z+X-1))+1,z:(z+Y-1),z) = mat(end:-1:1,:,z);
    end
    mat_shift = permute(mat_shift, [1 3 2]);
    
elseif isequal(direction, '135/45')
    
    [X, Y, Z] = size(mat);
    
    mat_shift = 0*ones(X+Z-1, Y+Z-1, Z);
    for z = 1:Z
        mat_shift(end-(z:(z+X-1))+1,end-(z:(z+Y-1))+1,z) = mat(end:-1:1,end:-1:1,z);
    end
    mat_shift = permute(mat_shift, [1 3 2]);
    
end