function Area = compute_Area(Faces, Verteces)

Area=0;
if ~isempty(Faces)
    for n = 1:length(Faces)
        a = Verteces(Faces(n,1),:);
        b = Verteces(Faces(n,2),:);
        c = Verteces(Faces(n,3),:);
        Area = Area + norm(cross(b-a, c-a))/2;
    end
end