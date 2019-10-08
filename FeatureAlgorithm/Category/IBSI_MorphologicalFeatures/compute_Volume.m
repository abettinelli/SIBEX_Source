function Volume = compute_Volume(Faces, Verteces)

Volume=0;
if ~isempty(Faces)
    for n = 1:length(Faces)
        a = Verteces(Faces(n,1),:);
        b = Verteces(Faces(n,2),:);
        c = Verteces(Faces(n,3),:);
        Volume = Volume + dot(a, cross(b, c))/6;
    end
    Volume = abs(Volume);
end