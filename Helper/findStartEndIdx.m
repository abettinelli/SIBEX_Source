function idx = findStartEndIdx(grid, ROI_ImageInfo)

temp_1 = find(single(grid.XGrid) <= single(ROI_ImageInfo.XStart)); % ROI start
temp_2 = find(single(grid.YGrid) <= single(ROI_ImageInfo.YStart));
temp_3 = find(single(grid.ZGrid) <= single(ROI_ImageInfo.ZStart));
temp_4 = find(single(grid.XGrid) >= single(ROI_ImageInfo.XStart+(ROI_ImageInfo.XDim-1)*ROI_ImageInfo.XPixDim));
temp_5 = find(single(grid.YGrid) >= single(ROI_ImageInfo.YStart+(ROI_ImageInfo.YDim-1)*ROI_ImageInfo.YPixDim));
temp_6 = find(single(grid.ZGrid) >= single(ROI_ImageInfo.ZStart+(ROI_ImageInfo.ZDim-1)*ROI_ImageInfo.ZPixDim));

%Correct if ROI is outside the new grid
if isempty(temp_1)
    temp_1 = 1;
end
if isempty(temp_2)
    temp_2 = 1;
end
if isempty(temp_3)
    temp_3 = 1;
end
if isempty(temp_4)
    temp_4 = length(grid.XGrid);
end
if isempty(temp_5)
    temp_5 = length(grid.YGrid);
end
if isempty(temp_6)
    temp_6 = length(grid.ZGrid);
end

% Set start end idx
idx.X_Start = temp_1(end);
idx.Y_Start = temp_2(end);
idx.Z_Start = temp_3(end);
idx.X_End = temp_4(1);
idx.Y_End = temp_5(1);
idx.Z_End = temp_6(1);