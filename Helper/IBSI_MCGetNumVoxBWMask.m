function NumberOfVoxel = IBSI_MCGetNumVoxBWMask(mask)

%Crossing Number Alghoritm
mask = logical(padarray(mask,[1 1 1],0,'both')); % padding for edges overlapping to bounding box
[m,n,p] = size(mask);
[X,Y,Z] = meshgrid((1:n),(1:m),(1:p));
idx = find(mask == 1);

% ROI MASK - FACET AND VERTICES
[Faces, Vertices] = marchingCubes(X,Z,Y,mask,0.5);

NumberOfVoxel=0;
if ~isempty(Faces)
    for n = 1:length(Faces)
        a = Vertices(Faces(n,1),:);
        b = Vertices(Faces(n,2),:);
        c = Vertices(Faces(n,3),:);
        NumberOfVoxel = NumberOfVoxel + dot(a, cross(b, c))/6;
    end
    NumberOfVoxel = abs(NumberOfVoxel);
end

NumberOfVoxel = compute_Volume(Faces, Vertices);