function ROIImageInfoNew = IBSI_Interpolation3D_gridInterp(ROIImageInfo, ROIImageInfoNew, Method, Precision, Grid_precision)

ClassName=class(ROIImageInfo.MaskData);
fhandle=str2func(ClassName);
fhandle_grid=str2func(Grid_precision);
fhandle_precision = str2func(Precision);

% Old Grid
x = ROIImageInfo.XStart+(0:(ROIImageInfo.XDim-1))*ROIImageInfo.XPixDim;
y = ROIImageInfo.YStart+(0:(ROIImageInfo.YDim-1))*ROIImageInfo.YPixDim;
z = ROIImageInfo.ZStart+(0:(ROIImageInfo.ZDim-1))*ROIImageInfo.ZPixDim;

% New Grid
xq = (0:(ROIImageInfoNew.XDim-1))*ROIImageInfoNew.XPixDim+ROIImageInfoNew.XStart;
yq = (0:(ROIImageInfoNew.YDim-1))*ROIImageInfoNew.YPixDim+ROIImageInfoNew.YStart;
zq = (0:(ROIImageInfoNew.ZDim-1))*ROIImageInfoNew.ZPixDim+ROIImageInfoNew.ZStart;

% ND-GRIDS
[X,Y,Z] = ndgrid(fhandle_grid(y),fhandle_grid(x),fhandle_grid(z));
[Xq,Yq,Zq] = ndgrid(fhandle_grid(yq),fhandle_grid(xq),fhandle_grid(zq));

% INTERPOLATION
if ROIImageInfo.ZDim > 1
    F = griddedInterpolant(X,Y,Z,fhandle_precision(flip(ROIImageInfo.MaskData,1)),Method,Method); % Flip first dimension
    MaskData = F(Xq, Yq, Zq);
else % if there is only one slice
    % ND-GRIDS
    [X,Y] = ndgrid(y,x);
    [Xq,Yq] = ndgrid(yq,xq);
    
    F = griddedInterpolant(X,Y,fhandle_precision(flip(ROIImageInfo.MaskData,1)),Method,Method);
    MaskData = F(Xq, Yq);
end
MaskData(isnan(MaskData)) = 0;

% Convert Data type back
ROIImageInfoNew.MaskData=fhandle(flip(MaskData,1)); % Re-Flip first dimension