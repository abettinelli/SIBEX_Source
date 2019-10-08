function BWSlice=MKroipoly(TempImage, x, y)

% interpolate the entire border between verticies
[x, y] = MKfillPolyOutline(x, y, 1, 1);

% round interpolated values
x = round(x);
y = round(y);

BWSlice = poly2mask(double(x), double(y), size(TempImage, 2), size(TempImage, 1));

%Remove outside
TempIndex=find(x < 1);
if ~isempty(TempIndex)
    x(TempIndex)=[];
    y(TempIndex)=[];
end

TempIndex=find(x > size(TempImage, 2));
if ~isempty(TempIndex)
    x(TempIndex)=[];
    y(TempIndex)=[];
end

TempIndex=find(y < 1);
if ~isempty(TempIndex)
    x(TempIndex)=[];
    y(TempIndex)=[];
end

TempIndex=find(y > size(TempImage, 1));
if ~isempty(TempIndex)
    x(TempIndex)=[];
    y(TempIndex)=[];
end

%Add polygon points
TempIndex=sub2ind(size(TempImage), y, x);
BWSlice(TempIndex) = logical(1);