function mat_shift = zigzag_matrix(mat, direction)

% img(:,:,1) = [
%     1 0 2; 
%     0 0 0; 
%     4 0 3];
% img(:,:,2) = [
%     0 0 0; 
%     0 3 0; 
%     0 0 0];
% img(:,:,3) = [
%     3 0 4; 
%     0 0 0; 
%     2 0 1];

if isequal(direction, '0/90')
    mat_shift = mat;
    
elseif isequal(direction, '90/90')
    mat_shift = permute(mat, [2 1 3]);
    % img_shift = flip(img_shift, 2);
    
elseif isequal(direction, '0/0')
    mat_shift = permute(mat, [1 3 2]); %img_shift = permute(img, [1 3 2]);
    % img_shift = flip(img_shift, 2);
    
elseif isequal(direction, '45/90')
    [X, Y, Z] = size(mat);
    
    mat_shift = 0*ones(X, Y+X-1, Z);
    for x = 1:X
        for z = 1:Z
            mat_shift(x,x:(x+Y-1),z) = mat(x,:,z);
        end
    end
    mat_shift = permute(mat_shift, [2 1 3]);
elseif isequal(direction, '135/90')
    [X, Y, Z] = size(mat);
    
    mat_shift = 0*ones(X, Y+X-1, Z);
    for x = 1:X
        for z = 1:Z
            mat_shift(end-x+1,x:(x+Y-1),z) = mat(end-x+1,:,z);
        end
    end
    mat_shift = permute(mat_shift, [2 1 3]);
elseif isequal(direction, '90/45')  
    img_align = permute(mat, [1 3 2]);
    % img_align = flip(img_align, 2);
    [X, Y, Z] = size(img_align);
    
    mat_shift = 0*ones(X, Y+X-1, Z);
    for x = 1:X
        for z = 1:Z
            mat_shift(x,x:(x+Y-1),z) = img_align(x,:,z);
        end
    end
    mat_shift = permute(mat_shift, [2 1 3]);
elseif isequal(direction, '90/135')  
    img_align = permute(mat, [1 3 2]);
    % img_align = flip(img_align, 2);
    [X, Y, Z] = size(img_align);
    
    mat_shift = 0*ones(X, Y+X-1, Z);
    for x = 1:X
        for z = 1:Z
            mat_shift(end-x+1,x:(x+Y-1),z) = img_align(end-x+1,:,z);
        end
    end
    mat_shift = permute(mat_shift, [2 1 3]);
    
elseif isequal(direction, '0/45')  
    img_align = permute(mat, [3 2 1]);
    % img_align = flip(img_align, 1);
    [X, Y, Z] = size(img_align);
    
    mat_shift = 0*ones(X, Y+X-1, Z);
    for x = 1:X
        for z = 1:Z
            mat_shift(end-x+1,x:(x+Y-1),z) = img_align(end-x+1,:,z);
        end
    end
    mat_shift = permute(mat_shift, [2 1 3]);
    
elseif isequal(direction, '0/135')  
    img_align = permute(mat, [3 2 1]);
    % img_align = flip(img_align, 1);
    [X, Y, Z] = size(img_align);
    
    mat_shift = 0*ones(X, Y+X-1, Z);
    for x = 1:X
        for z = 1:Z
            mat_shift(x,x:(x+Y-1),z) = img_align(x,:,z);
        end
    end
    mat_shift = permute(mat_shift, [2 1 3]);
elseif isequal(direction, '135/135') %135 135

    [X, Y, Z] = size(mat);
    
    mat_shift = 0*ones(X+Y-1, Y+X-1, Z);
        for z = 1:Z
            mat_shift(z:(z+X-1),z:(z+Y-1),z) = mat(:,:,z);
        end
    mat_shift = permute(mat_shift, [1 3 2]);
    
elseif isequal(direction, '45/135')

    [X, Y, Z] = size(mat);
    
    mat_shift = 0*ones(X+Y-1, Y+X-1, Z);
        for z = 1:Z
            mat_shift(z:(z+X-1),end-(z:(z+Y-1))+1,z) = mat(:,end:-1:1,z);
        end
    mat_shift = permute(mat_shift, [1 3 2]);
elseif isequal(direction, '45/45')

    [X, Y, Z] = size(mat);
    
    mat_shift = 0*ones(X+Y-1, Y+X-1, Z);
        for z = 1:Z
            mat_shift(end-(z:(z+X-1))+1,z:(z+Y-1),z) = mat(end:-1:1,:,z);
        end
    mat_shift = permute(mat_shift, [1 3 2]);
elseif isequal(direction, '135/45')

    [X, Y, Z] = size(mat);
    
    mat_shift = 0*ones(X+Y-1, Y+X-1, Z);
        for z = 1:Z
            mat_shift(end-(z:(z+X-1))+1,end-(z:(z+Y-1))+1,z) = mat(end:-1:1,end:-1:1,z);
        end
    mat_shift = permute(mat_shift, [1 3 2]);
end